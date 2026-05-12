import 'package:flutter/material.dart';

import 'core/core.dart';

import '../services/admin_service.dart';
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



  double get _widthRatio => (_size.width / _baseWidth).clamp(0.3, 1.4);

  double get _heightRatio => (_size.height / _baseHeight).clamp(0.3, 1.4);



  double scale(double value) => value * ((_widthRatio + _heightRatio) / 2);



  double hp(double value) => value * _widthRatio;



  double vp(double value) => value * _heightRatio;



  double fontSize(double value) => _textScale.scale(value * _widthRatio);

}



class MerchantsByCategoryPage extends StatefulWidget {

  const MerchantsByCategoryPage({super.key});



  @override

  State<MerchantsByCategoryPage> createState() => _MerchantsByCategoryPageState();

}



class _MerchantsByCategoryPageState extends State<MerchantsByCategoryPage> {

  final StatsService _statsService = StatsService();

  List<MerchantCategoryStats> _categoriesData = [];

  bool _isLoading = true;

  String? _error;



  @override

  void initState() {

    super.initState();

    _loadCategoriesData();

  }



  Future<void> _loadCategoriesData() async {
    setState(() => _isLoading = true);
    _error = null;
    try {
      final data = await _statsService.getMerchantsByCategory();
      setState(() {
        _categoriesData = data;
        _isLoading = false;
      });
    } catch (e) {
      print(' Error loading merchants by category data: $e');
      setState(() {
        _categoriesData = _getMockCategoriesData();
        _error = null; 
        _isLoading = false;
      });
    }
  }

