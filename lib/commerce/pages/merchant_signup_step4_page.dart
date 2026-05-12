import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:file_picker/file_picker.dart';
import 'package:peeco/core/core.dart';
import 'package:peeco/commerce/commerce.dart';
import 'package:peeco/client/client.dart';
import 'package:peeco/services/auth_service.dart';
import 'package:peeco/models/auth_models.dart';
import 'package:peeco/core/pages/verification_code_page.dart';
import 'package:path/path.dart' as p;

class MerchantSignupStep4Page extends StatefulWidget {
  final String prenom;
  final String nom;
  final String email;
  final String phone;
  final String password;
  final String nomCommerce;
  final String typeCommerce;
  final String ouverture;
  final String fermeture;
  final String adresse;
  final String wilaya;
  final String commune;
  final String codePostal;
  final String gps;

  const MerchantSignupStep4Page({
    super.key,
    required this.prenom,
    required this.nom,
    required this.email,
    required this.phone,
    required this.password,
    required this.nomCommerce,
    required this.typeCommerce,
    required this.ouverture,
    required this.fermeture,
    required this.adresse,
    required this.wilaya,
    required this.commune,
    required this.codePostal,
    required this.gps,
  });

  @override
  State<MerchantSignupStep4Page> createState() =>
      _MerchantSignupStep4PageState();
}

class _MerchantSignupStep4PageState extends State<MerchantSignupStep4Page> {
  static final _errorPadding = EdgeInsets.only(left: 14, top: 5, bottom: 2);

  final _rcController = TextEditingController();
  final _rcFocus = FocusNode();

  bool _acceptedTerms = false;
  bool _isSubmitting = false;

  File? _cinFile;
  File? _extraitRcFile;

