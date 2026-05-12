import 'package:flutter/material.dart';

import 'core/core.dart';

import 'notifications.dart';

import '../../../services/app_report_service.dart';

import '../../../models/app_report.dart';

import '../services/admin_service.dart';



class HelpRequestsPage extends StatefulWidget {

  const HelpRequestsPage({super.key});



  @override

  State<HelpRequestsPage> createState() => _HelpRequestsPageState();

}



class _HelpRequestsPageState extends State<HelpRequestsPage> {

  final AppReportService _appReportService = AppReportService();

final AdminService _adminService = AdminService();

List<AppReport> _helpRequests = [];

bool _isLoading = true;

String? _error;



@override

void initState() {

  super.initState();

  _loadHelpRequests();

}



Future<void> _loadHelpRequests() async {

  setState(() {

    _isLoading = true;

    _error = null;

  });

  try {

    final reports = await _appReportService.getAdminReports();

    final openReports = reports.where((report) => report.status == AppReportStatus.open).toList();

    setState(() {

      _helpRequests = openReports;

      _isLoading = false;

    });

  } catch (e) {

    setState(() {

      _error = e.toString();

      _isLoading = false;

    });

  }

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

                padding: EdgeInsets.fromLTRB(r.hp(20), r.vp(20), r.hp(20), r.vp(4)),

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

                    SizedBox(width: r.hp(8)),

                    Text('Demandes d\'aide', style: TextStyle(

                      fontFamily: AppFonts.plusJakarta,

                      fontSize: r.fontSize(22), 

                      fontWeight: FontWeight.w700,

                      color: AppColors.textPrimary,

                      letterSpacing: -0.5,

                    )),

                    const Spacer(),

                    if (!_isLoading && _error == null)

                      Container(

                        padding: EdgeInsets.symmetric(horizontal: r.hp(12), vertical: r.vp(8)),

                        decoration: BoxDecoration(

                          color: Colors.white.withValues(alpha: 0.5),

                          borderRadius: BorderRadius.circular(r.scale(30)),

                        ),

                        child: Row(

                          children: [

                            Icon(

                              Icons.support_agent_rounded,

                              size: r.scale(16),

                              color: const Color(0xFF5C4A2A),

                            ),

                            SizedBox(width: r.hp(6)),

                            Text(

                              '${_helpRequests.length}',

                              style: TextStyle(

                                fontFamily: AppFonts.plusJakarta,

                                fontSize: r.fontSize(14),

                                fontWeight: FontWeight.w600,

                                color: const Color(0xFF5C4A2A),

                              ),

                            ),

                          ],

                        ),

                      ),

                  ],

                ),

              ),

              Expanded(

                child: _buildBody(r),

              ),

            ],

          ),

        ),

      ),

    );

  }



