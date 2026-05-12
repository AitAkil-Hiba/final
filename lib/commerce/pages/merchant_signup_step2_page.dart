import 'package:flutter/material.dart';
import 'package:peeco/core/core.dart';
import 'package:peeco/commerce/commerce.dart';

const List<String> _typesCommerce = [
  'Épicerie',
  'Boulangerie',
  'Boucherie',
  'Superette',
  'Restaurant',
  'Café',
  'Autre',
];

class MerchantSignupStep2Page extends StatefulWidget {
  final String prenom;
  final String nom;
  final String email;
  final String phone;
  final String password;

  const MerchantSignupStep2Page({
    super.key,
    required this.prenom,
    required this.nom,
    required this.email,
    required this.phone,
    required this.password,
  });

  @override
  State<MerchantSignupStep2Page> createState() => _MerchantSignupStep2PageState();
}

class _MerchantSignupStep2PageState extends State<MerchantSignupStep2Page> {
  static final _errorPadding = EdgeInsets.only(left: 14, top: 5, bottom: 2);

  final _nomCommerceController = TextEditingController();
  final _nomCommerceFocus = FocusNode();

  String? _nomCommerceError;
  String? _typeError;
  String? _ouvertureError;
  String? _fermetureError;

  String? _selectedType;
  TimeOfDay? _ouvertureTime;
  TimeOfDay? _fermetureTime;

  @override
  void initState() {
    super.initState();

    _nomCommerceFocus.addListener(() {
      if (!_nomCommerceFocus.hasFocus) {
        setState(
          () => _nomCommerceError = InputValidator.nomCommerce(
            _nomCommerceController.text,
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _nomCommerceController.dispose();
    _nomCommerceFocus.dispose();
    super.dispose();
  }

  Future<void> _pickTime(bool isOuverture) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isOuverture
          ? (_ouvertureTime ?? const TimeOfDay(hour: 8, minute: 0))
          : (_fermetureTime ?? const TimeOfDay(hour: 20, minute: 0)),
      initialEntryMode: TimePickerEntryMode.dialOnly,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: const TimePickerThemeData(
              backgroundColor: Color(0xFFB5C99A),
              hourMinuteColor: Color.fromARGB(255, 210, 213, 178),
              hourMinuteTextColor: Colors.black,
              dialBackgroundColor: Color.fromARGB(255, 210, 213, 178),
              dialHandColor: Color.fromARGB(255, 248, 176, 104),
              dialTextColor: Colors.black,
              entryModeIconColor: Colors.black,
            ),
            colorScheme: const ColorScheme.light(
              primary: Color.fromARGB(255, 248, 176, 104),
              onPrimary: Colors.black,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: Colors.black),
            ),
          ),
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
            child: child!,
          ),
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isOuverture) {
          _ouvertureTime = picked;
          _ouvertureError = null;
        } else {
          _fermetureTime = picked;
          _fermetureError = null;
        }
      });
    }
  }

  String _formatTime(TimeOfDay? t) {
    if (t == null) return '--:--';
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  void _handleNext() {
    setState(() {
      _nomCommerceError = InputValidator.nomCommerce(
        _nomCommerceController.text,
      );
      _typeError = _selectedType == null
          ? 'Veuillez choisir un type de commerce'
          : null;
      _ouvertureError = _ouvertureTime == null
          ? 'Veuillez choisir l\'heure d\'ouverture'
          : null;
      _fermetureError = _fermetureTime == null
          ? 'Veuillez choisir l\'heure de fermeture'
          : null;
    });

    if (_nomCommerceError != null ||
        _typeError != null ||
        _ouvertureError != null ||
        _fermetureError != null)
      return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MerchantSignupStep3Page(
          prenom: widget.prenom,
          nom: widget.nom,
          email: widget.email,
          phone: widget.phone,
          password: widget.password,
          nomCommerce: _nomCommerceController.text.trim(),
          typeCommerce: _selectedType ?? '',
          ouverture: _formatTime(_ouvertureTime),
          fermeture: _formatTime(_fermetureTime),
        ),
      ),
    );
  }

  Widget _fieldError(String message) {
    return buildFieldError(message, padding: _errorPadding);
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;

    return commercePageScaffold(
      context: context,
      step: 2,
      children: [
        sectionTitle('Informations du commerce', sw: sw, sh: sh),

        CustomInputField(
          label: 'Nom / enseigne commerciale',
          icon: Icons.store_outlined,
          controller: _nomCommerceController,
          focusNode: _nomCommerceFocus,
          onChanged: (_) {
            if (_nomCommerceError != null)
              setState(() => _nomCommerceError = null);
          },
        ),
        if (_nomCommerceError != null) _fieldError(_nomCommerceError!),
        SizedBox(height: sh * 0.012),

        Padding(
          padding: EdgeInsets.only(left: 14, bottom: sh * 0.01),
          child: Text(
            'Type de commerce',
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize:(sw * 0.035).clamp(12.0, 15.0),
              color: Colors.black,
            ),
          ),
        ),
        AppDropdown<String>(
          value: _selectedType,
          hint: 'Choisir...',
          items: _typesCommerce,
          itemLabel: (t) => t,
          onChanged: (val) => setState(() {
            _selectedType = val;
            _typeError = null;
          }),
        ),
        if (_typeError != null) _fieldError(_typeError!),
        SizedBox(height: sh * 0.012),

        Padding(
          padding: EdgeInsets.only(left: 14, bottom: sh * 0.01),
          child: Text(
            'Horaires d\'ouverture',
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize:(sw * 0.035).clamp(12.0, 15.0),
              color: Colors.black,
            ),
          ),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _timeButton(
                    'Ouverture',
                    _ouvertureTime,
                    () => _pickTime(true),
                    sw,
                    sh,
                  ),
                  if (_ouvertureError != null) _fieldError(_ouvertureError!),
                ],
              ),
            ),
            SizedBox(width: sw * 0.025),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _timeButton(
                    'Fermeture',
                    _fermetureTime,
                    () => _pickTime(false),
                    sw,
                    sh,
                  ),
                  if (_fermetureError != null) _fieldError(_fermetureError!),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: sh * 0.025),

        actionButton(label: 'Suivant', onPressed: _handleNext, sw: sw, sh: sh),
      ],
    );
  }

  Widget _timeButton(String label, TimeOfDay? time, VoidCallback onTap, double sw, double sh) {
    final display = time == null
        ? label
        : '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: (sh * 0.052).clamp(40.0, 50.0),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 222, 225, 190),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.55),
              blurRadius: 0,
              spreadRadius: 1,
              offset: const Offset(1, 1),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 4,
              spreadRadius: 0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(horizontal: sw * 0.04),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              display,
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: (sw * 0.035).clamp(12.0, 15.0),
                color: time == null
                    ? const Color.fromARGB(120, 0, 0, 0)
                    : Colors.black87,
              ),
            ),
            const Icon(Icons.access_time, color: Colors.black45, size: 18),
          ],
        ),
      ),
    );
  }
}