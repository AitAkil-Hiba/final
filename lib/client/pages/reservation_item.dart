
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:peeco/client/pages/peeco_colors.dart';
import 'package:peeco/client/pages/peeco_text_field.dart';

class ReservationItem extends StatelessWidget {
  final String code;
  final String client;
  final String creneau;
 
  const ReservationItem({
    required this.code,
    required this.client,
    required this.creneau,
  });
 
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: PeecoColors.backgroundSecondary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                client.substring(0, 1),
                style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: PeecoColors.textPrimary),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(client,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14)),
                Text('Code : $code · $creneau',
                    style: const TextStyle(
                        color: PeecoColors.textSecondary, fontSize: 12)),
              ],
            ),
          ),
          PeecoStatusBadge(
            label: 'Réservé',
            color: PeecoColors.accentGreen,
          ),
        ],
      ),
    );
  }
}