Widget _buildBody(_Responsive r) {

  if (_isLoading) {

    return const Center(

      child: CircularProgressIndicator(color: Color(0xFFE07B39)),

    );

  }



  if (_error != null) {

    return Center(

      child: Column(

        mainAxisAlignment: MainAxisAlignment.center,

        children: [

          Icon(Icons.error_outline, size: r.scale(60), color: Colors.red),

          SizedBox(height: r.vp(16)),

          Text(

            'Erreur de chargement',

            style: TextStyle(

              fontFamily: AppFonts.plusJakarta,

              fontSize: r.fontSize(16),

              color: Colors.red,

            ),

          ),

          SizedBox(height: r.vp(8)),

          Text(

            _error!,

            style: TextStyle(

              fontFamily: AppFonts.plusJakarta,

              fontSize: r.fontSize(12),

              color: const Color(0xFFAAAAAA),

            ),

            textAlign: TextAlign.center,

          ),

          SizedBox(height: r.vp(16)),

          ElevatedButton(

            onPressed: _loadHelpRequests,

            style: ElevatedButton.styleFrom(

              backgroundColor: const Color(0xFFE07B39),

              foregroundColor: Colors.white,

              shape: RoundedRectangleBorder(

                borderRadius: BorderRadius.circular(r.scale(30)),

              ),

            ),

            child: const Text('Réessayer'),

          ),

        ],

      ),

    );

  }



  if (_helpRequests.isEmpty) {

    return Center(

      child: Column(

        mainAxisAlignment: MainAxisAlignment.center,

        children: [

          Icon(Icons.inbox_outlined, size: r.scale(60), color: const Color(0xFFAAAAAA)),

          SizedBox(height: r.vp(16)),

          Text(

            'Aucune demande d\'aide',

            style: TextStyle(

              fontFamily: AppFonts.plusJakarta,

              fontSize: r.fontSize(16),

              color: const Color(0xFFAAAAAA),

            ),

          ),

        ],

      ),

    );

  }



  return ListView.separated(

    padding: EdgeInsets.fromLTRB(r.hp(20), r.vp(20), r.hp(20), r.vp(100)),

    itemCount: _helpRequests.length,

    separatorBuilder: (_, __) => SizedBox(height: r.vp(12)),

    itemBuilder: (_, index) {

      final request = _helpRequests[index];

      return _HelpRequestCard(

        request: request,

        onTap: () => _openNotification(request),

        onDelete: () => _closeReport(request),

      );

    },

  );

}



  Future<void> _openNotification(AppReport request) async {


  String userType = 'merchants';
  Map<String, dynamic> userData;



  try {


    final merchant = await _adminService.getMerchantById(request.userId);

    userType = 'merchants';

    userData = {

      'id': merchant.id,

      'name': merchant.fullName,

      'initials': merchant.fullName.split(' ').map((p) => p.isNotEmpty ? p[0] : '').take(2).join().toUpperCase(),

      'status': 'Actif',

    };

  } catch (e) {


    try {

      final clients = await _adminService.getClients();

      final client = clients.firstWhere(

        (c) => c.id == request.userId,

        orElse: () => throw Exception('Client not found'),

      );

      userType = 'clients';

      userData = {

        'id': client.id,

        'name': client.fullName,

        'initials': client.fullName.split(' ').map((p) => p.isNotEmpty ? p[0] : '').take(2).join().toUpperCase(),

        'status': 'Actif',

      };

    } catch (e) {


      final nameParts = request.userName.trim().split(' ');

      final initials = nameParts

          .where((p) => p.isNotEmpty)

          .map((p) => p[0])

          .take(2)

          .join()

          .toUpperCase();



      userData = {

        'id': request.userId,

        'name': request.userName,

        'initials': initials,

        'status': 'Actif',

        'userType': 'merchants', 

      };

    }

  }



  Navigator.push(

    context,

    MaterialPageRoute(

      builder: (context) => NotificationsPage(

        preselectedMerchant: userData,

        preselectedTitle: 'Demande d\'aide: ${request.subject}',

        preselectedMessage: 'Votre demande a été prise en compte et sera traitée dans les plus brefs délais.',

        preselectedRecipient: userType,

      ),

    ),

  ).then((_) => _loadHelpRequests());

}



  Future<void> _closeReport(AppReport request) async {

  try {

    await _appReportService.updateStatus(

      reportId: request.id,

      status: AppReportStatus.closed,

    );

    ScaffoldMessenger.of(context).showSnackBar(

      const SnackBar(

        content: Text('Demande fermée avec succès'),

        backgroundColor: Color(0xFFA8C88A),

      ),

    );

    _loadHelpRequests();

  } catch (e) {

    ScaffoldMessenger.of(context).showSnackBar(

      SnackBar(

        content: Text('Erreur: ${e.toString()}'),

        backgroundColor: Colors.red,

      ),

    );

  }

}

}





class _HelpRequestCard extends StatelessWidget {

  const _HelpRequestCard({

    required this.request,

    required this.onTap,

    required this.onDelete,

  });



  final AppReport request;

  final VoidCallback onTap;

  final VoidCallback onDelete;



  String _formatDateTime(DateTime date) {

    final now = DateTime.now();

    final difference = now.difference(date);



    if (difference.inMinutes < 60) {

      return 'Il y a ${difference.inMinutes} min';

    } else if (difference.inHours < 24) {

      return 'Il y a ${difference.inHours}h';

    } else if (difference.inDays < 7) {

      return 'Il y a ${difference.inDays}j';

    } else {

      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

    }

  }



  Color _getTypeColor(String type) {

    return const Color(0xFFE07B39);

  }



  @override

