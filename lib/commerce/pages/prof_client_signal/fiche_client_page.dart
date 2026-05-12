import 'package:flutter/material.dart';
import 'signaler_client_page.dart';

class FicheClientPage extends StatelessWidget {
  const FicheClientPage({super.key});

  static const Color topBarColor = Color(0xFFCCD5AE);
  static const Color backgroundColor = Color(0xFFFEFAE0);
  static const Color cardColor = Color(0xFFF5EED8);
  static const Color orangeColor = Color(0xFFE8824A);
  static const Color brownColor = Color(0xFF5D4E37);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Container(height: 8, color: topBarColor),
            // App bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back,
                        color: Color(0xFF3E2723), size: 22),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const SignalerClientPage()),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline,
                            size: 16, color: Color(0xFF3E2723)),
                        const SizedBox(width: 4),
                        const Text(
                          'Signaler',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF3E2723),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    // Avatar
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD7CFC0),
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: const Color(0xFFB8A898), width: 2),
                      ),
                      child: const Center(
                        child: Text(
                          'ML',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            color: brownColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    // Name
                    const Text(
                      'Mahdi Lamari',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF3E2723),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Client depuis mars 2025',
                      style: TextStyle(fontSize: 13, color: Color(0xFF9E9E9E)),
                    ),
                    const SizedBox(height: 12),
                    // Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEDE8D8),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: const Color(0xFFD0C8B0), width: 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.person_outline,
                              size: 14, color: brownColor),
                          SizedBox(width: 6),
                          Text(
                            'Profil Client',
                            style: TextStyle(
                              fontSize: 12,
                              color: brownColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    // Stats row
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard('9', 'avis laissés'),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                              '79%', 'des commandes\nrécupérées'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Historique title
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Historique avec le commerçant',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF3E2723),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    // Historique stats
                    Row(
                      children: [
                        Expanded(
                          child: _buildHistoriqueCard(
                              '12', 'Commandes\neffectuées',
                              isOrange: false),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildHistoriqueCard(
                              '12/03/2026', 'Dernière\ncommande',
                              isOrange: true),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildHistoriqueCard(
                              '1', 'commandes\nannulées',
                              isOrange: false),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Locked info card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 36),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: const Color(0xFFEDE0CC),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.lock_outline,
                              size: 32,
                              color: orangeColor,
                            ),
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            'Adresse & email masqués',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: orangeColor,
                            ),
                          ),
                        ],
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

  Widget _buildStatCard(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: orangeColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 12, color: Color(0xFF9E9E9E), height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoriqueCard(String value, String label,
      {required bool isOrange}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isOrange ? 13 : 20,
              fontWeight: FontWeight.w700,
              color: isOrange ? orangeColor : const Color(0xFF3E2723),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 11, color: Color(0xFF9E9E9E), height: 1.3),
          ),
        ],
      ),
    );
  }
}
