import 'package:flutter/material.dart';
import 'core/core.dart';
import '../services/admin_service.dart';

class _Responsive {
  _Responsive(BuildContext context)
      : _size = MediaQuery.of(context).size,
        _textScale = MediaQuery.of(context).textScaler;

  final Size _size;
  final TextScaler _textScale;

  static const double _baseWidth = 390.0;
  static const double _baseHeight = 844.0;

  double get _widthRatio => (_size.width / _baseWidth).clamp(0.3, 1.4);
  double get _heightRatio => (_size.height / _baseHeight).clamp(0.3, 1.4);

  double scale(double value) => value * ((_widthRatio + _heightRatio) / 2);
  double hp(double value) => value * _widthRatio;
  double vp(double value) => value * _heightRatio;
  double fontSize(double value) => _textScale.scale(value * _widthRatio);
}

class UserDistributionPage extends StatefulWidget {
  const UserDistributionPage({super.key});

  @override
  State<UserDistributionPage> createState() => _UserDistributionPageState();
}

class _UserDistributionPageState extends State<UserDistributionPage> {
  final AdminService _adminService = AdminService();
  Map<String, dynamic>? _stats;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);
    try {
      final stats = await _adminService.getAdminStats();
      setState(() {
        _stats = stats;
        _isLoading = false;
      });
    } catch (e) {
      print(' Backend error, using zeros for user distribution stats');
      setState(() {
        _stats = _getZeroStats();
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Map<String, dynamic> _getZeroStats() {
    return {
      'totalUsers': 0,
      'totalClients': 0,
      'totalMerchants': 0,
      'suspendedClients': 0,
      'suspendedCommercants': 0,
    };
  }

  @override
  Widget build(BuildContext context) {
    final r = _Responsive(context);
    
    if (_isLoading) {
      return StatsDetailScaffold(
        title: '',
        body: Center(child: CircularProgressIndicator(color: const Color(0xFFE07B39))),
      );
    }
    
    if (_error != null) {
      return StatsDetailScaffold(
        title: '',
        body: Center(
          child: Text(
            'Erreur: $_error',
            style: TextStyle(color: Colors.red, fontSize: r.fontSize(16)),
          ),
        ),
      );
    }
    
    return StatsDetailScaffold(
      title: '',
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMainStatsCard(context),
              SizedBox(height: r.vp(20)),
              _buildGrowthAndEngagementRow(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainStatsCard(BuildContext context) {
    final r = _Responsive(context);

    final totalUsers = _stats?['totalUsers'] ?? 0;
    final totalClients = _stats?['totalClients'] ?? 0;
    final totalMerchants = _stats?['totalMerchants'] ?? 0;
    
    final activeUsers = totalClients + totalMerchants;
    final clientPercentage = activeUsers > 0 ? (totalClients / activeUsers) * 100 : 0;
    final merchantPercentage = activeUsers > 0 ? (totalMerchants / activeUsers) * 100 : 0;
    
    final List<PieSection> sections = [
      PieSection(percentage: clientPercentage, color: const Color(0xFFCCD5AE), label: 'Clients', value: totalClients.toString()),
      PieSection(percentage: merchantPercentage, color: const Color(0xFFF8B068), label: 'Commerçants', value: totalMerchants.toString()),
    ];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: r.hp(20),
        vertical: r.vp(20),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(r.scale(32)),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentBrown.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Répartition des utilisateurs',
            style: AppTextStyles.pageTitle.copyWith(
              fontSize: r.fontSize(22),
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: r.vp(6)),
          Text(
            'Total: $totalUsers comptes',
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: r.fontSize(13),
              color: AppColors.textSecondary,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          SizedBox(height: r.vp(20)),
          _buildPieChart(context, sections),
          SizedBox(height: r.vp(20)),
          _buildLegendInfo(context, sections),
        ],
      ),
    );
  }

  Widget _buildPieChart(BuildContext context, List<PieSection> sections) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final chartSize = constraints.maxWidth * 0.75;
        return Center(
          child: SizedBox(
            width: chartSize,
            height: chartSize,
            child: CustomPaint(
              painter: PieChartPainter(sections: sections),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLegendInfo(BuildContext context, List<PieSection> sections) {
    final r = _Responsive(context);
    return Column(
      children: sections.map((section) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: r.vp(5)),
          child: Row(
            children: [
              Container(
                width: r.scale(12),
                height: r.scale(12),
                decoration: BoxDecoration(
                  color: section.color,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: r.hp(10)),
              Expanded(
                flex: 3,
                child: Text(
                  section.label,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: r.fontSize(13),
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              SizedBox(width: r.hp(6)),
              Text(
                section.value,
                style: AppTextStyles.statValue.copyWith(
                  fontSize: r.fontSize(14),
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(width: r.hp(6)),
              Text(
                '(${section.percentage.toStringAsFixed(1)}%)',
                style: AppTextStyles.bodySmall.copyWith(
                  fontSize: r.fontSize(11),
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildGrowthAndEngagementRow(BuildContext context) {
    final r = _Responsive(context);

    final suspendedClients = _stats?['suspendedClients'] ?? 0;
    final suspendedCommercants = _stats?['suspendedCommercants'] ?? 0;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: r.hp(14),
                vertical: r.vp(16),
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(r.scale(28)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accentBrown.withOpacity(0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'CLIENTS SUSPENDUS',
                    style: AppTextStyles.sectionLabel.copyWith(
                      fontSize: r.fontSize(8),
                      letterSpacing: 0.8,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  SizedBox(height: r.vp(6)),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      suspendedClients.toString(),
                      style: AppTextStyles.statValue.copyWith(
                        fontSize: r.fontSize(36),
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFFE07B39),
                      ),
                    ),
                  ),
                  SizedBox(height: r.vp(4)),
                  Text(
                    'utilisateurs',
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: r.fontSize(10),
                      color: AppColors.textMuted,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: r.hp(10)),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: r.hp(14),
                vertical: r.vp(16),
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(r.scale(28)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accentBrown.withOpacity(0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'COMMERÇANTS SUSPENDUS',
                    style: AppTextStyles.sectionLabel.copyWith(
                      fontSize: r.fontSize(8),
                      letterSpacing: 0.8,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  SizedBox(height: r.vp(6)),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      suspendedCommercants.toString(),
                      style: AppTextStyles.statValue.copyWith(
                        fontSize: r.fontSize(36),
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFFE07B39),
                      ),
                    ),
                  ),
                  SizedBox(height: r.vp(4)),
                  Text(
                    'utilisateurs',
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: r.fontSize(10),
                      color: AppColors.textMuted,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PieSection {
  final double percentage;
  final Color color;
  final String label;
  final String value;

  const PieSection({
    required this.percentage,
    required this.color,
    required this.label,
    required this.value,
  });
}

class PieChartPainter extends CustomPainter {
  final List<PieSection> sections;

  const PieChartPainter({required this.sections});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final paint = Paint()..style = PaintingStyle.fill;

    double startAngle = -90 * (3.14159 / 180);

    for (final section in sections) {
      final sweepAngle = (section.percentage / 100) * 2 * 3.14159;
      paint.color = section.color;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