  Widget build(BuildContext context) {

    final r = _Responsive(context);

    final typeColor = _getTypeColor(request.subject);



    return GestureDetector(

      onTap: onTap,

      child: Container(

        padding: EdgeInsets.all(r.scale(16)),

        decoration: BoxDecoration(

          color: Colors.white,

          borderRadius: BorderRadius.circular(r.scale(28)),

          boxShadow: [

            BoxShadow(

              color: Colors.black.withValues(alpha: 0.04),

              blurRadius: r.scale(8),

              offset: const Offset(0, 2),

            ),

          ],

        ),

        child: Column(

          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            Row(

              mainAxisAlignment: MainAxisAlignment.spaceBetween,

              children: [

                Expanded(

                  child: Text(

                    request.userName,

                    style: AppTextStyles.listItemTitle.copyWith(

                      fontSize: r.fontSize(16),

                      fontWeight: FontWeight.w700,

                    ),

                    overflow: TextOverflow.ellipsis,

                  ),

                ),

                GestureDetector(

                  onTap: () => _confirmDelete(context),

                  child: Container(

                    padding: EdgeInsets.symmetric(horizontal: r.hp(8), vertical: r.vp(4)),

                    child: Icon(

                      Icons.close_rounded,

                      size: r.scale(16),

                      color: Colors.grey,

                    ),

                  ),

                ),

              ],

            ),

            SizedBox(height: r.vp(8)),

            Container(

              padding: EdgeInsets.symmetric(horizontal: r.hp(8), vertical: r.vp(4)),

              decoration: BoxDecoration(

                color: typeColor.withValues(alpha: 0.1),

                borderRadius: BorderRadius.circular(r.scale(12)),

              ),

              child: Text(

                request.subject,

                style: TextStyle(

                  fontFamily: AppFonts.plusJakarta,

                  fontSize: r.fontSize(11),

                  fontWeight: FontWeight.w600,

                  color: typeColor,

                ),

              ),

            ),

            SizedBox(height: r.vp(8)),

            Text(

              request.description,

              style: AppTextStyles.bodySmall.copyWith(

                fontSize: r.fontSize(12),

                height: 1.4,

                fontWeight: FontWeight.w400,

              ),

              maxLines: 2,

              overflow: TextOverflow.ellipsis,

            ),

            SizedBox(height: r.vp(12)),

            Row(

              children: [

                Icon(Icons.calendar_today_outlined,

                    size: r.scale(12), color: AppColors.textMuted),

                SizedBox(width: r.hp(6)),

                Text(

                  _formatDateTime(request.createdAt),

                  style: AppTextStyles.bodySmall.copyWith(

                    fontSize: r.fontSize(11),

                    color: AppColors.textMuted,

                  ),

                ),

              ],

            ),

          ],

        ),

      ),

    );

  }



  void _confirmDelete(BuildContext context) {

    final r = _Responsive(context);

    showDialog(

      context: context,

      builder: (context) => Dialog(

        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(r.scale(28))),

        backgroundColor: Colors.white,

        child: Container(

          padding: EdgeInsets.all(r.scale(24)),

          decoration: BoxDecoration(

            color: Colors.white,

            borderRadius: BorderRadius.circular(r.scale(28)),

          ),

          child: Column(

            mainAxisSize: MainAxisSize.min,

            children: [

              Text(

                'Supprimer la demande d\'aide ?',

                textAlign: TextAlign.center,

                style: AppTextStyles.listItemTitle.copyWith(

                  fontSize: r.fontSize(18), 

                  fontWeight: FontWeight.w700,

                ),

              ),

              SizedBox(height: r.vp(16)),

              Text(

                'Êtes-vous sûr de vouloir supprimer cette demande d\'aide ?',

                style: AppTextStyles.bodyMedium.copyWith(fontSize: r.fontSize(14)),

                textAlign: TextAlign.center,

              ),

              SizedBox(height: r.vp(8)),

              Container(

                padding: EdgeInsets.all(r.scale(12)),

                decoration: BoxDecoration(

                  color: const Color(0xFFFDF5E6),

                  borderRadius: BorderRadius.circular(r.scale(12)),

                ),

                child: Text(

                  '"${request.subject}"',

                  style: AppTextStyles.bodyMedium.copyWith(

                    fontWeight: FontWeight.w600,

                    color: AppColors.textPrimary,

                    fontSize: r.fontSize(14),

                  ),

                  textAlign: TextAlign.center,

                ),

              ),

              SizedBox(height: r.vp(8)),

              Text(

                'Cette action est irréversible.',

                style: AppTextStyles.bodySmall.copyWith(

                  color: AppColors.textMuted,

                  fontSize: r.fontSize(12),

                ),

                textAlign: TextAlign.center,

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

                      onPressed: () {

                        Navigator.pop(context);

                        onDelete();

                      },

                      style: TextButton.styleFrom(

                        padding: EdgeInsets.symmetric(vertical: r.vp(12)),

                        backgroundColor: Colors.red.withValues(alpha: 0.1),

                        shape: RoundedRectangleBorder(

                          borderRadius: BorderRadius.circular(r.scale(30)),

                        ),

                      ),

                      child: Text(

                        'Supprimer',

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

