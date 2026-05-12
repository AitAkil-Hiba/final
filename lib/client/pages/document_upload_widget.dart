// ignore_for_file: use_key_in_widget_constructors, unnecessary_import, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:peeco/client/pages/peeco_colors.dart';

class DocumentUploadWidget extends StatelessWidget {
  final String title;
  final IconData icon;
 
  const DocumentUploadWidget(
      {required this.title, required this.icon});
 
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: PeecoColors.backgroundSecondary.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: PeecoColors.accentGreen,
          style: BorderStyle.solid,
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, size: 32, color: PeecoColors.accentGreen),
          const SizedBox(height: 8),
          Text(title,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          const SizedBox(height: 4),
          const Text('Glisser le fichier ici ou parcourir',
              style:
                  TextStyle(color: PeecoColors.textSecondary, fontSize: 12)),
          const SizedBox(height: 2),
          const Text('JPG, PNG ou PDF — max 5 Mo',
              style: TextStyle(color: PeecoColors.textHint, fontSize: 11)),
        ],
      ),
    );
  }
}