  List<MerchantCategoryStats> _getMockCategoriesData() {
    return [
      MerchantCategoryStats(category: 'Épicerie', count: 15),
      MerchantCategoryStats(category: 'Boulangerie', count: 32),
      MerchantCategoryStats(category: 'Boucherie', count: 8),
      MerchantCategoryStats(category: 'Superette', count: 12),
      MerchantCategoryStats(category: 'Restaurant', count: 18),
      MerchantCategoryStats(category: 'Café', count: 6),
      MerchantCategoryStats(category: 'Autre', count: 4),
    ];
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

                  onPressed: _loadCategoriesData,

                  style: ElevatedButton.styleFrom(

                    backgroundColor: AppColors.accentBrown,

                    foregroundColor: Colors.white,

                  ),

                  child: Text('Réessayer'),

                ),

              ],

            ),

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

              _buildMetricsRow(context),

            ],

          ),

        ),

      ),

    );

  }



  Widget _buildMainStatsCard(BuildContext context) {

    final r = _Responsive(context);




    final Map<String, String> categoryNames = {

      'Épicerie': 'Épicerie',

      'Boulangerie': 'Boulangerie',

      'Boucherie': 'Boucherie',

      'Superette': 'Superette',

      'Restaurant': 'Restaurant',

      'Café': 'Café',

      'Autre': 'Autre',

    };




    final List<CategorySection> categories = [];

    int total = 0;

    

    for (var item in _categoriesData) {

      final categoryName = item.category;

      final count = item.count;

      

      if (categoryName != null && categoryNames.containsKey(categoryName)) {

        categories.add(CategorySection(

          name: categoryNames[categoryName]!,

          count: count,

          percentage: 0, 

          color: _getCategoryColor(categoryName),

        ));

        total += count;

      }

    }

    

   

    for (var category in categories) {

      final percentage = total > 0 ? (category.count / total) * 100 : 0;

      category.percentage = percentage.toDouble();

    }



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

            'Commerçants par catégorie',

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

            'Total: $total commerçants',

            style: AppTextStyles.bodyMedium.copyWith(

              fontSize: r.fontSize(13),

              color: AppColors.textSecondary,

            ),

            overflow: TextOverflow.ellipsis,

            maxLines: 1,

          ),

          SizedBox(height: r.vp(20)),

          _buildBarChart(context, categories, total),

        ],

      ),

    );

  }



  Widget _buildBarChart(

      BuildContext context, List<CategorySection> categories, int total) {

    final r = _Responsive(context);

    return Column(

      children: categories.map((category) {

        return Padding(

          padding: EdgeInsets.symmetric(vertical: r.vp(6)),

          child: Column(

            crossAxisAlignment: CrossAxisAlignment.start,

            children: [

              Row(

                children: [

                  Expanded(

                    child: Text(

                      category.name,

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

                    '(${category.percentage.toStringAsFixed(1)}%)',

                    style: AppTextStyles.bodySmall.copyWith(

                      fontSize: r.fontSize(11),

                      color: AppColors.textMuted,

                    ),

                  ),

                  SizedBox(width: r.hp(6)),

                  Text(

                    category.count.toString(),

                    style: AppTextStyles.statValue.copyWith(

                      fontSize: r.fontSize(14),

                      fontWeight: FontWeight.w700,

                    ),

                  ),

                ],

              ),

              SizedBox(height: r.vp(5)),

              LayoutBuilder(

                builder: (context, constraints) {

                  return Stack(

                    children: [

                      Container(

                        width: constraints.maxWidth,

                        height: r.scale(7),

                        decoration: BoxDecoration(

                          color: AppColors.divider,

                          borderRadius: BorderRadius.circular(r.scale(4)),

                        ),

                      ),

                      Container(

                        width: constraints.maxWidth * (category.count / total),

                        height: r.scale(7),

                        decoration: BoxDecoration(

                          color: category.color,

                          borderRadius: BorderRadius.circular(r.scale(4)),

                        ),

                      ),

                    ],

                  );

                },

              ),

            ],

          ),

        );

      }).toList(),

    );

  }



  Widget _buildMetricsRow(BuildContext context) {

    final r = _Responsive(context);



    

    CategorySection? topCategory;

    CategorySection? minCategory;

    

    if (_categoriesData.isNotEmpty) {

      final categories = _categoriesData.map((item) {

        final categoryName = item.category;

        final count = item.count;

        return CategorySection(

          name: _getDisplayName(categoryName ?? ''),

          count: count,

          percentage: 0,

          color: _getCategoryColor(categoryName ?? ''),

        );

      }).toList();

      

      categories.sort((a, b) => b.count.compareTo(a.count));

      topCategory = categories.isNotEmpty ? categories.first : null;

      minCategory = categories.length > 1 ? categories.last : null;

    }



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

                    'TOP CROISSANCE',

                    style: AppTextStyles.sectionLabel.copyWith(

                      fontSize: r.fontSize(9),

                      letterSpacing: 1.0,

                    ),

                    overflow: TextOverflow.ellipsis,

                    maxLines: 1,

                  ),

                  SizedBox(height: r.vp(6)),

                  Text(

                    topCategory?.name ?? 'N/A',

                    style: AppTextStyles.listItemTitle.copyWith(

                      fontSize: r.fontSize(15),

                      fontWeight: FontWeight.w700,

                    ),

                    overflow: TextOverflow.ellipsis,

                    maxLines: 1,

                  ),

                  SizedBox(height: r.vp(4)),

                  Row(

                    children: [

                      Icon(Icons.trending_up_rounded,

                          size: r.scale(11), color: const Color(0xFFCCD5AE)),

                      SizedBox(width: r.hp(3)),

                      Flexible(

                        child: Text(

                          '${topCategory?.count ?? 0} commerçants',

                          style: AppTextStyles.bodySmall.copyWith(

                            fontSize: r.fontSize(11),

                            color: const Color.fromARGB(255, 172, 180, 147),

                            fontWeight: FontWeight.w600,

                          ),

                          overflow: TextOverflow.ellipsis,

                          maxLines: 1,

                        ),

                      ),

                    ],

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

                    'MIN CROISSANCE',

                    style: AppTextStyles.sectionLabel.copyWith(

                      fontSize: r.fontSize(9),

                      letterSpacing: 1.0,

                    ),

                    overflow: TextOverflow.ellipsis,

                    maxLines: 1,

                  ),

                  SizedBox(height: r.vp(6)),

                  Text(

                    minCategory?.name ?? 'N/A',

                    style: AppTextStyles.listItemTitle.copyWith(

                      fontSize: r.fontSize(15),

                      fontWeight: FontWeight.w700,

                    ),

                    overflow: TextOverflow.ellipsis,

                    maxLines: 1,

                  ),

                  SizedBox(height: r.vp(4)),

                  Row(

                    children: [

                      Icon(Icons.trending_down_rounded,

                          size: r.scale(11), color: const Color(0xFFF8B068)),

                      SizedBox(width: r.hp(3)),

                      Flexible(

                        child: Text(

                          '${minCategory?.count ?? 0} commerçants',

                          style: AppTextStyles.bodySmall.copyWith(

                            fontSize: r.fontSize(11),

                            color: const Color(0xFFF8B068),

                            fontWeight: FontWeight.w600,

                          ),

                          overflow: TextOverflow.ellipsis,

                          maxLines: 1,

                        ),

                      ),

                    ],

                  ),

                ],

              ),

            ),

          ),

        ],

      ),

    );

  }



  String _getDisplayName(String categoryName) {

    final Map<String, String> displayNames = {

      'Épicerie': 'Épicerie',

      'Boulangerie': 'Boulangerie',

      'Boucherie': 'Boucherie',

      'Superette': 'Superette',

      'Restaurant': 'Restaurant',

      'Café': 'Café',

      'Autre': 'Autre',

    };

    return displayNames[categoryName] ?? categoryName;

  }

}



Color _getCategoryColor(String categoryName) {

    switch (categoryName) {

      case 'Épicerie':

        return const Color(0xFFCCD5AE);

      case 'Boulangerie':

        return const Color(0xFFA8C88A);

      case 'Boucherie':

        return const Color(0xFF8CB87A);

      case 'Superette':

        return const Color(0xFFF8B068);

      case 'Restaurant':

        return const Color(0xFFE89B3E);

      case 'Café':

        return const Color(0xFFD9882C);

      case 'Autre':

        return const Color(0xFFB0A0A0);

      default:

        return const Color(0xFFB0A0A0);

    }

  }



class CategorySection {

  final String name;

  final int count;

  double percentage;

  final Color color;



  CategorySection({

    required this.name,

    required this.count,

    required this.percentage,

    required this.color,

  });

}

