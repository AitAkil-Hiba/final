import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'core/core.dart';
import 'commercants_page.dart';
import '../services/admin_service.dart';
import '../models/merchant_model.dart';

class AccountVerificationPage extends StatefulWidget {
  const AccountVerificationPage({
    super.key,
    required this.merchant,
  });

  final CommercantItem merchant;

  @override
  State<AccountVerificationPage> createState() => _AccountVerificationPageState();
}

class _AccountVerificationPageState extends State<AccountVerificationPage> {
  bool _isProcessing = false;
  bool _isLoading = true;
  MerchantAPI? _merchantDetails;
  String? _errorMessage;
  
  final TextEditingController _rcExpirationController = TextEditingController();
  String? _rcExpirationError;
  
  final AdminService _adminService = AdminService();

  @override
  void initState() {
    super.initState();
    _loadMerchantDetails();
  }

  Future<void> _loadMerchantDetails() async {
    try {
      print(' Loading merchant details for: ${widget.merchant.id}');
      final details = await _adminService.getMerchantById(widget.merchant.id);
      print(' Merchant details loaded: ${details.nomCommerce}');
      
      if (details.cinExpirationDate != null) {
        print(' Existing CIN expiration date found: ${details.cinExpirationDate}');
        final formattedDate = _formatDate(details.cinExpirationDate!);
        print(' Formatted existing date: $formattedDate');
        if (mounted) {
          setState(() {
            _rcExpirationController.text = formattedDate;
          });
        }
      } else {
        print(' No existing CIN expiration date found');
      }
      
      if (mounted) {
        setState(() {
          _merchantDetails = details;
          _isLoading = false;
        });
      }
    } catch (e) {
      print(' Error loading merchant details: $e');
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _rcExpirationController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, _Responsive r) async {
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: today,  
      firstDate: today, 
      lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFE07B39),
              onPrimary: Colors.white,
              onSurface: Color(0xFF2C2C2C),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFE07B39),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        _rcExpirationController.text = _formatDate(picked);
        _rcExpirationError = null;
      });
    }
  }

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }

  String _formatTime(String? time) {
    if (time == null || time.isEmpty) {
      return 'Non spécifié';
    }
    if (time.endsWith(':00')) {
      return time.substring(0, time.length - 3);
    }
    return time;
  }

  bool _isValidRCDate(String date) {
    if (date.isEmpty) return false;
    final regex = RegExp(r'^(0[1-9]|[12][0-9]|3[01])/(0[1-9]|1[0-2])/([0-9]{4})$');
    if (!regex.hasMatch(date)) return false;
    
    final parts = date.split('/');
    final day = int.parse(parts[0]);
    final month = int.parse(parts[1]);
    final year = int.parse(parts[2]);
    final selectedDate = DateTime(year, month, day);
    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    
    return selectedDate.isAfter(today) || selectedDate.isAtSameMomentAs(today);
  }

  @override
  Widget build(BuildContext context) {
    final r = _Responsive(context);
    
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: appGradient,
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(r.hp(8), r.vp(12), r.hp(20), 0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: r.scale(20),
                        color: AppColors.textPrimary,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(
                        minWidth: r.scale(40),
                        minHeight: r.scale(40),
                      ),
                    ),
                    SizedBox(width: r.hp(4)),
                    Expanded(
                      child: Text(
                        'Vérification du compte',
                        style: TextStyle(
                          fontFamily: AppFonts.plusJakarta,
                          fontSize: r.fontSize(18),
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: r.hp(20)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: r.vp(12)),
                      _buildUserCard(r),
                      SizedBox(height: r.vp(24)),
                      _buildSectionTitle('INFORMATIONS DU GÉRANT', r),
                      SizedBox(height: r.vp(12)),
                      _buildManagerInfo(r),
                      SizedBox(height: r.vp(24)),
                      _buildSectionTitle('INFORMATIONS DU COMMERCE', r),
                      SizedBox(height: r.vp(12)),
                      _buildBusinessInfo(r),
                      SizedBox(height: r.vp(24)),
                      _buildSectionTitle('LOCALISATION', r),
                      SizedBox(height: r.vp(12)),
                      _buildLocationSection(r),
                      SizedBox(height: r.vp(24)),
                      _buildSectionTitle('DOCUMENTS SOUMIS', r),
                      SizedBox(height: r.vp(12)),
                      _buildDocumentsSection(r),
                      SizedBox(height: r.vp(24)),
                      _buildSectionTitle('DATE D\'EXPIRATION RC', r),
                      SizedBox(height: r.vp(12)),
                      _buildRcExpirationField(r),
                      SizedBox(height: r.vp(32)),
                      _buildActionButtons(r),
                      SizedBox(height: r.vp(30)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRcExpirationField(_Responsive r) {
    return Container(
      padding: EdgeInsets.all(r.scale(16)),
      decoration: _containerDecoration(r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: r.scale(36),
                height: r.scale(36),
                decoration: BoxDecoration(
                  color: const Color(0xFFFCE8D8),
                  borderRadius: BorderRadius.circular(r.scale(30)),
                ),
                child: Icon(
                  Icons.calendar_today_rounded,
                  size: r.scale(18),
                  color: const Color(0xFFE07B39),
                ),
              ),
              SizedBox(width: r.hp(12)),
              Expanded(
                child: Text(
                  'Date d\'expiration du Registre de Commerce (RC)',
                  style: TextStyle(
                    fontFamily: AppFonts.plusJakarta,
                    fontSize: r.fontSize(13),
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: r.vp(12)),
          GestureDetector(
            onTap: () => _selectDate(context, r),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: r.hp(16),
                vertical: r.vp(14),
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFF9F9F9),
                borderRadius: BorderRadius.circular(r.scale(30)),
                border: Border.all(
                  color: _rcExpirationError != null 
                      ? Colors.red 
                      : const Color(0xFFE8DEC8),
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.event_available_rounded,
                    size: r.scale(20),
                    color: _rcExpirationController.text.isEmpty 
                        ? AppColors.textMuted 
                        : const Color(0xFFE07B39),
                  ),
                  SizedBox(width: r.hp(12)),
                  Expanded(
                    child: Text(
                      _rcExpirationController.text.isEmpty
                          ? 'Sélectionner une date (JJ/MM/AAAA)'
                          : _rcExpirationController.text,
                      style: TextStyle(
                        fontFamily: AppFonts.plusJakarta,
                        fontSize: r.fontSize(14),
                        fontWeight: FontWeight.w500,
                        color: _rcExpirationController.text.isEmpty
                            ? AppColors.textMuted
                            : AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_drop_down_rounded,
                    size: r.scale(24),
                    color: AppColors.textMuted,
                  ),
                ],
              ),
            ),
          ),
          if (_rcExpirationError != null) ...[
            SizedBox(height: r.vp(8)),
            Row(
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  size: r.scale(14),
                  color: Colors.red,
                ),
                SizedBox(width: r.hp(6)),
                Expanded(
                  child: Text(
                    _rcExpirationError!,
                    style: TextStyle(
                      fontFamily: AppFonts.plusJakarta,
                      fontSize: r.fontSize(11),
                      color: Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildUserCard(_Responsive r) {
    return Container(
      padding: EdgeInsets.all(r.scale(16)),
      decoration: _containerDecoration(r),
      child: Row(
        children: [
          Container(
            width: r.scale(54),
            height: r.scale(54),
            decoration: BoxDecoration(
              color: const Color(0xFFF2E9DA),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                widget.merchant.initials,
                style: TextStyle(
                  fontFamily: AppFonts.plusJakarta,
                  fontSize: r.fontSize(18),
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF5C4A2A),
                ),
              ),
            ),
          ),
          SizedBox(width: r.hp(14)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.merchant.name,
                  style: TextStyle(
                    fontFamily: AppFonts.plusJakarta,
                    fontSize: r.fontSize(16),
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: r.vp(2)),
                Text(
                  widget.merchant.email,
                  style: TextStyle(
                    fontFamily: AppFonts.plusJakarta,
                    fontSize: r.fontSize(13),
                    color: AppColors.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: EdgeInsets.symmetric(horizontal: r.hp(12), vertical: r.vp(6)),
            decoration: BoxDecoration(
              color: const Color(0xFFFCE8D8),
              borderRadius: BorderRadius.circular(r.scale(30)),
            ),
            child: Text(
              'EN ATTENTE',
              style: TextStyle(
                fontFamily: AppFonts.plusJakarta,
                fontSize: r.fontSize(11),
                fontWeight: FontWeight.w700,
                color: const Color(0xFFE07B39),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, _Responsive r) {
    return Text(
      title,
      style: TextStyle(
        fontFamily: AppFonts.plusJakarta,
        fontSize: r.fontSize(12),
        fontWeight: FontWeight.w600,
        color: AppColors.textMuted,
        letterSpacing: 0.8,
      ),
    );
  }

  Widget _buildManagerInfo(_Responsive r) {
    if (_isLoading) {
      return Container(
        padding: EdgeInsets.all(r.scale(16)),
        decoration: _containerDecoration(r),
        child: Center(
          child: CircularProgressIndicator(color: const Color(0xFFE07B39)),
        ),
      );
    }
    
    if (_errorMessage != null) {
      return Container(
        padding: EdgeInsets.all(r.scale(16)),
        decoration: _containerDecoration(r),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.error_outline, color: Colors.red, size: r.scale(40)),
              SizedBox(height: r.vp(8)),
              Text(
                'Erreur de chargement',
                style: TextStyle(
                  fontFamily: AppFonts.plusJakarta,
                  fontSize: r.fontSize(14),
                  color: Colors.red,
                ),
              ),
              SizedBox(height: r.vp(4)),
              Text(
                _errorMessage!,
                style: TextStyle(
                  fontFamily: AppFonts.plusJakarta,
                  fontSize: r.fontSize(12),
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }
    
    return Container(
      padding: EdgeInsets.all(r.scale(16)),
      decoration: _containerDecoration(r),
      child: Column(
        children: [
          _InfoRow(
            icon: Icons.person_outline_rounded,
            label: 'Nom complet',
            value: _merchantDetails?.fullName ?? widget.merchant.name,
            r: r,
          ),
          SizedBox(height: r.vp(16)),
          _InfoRow(
            icon: Icons.email_outlined,
            label: 'Email',
            value: _merchantDetails?.email ?? widget.merchant.email,
            r: r,
          ),
          SizedBox(height: r.vp(16)),
          _InfoRow(
            icon: Icons.phone_outlined,
            label: 'Téléphone',
            value: _merchantDetails?.telephone ?? 'Non renseigné',
            r: r,
          ),
        ],
      ),
    );
  }

  Widget _buildBusinessInfo(_Responsive r) {
    if (_isLoading) {
      return Container(
        padding: EdgeInsets.all(r.scale(16)),
        decoration: _containerDecoration(r),
        child: Center(
          child: CircularProgressIndicator(color: const Color(0xFFE07B39)),
        ),
      );
    }
    
    return Container(
      padding: EdgeInsets.all(r.scale(16)),
      decoration: _containerDecoration(r),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ENSEIGNE',
                style: TextStyle(
                  fontFamily: AppFonts.plusJakarta,
                  fontSize: r.fontSize(12),
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: r.hp(12), vertical: r.vp(6)),
                decoration: BoxDecoration(
                  color: const Color(0xFFCCD5AE).withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(r.scale(30)),
                ),
                child: Text(
                  _merchantDetails?.typeCommerce ?? 'Non spécifié',
                  style: TextStyle(
                    fontFamily: AppFonts.plusJakarta,
                    fontSize: r.fontSize(12),
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF8B5E3C),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: r.vp(20)),
          Row(
            children: [
              Expanded(
                child: _TimeCard(
                  label: 'OUVERTURE',
                  value: _formatTime(_merchantDetails?.heureOuverture),
                  r: r,
                ),
              ),
              SizedBox(width: r.hp(12)),
              Expanded(
                child: _TimeCard(
                  label: 'FERMETURE',
                  value: _formatTime(_merchantDetails?.heureFermeture),
                  r: r,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLocationSection(_Responsive r) {
    if (_isLoading) {
      return Container(
        padding: EdgeInsets.all(r.scale(16)),
        decoration: _containerDecoration(r),
        child: Center(
          child: CircularProgressIndicator(color: const Color(0xFFE07B39)),
        ),
      );
    }
    
    const double latitude = 36.7538;
    const double longitude = 3.0588;
    final address = _merchantDetails?.adresse ?? 'Adresse non renseignée';

    return GestureDetector(
      onTap: () => _openMapViewer(latitude, longitude, r),
      child: Container(
        padding: EdgeInsets.all(r.scale(16)),
        decoration: _containerDecoration(r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(r.scale(30)),
              child: Container(
                height: r.vp(140),
                width: double.infinity,
                color: const Color(0xFFE8E8E8),
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: LatLng(latitude, longitude),
                    initialZoom: 14.0,
                    interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag.drag | InteractiveFlag.pinchZoom,
                    ),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.peeco.app',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: LatLng(latitude, longitude),
                          width: r.scale(40),
                          height: r.scale(40),
                          child: Icon(
                            Icons.location_pin,
                            size: r.scale(40),
                            color: const Color(0xFFE07B39),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: r.vp(16)),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: r.scale(18),
                  color: AppColors.accentBrown,
                ),
                SizedBox(width: r.hp(8)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        address,
                        style: TextStyle(
                          fontFamily: AppFonts.plusJakarta,
                          fontSize: r.fontSize(14),
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _openMapViewer(double latitude, double longitude, _Responsive r) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _MapFullScreenPage(
          latitude: latitude,
          longitude: longitude,
          r: r,
        ),
      ),
    );
  }

  Widget _buildDocumentsSection(_Responsive r) {
    final merchantId = widget.merchant.id;
    final cinUrl = _merchantDetails?.documentLegal?.documentUrls?.cinUrl;
    final rcUrl = _merchantDetails?.documentLegal?.documentUrls?.rcUrl;

    final cinFileName = cinUrl != null && cinUrl.isNotEmpty
        ? cinUrl.split('/').last
        : 'cin_document';
    final rcFileName = rcUrl != null && rcUrl.isNotEmpty
        ? rcUrl.split('/').last
        : 'extrait_rc';

    return Container(
      padding: EdgeInsets.all(r.scale(16)),
      decoration: _containerDecoration(r),
      child: Column(
        children: [
          _DocumentRow(
            fileName: cinFileName,
            onView: () => _openDocument(_adminService.getCinFileUrl(merchantId), cinFileName, r),
            r: r,
          ),
          SizedBox(height: r.vp(12)),
          _DocumentRow(
            fileName: rcFileName,
            onView: () => _openDocument(_adminService.getRcFileUrl(merchantId), rcFileName, r),
            r: r,
          ),
        ],
      ),
    );
  }

  void _openDocument(String fileUrl, String fileName, _Responsive r) async {
    final headers = await _adminService.getDocumentHeaders();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DocumentViewerPage(
          fileUrl: fileUrl,
          fileName: fileName,
          headers: headers,
          r: r,
        ),
      ),
    );
  }

  Widget _buildActionButtons(_Responsive r) {
    return Row(
      children: [
        Expanded(
          child: _OutlinedButton(
            label: 'Refuser',
            onPressed: _isProcessing ? null : () => _rejectVerification(r),
            r: r,
          ),
        ),
        SizedBox(width: r.hp(12)),
        Expanded(
          child: _PrimaryButton(
            label: 'Approuver',
            onPressed: _isProcessing ? null : () => _approveVerification(r),
            isLoading: _isProcessing,
            r: r,
          ),
        ),
      ],
    );
  }

  BoxDecoration _containerDecoration(_Responsive r) {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(r.scale(30)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: r.scale(8),
          offset: Offset(0, r.scale(2)),
        ),
      ],
    );
  }

  void _approveVerification(_Responsive r) async {
    if (_rcExpirationController.text.isEmpty) {
      setState(() {
        _rcExpirationError = 'Cette date est obligatoire car le RC doit être renouvelé périodiquement';
      });
      return;
    }
    
    if (!_isValidRCDate(_rcExpirationController.text)) {
      setState(() {
        _rcExpirationError = 'Date invalide. La date doit être au format JJ/MM/AAAA et ne peut pas être dans le passé.';
      });
      return;
    }

    setState(() => _isProcessing = true);
    
    try {
      final parts = _rcExpirationController.text.split('/');
      if (parts.length != 3) {
        throw Exception('Format de date invalide: ${_rcExpirationController.text}');
      }
      
      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);
      
      if (year < 2024 || year > 2050) {
        throw Exception('Année invalide: $year. Doit être entre 2024 et 2050');
      }
      if (month < 1 || month > 12) {
        throw Exception('Mois invalide: $month');
      }
      if (day < 1 || day > 31) {
        throw Exception('Jour invalide: $day');
      }
      
      final selectedDate = DateTime(year, month, day);
      final today = DateTime.now();
      final todayOnly = DateTime(today.year, today.month, today.day);
      
      if (selectedDate.isBefore(todayOnly)) {
        throw Exception('La date d\'expiration ne peut pas être dans le passé');
      }
      
      final isoFormat = '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
      final alternativeFormat1 = '$year-$month-$day';
      final alternativeFormat2 = '${day.toString().padLeft(2, '0')}-${month.toString().padLeft(2, '0')}-$year';
      
      print('Starting validation for merchant: ${widget.merchant.id}');
      print(' Original date from controller: "${_rcExpirationController.text}"');
      print(' Parsed - Day: $day, Month: $month, Year: $year');
      print(' DateTime object: $selectedDate');
      print(' ISO format (YYYY-MM-DD): $isoFormat');
      print(' Alternative format 1: $alternativeFormat1');
      print(' Alternative format 2 (DD-MM-YYYY): $alternativeFormat2');
      print(' Today: $todayOnly');
      print(' Is date valid: ${!selectedDate.isBefore(todayOnly)}');
      
      final testDate = '2025-12-31';
      print('🧪 TESTING: Using hardcoded date: $testDate');
      
      await _adminService.validateMerchant(
        widget.merchant.id,
        cinExpirationDate: testDate,
      );
      
      if (mounted) {
        setState(() => _isProcessing = false);
        print(' Account approved successfully. RC expiration date: ${_rcExpirationController.text}');
        print(' Returning to merchant list with refresh signal');
        Navigator.pop(context, true);
      }
    } catch (e) {
      print(' Validation error: $e');
      if (mounted) {
        setState(() => _isProcessing = false);
        _showErrorBanner('Erreur de validation', e.toString());
      }
    }
  }

  void _rejectVerification(_Responsive r) async {
    print(' REJECT VERIFICATION CALLED 🚨');
    print(' Merchant ID: ${widget.merchant.id}');
    print(' Is processing: $_isProcessing');
    
    final confirm = await _showRejectConfirmation(r);
    print(' User confirmation: $confirm');
    
    if (confirm == true && mounted) {
      print(' Starting rejection process...');
      setState(() => _isProcessing = true);
      
      try {
        print(' Calling rejectMerchant API...');
        final response = await _adminService.rejectMerchant(widget.merchant.id);
        
        if (mounted) {
          setState(() => _isProcessing = false);
          print(' Rejection successful, navigating back...');
          Navigator.pop(context, response['merchantId']);
        }
      } catch (e) {
        print(' Rejection failed: $e');
        if (mounted) {
          setState(() => _isProcessing = false);
          _showErrorBanner('Erreur de rejet', e.toString());
        }
      }
    } else {
      print('   Rejection cancelled or widget not mounted');
    }
  }

  Future<bool?> _showRejectConfirmation(_Responsive r) {
    return showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(r.scale(30))),
        backgroundColor: Colors.white,
        child: Container(
          padding: EdgeInsets.all(r.scale(24)),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(r.scale(30)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Refuser la vérification',
                style: TextStyle(
                  fontFamily: AppFonts.plusJakarta,
                  fontSize: r.fontSize(18),
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: r.vp(16)),
              Text(
                'Êtes-vous sûr de vouloir refuser ce compte ?',
                style: TextStyle(
                  fontFamily: AppFonts.plusJakarta,
                  fontSize: r.fontSize(14),
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: r.vp(8)),
              Container(
                padding: EdgeInsets.all(r.scale(12)),
                decoration: BoxDecoration(
                  color: const Color(0xFFFDF5E6),
                  borderRadius: BorderRadius.circular(r.scale(30)),
                ),
                child: Text(
                  widget.merchant.name,
                  style: TextStyle(
                    fontFamily: AppFonts.plusJakarta,
                    fontSize: r.fontSize(14),
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: r.vp(24)),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: r.vp(12)),
                        backgroundColor: const Color(0xFFE8E8E8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(r.scale(30)),
                        ),
                      ),
                      child: Text(
                        'Annuler',
                        style: TextStyle(
                          fontFamily: AppFonts.plusJakarta,
                          fontSize: r.fontSize(14),
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: r.hp(12)),
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: r.vp(12)),
                        backgroundColor: Colors.red.withValues(alpha: 0.1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(r.scale(30)),
                        ),
                      ),
                      child: Text(
                        'Refuser',
                        style: TextStyle(
                          fontFamily: AppFonts.plusJakarta,
                          fontSize: r.fontSize(14),
                          fontWeight: FontWeight.w600,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showErrorBanner(String message, String subtitle) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (ctx) => Material(
        color: Colors.transparent,
        child: Container(
          margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 16),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.error, color: Colors.white, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        message,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => entry.remove(),
                  icon: const Icon(Icons.close, color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    overlay.insert(entry);
    
    Future.delayed(const Duration(seconds: 5), () {
      if (entry.mounted) {
        entry.remove();
      }
    });
  }
}

class DocumentViewerPage extends StatefulWidget {
  const DocumentViewerPage({
    super.key,
    required this.fileUrl,
    required this.fileName,
    required this.headers,
    required this.r,
  });

  final String fileUrl;
  final String fileName;
  final Map<String, String> headers;
  final _Responsive r;

  @override
  State<DocumentViewerPage> createState() => _DocumentViewerPageState();
}

class _DocumentViewerPageState extends State<DocumentViewerPage> {
  Uint8List? _fileBytes;
  bool _isLoading = false;
  String? _error;
  String? _contentType;

  @override
  void initState() {
    super.initState();
    _loadFile();
  }

  Future<void> _loadFile() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(Uri.parse(widget.fileUrl), headers: widget.headers);
      if (response.statusCode == 200) {
        setState(() {
          _fileBytes = response.bodyBytes;
          _contentType = response.headers['content-type']?.toLowerCase() ?? '';
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Erreur ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Erreur réseau: $e';
        _isLoading = false;
      });
    }
  }

  bool _isImageType(String? contentType) {
    if (contentType == null || contentType!.isEmpty) {
      final lowerUrl = widget.fileUrl.toLowerCase();
      return lowerUrl.endsWith('.jpg') ||
          lowerUrl.endsWith('.jpeg') ||
          lowerUrl.endsWith('.png') ||
          lowerUrl.endsWith('.webp') ||
          lowerUrl.endsWith('.gif');
    }
    return contentType!.startsWith('image/');
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.r;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.fileName,
          style: TextStyle(
            fontFamily: AppFonts.plusJakarta,
            fontSize: r.fontSize(14),
            fontWeight: FontWeight.w500,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, size: r.scale(20)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFE07B39)))
          : _error != null
              ? Center(child: Text(_error!))
              : _isImageType(_contentType)
                  ? InteractiveViewer(
                      child: Center(child: Image.memory(_fileBytes!)),
                    )
                  : SfPdfViewer.memory(
                      _fileBytes!,
                    ),
    );
  }
}

class _MapFullScreenPage extends StatelessWidget {
  const _MapFullScreenPage({
    required this.latitude,
    required this.longitude,
    required this.r,
  });

  final double latitude;
  final double longitude;
  final _Responsive r;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Localisation',
          style: TextStyle(
            fontFamily: AppFonts.plusJakarta,
            fontSize: r.fontSize(18),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, size: r.scale(20)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: LatLng(latitude, longitude),
          initialZoom: 15.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.peeco.app',
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: LatLng(latitude, longitude),
                width: r.scale(48),
                height: r.scale(48),
                child: Icon(
                  Icons.location_pin,
                  size: r.scale(48),
                  color: const Color(0xFFE07B39),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.r,
  });

  final IconData icon;
  final String label;
  final String value;
  final _Responsive r;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: r.scale(36),
          height: r.scale(36),
          decoration: BoxDecoration(
            color: const Color(0xFFFCE8D8),
            borderRadius: BorderRadius.circular(r.scale(30)),
          ),
          child: Icon(icon, size: r.scale(18), color: const Color(0xFFE07B39)),
        ),
        SizedBox(width: r.hp(12)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontFamily: AppFonts.plusJakarta,
                  fontSize: r.fontSize(11),
                  fontWeight: FontWeight.w500,
                  color: AppColors.textMuted,
                ),
              ),
              SizedBox(height: r.vp(2)),
              Text(
                value,
                style: TextStyle(
                  fontFamily: AppFonts.plusJakarta,
                  fontSize: r.fontSize(14),
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TimeCard extends StatelessWidget {
  const _TimeCard({
    required this.label,
    required this.value,
    required this.r,
  });

  final String label;
  final String value;
  final _Responsive r;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: r.vp(12)),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(r.scale(30)),
        border: Border.all(color: const Color(0xFFE8DEC8), width: 1.5),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: AppFonts.plusJakarta,
              fontSize: r.fontSize(10),
              fontWeight: FontWeight.w500,
              color: AppColors.textMuted,
            ),
          ),
          SizedBox(height: r.vp(4)),
          Text(
            value,
            style: TextStyle(
              fontFamily: AppFonts.plusJakarta,
              fontSize: r.fontSize(14),
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _DocumentRow extends StatelessWidget {
  const _DocumentRow({
    required this.fileName,
    required this.onView,
    required this.r,
  });

  final String fileName;
  final VoidCallback onView;
  final _Responsive r;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: r.scale(36),
          height: r.scale(36),
          decoration: BoxDecoration(
            color: const Color(0xFFF2E9DA),
            borderRadius: BorderRadius.circular(r.scale(30)),
          ),
          child: Icon(
            Icons.picture_as_pdf_outlined,
            size: r.scale(20),
            color: const Color(0xFFE07B39),
          ),
        ),
        SizedBox(width: r.hp(12)),
        Expanded(
          child: Text(
            fileName,
            style: TextStyle(
              fontFamily: AppFonts.plusJakarta,
              fontSize: r.fontSize(14),
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        TextButton(
          onPressed: onView,
          style: TextButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: r.hp(16), vertical: r.vp(8)),
            backgroundColor: const Color(0xFFF5F5F5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(r.scale(30)),
            ),
          ),
          child: Text(
            'Voir',
            style: TextStyle(
              fontFamily: AppFonts.plusJakarta,
              fontSize: r.fontSize(12),
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    required this.r,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final _Responsive r;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFE8D6B5),
        disabledBackgroundColor: const Color(0xFFE8D6B5).withValues(alpha: 0.5),
        padding: EdgeInsets.symmetric(vertical: r.vp(14)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(r.scale(30)),
        ),
        elevation: 0,
      ),
      child: isLoading
          ? SizedBox(
              width: r.scale(20),
              height: r.scale(20),
              child: const CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : Text(
              label,
              style: TextStyle(
                fontFamily: AppFonts.plusJakarta,
                fontSize: r.fontSize(14),
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
    );
  }
}

class _OutlinedButton extends StatelessWidget {
  const _OutlinedButton({
    required this.label,
    required this.onPressed,
    required this.r,
  });

  final String label;
  final VoidCallback? onPressed;
  final _Responsive r;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Colors.grey, width: 1.5),
        backgroundColor: Colors.white,
        padding: EdgeInsets.symmetric(vertical: r.vp(14)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(r.scale(30)),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: AppFonts.plusJakarta,
          fontSize: r.fontSize(14),
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

class _Responsive {
  _Responsive(BuildContext context)
      : _size = MediaQuery.of(context).size,
        _textScale = MediaQuery.of(context).textScaler;

  final Size _size;
  final TextScaler _textScale;

  static const double _baseWidth = 390.0;
  static const double _baseHeight = 844.0;

  double get _widthRatio => (_size.width / _baseWidth).clamp(0.5, 1.4);
  double get _heightRatio => (_size.height / _baseHeight).clamp(0.5, 1.4);

  double scale(double value) => value * ((_widthRatio + _heightRatio) / 2);

  double hp(double value) => value * _widthRatio;

  double vp(double value) => value * _heightRatio;

  double fontSize(double value) => _textScale.scale(value * _widthRatio);
}