// ─────────────────────────────────────────────
//  FAVORIS — Merchants favorites
//  - Liste des commerçants favoris
//  - Distance, localisation, offres
//  - Tap → profil commerçant
//  - X → supprimer des favoris
// ─────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:peeco/client/pages/navigation_bar.dart';
import 'package:peeco/client/pages/app_constants.dart';
import 'package:peeco/client/pages/widgets/standard_header.dart';
import 'package:peeco/client/pages/widgets/standard_card.dart';
import 'package:peeco/client/pages/profil_commercant_client_screen.dart'; // ← AJOUT

// ─────────────────────────────────────────────
// COULEURS - Using AppConstants now
// ─────────────────────────────────────────────

// ─────────────────────────────────────────────
// MODÈLE
// ─────────────────────────────────────────────
class FavoriMerchant {
  final String id;
  final String nom;
  final String categorie;
  final String adresse;
  final double distance;
  final int nbOffres;
  final String imageAsset;

  FavoriMerchant({
    required this.id,
    required this.nom,
    required this.categorie,
    required this.adresse,
    required this.distance,
    required this.nbOffres,
    required this.imageAsset,
  });
}

// ─────────────────────────────────────────────
// DONNÉES FICTIVES
// ─────────────────────────────────────────────
final List<FavoriMerchant> _favoris = [
  FavoriMerchant(
    id: 'f1',
    nom: 'LE MOULIN DORE',
    categorie: 'Boulangerie',
    adresse: 'Rue des Belges, Kouba',
    distance: 0.5,
    nbOffres: 3,
    imageAsset: 'assets/images/moulin_dore.png',
  ),
  FavoriMerchant(
    id: 'f2',
    nom: 'L\'ASSIETTE DES ANGLES',
    categorie: 'Restaurant',
    adresse: 'Centre commercial, Alger',
    distance: 1.2,
    nbOffres: 5,
    imageAsset: 'assets/images/assiette_angles.png',
  ),
  FavoriMerchant(
    id: 'f3',
    nom: 'LE PANIER FRAIS',
    categorie: 'Superette',
    adresse: 'Laprovale, Kouba',
    distance: 0.9,
    nbOffres: 2,
    imageAsset: 'assets/images/panier_frais.png',
  ),
];

// ─────────────────────────────────────────────
// FAVORIS SCREEN
// ─────────────────────────────────────────────
class FavorisScreen extends StatefulWidget {
  const FavorisScreen({super.key});

  @override
  State<FavorisScreen> createState() => _FavorisScreenState();
}

class _FavorisScreenState extends State<FavorisScreen> {
  List<FavoriMerchant> get _favorisListe => _favoris;

  // Fonction pour supprimer un favori
  void _supprimerFavori(FavoriMerchant merchant) {
    setState(() {
      _favoris.remove(merchant);
    });
    
    // Notification de suppression
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${merchant.nom} retiré des favoris'),
        backgroundColor: AppColors.accent,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      body: Stack(
        children: [
          // Main content
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StandardHeader(
                  title: 'Mes favoris',
                  showLogo: false,
                  showSearchBar: false,
                  showBackButton: false,
                ),
                const SizedBox(height: AppSpacing.lg),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Mes favoris',
                            style: TextStyle(
                                fontSize: AppTextSizes.titleLarge,
                                fontWeight: AppFontWeights.extraBold,
                                color: AppColors.textDark)),
                        const SizedBox(height: AppSpacing.md),
                        // Liste des favoris
                        ..._favorisListe.map((f) => _favoriItem(f)),
                        if (_favorisListe.isEmpty)
                          _emptyState(),
                        const SizedBox(height: AppSpacing.xxl),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Navigation bar
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: AppNavigationBar(
              selectedIndex: 0, // Heart/favorites is index 0
              onTap: (index) {
                AppNavigationBar.handleNavigation(context, index);
              },
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // ÉTAT VIDE
  // ─────────────────────────────────────────────
  Widget _emptyState() {
    return Padding(
      padding: const EdgeInsets.only(top: 60),
      child: Center(
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.divider.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.favorite_border,
                size: 40,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Aucun favori pour le moment',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Ajoutez des commerçants en favoris pour les retrouver ici',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textMuted,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // ITEM FAVORI — avec tap vers profil commerçant
  // ─────────────────────────────────────────────
  Widget _favoriItem(FavoriMerchant f) {
    return GestureDetector(
      onTap: () {
        // Navigation vers le profil du commerçant
        final donneesCommercant = DonneesCommercant(
          nom: f.nom,
          email: '${f.nom.toLowerCase().replaceAll(' ', '')}@email.com',
          adresse: f.adresse,
          nbOffres: f.nbOffres,
          nbReservations: 0, // À remplacer par des données réelles
          note: 4.5, // Note par défaut, à remplacer
          revenus: '0 DA',
          description: 'Découvrez les offres de ${f.nom}.',
          logoAsset: f.imageAsset,
        );
        
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProfilCommercantClientScreen(
              commercant: donneesCommercant,
            ),
          ),
        );
      },
      child: StandardCard(
        title: f.nom,
        category: f.categorie,
        subtitle: f.adresse,
        distance: '${f.distance.toStringAsFixed(1)} km',
        imagePath: f.imageAsset,
        trailing: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
            onTap: () => _supprimerFavori(f),
            child: const Icon(
              Icons.close,
              size: 20,
              color: AppColors.textMuted, // Gris
            ),
          ),
            const SizedBox(height: AppSpacing.sm),
            // Nombre d'offres
            StandardChip(
              label: '${f.nbOffres} offres',
              backgroundColor: AppColors.accent,
              textColor: AppColors.white,
            ),
          ],
        ),
      ),
    );
  }
}