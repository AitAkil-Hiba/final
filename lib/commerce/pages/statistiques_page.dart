import 'package:flutter/material.dart';
import '../../../services/api_service.dart';
import 'profile/profil_commercant.dart';
import 'mes_commandes_page.dart';
import 'creer_offre/creer_offre_step1.dart';

class StatistiquesPage extends StatefulWidget {
  const StatistiquesPage({super.key});

  @override
  State<StatistiquesPage> createState() => _StatistiquesPageState();
}

class _StatistiquesPageState extends State<StatistiquesPage> {
  int _selectedNavIndex = 3;
  bool _isLoading = true;
  Map<String, dynamic>? _statistics;
  List<Map<String, dynamic>>? _weeklyEvolution;

  static const Color topBarColor = Color(0xFFCCD5AE);
  static const Color backgroundColor = Color(0xFFFEFAE0);
  static const Color cardColor = Color(0xFFE9EDC9);
  static const Color cardColorLight = Color(0xFFF5EED8);
  static const Color orangeColor = Color(0xFFE8824A);
  static const Color brownColor = Color(0xFF5D4E37);
  static const Color selectedNavColor = Color(0xFFDDCD9E);
  static const Color unselectedNavColor = Color(0xFFE9EDC9);

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    try {
      final response = await ApiService.getMerchantStatistics();
      setState(() {
        _statistics = response;
        _weeklyEvolution = List<Map<String, dynamic>>.from(
          response['evolutionSemaine'] ?? [],
        );
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur de chargement : ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Container(height: 8, color: topBarColor),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFE8824A),
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),
                          const Text(
                            'Statistiques',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF3E2723),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildRevenusCard(),
                          const SizedBox(height: 12),
                          _buildOffresNotesRow(),
                          const SizedBox(height: 12),
                          _buildEvolutionCard(),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
            ),
            _buildBottomNavBar(),
          ],
        ),
      ),
    );
  }

  String _formatNumber(String number) {
    final value = double.tryParse(number) ?? 0;
    if (value >= 1000) {
      return value
          .toStringAsFixed(0)
          .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => ' ');
    }
    return value.toStringAsFixed(0);
  }

  Widget _buildRevenusCard() {
    final revenue = _statistics?['revenueGlobal']?.toString() ?? '0';
    final reservations = _statistics?['totalReservations']?.toString() ?? '0';
    final tauxRetrait = _statistics?['tauxRetrait']?.toString() ?? '0';
    final moyenneCommande =
        _statistics?['moyennePrixCommande']?.toString() ?? '0';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Revenus récupérés',
            style: TextStyle(fontSize: 13, color: Color(0xFF757575)),
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatNumber(revenue),
                style: const TextStyle(
                  fontSize: 38,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF3E2723),
                  height: 1.0,
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(bottom: 4, left: 2),
                child: Text(
                  'DA',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF3E2723),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Mini stats row
          Row(
            children: [
              _buildMiniStatCard(reservations, 'Réservations'),
              const SizedBox(width: 10),
              _buildMiniStatCard('${tauxRetrait}%', 'Taux retrait'),
              const SizedBox(width: 10),
              _buildMiniStatCard(
                '${_formatNumber(moyenneCommande)}DA',
                'Moy./cmd',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStatCard(String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFD7E0BE),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF3E2723),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 10,
                color: Color(0xFF757575),
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOffresNotesRow() {
    final totalOffres = _statistics?['totalOffres']?.toString() ?? '0';
    final noteMoyenne = _statistics?['noteMoyenne']?.toString() ?? '0';

    return Row(
      children: [
        Expanded(
          child: _buildStatSquare(
            iconWidget: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFD7E0BE),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.shopping_bag_outlined,
                size: 22,
                color: brownColor,
              ),
            ),
            value: totalOffres,
            label: 'Offres publiées',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatSquare(
            iconWidget: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF3E2723),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.star, size: 22, color: Colors.white),
            ),
            value: noteMoyenne,
            label: 'Note moyenne',
          ),
        ),
      ],
    );
  }

  Widget _buildStatSquare({
    required Widget iconWidget,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          iconWidget,
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w800,
              color: Color(0xFF3E2723),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 13, color: Color(0xFF757575)),
          ),
        ],
      ),
    );
  }

  Widget _buildEvolutionCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColorLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Évolution des revenus',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF3E2723),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: _weeklyEvolution != null && _weeklyEvolution!.isNotEmpty
                ? CustomPaint(
                    size: const Size(double.infinity, 120),
                    painter: _LineChartPainter(_weeklyEvolution!),
                  )
                : const Center(
                    child: Text(
                      'Aucune donnée disponible',
                      style: TextStyle(fontSize: 12, color: Color(0xFF9E9E9E)),
                    ),
                  ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children:
                _weeklyEvolution
                    ?.map(
                      (day) => Text(
                        day['jour'] ?? '',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF9E9E9E),
                        ),
                      ),
                    )
                    .toList() ??
                ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim']
                    .map(
                      (d) => Text(
                        d,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF9E9E9E),
                        ),
                      ),
                    )
                    .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavBar() {
    final icons = [
      Icons.shopping_bag_outlined,
      Icons.add,
      Icons.home_outlined,
      Icons.show_chart,
      Icons.person_outline,
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: topBarColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(icons.length, (index) {
          final isSelected = _selectedNavIndex == index;
          return GestureDetector(
            onTap: () {
              if (index == 3) return;
              if (index == 0) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const MesCommandesPage()),
                );
                return;
              }
              if (index == 1) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CreerOffreStep1()),
                );
                return;
              }
              if (index == 2) {
                Navigator.popUntil(context, (route) => route.isFirst);
                return;
              }
              if (index == 4) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfilCommercant()),
                );
                return;
              }
              setState(() => _selectedNavIndex = index);
            },
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: isSelected ? selectedNavColor : unselectedNavColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFB8C49E), width: 1),
              ),
              child: Icon(
                icons[index],
                size: 24,
                color: isSelected
                    ? const Color(0xFF5D4037)
                    : const Color(0xFF7D7D7D),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> data;

  _LineChartPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    // Trouver les valeurs min/max pour l'échelle
    final revenues = data
        .map((d) => (d['revenu'] as num?)?.toDouble() ?? 0.0)
        .toList();
    final maxRevenue = revenues.reduce((a, b) => a > b ? a : b);
    final minRevenue = 0.0;

    // Lignes horizontales de fond
    final gridPaint = Paint()
      ..color = const Color(0xFFE0D8C8)
      ..strokeWidth = 1;

    for (int i = 0; i <= 3; i++) {
      final y = size.height * (i / 3) * 0.85;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Courbe
    final paint = Paint()
      ..color = const Color(0xFFE8824A)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Créer les points basés sur les données réelles
    final points = <Offset>[];
    for (int i = 0; i < data.length; i++) {
      final revenue = revenues[i];
      final x = size.width * (i / (data.length - 1));
      final y =
          size.height * 0.85 -
          (revenue - minRevenue) /
              (maxRevenue - minRevenue) *
              size.height *
              0.7;
      points.add(Offset(x, y));
    }

    if (points.isEmpty) return;

    final path = Path();
    path.moveTo(points[0].dx, points[0].dy);
    for (int i = 0; i < points.length - 1; i++) {
      final cp1 = Offset((points[i].dx + points[i + 1].dx) / 2, points[i].dy);
      final cp2 = Offset(
        (points[i].dx + points[i + 1].dx) / 2,
        points[i + 1].dy,
      );
      path.cubicTo(
        cp1.dx,
        cp1.dy,
        cp2.dx,
        cp2.dy,
        points[i + 1].dx,
        points[i + 1].dy,
      );
    }
    canvas.drawPath(path, paint);

    // Points
    final dotPaint = Paint()
      ..color = const Color(0xFFE8824A)
      ..style = PaintingStyle.fill;
    for (final p in points) {
      canvas.drawCircle(p, 4, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
