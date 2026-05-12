import 'package:flutter/material.dart';
import 'package:peeco/client/pages/peeco_colors.dart';
import 'package:peeco/client/pages/home_client_screen.dart';
import 'package:peeco/client/pages/app_constants.dart';

class AppNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const AppNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final icons = [
      Icons.favorite_border,
      Icons.search,
      Icons.home_outlined,
      Icons.shopping_bag_outlined,
      Icons.person_outline,
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(10, 0, 10, 10),
      height: 60,
      decoration: BoxDecoration(
        color: AppColors.navBg,
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(icons.length, (i) {
          final bool sel = i == selectedIndex;
          return GestureDetector(
            onTap: () => onTap(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: sel ? AppColors.white : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icons[i],
                size: 22,
                color: sel
                    ? AppColors.textDark
                    : AppColors.textDark.withOpacity(0.55),
              ),
            ),
          );
        }),
      ),
    );
  }

  static void handleNavigation(BuildContext context, int index) {
    switch (index) {
      case 0:
        Navigator.pushNamed(context, '/favoris');
        break;
      case 1:
        Navigator.pushNamed(context, '/carte');
        break;
      case 2:
        Navigator.pushNamed(context, '/home_client');
        break;
      case 3:
        Navigator.pushNamed(context, '/reservations');
        break;
      case 4:
        Navigator.pushNamed(context, '/profil_client');
        break;
    }
  }
}
