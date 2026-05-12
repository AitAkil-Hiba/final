import 'package:flutter/material.dart';
import '../prof_client_signal/fiche_client_page.dart';

// ── Modèle de données prêt pour le backend ──
// TODO Backend: remplacer par un appel API
// GET /api/commercant/{id}/avis
class AvisModel {
  final String id;
  final String initial;
  final Color initialColor;
  final String name;
  final int stars;
  final String date;
  final String comment;

  const AvisModel({
    required this.id,
    required this.initial,
    required this.initialColor,
    required this.name,
    required this.stars,
    required this.date,
    required this.comment,
  });
}

// ── Données statiques (à remplacer par API) ──
const _mockAvis = [
  AvisModel(
    id: '1',
    initial: 'K',
    initialColor: Color(0xFF8B9E6B),
    name: 'Karim B',
    stars: 5,
    date: '18 mars',
    comment:
        'Excellent ! Le panier était très généreux, pain frais et viennoiseries de qualité. Je reviendrai certainement',
  ),
  AvisModel(
    id: '2',
    initial: 'S',
    initialColor: Color(0xFF9E9E9E),
    name: 'Sarah M',
    stars: 4,
    date: '15 mars',
    comment:
        "Très bon rapport qualité/prix. Juste un peu d'attente à la caisse mais les produits valaient le détour.",
  ),
  AvisModel(
    id: '3',
    initial: 'A',
    initialColor: Color(0xFF9E9E9E),
    name: 'Amina B',
    stars: 3,
    date: '02 mars',
    comment:
        "Service correct dans l'ensemble. La commande était prête à temps, mais la qualité pourrait être améliorée. Personnel accueillant, mais j'espère une meilleure expérience la prochaine fois.",
  ),
];

class AvisEvaluationsPage extends StatefulWidget {
  const AvisEvaluationsPage({super.key});

  @override
  State<AvisEvaluationsPage> createState() => _AvisEvaluationsPageState();
}

class _AvisEvaluationsPageState extends State<AvisEvaluationsPage> {
  static const Color backgroundColor = Color(0xFFFEFAE0);
  static const Color cardColor = Color(0xFFFEFAF0);
  static const Color orangeColor = Color(0xFFE8824A);
  static const Color topBarColor = Color(0xFFCCD5AE);

  final List<AvisModel> _avisList = _mockAvis;

  // TODO Backend: ces valeurs viennent de l'API
  final double _noteMoyenne = 4.8;
  final int _totalAvis = 79;
  final Map<int, double> _repartition = {
    5: 0.72,
    4: 0.18,
    3: 0.07,
    2: 0.02,
    1: 0.01,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Container(height: 8, color: topBarColor),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.arrow_back,
                      color: Color(0xFF3E2723),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Avis & évaluations',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF3E2723),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    _buildRatingSummaryCard(),
                    const SizedBox(height: 20),
                    Text(
                      '$_totalAvis avis',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF757575),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ..._avisList.map(
                      (avis) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildAvisCard(avis),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _noteMoyenne.toString(),
                style: const TextStyle(
                  fontSize: 64,
                  fontWeight: FontWeight.w700,
                  color: orangeColor,
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: List.generate(
                  5,
                  (i) => const Icon(Icons.star, color: orangeColor, size: 18),
                ),
              ),
            ],
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              children: [5, 4, 3, 2, 1].map((star) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: _buildRatingBar(star, _repartition[star] ?? 0.0),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingBar(int star, double value) {
    final label = '${(value * 100).toInt()}%';
    return Row(
      children: [
        Icon(Icons.star, size: 12, color: orangeColor),
        const SizedBox(width: 4),
        Text(
          '$star',
          style: const TextStyle(fontSize: 11, color: Color(0xFF757575)),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 6,
              backgroundColor: const Color(0xFFE0D8C8),
              valueColor: AlwaysStoppedAnimation<Color>(
                star >= 4 ? orangeColor : const Color(0xFF5D4E37),
              ),
            ),
          ),
        ),
        const SizedBox(width: 6),
        SizedBox(
          width: 28,
          child: Text(
            label,
            style: const TextStyle(fontSize: 11, color: Color(0xFF757575)),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _buildAvisCard(AvisModel avis) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Avatar cliquable → FicheClientPage
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const FicheClientPage()),
                ),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: avis.initialColor,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      avis.initial,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  avis.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Color(0xFF3E2723),
                  ),
                ),
              ),
              // Étoiles
              Row(
                children: List.generate(
                  5,
                  (i) => Icon(
                    Icons.star,
                    size: 13,
                    color: i < avis.stars
                        ? orangeColor
                        : const Color(0xFFE0D8C8),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                avis.date,
                style: const TextStyle(fontSize: 11, color: Color(0xFF9E9E9E)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            avis.comment,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF424242),
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}
