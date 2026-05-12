
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:peeco/client/pages/peeco_colors.dart';

class ProfileCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final List<String> features;
  final bool isSelected;
  final Color selectedColor;
  final VoidCallback onTap;

  const ProfileCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.features,
    required this.isSelected,
    required this.selectedColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected
              ? selectedColor.withOpacity(0.15)
              : PeecoColors.backgroundCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? selectedColor : PeecoColors.border,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: selectedColor.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icône
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isSelected
                    ? selectedColor
                    : PeecoColors.backgroundSecondary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon,
                  color: isSelected ? Colors.white : PeecoColors.textSecondary),
            ),
            const SizedBox(height: 10),
            Text(title,
                style: const TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 15)),
            const SizedBox(height: 4),
            Text(subtitle,
                style: const TextStyle(
                    color: PeecoColors.textSecondary,
                    fontSize: 11,
                    height: 1.3)),
            const SizedBox(height: 10),
            // Features visibles seulement si sélectionné
            if (isSelected)
              ...features.map((f) => Padding(
                    padding: const EdgeInsets.only(bottom: 3),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle,
                            size: 12, color: selectedColor),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(f,
                              style: const TextStyle(
                                  fontSize: 10,
                                  color: PeecoColors.textSecondary)),
                        ),
                      ],
                    ),
                  )),
          ],
        ),
      ),
    );
  }
}