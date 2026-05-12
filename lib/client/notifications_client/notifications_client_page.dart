import 'package:flutter/material.dart';
import 'gestion_notifications_client_page.dart';

class NotificationsClientPage extends StatefulWidget {
  const NotificationsClientPage({super.key});

  @override
  State<NotificationsClientPage> createState() =>
      _NotificationsClientPageState();
}

class _NotificationsClientPageState extends State<NotificationsClientPage> {
  int _selectedFilter = 0;

  static const Color topBarColor = Color(0xFFCCD5AE);
  static const Color backgroundColor = Color(0xFFFEFAE0);
  static const Color cardColor = Color(0xFFF5EED8);
  static const Color orangeColor = Color(0xFFE8824A);
  static const Color brownColor = Color(0xFF5D4E37);

  final List<String> _filters = ['Tout', 'Activité', 'Offres'];

  final List<Map<String, dynamic>> _allNotifications = [
    {
      'icon': Icons.local_offer_outlined,
      'iconBg': Color(0xFF8B9E6B),
      'iconColor': Colors.white,
      'title': 'Offre proche de vous',
      'time': 'Il y a 3 min',
      'filter': 'Offres',
      'initials': null,
      'isFood': false,
    },
    {
      'icon': null,
      'iconBg': Color(0xFFD7CFC0),
      'iconColor': Colors.white,
      'title': 'Votre commande a été confirmée',
      'time': 'Il y a 12 min',
      'filter': 'Activité',
      'initials': null,
      'isFood': true,
    },
    {
      'icon': null,
      'iconBg': Color(0xFFD7CFC0),
      'iconColor': Colors.white,
      'title': 'Votre commande est prête',
      'time': 'Il y a 26 min',
      'filter': 'Activité',
      'initials': null,
      'isFood': true,
    },
    {
      'icon': null,
      'iconBg': Color(0xFFD7CFC0),
      'iconColor': Colors.white,
      'title': 'Votre commande expire bientôt',
      'time': 'Il y a 48 min',
      'filter': 'Activité',
      'initials': null,
      'isFood': true,
    },
    {
      'icon': null,
      'iconBg': Color(0xFFD7CFC0),
      'iconColor': Colors.white,
      'title': 'Votre commande est en cours de préparation',
      'time': 'Il y a 2h',
      'filter': 'Activité',
      'initials': null,
      'isFood': true,
    },
    {
      'icon': null,
      'iconBg': Color(0xFFD7CFC0),
      'iconColor': Colors.white,
      'title': 'Votre commande a été confirmée',
      'time': 'Il y a 2h 27 min',
      'filter': 'Activité',
      'initials': null,
      'isFood': true,
    },
    {
      'icon': Icons.favorite_border,
      'iconBg': Color(0xFFD7CFC0),
      'iconColor': Color(0xFF5D4E37),
      'title': 'Nouvelle offre d\'un commerçant que vous avez sauvegardé',
      'time': 'Il y a 5h',
      'filter': 'Offres',
      'initials': null,
      'isFood': false,
    },
  ];

  List<Map<String, dynamic>> get _filteredNotifications {
    final filterName = _selectedFilter == 0 ? null : _filters[_selectedFilter];
    return _allNotifications.where((n) {
      final category = n['filter'] as String;
      if (filterName != null && category != filterName) return false;
      return true;
    }).toList();
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
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const GestionNotificationsClientPage(),
                      ),
                    ),
                    child: Text(
                      'Gestion des notifications',
                      style: TextStyle(
                        fontSize: 12,
                        color: orangeColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 42,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _filters.length,
                itemBuilder: (context, i) {
                  final isSelected = _selectedFilter == i;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedFilter = i),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? orangeColor : cardColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _filters[i],
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: isSelected ? Colors.white : brownColor,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _filteredNotifications.isEmpty
                  ? const Center(
                      child: Text(
                        'Aucune notification',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF9E9E9E),
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _filteredNotifications.length,
                      itemBuilder: (context, index) {
                        return _buildNotifItem(_filteredNotifications[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotifItem(Map<String, dynamic> notif) {
    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: cardColor,
        border: Border(
          bottom: BorderSide(color: Colors.white.withOpacity(0.6), width: 1),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: notif['iconBg'] as Color,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: notif['isFood'] == true
                  ? const Icon(
                      Icons.lunch_dining,
                      size: 22,
                      color: Color(0xFF8B7355),
                    )
                  : Icon(
                      notif['icon'] as IconData,
                      size: 22,
                      color: notif['iconColor'] as Color,
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notif['title'] as String,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF3E2723),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  notif['time'] as String,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF9E9E9E),
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, size: 18, color: Color(0xFFBDBDBD)),
        ],
      ),
    );
  }
}
