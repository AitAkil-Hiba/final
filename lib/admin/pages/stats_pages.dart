import 'package:flutter/material.dart';
import 'core/core.dart';
import '../services/stats_service.dart';
import '../models/stats_model.dart';

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


class RegistrationEvolutionPage extends StatefulWidget {
  const RegistrationEvolutionPage({super.key});

  @override
  State<RegistrationEvolutionPage> createState() =>
      _RegistrationEvolutionPageState();
}

class _RegistrationEvolutionPageState
    extends State<RegistrationEvolutionPage> {
  String _selectedPeriod = 'month';
  final StatsService _statsService = StatsService();
  
  RegistrationStats? _registrationStats;
  bool _isLoading = true;
  String? _error;

  final DateTime _currentDate = DateTime.now();

  final List<String> _allMonths = [
    'Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Juin',
    'Juil', 'Août', 'Sept', 'Oct', 'Nov', 'Déc'
  ];

  @override
  void initState() {
    super.initState();
    _loadRegistrationStats();
  }

  Future<void> _loadRegistrationStats() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final stats = await _statsService.getRegistrationStats();
      setState(() {
        _registrationStats = stats;
        _isLoading = false;
      });
    } catch (e) {
      print(' Error loading registration stats: $e');
      setState(() {
        _registrationStats = _getMockRegistrationStats();
        _error = null; 
        _isLoading = false;
      });
    }
  }

  RegistrationStats _getMockRegistrationStats() {
    final now = DateTime.now();
    final dailyData = List.generate(now.day, (index) {
      final day = index + 1;
      final count = 5 + (day * 3) % 25 + (day % 7);
      return DailyData(date: '${now.year}-${now.month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}', count: count);
    });
    
    final monthlyData = List.generate(now.month, (index) {
      final month = index + 1;
      final count = 245 + (month * 15) + (month % 3) * 8;
      return MonthlyData(month: month.toString(), count: count);
    });
    
    return RegistrationStats(daily: dailyData, monthly: monthlyData);
  }

  List<String> get _days {
    if (_registrationStats?.daily.isNotEmpty == true) {
      return _registrationStats!.daily.map((data) {
        try {
          final date = DateTime.parse(data.date);
          return '${date.day}';
        } catch (e) {
          print(' Date parsing error for daily data: ${data.date}, error: $e');
          return '--';
        }
      }).toList();
    }
    return List.generate(_currentDate.day, (index) => '${index + 1}');
  }

  List<int> get _dailyData {
    if (_registrationStats?.daily.isNotEmpty == true) {
      return _registrationStats!.daily.map((data) => data.count).toList();
    }
    return List.generate(_currentDate.day, (index) {
      return 5 + (index * 3) % 25 + (index % 7);
    });
  }

  List<String> get _months {
    if (_registrationStats?.monthly.isNotEmpty == true) {
      return _registrationStats!.monthly.map((data) {
        try {
          String monthStr = data.month.toString().trim();
          
          if (monthStr.isEmpty) {
            return 'Jan';
          }
          
         
          int? month = int.tryParse(monthStr);
          if (month != null && month >= 1 && month <= 12) {
            return _allMonths[month - 1];
          }
          
         
          if (monthStr.length == 2 && monthStr.startsWith('0')) {
            month = int.tryParse(monthStr.substring(1));
            if (month != null && month >= 1 && month <= 9) {
              return _allMonths[month - 1];
            }
          }
          
          if (monthStr.contains('-')) {
            final parts = monthStr.split('-');
            for (final part in parts) {
              month = int.tryParse(part);
              if (month != null && month >= 1 && month <= 12) {
                return _allMonths[month - 1];
              }
            }
          }
          
          print(' Could not parse month: "$monthStr", using fallback');
          return 'Jan';
        } catch (e) {
          print(' Date parsing error for monthly data: ${data.month}, error: $e');
          return 'Jan';
        }
      }).toList();
    }
    return _allMonths.sublist(0, _currentDate.month);
  }

  List<int> get _monthlyData {
    if (_registrationStats?.monthly.isNotEmpty == true) {
      return _registrationStats!.monthly.map((data) => data.count).toList();
    }
    final List<int> fullYearData = [
      245, 278, 312, 298, 356, 389, 412, 445, 478, 512, 534, 568
    ];
    return fullYearData.sublist(0, _currentDate.month);
  }

  @override
  Widget build(BuildContext context) {
    final r = _Responsive(context);
    return StatsDetailScaffold(
      title: '',
      body: _isLoading 
        ? Center(child: CircularProgressIndicator(color: AppColors.accentBrown))
        : _error != null
          ? Center(
              child: Padding(
                padding: EdgeInsets.all(r.scale(20)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: r.scale(48), color: Colors.red),
                    SizedBox(height: r.vp(16)),
                    Text(
                      'Erreur de chargement',
                      style: AppTextStyles.pageTitle.copyWith(
                        fontSize: r.fontSize(18),
                        color: Colors.red,
                      ),
                    ),
                    SizedBox(height: r.vp(8)),
                    Text(
                      _error!,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontSize: r.fontSize(14),
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: r.vp(16)),
                    ElevatedButton(
                      onPressed: _loadRegistrationStats,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentBrown,
                        foregroundColor: Colors.white,
                      ),
                      child: Text('Réessayer'),
                    ),
                  ],
                ),
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildMainStatsCard(context),
                SizedBox(height: r.vp(32)),
                _buildMetricsRow(context),
                SizedBox(height: r.vp(20)),
              ],
            ),
    );
  }

  String _getSubtitle() {
    if (_selectedPeriod == 'month') {
      final currentDay = _currentDate.day;
      final currentMonth = _getMonthName(_currentDate.month - 1);
      return 'Du 1er au $currentDay $currentMonth';
    } else {
      final currentMonth = _getMonthName(_currentDate.month - 1);
      return 'Croissance du Janvier au $currentMonth ${_currentDate.year}';
    }
  }

  String _getMonthName(int index) {
    const months = [
      'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
      'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'
    ];
    return months[index];
  }

  Widget _buildMainStatsCard(BuildContext context) {
    final r = _Responsive(context);
    final labels = _selectedPeriod == 'month' ? _days : _months;
    final dataPoints = _selectedPeriod == 'month' ? _dailyData : _monthlyData;
    final subtitle = _getSubtitle();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(r.scale(24)),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  'Évolution des inscriptions',
                  style: AppTextStyles.pageTitle.copyWith(
                    fontSize: r.fontSize(22),
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                    height: 1.3,
                  ),
                ),
              ),
              SizedBox(width: r.hp(12)),
              _buildSegmentedToggle(context),
            ],
          ),
          SizedBox(height: r.vp(16)),
          Text(
            subtitle,
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: r.fontSize(14),
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: r.vp(32)),
          _buildLineChart(context, labels, dataPoints),
        ],
      ),
    );
  }

  Widget _buildSegmentedToggle(BuildContext context) {
    final r = _Responsive(context);
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(r.scale(40)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildToggleOption(context, 'Mois', 'month'),
          _buildToggleOption(context, 'Année', 'year'),
        ],
      ),
    );
  }

  Widget _buildToggleOption(
      BuildContext context, String label, String period) {
    final r = _Responsive(context);
    final isSelected = _selectedPeriod == period;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPeriod = period;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(
            horizontal: r.hp(20), vertical: r.vp(10)),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(r.scale(32)),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: AppFonts.plusJakarta,
            fontSize: r.fontSize(13),
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildLineChart(
      BuildContext context, List<String> labels, List<int> dataPoints) {
    final r = _Responsive(context);

    if (dataPoints.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(r.scale(40)),
          child: const Text('Aucune donnée disponible'),
        ),
      );
    }

    final maxValue = dataPoints.reduce((a, b) => a > b ? a : b).toDouble();
    final chartHeight = r.vp(280);
    final roundedMax = ((maxValue / 50).ceil() * 50).toDouble();
    final midValue = roundedMax / 2;

    return Column(
      children: [
        SizedBox(
          height: chartHeight,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: r.hp(45),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${roundedMax.toInt()}',
                      style: AppTextStyles.chartLabel.copyWith(
                          fontSize: r.fontSize(11),
                          fontWeight: FontWeight.w600),
                    ),
                    Text(
                      '${midValue.toInt()}',
                      style: AppTextStyles.chartLabel
                          .copyWith(fontSize: r.fontSize(11)),
                    ),
                    Text(
                      '0',
                      style: AppTextStyles.chartLabel.copyWith(
                          fontSize: r.fontSize(11),
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              SizedBox(width: r.hp(10)),
              Expanded(
                child: CustomPaint(
                  painter: LineChartPainter(
                    dataPoints: dataPoints,
                    maxValue: roundedMax,
                    minValue: 0,
                    lineColor: const Color(0xFFF8B068),
                    areaColor: const Color(0xFFF8B068).withOpacity(0.15),
                    isFillArea: true,
                  ),
                  size: Size(double.infinity, chartHeight),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: r.vp(12)),
        Padding(
          padding: EdgeInsets.only(left: r.hp(45) + r.hp(10)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _getVisibleLabels(labels).map((label) {
              return Text(
                label,
                style: AppTextStyles.chartLabel.copyWith(fontSize: r.fontSize(10)),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  List<String> _getVisibleLabels(List<String> labels) {
    if (labels.length <= 12) return labels;
    return labels
        .asMap()
        .entries
        .where((entry) =>
            entry.key % 3 == 0 || entry.key == labels.length - 1)
        .map((entry) => entry.value)
        .toList();
  }

  Widget _buildMetricsRow(BuildContext context) {
    final r = _Responsive(context);
    
    int newInscriptions = 0;
    double growthRate = 0.0;
    
    if (_registrationStats != null) {
      if (_selectedPeriod == 'month' && _registrationStats!.daily.isNotEmpty) {
        newInscriptions = _registrationStats!.daily
            .map((data) => data.count)
            .fold(0, (sum, count) => sum + count);
        
        if (_registrationStats!.monthly.length >= 2) {
          final currentMonth = _registrationStats!.monthly.last.count;
          final previousMonth = _registrationStats!.monthly[_registrationStats!.monthly.length - 2].count;
          if (previousMonth > 0) {
            growthRate = ((currentMonth - previousMonth) / previousMonth) * 100;
          }
        }
      } else if (_registrationStats!.monthly.isNotEmpty) {
        newInscriptions = _registrationStats!.monthly
            .map((data) => data.count)
            .fold(0, (sum, count) => sum + count);
        
        if (_registrationStats!.monthly.length >= 2) {
          final currentMonth = _registrationStats!.monthly.last.count;
          final previousMonth = _registrationStats!.monthly[_registrationStats!.monthly.length - 2].count;
          if (previousMonth > 0) {
            growthRate = ((currentMonth - previousMonth) / previousMonth) * 100;
          }
        }
      }
    } else {
      newInscriptions = _selectedPeriod == 'month' ? 248 : 568;
      growthRate = _selectedPeriod == 'month' ? 12.5 : 18.2;
    }
    
    final periodText =
        _selectedPeriod == 'month' ? 'ce mois' : 'cette année';
    final vsText = _selectedPeriod == 'month'
        ? 'vs mois précédent'
        : 'vs année précédente';

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.all(r.scale(16)),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(r.scale(24)),
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
                    'NOUVEAUX INSCRITS',
                    style: AppTextStyles.sectionLabel.copyWith(
                      fontSize: r.fontSize(10),
                      letterSpacing: 1,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  SizedBox(height: r.vp(6)),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '+$newInscriptions',
                      style: AppTextStyles.statValue.copyWith(
                        fontSize: r.fontSize(28),
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFFF8B068),
                      ),
                    ),
                  ),
                  SizedBox(height: r.vp(6)),
                  Text(
                    periodText,
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: r.fontSize(11),
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: r.hp(12)),
          Expanded(
            child: Container(
              padding: EdgeInsets.all(r.scale(16)),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(r.scale(24)),
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
                    'CROISSANCE',
                    style: AppTextStyles.sectionLabel.copyWith(
                      fontSize: r.fontSize(10),
                      letterSpacing: 1,
                    ),
                  ),
                  SizedBox(height: r.vp(6)),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '+$growthRate',
                          style: AppTextStyles.statValue.copyWith(
                            fontSize: r.fontSize(28),
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFFF8B068),
                          ),
                        ),
                        Text(
                          '%',
                          style: AppTextStyles.statValue.copyWith(
                            fontSize: r.fontSize(20),
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFFF8B068),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: r.vp(6)),
                  Text(
                    vsText,
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: r.fontSize(11),
                      color: AppColors.textMuted,
                    ),
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


class ReservationsPerDayPage extends StatefulWidget {
  const ReservationsPerDayPage({super.key});

  @override
  State<ReservationsPerDayPage> createState() => _ReservationsPerDayPageState();
}

class _ReservationsPerDayPageState extends State<ReservationsPerDayPage> {
  final StatsService _statsService = StatsService();
  ReservationStats? _reservationStats;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadReservationStats();
  }

  Future<void> _loadReservationStats() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final stats = await _statsService.getReservationStats();
      setState(() {
        _reservationStats = stats;
        _isLoading = false;
      });
    } catch (e) {
      print(' Error loading reservation stats: $e');
      setState(() {
        _reservationStats = _getMockReservationStats();
        _error = null; 
        _isLoading = false;
      });
    }
  }

  ReservationStats _getMockReservationStats() {
    final dailyData = List.generate(30, (index) {
      final day = index + 1;
      final count = 45 + (day * 3) % 25 + (day % 7);
      return DailyData(date: '2024-04-${day.toString().padLeft(2, '0')}', count: count);
    });
    
    return ReservationStats(
      daily: dailyData,
      monthly: MonthlyStats(
        published: List.generate(12, (index) => 40 + (index % 15)),
        reserved: List.generate(12, (index) => 35 + (index % 12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final r = _Responsive(context);
    return StatsDetailScaffold(
      title: '',
      body: _isLoading 
        ? Center(child: CircularProgressIndicator(color: AppColors.accentBrown))
        : _error != null
          ? Center(
              child: Padding(
                padding: EdgeInsets.all(r.scale(20)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: r.scale(48), color: Colors.red),
                    SizedBox(height: r.vp(16)),
                    Text(
                      'Erreur de chargement',
                      style: AppTextStyles.pageTitle.copyWith(
                        fontSize: r.fontSize(18),
                        color: Colors.red,
                      ),
                    ),
                    SizedBox(height: r.vp(8)),
                    Text(
                      _error!,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontSize: r.fontSize(14),
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: r.vp(16)),
                    ElevatedButton(
                      onPressed: _loadReservationStats,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentBrown,
                        foregroundColor: Colors.white,
                      ),
                      child: Text('Réessayer'),
                    ),
                  ],
                ),
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildChartCard(context),
              ],
            ),
    );
  }

  Widget _buildChartCard(BuildContext context) {
    final r = _Responsive(context);

    List<String> dates = [];
    List<int> reservations = [];

    if (_reservationStats?.daily.isNotEmpty == true) {
      dates = _reservationStats!.daily.map((data) {
        final date = DateTime.parse(data.date);
        return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';
      }).toList();
      reservations = _reservationStats!.daily.map((data) => data.count).toList();
    } else {
      dates = [
        '29/03', '30/03', '31/03', '01/04', '02/04', '03/04', '04/04',
        '05/04', '06/04', '07/04', '08/04', '09/04', '10/04', '11/04',
        '12/04', '13/04', '14/04', '15/04', '16/04', '17/04', '18/04',
        '19/04', '20/04', '21/04', '22/04', '23/04', '24/04', '25/04',
        '26/04', '27/04'
      ];
      reservations = [
        45, 52, 48, 55, 62, 58, 65, 72, 68, 75, 82, 78, 85, 88,
        92, 86, 90, 95, 98, 94, 100, 96, 88, 92, 85, 82, 78, 75, 72, 68
      ];
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(r.scale(24)),
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
            'Réservations par jour',
            style: AppTextStyles.pageTitle.copyWith(
              fontSize: r.fontSize(22),
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: r.vp(4)),
          Text(
            '30 derniers jours',
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: r.fontSize(14),
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: r.vp(24)),
          _buildLineChartReservations(context, dates, reservations),
        ],
      ),
    );
  }

  Widget _buildLineChartReservations(
      BuildContext context, List<String> labels, List<int> dataPoints) {
    final r = _Responsive(context);
    final maxValue = dataPoints.reduce((a, b) => a > b ? a : b).toDouble();
    final chartHeight = r.vp(260);
    final roundedMax = ((maxValue / 20).ceil() * 20).toDouble();
    final midValue = roundedMax / 2;

    final visibleLabels = <String>[];
    for (int i = 0; i < labels.length; i++) {
      if (i % 5 == 0 || i == labels.length - 1) {
        visibleLabels.add(labels[i]);
      }
    }

    return Column(
      children: [
        SizedBox(
          height: chartHeight,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: r.hp(45),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${roundedMax.toInt()}',
                      style: AppTextStyles.chartLabel.copyWith(
                          fontSize: r.fontSize(11),
                          fontWeight: FontWeight.w600),
                    ),
                    Text(
                      '${midValue.toInt()}',
                      style: AppTextStyles.chartLabel
                          .copyWith(fontSize: r.fontSize(11)),
                    ),
                    Text(
                      '0',
                      style: AppTextStyles.chartLabel.copyWith(
                          fontSize: r.fontSize(11),
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              SizedBox(width: r.hp(10)),
              Expanded(
                child: CustomPaint(
                  painter: LineChartPainter(
                    dataPoints: dataPoints,
                    maxValue: roundedMax,
                    minValue: 0,
                    lineColor: const Color(0xFFF8B068),
                    areaColor: const Color(0xFFF8B068).withOpacity(0.15),
                    isFillArea: true,
                  ),
                  size: Size(double.infinity, chartHeight),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: r.vp(12)),
        Padding(
          padding: EdgeInsets.only(left: r.hp(45) + r.hp(10)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: visibleLabels.map((label) {
              return Text(
                label,
                style:
                    AppTextStyles.chartLabel.copyWith(fontSize: r.fontSize(10)),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow(BuildContext context) {
    final r = _Responsive(context);
    
    int totalThisMonth = _reservationStats?.monthly.reserved.isNotEmpty == true 
        ? _reservationStats!.monthly.reserved.fold(0, (sum, count) => sum + count) 
        : 1482;
    double growthRate = 18.0; 
    
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.all(r.scale(16)),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(r.scale(24)),
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
                    'TOTAL CE MOIS',
                    style: AppTextStyles.sectionLabel.copyWith(
                      fontSize: r.fontSize(10),
                      letterSpacing: 1,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  SizedBox(height: r.vp(6)),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '$totalThisMonth',
                      style: AppTextStyles.statValue.copyWith(
                        fontSize: r.fontSize(28),
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFFF8B068),
                      ),
                    ),
                  ),
                  SizedBox(height: r.vp(6)),
                  Text(
                    'unités',
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: r.fontSize(11),
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: r.hp(12)),
          Expanded(
            child: Container(
              padding: EdgeInsets.all(r.scale(16)),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(r.scale(24)),
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
                    'CROISSANCE',
                    style: AppTextStyles.sectionLabel.copyWith(
                      fontSize: r.fontSize(10),
                      letterSpacing: 1,
                    ),
                  ),
                  SizedBox(height: r.vp(6)),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Icon(
                          Icons.trending_up_rounded,
                          size: r.scale(20),
                          color: const Color(0xFFF8B068),
                        ),
                        SizedBox(width: r.hp(4)),
                        Text(
                          '+${growthRate.toStringAsFixed(1)}',
                          style: AppTextStyles.statValue.copyWith(
                            fontSize: r.fontSize(28),
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFFF8B068),
                          ),
                        ),
                        Text(
                          '%',
                          style: AppTextStyles.statValue.copyWith(
                            fontSize: r.fontSize(20),
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFFF8B068),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: r.vp(6)),
                  Text(
                    'vs mois dernier',
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: r.fontSize(11),
                      color: AppColors.textMuted,
                    ),
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


class OfferPerformancePage extends StatefulWidget {
  const OfferPerformancePage({super.key});

  @override
  State<OfferPerformancePage> createState() => _OfferPerformancePageState();
}

class _OfferPerformancePageState extends State<OfferPerformancePage> {
  String _selectedPeriod = 'weekly';
  final StatsService _statsService = StatsService();
  OfferStats? _offerStats;
  bool _isLoading = true;
  String? _error;

  final List<String> _weekDays = [
    'Dim', 'Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam'
  ];

  @override
  void initState() {
    super.initState();
    _loadOfferStats();
  }

  Future<void> _loadOfferStats() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final stats = await _statsService.getOfferStats();
      setState(() {
        _offerStats = stats;
        _isLoading = false;
      });
    } catch (e) {
      print(' Error loading offer stats: $e');
      setState(() {
        _offerStats = _getMockOfferStats();
        _error = null;
        _isLoading = false;
      });
    }
  }

  OfferStats _getMockOfferStats() {
    return OfferStats(
      weekly: WeeklyStats(
        published: [35, 44, 46, 42, 48, 52, 38],
        reserved: [30, 40, 42, 38, 44, 48, 34],
      ),
      monthly: MonthlyStats(
        published: List.generate(30, (index) => 40 + (index % 15)),
        reserved: List.generate(30, (index) => 35 + (index % 12)),
      ),
      successRate: SuccessRateStats(
        current: 85.5,
        previous: 82.3,
      ),
    );
  }

  List<int> get _offersPublishedWeekly {
    if (_offerStats?.weekly.published.isNotEmpty == true) {
      return _offerStats!.weekly.published;
    }
    return [35, 44, 46, 42, 48, 52, 38];
  }

  List<int> get _offersReservedWeekly {
    if (_offerStats?.weekly.reserved.isNotEmpty == true) {
      return _offerStats!.weekly.reserved;
    }
    return [30, 40, 42, 38, 44, 48, 34];
  }

  final List<String> _monthDays =
      List.generate(30, (index) => '${index + 1}');
  
  List<int> get _offersPublishedMonthly {
    if (_offerStats?.monthly.published.isNotEmpty == true) {
      return _offerStats!.monthly.published;
    }
    return List.generate(30, (index) => 40 + (index % 15));
  }
  
  List<int> get _offersReservedMonthly {
    if (_offerStats?.monthly.reserved.isNotEmpty == true) {
      return _offerStats!.monthly.reserved;
    }
    return List.generate(30, (index) => 35 + (index % 12));
  }

  @override
  Widget build(BuildContext context) {
    final r = _Responsive(context);
    return StatsDetailScaffold(
      title: '',
      body: _isLoading 
        ? Center(child: CircularProgressIndicator(color: AppColors.accentBrown))
        : _error != null
          ? Center(
              child: Padding(
                padding: EdgeInsets.all(r.scale(20)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: r.scale(48), color: Colors.red),
                    SizedBox(height: r.vp(16)),
                    Text(
                      'Erreur de chargement',
                      style: AppTextStyles.pageTitle.copyWith(
                        fontSize: r.fontSize(18),
                        color: Colors.red,
                      ),
                    ),
                    SizedBox(height: r.vp(8)),
                    Text(
                      _error!,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontSize: r.fontSize(14),
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: r.vp(16)),
                    ElevatedButton(
                      onPressed: _loadOfferStats,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentBrown,
                        foregroundColor: Colors.white,
                      ),
                      child: Text('Réessayer'),
                    ),
                  ],
                ),
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildChartCard(context),
                SizedBox(height: r.vp(20)),
                _buildSummaryRow(context),
                SizedBox(height: r.vp(20)),
                _buildSuccessRateCard(context),
                SizedBox(height: r.vp(20)),
              ],
            ),
    );
  }

  Widget _buildChartCard(BuildContext context) {
    final r = _Responsive(context);
    final isWeekly = _selectedPeriod == 'weekly';
    final labels = isWeekly ? _weekDays : _monthDays;
    final publishedData =
        isWeekly ? _offersPublishedWeekly : _offersPublishedMonthly;
    final reservedData =
        isWeekly ? _offersReservedWeekly : _offersReservedMonthly;
    final maxValue = [
      ...publishedData,
      ...reservedData,
    ].reduce((a, b) => a > b ? a : b).toDouble();

    final roundedMax = ((maxValue / 10).ceil() * 10).toDouble();
    final midValue = roundedMax / 2;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(r.scale(24)),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Offres publiées vs réservées',
                      style: AppTextStyles.pageTitle.copyWith(
                        fontSize: r.fontSize(20),
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                      ),
                    ),
                    SizedBox(height: r.vp(4)),
                    Text(
                      isWeekly ? 'Volume hebdomadaire' : 'Volume mensuel',
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: r.fontSize(12),
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              _buildPeriodToggle(context),
            ],
          ),
          SizedBox(height: r.vp(24)),
          _buildBarChart(context, labels, publishedData, reservedData,
              roundedMax, midValue, isWeekly),
          SizedBox(height: r.vp(16)),
          _buildLegend(context),
        ],
      ),
    );
  }

  Widget _buildPeriodToggle(BuildContext context) {
    final r = _Responsive(context);
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(r.scale(40)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildToggleOption(context, 'Hebdo', 'weekly'),
          _buildToggleOption(context, 'Mensuel', 'monthly'),
        ],
      ),
    );
  }

  Widget _buildToggleOption(
      BuildContext context, String label, String period) {
    final r = _Responsive(context);
    final isSelected = _selectedPeriod == period;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPeriod = period;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(
            horizontal: r.hp(18), vertical: r.vp(8)),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(r.scale(32)),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: AppFonts.plusJakarta,
            fontSize: r.fontSize(12),
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildBarChart(
    BuildContext context,
    List<String> labels,
    List<int> publishedData,
    List<int> reservedData,
    double maxValue,
    double midValue,
    bool isWeekly,
  ) {
    final r = _Responsive(context);
    final chartHeight = r.vp(220);

    return Column(
      children: [
        SizedBox(
          height: chartHeight,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: r.hp(45),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${maxValue.toInt()}',
                      style: AppTextStyles.chartLabel.copyWith(
                          fontSize: r.fontSize(11),
                          fontWeight: FontWeight.w600),
                    ),
                    Text(
                      '${midValue.toInt()}',
                      style: AppTextStyles.chartLabel
                          .copyWith(fontSize: r.fontSize(11)),
                    ),
                    Text(
                      '0',
                      style: AppTextStyles.chartLabel.copyWith(
                          fontSize: r.fontSize(11),
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              SizedBox(width: r.hp(10)),
              Expanded(
                child: CustomPaint(
                  painter: BarChartPainter(
                    labels: labels,
                    publishedData: publishedData,
                    reservedData: reservedData,
                    maxValue: maxValue,
                    chartHeight: chartHeight,
                    barSpacing: 0,
                    barWidthFactor: isWeekly ? 0.3 : 0.12,
                  ),
                  size: Size(double.infinity, chartHeight),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: r.vp(8)),
        Padding(
          padding: EdgeInsets.only(left: r.hp(45) + r.hp(10)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children:
                _getVisibleLabels(labels, isWeekly).map((label) {
              return Text(
                label,
                style: AppTextStyles.chartLabel.copyWith(
                    fontSize: isWeekly ? r.fontSize(11) : r.fontSize(9)),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  List<String> _getVisibleLabels(List<String> labels, bool isWeekly) {
    if (isWeekly) return labels;
    return labels
        .asMap()
        .entries
        .where((entry) =>
            entry.key % 5 == 0 || entry.key == labels.length - 1)
        .map((entry) => entry.value)
        .toList();
  }

  Widget _buildLegend(BuildContext context) {
    final r = _Responsive(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          children: [
            Container(
              width: r.scale(12),
              height: r.scale(12),
              decoration: BoxDecoration(
                color: const Color(0xFFCCD5AE),
                borderRadius: BorderRadius.circular(r.scale(3)),
              ),
            ),
            SizedBox(width: r.hp(6)),
            Text(
              'Offres publiées',
              style:
                  AppTextStyles.bodySmall.copyWith(fontSize: r.fontSize(11)),
            ),
          ],
        ),
        SizedBox(width: r.hp(20)),
        Row(
          children: [
            Container(
              width: r.scale(12),
              height: r.scale(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8B068),
                borderRadius: BorderRadius.circular(r.scale(3)),
              ),
            ),
            SizedBox(width: r.hp(6)),
            Text(
              'Offres réservées',
              style:
                  AppTextStyles.bodySmall.copyWith(fontSize: r.fontSize(11)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSuccessRateCard(BuildContext context) {
    final r = _Responsive(context);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(r.scale(16)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(r.scale(24)),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentBrown.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: r.scale(40),
            height: r.scale(40),
            decoration: BoxDecoration(
              color: const Color(0xFFCCD5AE).withOpacity(0.25),
              borderRadius: BorderRadius.circular(r.scale(12)),
            ),
            child: Icon(
              Icons.analytics_outlined,
              size: r.scale(22),
              color: const Color(0xFF5C4A2A),
            ),
          ),
          SizedBox(width: r.hp(14)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TAUX DE RÉUSSITE',
                  style: AppTextStyles.sectionLabel.copyWith(
                    fontSize: r.fontSize(10),
                    letterSpacing: 1,
                  ),
                ),
                SizedBox(height: r.vp(2)),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '${(_offerStats?.successRate.current ?? 84.2).toStringAsFixed(1)}%',
                    style: AppTextStyles.statValue.copyWith(
                      fontSize: r.fontSize(26),
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFFF8B068),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(BuildContext context) {
    final r = _Responsive(context);
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.all(r.scale(16)),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(r.scale(24)),
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
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: r.scale(40),
                    height: r.scale(40),
                    decoration: BoxDecoration(
                      color: const Color(0xFFCCD5AE).withOpacity(0.25),
                      borderRadius: BorderRadius.circular(r.scale(12)),
                    ),
                    child: Icon(
                      Icons.local_offer_outlined,
                      size: r.scale(22),
                      color: const Color(0xFF5C4A2A),
                    ),
                  ),
                  SizedBox(height: r.vp(10)),
                  Text(
                    'TOTAL OFFRES',
                    style: AppTextStyles.sectionLabel.copyWith(
                      fontSize: r.fontSize(10),
                      letterSpacing: 1,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  SizedBox(height: r.vp(2)),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '${_offerStats != null ? _offerStats!.weekly.published.fold(0, (sum, count) => sum + count).toString() : '1 402'}',
                      style: AppTextStyles.statValue.copyWith(
                        fontSize: r.fontSize(26),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: r.hp(12)),
          Expanded(
            child: Container(
              padding: EdgeInsets.all(r.scale(16)),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(r.scale(24)),
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
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: r.scale(40),
                    height: r.scale(40),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8B068).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(r.scale(12)),
                    ),
                    child: Icon(
                      Icons.bookmark_outline_rounded,
                      size: r.scale(22),
                      color: const Color(0xFFE07B39),
                    ),
                  ),
                  SizedBox(height: r.vp(10)),
                  Text(
                    'TOTAL RÉSERVATIONS',
                    style: AppTextStyles.sectionLabel.copyWith(
                      fontSize: r.fontSize(10),
                      letterSpacing: 1,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  SizedBox(height: r.vp(2)),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '${_offerStats != null ? _offerStats!.weekly.reserved.fold(0, (sum, count) => sum + count).toString() : '1 181'}',
                      style: AppTextStyles.statValue.copyWith(
                        fontSize: r.fontSize(26),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
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


class LineChartPainter extends CustomPainter {
  final List<int> dataPoints;
  final double maxValue;
  final double minValue;
  final Color lineColor;
  final Color areaColor;
  final bool isFillArea;

  LineChartPainter({
    required this.dataPoints,
    required this.maxValue,
    required this.minValue,
    required this.lineColor,
    required this.areaColor,
    this.isFillArea = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final areaPaint = Paint()
      ..color = areaColor
      ..style = PaintingStyle.fill;

    final width = size.width;
    final height = size.height;
    final stepX = width / (dataPoints.length - 1);
    final range = maxValue - minValue;
    final scaleY = height / range;

    final gridPaint = Paint()
      ..color = AppColors.divider
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    final stepY = height / 2;
    canvas.drawLine(Offset(0, stepY), Offset(width, stepY), gridPaint);

    List<Offset> points = [];
    for (int i = 0; i < dataPoints.length; i++) {
      final x = i * stepX;
      final y = height - (dataPoints[i] - minValue) * scaleY;
      points.add(Offset(x, y));
    }

    if (points.isNotEmpty) {
      final path = Path();
      path.moveTo(points.first.dx, points.first.dy);
      for (int i = 1; i < points.length; i++) {
        path.lineTo(points[i].dx, points[i].dy);
      }
      canvas.drawPath(path, paint);

      if (isFillArea && points.isNotEmpty) {
        final areaPath = Path();
        areaPath.moveTo(points.first.dx, height);
        areaPath.lineTo(points.first.dx, points.first.dy);
        for (int i = 1; i < points.length; i++) {
          areaPath.lineTo(points[i].dx, points[i].dy);
        }
        areaPath.lineTo(points.last.dx, height);
        areaPath.close();
        canvas.drawPath(areaPath, areaPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class BarChartPainter extends CustomPainter {
  final List<String> labels;
  final List<int> publishedData;
  final List<int> reservedData;
  final double maxValue;
  final double chartHeight;
  final double barSpacing;
  final double barWidthFactor;

  BarChartPainter({
    required this.labels,
    required this.publishedData,
    required this.reservedData,
    required this.maxValue,
    required this.chartHeight,
    required this.barSpacing,
    required this.barWidthFactor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final barWidth = width / labels.length * barWidthFactor;
    final groupWidth = width / labels.length;
    final scaleY = chartHeight / maxValue;

    final gridPaint = Paint()
      ..color = AppColors.divider
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    final stepY = chartHeight / 2;
    canvas.drawLine(Offset(0, stepY), Offset(width, stepY), gridPaint);

    for (int i = 0; i < labels.length; i++) {
      if (i >= publishedData.length || i >= reservedData.length) {
        continue;
      }
      
      final xCenter = i * groupWidth + groupWidth / 2;

      final publishedHeight = publishedData[i] * scaleY;
      final publishedRect = Rect.fromLTWH(
        xCenter - barWidth - barSpacing,
        chartHeight - publishedHeight,
        barWidth,
        publishedHeight,
      );
      final publishedPaint = Paint()
        ..color = const Color(0xFFCCD5AE)
        ..style = PaintingStyle.fill;
      canvas.drawRRect(
        RRect.fromRectAndRadius(publishedRect, const Radius.circular(4)),
        publishedPaint,
      );

      final reservedHeight = reservedData[i] * scaleY;
      final reservedRect = Rect.fromLTWH(
        xCenter + barSpacing,
        chartHeight - reservedHeight,
        barWidth,
        reservedHeight,
      );
      final reservedPaint = Paint()
        ..color = const Color(0xFFF8B068)
        ..style = PaintingStyle.fill;
      canvas.drawRRect(
        RRect.fromRectAndRadius(reservedRect, const Radius.circular(4)),
        reservedPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
