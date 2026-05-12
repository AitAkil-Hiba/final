import 'package:flutter/material.dart';
import 'dart:io';

class SignalerClientPage extends StatefulWidget {
  const SignalerClientPage({super.key});

  @override
  State<SignalerClientPage> createState() => _SignalerClientPageState();
}

class _SignalerClientPageState extends State<SignalerClientPage> {
  int? _selectedRaison;
  final TextEditingController _descController = TextEditingController();
  bool _showSuccess = false;

  static const Color topBarColor = Color(0xFFCCD5AE);
  static const Color backgroundColor = Color(0xFFFEFAE0);
  static const Color cardColor = Color(0xFFF5EED8);
  static const Color orangeColor = Color(0xFFE8824A);
  static const Color brownColor = Color(0xFF5D4E37);

  final List<String> _raisons = [
    'Le client ne récupère pas ses commandes',
    'Annulations fréquentes',
    'Comportement irrespectueux',
    'Abus ou utilisation frauduleuse',
    'Autre',
  ];

  @override
  void dispose() {
    _descController.dispose();
    super.dispose();
  }

  void _handleSend() {
    if (_selectedRaison == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner une raison'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    setState(() => _showSuccess = true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            // ── Main content ──
            Column(
              children: [
                Container(height: 8, color: topBarColor),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
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
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        // Title
                        const Center(
                          child: Text(
                            'Signaler ce client',
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF3E2723),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Center(
                          child: Text(
                            'Aidez-nous à comprendre le problème en\nsélectionnant une raison.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF9E9E9E),
                              height: 1.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),
                        // Radio buttons
                        ..._raisons.asMap().entries.map((entry) {
                          final i = entry.key;
                          final label = entry.value;
                          final isSelected = _selectedRaison == i;
                          return GestureDetector(
                            onTap: () => setState(() => _selectedRaison = i),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                              decoration: BoxDecoration(
                                color: cardColor,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isSelected
                                      ? orangeColor
                                      : Colors.transparent,
                                  width: 1.5,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 22,
                                    height: 22,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: isSelected
                                            ? orangeColor
                                            : const Color(0xFFBDB5A0),
                                        width: 2,
                                      ),
                                    ),
                                    child: isSelected
                                        ? Center(
                                            child: Container(
                                              width: 10,
                                              height: 10,
                                              decoration: BoxDecoration(
                                                color: orangeColor,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                          )
                                        : null,
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Text(
                                      label,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: isSelected
                                            ? brownColor
                                            : const Color(0xFF424242),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                        const SizedBox(height: 20),
                        // Description
                        const Text(
                          'Description (optionnel)',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF3E2723),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: TextField(
                            controller: _descController,
                            maxLines: 5,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF424242),
                            ),
                            decoration: const InputDecoration(
                              hintText:
                                  'Expliquez le problème en quelques détails...',
                              hintStyle: TextStyle(
                                fontSize: 13,
                                color: Color(0xFFBDB5A0),
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.all(14),
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),
                        // Send button
                        GestureDetector(
                          onTap: _handleSend,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            decoration: BoxDecoration(
                              color: orangeColor,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: const Center(
                              child: Text(
                                'Envoyer le signalement',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // ── Success overlay ──
            if (_showSuccess)
              Positioned.fill(
                child: Stack(
                  children: [
                    Container(color: Colors.black.withOpacity(0.15)),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 36,
                        ),
                        decoration: const BoxDecoration(
                          color: Color(0xFFDDE5C4),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30),
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: orangeColor,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check,
                                color: Colors.black,
                                size: 44,
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'Merci pour votre contribution',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF3E2723),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Signalement envoyé avec succès',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF757575),
                              ),
                            ),
                            const SizedBox(height: 28),
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE8DCC0),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: const Center(
                                  child: Text(
                                    'Retour',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: brownColor,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
