import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:peeco/core/core.dart';
import 'package:peeco/commerce/commerce.dart';

class _CommuneEntry {
  final String name;
  final String codePostal;
  const _CommuneEntry({required this.name, required this.codePostal});
}

class _WilayaEntry {
  final String code;
  final String name;
  const _WilayaEntry({required this.code, required this.name});
}

class MerchantSignupStep3Page extends StatefulWidget {
  final String prenom;
  final String nom;
  final String email;
  final String phone;
  final String password;
  final String nomCommerce;
  final String typeCommerce;
  final String ouverture;
  final String fermeture;

  const MerchantSignupStep3Page({
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
  });

  @override
  State<MerchantSignupStep3Page> createState() => _MerchantSignupStep3PageState();
}

class _MerchantSignupStep3PageState extends State<MerchantSignupStep3Page> {
  static final _errorPadding = EdgeInsets.only(left: 14, top: 5, bottom: 2);

  final _adresseController = TextEditingController();
  final _adresseFocus = FocusNode();

  List<_WilayaEntry> _wilayas = [];
  Map<String, List<_CommuneEntry>> _communesMap = {};

  _WilayaEntry? _selectedWilaya;
  _CommuneEntry? _selectedCommune;
  double? _latitude;
  double? _longitude;
  bool _loadingGps = false;

  String? _wilayaError;
  String? _communeError;
  String? _adresseError;
  String? _gpsError;

  List<_CommuneEntry> get _communes => _selectedWilaya == null
      ? []
      : (_communesMap[_selectedWilaya!.code] ?? []);

  String get _codePostal => _selectedCommune?.codePostal ?? '';

  @override
  void initState() {
    super.initState();
    _loadAlgeriaData();

    _adresseFocus.addListener(() {
      if (!_adresseFocus.hasFocus) {
        setState(() {
          _adresseError = InputValidator.adresseComplete(
            _adresseController.text,
          );
        });
      }
    });
  }

  @override
  void dispose() {
    _adresseController.dispose();
    _adresseFocus.dispose();
    super.dispose();
  }

  Future<void> _loadAlgeriaData() async {
    final raw = await rootBundle.loadString('assets/data/algeria.json');
    final json = jsonDecode(raw) as Map<String, dynamic>;

    final wilayas = (json['wilayas'] as List)
        .map(
          (w) => _WilayaEntry(
            code: w['code'] as String,
            name: w['name'] as String,
          ),
        )
        .toList();

    final communesMap = <String, List<_CommuneEntry>>{};
    (json['communes'] as Map<String, dynamic>).forEach((code, list) {
      communesMap[code] = (list as List)
          .map(
            (c) => _CommuneEntry(
              name: c['name'] as String,
              codePostal: c['codePostal'] as String,
            ),
          )
          .toList();
    });

    setState(() {
      _wilayas = wilayas;
      _communesMap = communesMap;
    });
  }