  String? _rcError;
  String? _cinError;
  String? _extraitRcError;
  String? _termsError;

  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _rcFocus.addListener(() {
      if (!_rcFocus.hasFocus) {
        setState(() => _rcError = InputValidator.numeroRC(_rcController.text));
      }
    });
  }

  @override
  void dispose() {
    _rcController.dispose();
    _rcFocus.dispose();
    super.dispose();
  }

  bool _isPdf(File file) => p.extension(file.path).toLowerCase() == '.pdf';

  void _showSuccessBanner(String message, String subtitle) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (ctx) => _SuccessBanner(
        message: message,
        subtitle: subtitle,
        onDone: () => entry.remove(),
      ),
    );
    overlay.insert(entry);
  }

  void _showErrorBanner(String message, String subtitle) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (ctx) => _ErrorBanner(
        message: message,
        subtitle: subtitle,
        onDone: () => entry.remove(),
      ),
    );
    overlay.insert(entry);
  }

  Future<void> _pickFile(bool isCin) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
    );
    if (result != null && result.files.single.path != null) {
      setState(() {
        final file = File(result.files.single.path!);
        if (isCin) {
          _cinFile = file;
          _cinError = null;
        } else {
          _extraitRcFile = file;
          _extraitRcError = null;
        }
      });
    }
  }

  void _handleSubmit() {
    _validateAndShowConfirmation();
  }

  void _validateAndShowConfirmation() {
    final rcError = InputValidator.numeroRC(_rcController.text);
    final cinError = _cinFile == null
        ? 'Veuillez joindre votre CIN/Passeport'
        : null;
    final extraitRcError = _extraitRcFile == null
        ? 'Veuillez joindre l\'extrait RC'
        : null;
    final termsError = !_acceptedTerms
        ? 'Veuillez accepter les conditions'
        : null;

    setState(() {
      _rcError = rcError;
      _cinError = cinError;
      _extraitRcError = extraitRcError;
      _termsError = termsError;
    });

    if (rcError != null ||
        cinError != null ||
        extraitRcError != null ||
        termsError != null) {
      return;
    }

    _showConfirmationSheet(widget.email);
  }

  Future<void> _submitMerchantRegistration() async {
    setState(() => _isSubmitting = true);

    try {
      final fullAddress =
          '${widget.adresse}, ${widget.commune}, ${widget.wilaya}';

      final request = MerchantRegisterRequest(
        email: widget.email,
        password: widget.password,
        fullName: '${widget.prenom} ${widget.nom}',
        telephone: widget.phone,
        nomCommerce: widget.nomCommerce,
        numeroRc: _rcController.text.trim(),
        adresse: fullAddress,
        typeCommerce: widget.typeCommerce,
        description: '',
        heureOuverture: widget.ouverture,
        heureFermeture: widget.fermeture,
      );

      print('  Envoi inscription commerçant au backend (multipart)');
      print('Email: ${request.email}');
      print('FullName: ${request.fullName}');

      final result = await _authService.registerMerchantWithFiles(
        request: request,
        cinPasseport: _cinFile!,
        extraitRc: _extraitRcFile!,
        brochure: null,
      );

      setState(() => _isSubmitting = false);

      if (mounted && result != null) {
        _navigateToVerification(widget.email);
      }
    } catch (e) {
      setState(() => _isSubmitting = false);
      _showErrorBanner('Erreur d\'inscription', e.toString());
    }
  }

  void _showConfirmationSheet(String email) {
    final displayEmail = _maskEmail(email);

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFB5C99A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Icon(
              Icons.mark_email_unread_outlined,
              size: 48,
              color: Color.fromARGB(255, 248, 176, 104),
            ),
            const SizedBox(height: 16),
            const Text(
              'Le code sera envoyé à',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              displayEmail,
              style: const TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 45,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _submitMerchantRegistration();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 248, 176, 104),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Confirmer',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  String _maskEmail(String email) {
    if (!email.contains('@')) return email;
    final parts = email.split('@');
    final local = parts[0];
    final domain = parts[1];
    final maskedLocal = local.length > 2
        ? '${local.substring(0, 2)}${'*' * (local.length - 2)}'
        : '*' * local.length;
    return '$maskedLocal@$domain';
  }

  Future<void> _navigateToVerification(String email) async {
    final isVerified = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VerificationCodePage(
          identifier: email,
          mode: VerificationMode.emailVerification,
        ),
      ),
    );

    if (mounted && isVerified == true) {
      _showSuccessBanner(
        'Compte vérifié !',
        'Vous pouvez maintenant vous connecter.',
      );

      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const LoginPage()),
            (route) => false,
          );
        }
      });
    }
  }

  void _go(Widget page) =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => page));

  Widget _fieldError(String message) {
    return buildFieldError(message, padding: _errorPadding);
  }

  Widget _uploadBox({
    required File? file,
    required VoidCallback onTap,
    required double sw,
    required double sh,
  }) {
    Widget content;

    if (file == null) {
      content = Container(
        height: sh * 0.15,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: const Color.fromARGB(10, 0, 0, 0),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.upload_file_outlined,
                size: sw * 0.08,
                color: Colors.black38,
              ),
              SizedBox(height: sh * 0.01),
              Text(
                'Appuyer pour joindre un fichier',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: (sw * 0.032).clamp(11.0, 14.0),
                  color: Colors.black45,
                ),
              ),
              SizedBox(height: sh * 0.005),
              Text(
                'JPG, PNG ou PDF',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: (sw * 0.026).clamp(10.0, 12.0),
                  color: Colors.black38,
                ),
              ),
            ],
          ),
        ),
      );
    } else if (_isPdf(file)) {
      final fileName = p.basename(file.path);
      content = Container(
        height: sh * 0.15,
        decoration: BoxDecoration(
          border: Border.all(
            color: const Color.fromARGB(255, 248, 176, 104),
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(12),
          color: const Color.fromARGB(20, 248, 176, 104),
        ),
        child: Row(
          children: [
            SizedBox(width: sw * 0.04),
            Container(
              width: sw * 0.12,
              height: sh * 0.085,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 230, 163, 97),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.picture_as_pdf,
                    color: Colors.white,
                    size: sw * 0.065,
                  ),
                  SizedBox(height: sh * 0.005),
                  Text(
                    'PDF',
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: (sw * 0.025).clamp(9.0, 11.0),
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: sw * 0.035),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fileName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: (sw * 0.032).clamp(11.0, 14.0),
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: sh * 0.008),
                  Text(
                    'Fichier PDF joint ✓',
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: (sw * 0.026).clamp(10.0, 12.0),
                      color: const Color.fromARGB(255, 100, 160, 100),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(right: sw * 0.03),
              child: const Icon(
                Icons.edit_outlined,
                size: 18,
                color: Colors.black38,
              ),
            ),
          ],
        ),
      );
    } else {
      content = ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            Image.file(
              file,
              height: sh * 0.15,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.edit_outlined,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return GestureDetector(onTap: onTap, child: content);
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;

    return commercePageScaffold(
      context: context,
      step: 4,
      isLoading: _isSubmitting,
      children: [
        sectionTitle('Documents du gérant', sw: sw, sh: sh),

        Padding(
          padding: EdgeInsets.only(left: 14, bottom: sh * 0.01),
          child: Text(
            'CIN ou Passeport',
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: (sw * 0.035).clamp(12.0, 15.0),
              color: Colors.black,
            ),
          ),
        ),
        _uploadBox(
          file: _cinFile,
          onTap: () => _pickFile(true),
          sw: sw,
          sh: sh,
        ),
        if (_cinError != null) _fieldError(_cinError!),
        SizedBox(height: sh * 0.025),

        sectionTitle('Documents du commerce', sw: sw, sh: sh),

        Padding(
          padding: EdgeInsets.only(left: 14, bottom: sh * 0.01),
          child: Text(
            'Numéro du Registre du Commerce (RC)',
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: (sw * 0.035).clamp(12.0, 15.0),
              color: Colors.black,
            ),
          ),
        ),
        Container(
          height: (sh * 0.052).clamp(40.0, 50.0),
          decoration: inputBoxDecoration(),
          child: TextField(
            controller: _rcController,
            focusNode: _rcFocus,
            keyboardType: TextInputType.text,
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: (sw * 0.035).clamp(12.0, 15.0),
              color: Colors.black,
            ),
            onChanged: (_) {
              if (_rcError != null) setState(() => _rcError = null);
            },
            decoration: InputDecoration(
              isDense: true,
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                vertical: 11,
                horizontal: sw * 0.04,
              ),
              hintText: 'ex: 123456789',
              hintStyle: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: (sw * 0.033).clamp(11.0, 14.0),
                color: const Color.fromARGB(120, 0, 0, 0),
              ),
              prefixIcon: Padding(
                padding: EdgeInsets.only(left: sw * 0.035, right: sw * 0.02),
                child: const Icon(
                  Icons.receipt_long_outlined,
                  color: Colors.black45,
                  size: 20,
                ),
              ),
              prefixIconConstraints: const BoxConstraints(
                minWidth: 0,
                minHeight: 0,
              ),
            ),
          ),
        ),
        if (_rcError != null) _fieldError(_rcError!),
        SizedBox(height: sh * 0.012),

        Padding(
          padding: EdgeInsets.only(left: 14, bottom: sh * 0.01),
          child: Text(
            'Extrait RC',
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: (sw * 0.035).clamp(12.0, 15.0),
              color: Colors.black,
            ),
          ),
        ),
        _uploadBox(
          file: _extraitRcFile,
          onTap: () => _pickFile(false),
          sw: sw,
          sh: sh,
        ),
        if (_extraitRcError != null) _fieldError(_extraitRcError!),
        SizedBox(height: sh * 0.025),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: Checkbox(
                value: _acceptedTerms,
                onChanged: (val) => setState(() {
                  _acceptedTerms = val ?? false;
                  if (_acceptedTerms) _termsError = null;
                }),
                activeColor: const Color.fromARGB(255, 248, 176, 104),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                side: BorderSide(
                  color: _termsError != null ? Colors.red : Colors.black54,
                ),
              ),
            ),
            SizedBox(width: sw * 0.025),
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontFamily: 'NotoLoopedThai',
                    fontSize: (sw * 0.028).clamp(10.0, 12.0),
                    color: Colors.black87,
                  ),
                  children: [
                    const TextSpan(text: 'J\'accepte les '),
                    TextSpan(
                      text: 'conditions d\'utilisation',
                      style: const TextStyle(
                        color: Color.fromARGB(255, 230, 163, 97),
                        decoration: TextDecoration.underline,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () => _go(const ConditionsPage()),
                    ),
                    const TextSpan(text: ' de Peeco, la '),
                    TextSpan(
                      text: 'politique de confidentialité',
                      style: const TextStyle(
                        color: Color.fromARGB(255, 230, 163, 97),
                        decoration: TextDecoration.underline,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () =>
                            _go(const PolitiqueConfidentialitePage()),
                    ),
                    const TextSpan(text: ' et le '),
                    TextSpan(
                      text: 'contrat de licence utilisateur',
                      style: const TextStyle(
                        color: Color.fromARGB(255, 230, 163, 97),
                        decoration: TextDecoration.underline,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () => _go(const ContratLicencePage()),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        if (_termsError != null)
          Padding(
            padding: EdgeInsets.only(top: sh * 0.006),
            child: _fieldError(_termsError!),
          ),
        SizedBox(height: sh * 0.03),

        actionButton(
          label: 'Créer un compte',
          onPressed: _isSubmitting ? null : _handleSubmit,
          sw: sw,
          sh: sh,
          isLoading: _isSubmitting,
        ),
      ],
    );
  }
}

class _SuccessBanner extends StatefulWidget {
  final String message;
  final String subtitle;
  final VoidCallback onDone;

  const _SuccessBanner({
    required this.message,
    required this.subtitle,
    required this.onDone,
  });

  @override
  State<_SuccessBanner> createState() => _SuccessBannerState();
}

class _SuccessBannerState extends State<_SuccessBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<Offset> _slide;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _slide = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();
    Future.delayed(const Duration(milliseconds: 2400), () {
      if (mounted) _ctrl.reverse().then((_) => widget.onDone());
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final navbarHeight = kBottomNavigationBarHeight;
    final finalBottom = navbarHeight + 20;

    return Positioned(
      bottom: finalBottom,
      left: 20,
      right: 20,
      child: SlideTransition(
        position: _slide,
        child: FadeTransition(
          opacity: _fade,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFCCD5AE),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.10),
                    blurRadius: 18,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      size: 18,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.message,
                          style: const TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          widget.subtitle,
                          style: const TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 11,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatefulWidget {
  final String message;
  final String subtitle;
  final VoidCallback onDone;

  const _ErrorBanner({
    required this.message,
    required this.subtitle,
    required this.onDone,
  });

  @override
  State<_ErrorBanner> createState() => _ErrorBannerState();
}

class _ErrorBannerState extends State<_ErrorBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<Offset> _slide;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _slide = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();
    Future.delayed(const Duration(milliseconds: 2400), () {
      if (mounted) _ctrl.reverse().then((_) => widget.onDone());
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final navbarHeight = kBottomNavigationBarHeight;
    final finalBottom = navbarHeight + 20;

    return Positioned(
      bottom: finalBottom,
      left: 20,
      right: 20,
      child: SlideTransition(
        position: _slide,
        child: FadeTransition(
          opacity: _fade,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFF8B068).withOpacity(0.95),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.10),
                    blurRadius: 18,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.message,
                          style: const TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          widget.subtitle,
                          style: const TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 11,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
