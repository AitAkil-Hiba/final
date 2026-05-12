import 'package:flutter/material.dart';

class NotificationClientSettings {
  static final NotificationClientSettings _instance =
      NotificationClientSettings._internal();
  factory NotificationClientSettings() => _instance;
  NotificationClientSettings._internal();

  Map<String, bool> pushEnabled = {
    'Tout': true,
    'Activité': true,
    'Offres': true,
  };
}

class GestionNotificationsClientPage extends StatefulWidget {
  const GestionNotificationsClientPage({super.key});

  @override
  State<GestionNotificationsClientPage> createState() =>
      _GestionNotificationsClientPageState();
}

class _GestionNotificationsClientPageState
    extends State<GestionNotificationsClientPage> {
  static const Color topBarColor = Color(0xFFCCD5AE);
  static const Color backgroundColor = Color(0xFFFEFAE0);
  static const Color cardColor = Color(0xFFF5EED8);
  static const Color orangeColor = Color(0xFFE8824A);

  final NotificationClientSettings _settings = NotificationClientSettings();

  void _toggle(String key, bool value) {
    setState(() {
      _settings.pushEnabled[key] = value;
      if (key == 'Tout') {
        for (final k in _settings.pushEnabled.keys) {
          _settings.pushEnabled[k] = value;
        }
      }
    });
  }

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
                    'Notifications',
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
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    const Text(
                      'Gestion des notifications',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF3E2723),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Choisissez les notifications push que vous souhaitez recevoir sur votre téléphone.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF9E9E9E),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 28),
                    // Toggle "Tout"
                    _buildToggleRow(
                      label: 'Tout',
                      isMain: true,
                      value: _settings.pushEnabled['Tout']!,
                      onChanged: (v) => _toggle('Tout', v),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          _buildToggleRow(
                            label: 'Activité',
                            value: _settings.pushEnabled['Activité']!,
                            onChanged: (v) => _toggle('Activité', v),
                            hasDivider: true,
                          ),
                          _buildToggleRow(
                            label: 'Offres',
                            value: _settings.pushEnabled['Offres']!,
                            onChanged: (v) => _toggle('Offres', v),
                            hasDivider: false,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Icon(
                            Icons.info_outline,
                            size: 16,
                            color: Color(0xFF9E9E9E),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Désactiver une catégorie empêche les notifications push sur votre téléphone. Toutes vos notifications restent toujours accessibles dans l\'application.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF9E9E9E),
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Bouton Sauvegarder
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        decoration: BoxDecoration(
                          color: orangeColor,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Center(
                          child: Text(
                            'Sauvegarder',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
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

  Widget _buildToggleRow({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool isMain = false,
    bool hasDivider = false,
  }) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isMain ? 0 : 16,
            vertical: 14,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: isMain ? 18 : 15,
                    fontWeight: isMain ? FontWeight.w700 : FontWeight.w500,
                    color: const Color(0xFF3E2723),
                  ),
                ),
              ),
              Switch(
                value: value,
                onChanged: onChanged,
                activeColor: Colors.white,
                activeTrackColor: orangeColor,
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: const Color(0xFFD7CFC0),
                trackOutlineColor: MaterialStateProperty.all(
                  Colors.transparent,
                ),
              ),
            ],
          ),
        ),
        if (hasDivider)
          Divider(
            height: 1,
            thickness: 1,
            color: Colors.white.withOpacity(0.6),
            indent: 16,
            endIndent: 16,
          ),
      ],
    );
  }
}
