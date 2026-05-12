import 'package:flutter/material.dart';
import 'core/core.dart';
import 'clients_page.dart';
import 'commercants_page.dart';
import 'help_requests_page.dart';
import 'package:peeco/core/pages/role_selection_page.dart';
import '../services/admin_service.dart';
import '../services/stats_service.dart';
import '../models/stats_model.dart';
import '../../services/app_report_service.dart';
import '../../models/app_report.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  final AdminService _adminService = AdminService();
  final StatsService _statsService = StatsService();
  final AppReportService _appReportService = AppReportService();
  AdminStats? _adminStats;
  bool _isLoadingStats = true;
  String? _statsError;
  int _pendingMerchants = 0;
  int _pendingHelpRequests = 0;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoadingStats = true);
    try {
      final stats = await _statsService.getAdminStats();
      
      debugPrint(' Getting pending merchants from API...');
      final pendingMerchantsList = await _adminService.getMerchants(statut: 'En attente');
      debugPrint(' Pending merchants API response: ${pendingMerchantsList.length} merchants found');
      
      debugPrint(' Getting open help requests from API...');
      final allReports = await _appReportService.getAdminReports();
      final openReports = allReports.where((report) => report.status == AppReportStatus.open).toList();
      debugPrint(' Open help requests API response: ${openReports.length} requests found');
      
      setState(() {
        _adminStats = stats;
        _pendingMerchants = pendingMerchantsList.length;
        _pendingHelpRequests = openReports.length;
        _isLoadingStats = false;
        debugPrint(' Stats loaded: pendingMerchants=$_pendingMerchants, pendingHelpRequests=$_pendingHelpRequests');
      });
    } catch (e) {
      debugPrint(' Backend error, using zeros for all stats: $e');
      setState(() {
        _adminStats = null;
        _statsError = e.toString();
        _pendingMerchants = 0;
        _pendingHelpRequests = 0;
        _isLoadingStats = false;
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
              _DashboardAppBar(),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: r.hp(20)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: r.vp(30)),
                      _StatsGrid(adminStats: _adminStats, isLoading: _isLoadingStats),
                      SizedBox(height: r.vp(24)),
                      _QuickAccessButton(
  pendingMerchants: _pendingMerchants,
  pendingHelpRequests: _pendingHelpRequests,
),
                      SizedBox(height: r.vp(10)),
                      Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  'STATISTIQUES & ANALYSES',
                  style: TextStyle(
                    fontFamily: AppFonts.plusJakarta,
                    fontSize: r.fontSize(12),
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF666666), 
                    letterSpacing: 1.2,
                  ),
                ),
              ),
                      _StatsList(),
                      SizedBox(height: r.vp(100)),
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

class _DashboardAppBar extends StatefulWidget {
  @override
  State<_DashboardAppBar> createState() => _DashboardAppBarState();
}