  Future<void> _autoGps() async {
    setState(() {
      _loadingGps = true;
      _gpsError = null;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          setState(() {
            _gpsError = 'Activez la localisation dans les paramètres';
            _loadingGps = false;
          });
        }
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            setState(() {
              _gpsError = 'Permission de localisation refusée';
              _loadingGps = false;
            });
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          setState(() {
            _gpsError = 'Autorisez la localisation dans les paramètres';
            _loadingGps = false;
          });
        }
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (mounted) {
        setState(() {
          _latitude = pos.latitude;
          _longitude = pos.longitude;
          _gpsError = null;
          _loadingGps = false;
        });
      }
    } catch (e) {
      debugPrint('GPS Error: $e');
      if (mounted) {
        setState(() {
          _gpsError = 'Position introuvable. Vérifiez le GPS.';
          _loadingGps = false;
        });
      }
    }
  }

  Future<void> _openMapPicker() async {
    final initial = (_latitude != null && _longitude != null)
        ? LatLng(_latitude!, _longitude!)
        : const LatLng(28.0, 3.0);

    final result = await Navigator.push<LatLng>(
      context,
      MaterialPageRoute(
        builder: (_) => _MapPickerPage(initialLocation: initial),
      ),
    );

    if (result != null) {
      setState(() {
        _latitude = result.latitude;
        _longitude = result.longitude;
        _gpsError = null;
      });
    }
  }

  void _handleNext() {
    setState(() {
      _wilayaError = _selectedWilaya == null
          ? 'Veuillez choisir une wilaya'
          : null;
      _communeError = _selectedCommune == null
          ? 'Veuillez choisir une commune'
          : null;
      _adresseError = InputValidator.adresseComplete(_adresseController.text);
      _gpsError = (_latitude == null || _longitude == null)
          ? 'Veuillez définir la position GPS de votre commerce'
          : null;
    });

    if (_wilayaError != null ||
        _communeError != null ||
        _adresseError != null ||
        _gpsError != null) {
      return;
    }

    String gps = '';
    if (_latitude != null && _longitude != null) {
      gps = '${_latitude!.toString()},${_longitude!.toString()}';
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MerchantSignupStep4Page(
          prenom: widget.prenom,
          nom: widget.nom,
          email: widget.email,
          phone: widget.phone,
          password: widget.password,
          nomCommerce: widget.nomCommerce,
          typeCommerce: widget.typeCommerce,
          ouverture: widget.ouverture,
          fermeture: widget.fermeture,
          wilaya: _selectedWilaya!.name,
          commune: _selectedCommune!.name,
          codePostal: _codePostal,
          adresse: _adresseController.text.trim(),
          gps: gps,
        ),
      ),
    );
  }

  Widget _fieldError(String message) {
    return buildFieldError(message, padding: _errorPadding);
  }

  Widget _readOnlyField({
    required String label,
    required String value,
    required IconData icon,
    required double sw,
    required double sh,
  }) {
    return Container(
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
      padding: EdgeInsets.symmetric(horizontal: sw * 0.045),
      child: Row(
        children: [
          Icon(icon, color: Colors.black45, size: 18),
          SizedBox(width: sw * 0.025),
          Text(
            value.isEmpty ? label : value,
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: (sw * 0.035).clamp(12.0, 15.0),
              color: value.isEmpty
                  ? const Color.fromARGB(120, 0, 0, 0)
                  : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text, double sw, double sh) {
    return Padding(
      padding: EdgeInsets.only(left: 14, bottom: sh * 0.01),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'PlusJakartaSans',
          fontSize: (sw * 0.035).clamp(12.0, 15.0),
          color: Colors.black,
        ),
      ),
    );
  }

  String _gpsDisplay() {
    if (_latitude == null || _longitude == null) return '';
    return '${_latitude!.toStringAsFixed(5)}, ${_longitude!.toStringAsFixed(5)}';
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;

    return commercePageScaffold(
      context: context,
      step: 3,
      children: [
        sectionTitle('Localisation du commerce', sw: sw, sh: sh),

        _sectionLabel('Wilaya', sw, sh),
        AppDropdown<_WilayaEntry>(
          value: _selectedWilaya,
          hint: 'Choisir une wilaya...',
          items: _wilayas,
          itemLabel: (w) => '${w.code} – ${w.name}',
          onChanged: (val) => setState(() {
            _selectedWilaya = val;
            _selectedCommune = null;
            _wilayaError = null;
          }),
        ),
        if (_wilayaError != null) _fieldError(_wilayaError!),
        SizedBox(height: sh * 0.012),

        _sectionLabel('Commune', sw, sh),
        AppDropdown<_CommuneEntry>(
          value: _selectedCommune,
          hint: _selectedWilaya == null
              ? 'Sélectionnez d\'abord une wilaya'
              : 'Choisir une commune...',
          items: _communes,
          itemLabel: (c) => c.name,
          onChanged: (val) {
            if (_selectedWilaya != null) {
              setState(() {
                _selectedCommune = val;
                _communeError = null;
              });
            }
          },
        ),
        if (_communeError != null) _fieldError(_communeError!),
        SizedBox(height: sh * 0.012),

        _sectionLabel('Code postal', sw, sh),
        _readOnlyField(
          label: 'Rempli automatiquement',
          value: _codePostal,
          icon: Icons.markunread_mailbox_outlined,
          sw: sw,
          sh: sh,
        ),
        SizedBox(height: sh * 0.012),

        CustomInputField(
          label: 'Adresse complète (rue, bâtiment...)',
          icon: Icons.home_outlined,
          controller: _adresseController,
          focusNode: _adresseFocus,
          onChanged: (_) {
            if (_adresseError != null) {
              setState(() => _adresseError = null);
            }
          },
        ),
        if (_adresseError != null) _fieldError(_adresseError!),
        SizedBox(height: sh * 0.02),

        _sectionLabel('Position GPS', sw, sh),
        if (_latitude != null && _longitude != null) ...[
          _readOnlyField(
            label: '',
            value: _gpsDisplay(),
            icon: Icons.location_on_outlined,
            sw: sw,
            sh: sh,
          ),
          SizedBox(height: sh * 0.01),
        ],
        Row(
          children: [
            Expanded(
              child: _gpsButton(
                label: _loadingGps ? 'Localisation...' : 'Ma position',
                icon: _loadingGps ? null : Icons.my_location,
                loading: _loadingGps,
                onTap: _loadingGps ? null : _autoGps,
                sw: sw,
                sh: sh,
              ),
            ),
            SizedBox(width: sw * 0.025),
            Expanded(
              child: _gpsButton(
                label: 'Choisir sur la carte',
                icon: Icons.map_outlined,
                loading: false,
                onTap: _openMapPicker,
                sw: sw,
                sh: sh,
              ),
            ),
          ],
        ),
        if (_gpsError != null) _fieldError(_gpsError!),
        SizedBox(height: sh * 0.025),

        actionButton(label: 'Suivant', onPressed: _handleNext, sw: sw, sh: sh),
      ],
    );
  }

  Widget _gpsButton({
    required String label,
    required IconData? icon,
    required bool loading,
    required VoidCallback? onTap,
    required double sw,
    required double sh,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: (sh * 0.055).clamp(44.0, 54.0),
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
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              spreadRadius: 0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: loading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.black54,
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, size: 16, color: Colors.black87),
                      SizedBox(width: sw * 0.015),
                    ],
                    Text(
                      label,
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: (sw * 0.032).clamp(11.0, 14.0),
                        color: Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _MapPickerPage extends StatefulWidget {
  final LatLng initialLocation;
  const _MapPickerPage({required this.initialLocation});

  @override
  State<_MapPickerPage> createState() => _MapPickerPageState();
}

class _MapPickerPageState extends State<_MapPickerPage> {
  late LatLng _pickedLocation;
  late final MapController _mapController;

  @override
  void initState() {
    super.initState();
    _pickedLocation = widget.initialLocation;
    _mapController = MapController();
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFB5C99A),
        elevation: 0,
        title: const Text(
          'Choisir la position',
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, _pickedLocation),
            child: const Text(
              'Confirmer',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _pickedLocation,
              initialZoom: 13.0,
              onTap: (tapPosition, point) {
                setState(() => _pickedLocation = point);
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.peeco.app',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: _pickedLocation,
                    width: 48,
                    height: 48,
                    child: const Icon(
                      Icons.location_pin,
                      size: 48,
                      color: Color.fromARGB(255, 248, 176, 104),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Text(
                'Appuyez sur la carte pour placer le marqueur à l\'endroit exact de votre commerce.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 13,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 24,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFB5C99A),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${_pickedLocation.latitude.toStringAsFixed(5)}, ${_pickedLocation.longitude.toStringAsFixed(5)}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}