import 'package:flutter/material.dart';
import 'documents_page.dart';
import 'avis_evaluation.dart';
import 'documents_juridiques_page.dart';
import 'aide_support_page.dart';
import '../statistiques_page.dart';
import 'notifications/notifications_page.dart';
import '../mes_commandes_page.dart';
import '../creer_offre/creer_offre_step1.dart';
import 'informations_personnelles_menu_page.dart';
import 'package:peeco/core/pages/role_selection_page.dart';
import 'Securite_page.dart';

class ProfilCommercant extends StatefulWidget {
  const ProfilCommercant({super.key});

  @override
  State<ProfilCommercant> createState() => _ProfilCommercantState();
}

class _ProfilCommercantState extends State<ProfilCommercant> {
  int _selectedNavIndex = 4;

  // Couleurs exactes du design
  static const Color topBarColor = Color(0xFFCCD5AE);
  static const Color backgroundColor = Color(0xFFFEFAE0);
  static const Color unselectedNavColor = Color(0xFFE9EDC9);
  static const Color selectedNavColor = Color(0xFFDDCD9E);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Container(height: 8, color: topBarColor),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    _buildProfileHeader(),
                    const SizedBox(height: 40),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle('Compte'),
                          const SizedBox(height: 16),
                          _buildMenuItem(
                            icon: Icons.person_outline,
                            title: 'Informations personnelles',
                            onTap: () => _handleNavigation('personal_info'),
                          ),
                          _buildMenuItem(
                            icon: Icons.notifications_none_outlined,
                            title: 'Notifications',
                            onTap: () => _handleNavigation('notifications'),
                          ),
                          _buildMenuItem(
                            icon: Icons.lock_outline,
                            title: 'Sécurité',
                            onTap: () => _handleNavigation('security'),
                          ),
                          _buildMenuItem(
                            icon: Icons.description_outlined,
                            title: 'Documents',
                            showBadge: true,
                            onTap: () => _handleNavigation('documents'),
                          ),
                          const SizedBox(height: 28),
                          _buildSectionTitle('Réputation'),
                          const SizedBox(height: 16),
                          _buildMenuItem(
                            icon: Icons.star_outline,
                            title: 'Avis & évaluations',
                            onTap: () => _handleNavigation('reviews'),
                          ),
                          const SizedBox(height: 28),
                          _buildSectionTitle('Aide'),
                          const SizedBox(height: 16),
                          _buildMenuItem(
                            icon: Icons.help_outline,
                            title: 'Aide & support',
                            onTap: () => _handleNavigation('support'),
                          ),
                          _buildMenuItem(
                            icon: Icons.folder_outlined,
                            title: 'Documents Juridiques',
                            onTap: () => _handleNavigation('legal'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 36),
                    Center(
                      child: Container(
                        decoration: BoxDecoration(
                          color: topBarColor,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _handleLogout,
                            borderRadius: BorderRadius.circular(30),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 28,
                                vertical: 14,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: const Color(0xFF5D4E37),
                                        width: 1.5,
                                      ),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Icon(
                                      Icons.arrow_back,
                                      size: 14,
                                      color: Color(0xFF5D4E37),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Text(
                                    'Se déconnecter',
                                    style: TextStyle(
                                      color: Color(0xFF5D4E37),
                                      fontWeight: FontWeight.w500,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: TextButton(
                        onPressed: _handleDeleteAccount,
                        child: const Text(
                          'Supprimer mon compte',
                          style: TextStyle(
                            color: Color(0xFF5D4E37),
                            fontSize: 14,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
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

  Widget _buildProfileHeader() {
    return Center(
      child: Column(
        children: [
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFFFF8E1),
              border: Border.all(color: const Color(0xFF8B7355), width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipOval(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 55,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD2691E),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.lunch_dining,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'BURGER',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF5D4037),
                      ),
                    ),
                    const Text(
                      'HOUSE',
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF5D4037),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Boulangerie El Baraka',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF3E2723),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'boulangerie.elbaraka@email.com',
            style: TextStyle(fontSize: 14, color: Color(0xFF757575)),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: topBarColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFF4CAF50),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Profil Commerçant',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF5D4E37),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Color(0xFF3E2723),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    VoidCallback? onTap,
    bool showBadge = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 22, color: const Color(0xFF757575)),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontSize: 15, color: Color(0xFF424242)),
              ),
            ),
            if (showBadge)
              Container(
                width: 10,
                height: 10,
                margin: const EdgeInsets.only(right: 8),
                decoration: const BoxDecoration(
                  color: Color(0xFFFF9800),
                  shape: BoxShape.circle,
                ),
              ),
            const Icon(Icons.chevron_right, size: 22, color: Color(0xFFBDBDBD)),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: topBarColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(Icons.shopping_bag_outlined, 0),
          _buildNavItem(Icons.add, 1),
          _buildNavItem(Icons.home_outlined, 2),
          _buildNavItem(Icons.show_chart, 3),
          _buildNavItem(Icons.person_outline, 4),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index) {
    final isSelected = _selectedNavIndex == index;
    return GestureDetector(
      onTap: () {
        if (index == 4) return; // déjà ici
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
        if (index == 3) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const StatistiquesPage()),
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
          icon,
          size: 24,
          color: isSelected ? const Color(0xFF5D4037) : const Color(0xFF7D7D7D),
        ),
      ),
    );
  }

  void _handleNavigation(String route) {
    /////////////////
    if (route == 'personal_info') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const InformationsPersonnellesMenuPage(),
        ),
      );
      return;
    }
    ///////////
    if (route == 'security') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => /*const*/ SecuritePage()),
      );
      return;
    }

    if (route == 'notifications') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const NotificationsPage()),
      );
      return;
    }
    if (route == 'reviews') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AvisEvaluationsPage()),
      );
      return;
    }
    if (route == 'documents') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => DocumentsPage()),
      );
      return;
    }
    if (route == 'legal') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const DocumentsJuridiquesPage(),
        ),
      );
      return;
    }
    if (route == 'support') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AideSupportPage()),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Navigation vers: $route'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Voulez-vous vraiment vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const ChoicePage()),
                (route) => false,
              );
            },
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );
  }

  void _handleDeleteAccount() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le compte'),
        content: const Text(
          'Cette action est irréversible. Voulez-vous vraiment supprimer votre compte ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}
