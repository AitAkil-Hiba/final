// ignore_for_file: unnecessary_import, dangling_library_doc_comments

/// Carte offre anti-gaspillage
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:peeco/client/pages/peeco_colors.dart';
import 'package:peeco/client/pages/peeco_gradient_background.dart';
import 'package:peeco/client/pages/peeco_text_field.dart';

class OffreCard extends StatelessWidget {
  final String nom;
  final String commercant;
  final String adresse;
  final String prix;
  final String prixOriginal;
  final String distance;
  final double note;
  final int restants;
  final String creneau;
  final String categorie;
  final VoidCallback? onTap;
 
  const OffreCard({
    super.key,
    required this.nom,
    required this.commercant,
    required this.adresse,
    required this.prix,
    required this.prixOriginal,
    required this.distance,
    required this.note,
    required this.restants,
    required this.creneau,
    required this.categorie,
    this.onTap,
  });
 
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: PeecoCard(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image placeholder avec overlay
            Stack(
              children: [
                Container(
                  height: 130,
                  decoration: const BoxDecoration(
                    gradient: PeecoColors.gradientSplash,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  child: Center(
                    child: Icon(
                      categorie == 'Restaurant'
                          ? Icons.restaurant
                          : categorie == 'Boulangerie'
                              ? Icons.bakery_dining
                              : Icons.shopping_basket,
                      size: 48,
                      color: PeecoColors.accentGreen,
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: PeecoStatusBadge(
                    label: '$restants restants',
                    color: restants <= 2
                        ? PeecoColors.error
                        : PeecoColors.success,
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: PeecoColors.backgroundCard,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.star, size: 12, color: Color(0xFFFFC107)),
                        const SizedBox(width: 3),
                        Text(note.toString(),
                            style: const TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // Infos
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(nom,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text(commercant,
                      style: const TextStyle(
                          color: PeecoColors.textSecondary, fontSize: 12)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 12, color: PeecoColors.textHint),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(adresse,
                            style: const TextStyle(
                                color: PeecoColors.textHint, fontSize: 11),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                      ),
                      Text(distance,
                          style: const TextStyle(
                              color: PeecoColors.textHint, fontSize: 11)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(prix,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              color: PeecoColors.textPrimary)),
                      const SizedBox(width: 6),
                      Text(prixOriginal,
                          style: const TextStyle(
                              decoration: TextDecoration.lineThrough,
                              color: PeecoColors.textHint,
                              fontSize: 12)),
                      const Spacer(),
                      const Icon(Icons.access_time,
                          size: 12, color: PeecoColors.textHint),
                      const SizedBox(width: 3),
                      Text(creneau,
                          style: const TextStyle(
                              color: PeecoColors.textHint, fontSize: 11)),
                    ],
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