class _DashboardAppBarState extends State<_DashboardAppBar>
    with SingleTickerProviderStateMixin {
  final GlobalKey _menuButtonKey = GlobalKey();
  OverlayEntry? _overlayEntry;

  late final AnimationController _animController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 220),
  );

  late final Animation<double> _scaleAnim = CurvedAnimation(
    parent: _animController,
    curve: Curves.easeOutBack,
  );

  late final Animation<double> _fadeAnim = CurvedAnimation(
    parent: _animController,
    curve: Curves.easeOut,
  );

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _showMenu() {
    final r = _Responsive(context);
    final RenderBox renderBox =
        _menuButtonKey.currentContext!.findRenderObject() as RenderBox;
    final Offset offset = renderBox.localToGlobal(Offset.zero);
    final Size buttonSize = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return GestureDetector(
          onTap: _hideMenu,
          behavior: HitTestBehavior.opaque,
          child: Stack(
            children: [
              Positioned.fill(child: Container(color: Colors.transparent)),
              Positioned(
                top: offset.dy + buttonSize.height + r.vp(4),
                right: MediaQuery.of(context).size.width -
                    (offset.dx + buttonSize.width),
                child: GestureDetector(
                  onTap: () {},
                  child: FadeTransition(
                    opacity: _fadeAnim,
                    child: ScaleTransition(
                      scale: _scaleAnim,
                      alignment: Alignment.topRight,
                      child: Material(
                        color: Colors.transparent,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              vertical: r.vp(12), horizontal: r.hp(12)),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFDF8F0),
                            borderRadius: BorderRadius.circular(r.scale(40)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: r.scale(20),
                                spreadRadius: r.scale(2),
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _menuItem(
                                icon: Icons.people_outline_rounded,
                                iconColor: const Color(0xFF2D2D2D),
                                bgColor: const Color(0xFFCCD5AE),
                                onTap: () {
                                  _hideMenu();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => const ClientsPage()),
                                  );
                                },
                              ),
                              SizedBox(height: r.vp(12)),
                              _menuItem(
                                icon: Icons.storefront_outlined,
                                iconColor: const Color(0xFF2D2D2D),
                                bgColor: const Color(0xFFFAEDCD),
                                onTap: () {
                                  _hideMenu();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) =>
                                            const CommercantsPage()),
                                  );
                                },
                              ),
                              SizedBox(height: r.vp(12)),
                              _menuItem(
                                icon: Icons.support_agent_rounded,
                                iconColor: const Color(0xFF5C4A2A),
                                bgColor: const Color(0xFFE8DEC8),
                                onTap: () {
                                  _hideMenu();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => const HelpRequestsPage()),
                                  );
                                },
                              ),
                              SizedBox(height: r.vp(12)),
                              _menuItem(
                                icon: Icons.logout_rounded,
                                iconColor: const Color(0xFFE07B39),
                                bgColor:
                                    const Color(0xFFE07B39).withValues(alpha: 0.15),
                                onTap: () {
                                  _hideMenu();
                                  _showLogoutConfirmation();
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

    Overlay.of(context).insert(_overlayEntry!);
    _animController.forward(from: 0);
    setState(() {});
  }

  Future<void> _hideMenu() async {
    await _animController.reverse();
    _overlayEntry?.remove();
    _overlayEntry = null;
    if (mounted) setState(() {});
  }

  Future<void> _showLogoutConfirmation() async {
    final r = _Responsive(context);
    final result = await showDialog<bool>(
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
              Container(
                width: r.scale(60),
                height: r.scale(60),
                decoration: BoxDecoration(
                  color: const Color(0xFFE07B39).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.logout_rounded,
                  size: r.scale(30),
                  color: const Color(0xFFE07B39),
                ),
              ),
              SizedBox(height: r.vp(20)),
              Text(
                'Se déconnecter',
                style: TextStyle(
                  fontFamily: AppFonts.plusJakarta,
                  fontSize: r.fontSize(18),
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: r.vp(12)),
              Text(
                'Êtes-vous sûr de vouloir vous déconnecter ?',
                style: TextStyle(
                  fontFamily: AppFonts.plusJakarta,
                  fontSize: r.fontSize(14),
                  color: AppColors.textSecondary,
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
                      onPressed: () => Navigator.pop(context, true),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: r.vp(12)),
                        backgroundColor: const Color(0xFFE07B39),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(r.scale(30)),
                        ),
                      ),
                      child: Text(
                        'Se déconnecter',
                        style: TextStyle(
                          fontFamily: AppFonts.plusJakarta,
                          fontSize: r.fontSize(14),
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
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
    
    if (result == true && mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const ChoicePage()),
        (route) => false,
      );
    }
  }

  Widget _menuItem({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    final r = _Responsive(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(r.scale(30)),
      child: Container(
        width: r.scale(44),
        height: r.scale(44),
        decoration: BoxDecoration(
          color: bgColor,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: r.scale(28), color: iconColor),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final r = _Responsive(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(r.hp(20), r.vp(20), r.hp(20), r.vp(4)),
      child: Row(
        children: [
          Expanded(
            child: Text('Tableau de bord', 
              style: AppTextStyles.pageTitle.copyWith(fontSize: r.fontSize(28))),
          ),
          GestureDetector(
            key: _menuButtonKey,
            onTap: () {
              if (_overlayEntry == null) {
                _showMenu();
              } else {
                _hideMenu();
              }
            },
            child: Container(
              padding: EdgeInsets.fromLTRB(r.hp(8), r.vp(10), r.hp(18), r.vp(8)),
              child: Icon(
                Icons.menu,
                size: r.scale(30),
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  final AdminStats? adminStats;
  final bool isLoading;
  
  const _StatsGrid({this.adminStats, this.isLoading = true});

  @override
  Widget build(BuildContext context) {
    final r = _Responsive(context);
    
    if (isLoading) {
      return Center(child: CircularProgressIndicator(color: const Color(0xFFE07B39)));
    }
    
    final totalUsers = adminStats?.totalUsers ?? 0;
    final totalMerchants = adminStats?.totalMerchants ?? 0;
    final suspendedCommercants = adminStats?.suspendedCommercants ?? 0;
    final totalClients = adminStats?.totalClients ?? 0;
    final suspendedClients = adminStats?.suspendedClients ?? 0;
    final newUsersThisWeek = adminStats?.newUsersThisWeek ?? 0;
    final totalReservations = adminStats?.totalReservations ?? 0;
    final totalAnnulations = adminStats?.totalAnnulations ?? 0;
    
    final items = [
      _StatData('UTILISATEURS', totalUsers.toString(), '$newUsersThisWeek cette semaine', Icons.trending_up_rounded, true),
      _StatData('COMMERÇANTS', totalMerchants.toString(), '$suspendedCommercants suspendus', Icons.storefront_outlined, false),
      _StatData('CLIENTS', totalClients.toString(), '$suspendedClients suspendus', Icons.people_outline_rounded, false),
      _StatData('RÉSERVATIONS', totalReservations.toString(), '$totalAnnulations annulations', Icons.calendar_today_outlined, true),
    ];
    
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = (constraints.maxWidth - r.hp(12)) / 2;
        return Wrap(
          spacing: r.hp(12),
          runSpacing: r.vp(12),
          children: items
              .map((d) => SizedBox(width: w, child: _StatCard(data: d)))
              .toList(),
        );
      },
    );
  }
}

class _StatData {
  const _StatData(
      this.label, this.value, this.delta, this.icon, this.isGreenCard);
  final String label;
  final String value;
  final String delta;
  final IconData icon;
  final bool isGreenCard;
}

class _StatCard extends StatefulWidget {
  const _StatCard({required this.data});
  final _StatData data;

  @override
  State<_StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<_StatCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  int _displayValue = 0;

  @override
  void initState() {
    super.initState();
    final targetValue = int.parse(widget.data.value.replaceAll(' ', ''));

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );

    _animation.addListener(() {
      setState(() {
        _displayValue = (targetValue * _animation.value).round();
      });
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = _Responsive(context);
    final cardColor = widget.data.isGreenCard
        ? const Color(0xFFA8C88A)
        : const Color(0xFFF8B068);

    final iconColor = widget.data.isGreenCard
        ? const Color.fromARGB(255, 141, 168, 115)
        : const Color(0xFFF8B068);

    final textColor = widget.data.isGreenCard
        ? const Color.fromARGB(255, 141, 168, 115)
        : const Color(0xFFF8B068);

    final backgroundColor = widget.data.isGreenCard
        ? const Color(0xFFEDF5E5)
        : const Color(0xFFFDF5E6);

    final formattedValue = _formatNumber(_displayValue);

    return Container(
      padding: EdgeInsets.fromLTRB(r.hp(16), r.vp(21), r.hp(16), r.vp(21)),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 251, 251, 251),
        borderRadius: BorderRadius.circular(r.scale(30)),
        boxShadow: [
          BoxShadow(
            color: cardColor.withValues(alpha: 0.5),
            blurRadius: 0,
            spreadRadius: 0,
            offset: const Offset(0, -4),
          ),
          BoxShadow(
            color: AppColors.accentBrown.withValues(alpha: 0.06),
            blurRadius: r.scale(12),
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              widget.data.label,
              style: AppTextStyles.statLabel.copyWith(
                fontSize: r.fontSize(10),
                fontWeight: FontWeight.w700,
                color: AppColors.textMuted,
              ),
            ),
          ),
          SizedBox(height: r.vp(6)),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              formattedValue,
              style: AppTextStyles.statValue.copyWith(
                fontSize: r.fontSize(28),
                color: const Color.fromARGB(255, 60, 60, 60),
              ),
            ),
          ),
          SizedBox(height: r.vp(6)),
          Container(
            padding: EdgeInsets.symmetric(horizontal: r.hp(10), vertical: r.vp(6)),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(r.scale(20)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(widget.data.icon, size: r.scale(14), color: iconColor),
                SizedBox(width: r.hp(5)),
                Flexible(
                  child: Text(
                    widget.data.delta,
                    style: AppTextStyles.statDelta.copyWith(
                      fontSize: r.fontSize(11),
                      color: textColor
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000) {
      final thousands = (number / 1000).floor();
      final remainder = number % 1000;
      if (remainder == 0) {
        return '$thousands';
      }
      return '$thousands ${remainder.toString().padLeft(3, '0')}';
    }
    return number.toString();
  }
}

class _StatsList extends StatelessWidget {
  static const _items = [
    _NavItem(Icons.pie_chart_outline, 'Répartition utilisateurs',
        AdminRouter.userDistribution, true),
    _NavItem(Icons.filter_list, 'Commerçants par catégorie',
        AdminRouter.merchantsByCategory, false),
    _NavItem(Icons.stacked_line_chart, 'Évolution inscriptions',
        AdminRouter.registrationEvolution, true),
    _NavItem(Icons.ssid_chart, 'Réservations par jour',
        AdminRouter.reservationsPerDay, false),
    _NavItem(Icons.bar_chart, 'Performance offres',
        AdminRouter.offerPerformance, true),
  ];

  @override
  Widget build(BuildContext context) {
    final r = _Responsive(context);
    return Column(
      children: _items.asMap().entries.map((entry) {
        final item = entry.value;
        return Padding(
          padding: EdgeInsets.only(bottom: r.vp(10)),
          child: _StatsNavTile(item: item, isGreenCard: item.isGreenCard),
        );
      }).toList(),
    );
  }
}

class _NavItem {
  const _NavItem(this.icon, this.label, this.route, this.isGreenCard);
  final IconData icon;
  final String label;
  final String route;
  final bool isGreenCard;
}

class _StatsNavTile extends StatelessWidget {
  const _StatsNavTile({required this.item, required this.isGreenCard});
  final _NavItem item;
  final bool isGreenCard;

  @override
  Widget build(BuildContext context) {
    final r = _Responsive(context);
    final iconColor =
        isGreenCard ? const Color(0xFFA8C88A) : const Color(0xFFF8B068);

    final backgroundColor =
        isGreenCard ? const Color(0xFFEDF5E5) : const Color(0xFFFDF5E6);

    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, item.route),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: r.hp(18), vertical: r.vp(16)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(r.scale(30)),
          boxShadow: [
            BoxShadow(
              color: AppColors.accentBrown.withValues(alpha: 0.05),
              blurRadius: r.scale(8),
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: r.scale(40),
              height: r.scale(40),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(r.scale(30)),
              ),
              child: Icon(item.icon, size: r.scale(20), color: iconColor),
            ),
            SizedBox(width: r.hp(14)),
            Expanded(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  item.label,
                  style: AppTextStyles.listItemTitle.copyWith(
                    fontSize: r.fontSize(15),
                    fontWeight: FontWeight.w500,
                    color: const Color.fromARGB(255, 0, 0, 0),
                  ),
                ),
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: AppColors.textMuted, size: r.scale(20)),
          ],
        ),
      ),
    );
  }
}

class _QuickAccessButton extends StatelessWidget {
  final int pendingMerchants;
  final int pendingHelpRequests;
  
  const _QuickAccessButton({
    this.pendingMerchants = 0,
    this.pendingHelpRequests = 0,
  });

  int _getTotalPending() {
    return pendingMerchants + pendingHelpRequests;
  }

  @override
  Widget build(BuildContext context) {
    final r = _Responsive(context);
    
    final totalPending = _getTotalPending();

    return GestureDetector(
      onTap: () => _showQuickAccessMenu(context, r),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(r.hp(16), r.vp(12), r.hp(16), r.vp(12)),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 251, 251, 251),
          borderRadius: BorderRadius.circular(r.scale(30)),
          boxShadow: [
            BoxShadow(
              color: AppColors.accentBrown.withValues(alpha: 0.06),
              blurRadius: r.scale(12),
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'ACCÈS RAPIDE AU DEMANDES',
                style: AppTextStyles.statLabel.copyWith(
                  fontSize: r.fontSize(10),
                  fontWeight: FontWeight.w700,
                  color: AppColors.textMuted,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Flexible(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: r.hp(10), vertical: r.vp(5)),
                decoration: BoxDecoration(
                  color: const Color(0xFFEDF5E5),
                  borderRadius: BorderRadius.circular(r.scale(16)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$totalPending',
                      style: TextStyle(
                        fontFamily: AppFonts.plusJakarta,
                        fontSize: r.fontSize(10),
                        fontWeight: FontWeight.w600,
                        color: const Color.fromARGB(255, 141, 168, 115),
                      ),
                    ),
                    SizedBox(width: r.hp(3)),
                    Icon(
                      Icons.arrow_outward_rounded,
                      size: r.scale(10),
                      color: const Color.fromARGB(255, 141, 168, 115),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showQuickAccessMenu(BuildContext context, _Responsive r) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(r.scale(30)),
            topRight: Radius.circular(r.scale(30)),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: r.scale(40),
              height: r.scale(4),
              margin: EdgeInsets.only(top: r.vp(12)),
              decoration: BoxDecoration(
                color: const Color(0xFFE0E0E0),
                borderRadius: BorderRadius.circular(r.scale(2)),
              ),
            ),
            SizedBox(height: r.vp(24)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: r.hp(20)),
              child: Column(
                children: [
                  _MenuOption(
                    icon: Icons.support_agent_rounded,
                    title: 'Demandes d\'aide',
                    isGreen: true, 
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const HelpRequestsPage()),
                      );
                    },
                  ),
                  SizedBox(height: r.vp(16)),
                  _MenuOption(
                    icon: Icons.storefront_outlined,
                    title: 'Commerçants en attente',
                    isGreen: false, 
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CommercantsPage(initialFilter: 'En attente')),
                      );
                    },
                  ),
                  SizedBox(height: r.vp(24)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuOption extends StatelessWidget {
  const _MenuOption({
    required this.icon,
    required this.title,
    required this.onTap,
    required this.isGreen,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isGreen;

  @override
  Widget build(BuildContext context) {
    final r = _Responsive(context);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(r.scale(16)),
        decoration: BoxDecoration(
          color: const Color(0xFFF9F9F9),
          borderRadius: BorderRadius.circular(r.scale(30)), 
        ),
        child: Row(
          children: [
            Container(
              width: r.scale(40),
              height: r.scale(40),
              decoration: BoxDecoration(
                color: isGreen 
                    ? const Color(0xFFA8C88A).withValues(alpha: 0.15) 
                    : const Color(0xFFF8B068).withValues(alpha: 0.15), 
                borderRadius: BorderRadius.circular(r.scale(12)),
              ),
              child: Icon(
                icon,
                size: r.scale(20),
                color: isGreen 
                    ? const Color(0xFFA8C88A) 
                    : const Color(0xFFF8B068), 
              ),
            ),
            SizedBox(width: r.hp(16)),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontFamily: AppFonts.plusJakarta,
                  fontSize: r.fontSize(16),
                  fontWeight: FontWeight.w500, 
                  color: const Color(0xFF666666), 
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: r.scale(20),
              color: const Color(0xFFAAAAAA),
            ),
          ],
        ),
      ),
    );
  }
}
