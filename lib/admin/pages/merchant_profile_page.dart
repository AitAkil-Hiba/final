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

class MerchantProfilePage extends StatefulWidget {
  const MerchantProfilePage({
    super.key,
    required this.merchant,
  });

  final CommercantItem merchant;

  @override
  State<MerchantProfilePage> createState() => _MerchantProfilePageState();
}

class _MerchantProfilePageState extends State<MerchantProfilePage> {
  final AdminService _adminService = AdminService();
  bool _isLoading = false;
  MerchantAPI? _merchantDetails;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadMerchantDetails();
  }

  Future<void> _loadMerchantDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final details = await _adminService.getMerchantById(widget.merchant.id);
      setState(() {
        _merchantDetails = details;
        _isLoading = false;
      });
    } catch (e) {
      print(' Failed to load merchant details: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _formatDateTime(DateTime date) {
    return '${_formatDate(date)} à ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
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

  @override
  Widget build(BuildContext context) {
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
    final r = _Responsive(context);
    
    if (_isLoading) {
      return Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: appGradient,
          child: SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: const Color(0xFFE07B39)),
                  SizedBox(height: r.vp(16)),
                  Text(
                    'Chargement des détails...',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: r.fontSize(16),
                      fontFamily: AppFonts.plusJakarta,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
    
    final merchantName = _merchantDetails?.nomCommerce ?? widget.merchant.name;
    final merchantEmail = _merchantDetails?.email ?? widget.merchant.email;
    final merchantPhone = _merchantDetails?.telephone ?? 'Non spécifié';
    final merchantType = _merchantDetails?.typeCommerce ?? 'Non spécifié';
    final merchantAddress = _merchantDetails?.adresse ?? 'Non spécifiée';
    final merchantFullName = _merchantDetails?.fullName ?? 'Non spécifié';
    final statusColor = widget.merchant.statusType == CommercantStatus.active
        ? const Color(0xFFA8C88A)
        : widget.merchant.statusType == CommercantStatus.pending
            ? const Color(0xFFF8B068)
            : const Color(0xFFAAAAAA);

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
                    ),
                    const Spacer(),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: r.hp(12), vertical: r.vp(6)),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(r.scale(20)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Text(
                        widget.merchant.status,
                        style: TextStyle(
                          fontFamily: AppFonts.plusJakarta,
                          fontSize: r.fontSize(12),
                          fontWeight: FontWeight.w700,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: r.hp(20)),
                  child: Column(
                    children: [
                      SizedBox(height: r.vp(20)),
                      
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(vertical: r.vp(24)),
                        child: Column(
                          children: [
                            Container(
                              width: r.scale(100),
                              height: r.scale(100),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [Color(0xFFCCD5AE), Color(0xFFA8C88A)],
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  widget.merchant.initials,
                                  style: TextStyle(
                                    fontFamily: AppFonts.plusJakarta,
                                    fontSize: r.fontSize(36),
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: r.vp(16)),
                            Text(
                              merchantName,
                              style: TextStyle(
                                fontFamily: AppFonts.plusJakarta,
                                fontSize: r.fontSize(22),
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            SizedBox(height: r.vp(6)),
                            Text(
                              merchantEmail,
                              style: TextStyle(
                                fontFamily: AppFonts.plusJakarta,
                                fontSize: r.fontSize(14),
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                                            
                      SizedBox(height: r.vp(20)),
                      
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(r.scale(20)),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(r.scale(24)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: r.scale(32),
                                  height: r.scale(32),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFCCD5AE).withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(r.scale(10)),
                                  ),
                                  child: Icon(
                                    Icons.info_outline_rounded,
                                    size: r.scale(18),
                                    color: const Color(0xFF8B5E3C),
                                  ),
                                ),
                                SizedBox(width: r.hp(12)),
                                Text(
                                  'Informations',
                                  style: TextStyle(
                                    fontFamily: AppFonts.plusJakarta,
                                    fontSize: r.fontSize(16),
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF1A1A1A),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: r.vp(20)),
                            _DetailItem(
                              label: 'Date d\'inscription',
                              value: _formatDateTime(widget.merchant.registeredDate),
                              r: r,
                            ),
                            Divider(color: const Color(0xFFE8DEC8), height: r.vp(24)),
                            _DetailItem(
                              label: 'Dernière connexion',
                              value: widget.merchant.lastConnection != null 
                                  ? _formatDateTime(widget.merchant.lastConnection!)
                                  : 'Jamais',
                              r: r,
                            ),
                          ],
                        ),
                      ),
                      
                      SizedBox(height: r.vp(20)),
                      
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(r.scale(20)),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(r.scale(24)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: r.scale(32),
                                  height: r.scale(32),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFCCD5AE).withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(r.scale(10)),
                                  ),
                                  child: Icon(
                                    Icons.person_outline_rounded,
                                    size: r.scale(18),
                                    color: const Color(0xFF8B5E3C),
                                  ),
                                ),
                                SizedBox(width: r.hp(12)),
                                Text(
                                  'Gérant',
                                  style: TextStyle(
                                    fontFamily: AppFonts.plusJakarta,
                                    fontSize: r.fontSize(16),
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF1A1A1A),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: r.vp(20)),
                            _DetailItem(
                              label: 'Nom complet',
                              value: merchantFullName,
                              r: r,
                            ),
                            Divider(color: const Color(0xFFE8DEC8), height: r.vp(24)),
                            _DetailItem(
                              label: 'Email',
                              value: merchantEmail,
                              r: r,
                            ),
                            Divider(color: const Color(0xFFE8DEC8), height: r.vp(24)),
                            _DetailItem(
                              label: 'Téléphone',
                              value: merchantPhone,
                              r: r,
                            ),
                          ],
                        ),
                      ),
                      
                      SizedBox(height: r.vp(20)),
                      
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(r.scale(20)),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(r.scale(24)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: r.scale(32),
                                  height: r.scale(32),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFCCD5AE).withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(r.scale(10)),
                                  ),
                                  child: Icon(
                                    Icons.store_outlined,
                                    size: r.scale(18),
                                    color: const Color(0xFF8B5E3C),
                                  ),
                                ),
                                SizedBox(width: r.hp(12)),
                                Text(
                                  'Commerce',
                                  style: TextStyle(
                                    fontFamily: AppFonts.plusJakarta,
                                    fontSize: r.fontSize(16),
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF1A1A1A),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: r.vp(20)),
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
                                    merchantType,
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
                                  child: Container(
                                    padding: EdgeInsets.symmetric(vertical: r.vp(12)),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF9F9F9),
                                      borderRadius: BorderRadius.circular(r.scale(16)),
                                    ),
                                    child: Column(
                                      children: [
                                        Text(
                                          _formatTime(_merchantDetails?.heureOuverture),
                                          style: TextStyle(
                                            fontFamily: AppFonts.plusJakarta,
                                            fontSize: r.fontSize(16),
                                            fontWeight: FontWeight.w700,
                                            color: const Color(0xFF1A1A1A),
                                          ),
                                        ),
                                        SizedBox(height: r.vp(4)),
                                        Text(
                                          'OUVERTURE',
                                          style: AppTextStyles.statLabel.copyWith(fontSize: r.fontSize(10)),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(width: r.hp(12)),
                                Expanded(
                                  child: Container(
                                    padding: EdgeInsets.symmetric(vertical: r.vp(12)),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF9F9F9),
                                      borderRadius: BorderRadius.circular(r.scale(16)),
                                    ),
                                    child: Column(
                                      children: [
                                        Text(
                                          _formatTime(_merchantDetails?.heureFermeture),
                                          style: TextStyle(
                                            fontFamily: AppFonts.plusJakarta,
                                            fontSize: r.fontSize(16),
                                            fontWeight: FontWeight.w700,
                                            color: const Color(0xFF1A1A1A),
                                          ),
                                        ),
                                        SizedBox(height: r.vp(4)),
                                        Text(
                                          'FERMETURE',
                                          style: AppTextStyles.statLabel.copyWith(fontSize: r.fontSize(10)),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      
                      SizedBox(height: r.vp(20)),
                      
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(r.scale(20)),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(r.scale(24)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: r.scale(32),
                                  height: r.scale(32),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFCCD5AE).withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(r.scale(10)),
                                  ),
                                  child: Icon(
                                    Icons.location_on_outlined,
                                    size: r.scale(18),
                                    color: const Color(0xFF8B5E3C),
                                  ),
                                ),
                                SizedBox(width: r.hp(12)),
                                Text(
                                  'Localisation',
                                  style: TextStyle(
                                    fontFamily: AppFonts.plusJakarta,
                                    fontSize: r.fontSize(16),
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF1A1A1A),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: r.vp(20)),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(r.scale(30)),
                              child: Container(
                                height: r.vp(140),
                                width: double.infinity,
                                color: const Color(0xFFE8E8E8),
                                child: FlutterMap(
                                  options: MapOptions(
                                    initialCenter: const LatLng(36.7538, 3.0588),
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
                                          point: const LatLng(36.7538, 3.0588),
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
                                        merchantAddress,
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
                      
                      SizedBox(height: r.vp(20)),
                      
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(r.scale(20)),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(r.scale(24)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: r.scale(32),
                                  height: r.scale(32),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFCCD5AE).withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(r.scale(10)),
                                  ),
                                  child: Icon(
                                    Icons.description_outlined,
                                    size: r.scale(18),
                                    color: const Color(0xFF8B5E3C),
                                  ),
                                ),
                                SizedBox(width: r.hp(12)),
                                Text(
                                  'Documents soumis',
                                  style: TextStyle(
                                    fontFamily: AppFonts.plusJakarta,
                                    fontSize: r.fontSize(16),
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF1A1A1A),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: r.vp(20)),
                            _DocumentItem(
                              fileName: _merchantDetails?.documentLegal?.documentUrls?.cinUrl?.split('/').last ?? 'cin_document',
                              onView: () => _openDocument(_adminService.getCinFileUrl(widget.merchant.id), _merchantDetails?.documentLegal?.documentUrls?.cinUrl?.split('/').last ?? 'cin_document', r),
                              r: r,
                            ),
                            SizedBox(height: r.vp(12)),
                            _DocumentItem(
                              fileName: _merchantDetails?.documentLegal?.documentUrls?.rcUrl?.split('/').last ?? 'extrait_rc',
                              onView: () => _openDocument(_adminService.getRcFileUrl(widget.merchant.id), _merchantDetails?.documentLegal?.documentUrls?.rcUrl?.split('/').last ?? 'extrait_rc', r),
                              r: r,
                            ),
                          ],
                        ),
                      ),
                      
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

class _DetailItem extends StatelessWidget {
  const _DetailItem({
    required this.label,
    required this.value,
    required this.r,
  });

  final String label;
  final String value;
  final _Responsive r;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: AppFonts.plusJakarta,
            fontSize: r.fontSize(13),
            color: AppColors.textSecondary,
          ),
        ),
        Flexible(
          child: Text(
            value,
            style: TextStyle(
              fontFamily: AppFonts.plusJakarta,
              fontSize: r.fontSize(14),
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}

class _DocumentItem extends StatelessWidget {
  const _DocumentItem({
    required this.fileName,
    required this.onView,
    required this.r,
  });

  final String fileName;
  final VoidCallback onView;
  final _Responsive r;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(r.scale(12)),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(r.scale(12)),
      ),
      child: Row(
        children: [
          Container(
            width: r.scale(36),
            height: r.scale(36),
            decoration: BoxDecoration(
              color: const Color(0xFFE07B39).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(r.scale(8)),
            ),
            child: Icon(
              Icons.picture_as_pdf,
              size: r.scale(20),
              color: const Color(0xFFE07B39),
            ),
          ),
          SizedBox(width: r.hp(12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fileName,
                  style: TextStyle(
                    fontFamily: AppFonts.plusJakarta,
                    fontSize: r.fontSize(14),
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: r.vp(2)),
                Text(
                  'Document PDF',
                  style: TextStyle(
                    fontFamily: AppFonts.plusJakarta,
                    fontSize: r.fontSize(12),
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onView,
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: r.hp(12), vertical: r.vp(6)),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              backgroundColor: const Color(0xFFCCD5AE).withValues(alpha: 0.15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(r.scale(20)),
              ),
            ),
            child: Text(
              'Voir',
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
    );
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

  double scale(double value) =>
      value * ((_widthRatio + _heightRatio) / 2);

  double hp(double value) => value * _widthRatio;

  double vp(double value) => value * _heightRatio;

  double fontSize(double value) =>
      _textScale.scale(value * _widthRatio);
}
