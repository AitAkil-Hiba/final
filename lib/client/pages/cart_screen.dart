// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:peeco/client/pages/navigation_bar.dart';
import 'package:peeco/client/pages/app_constants.dart';
import 'package:peeco/client/pages/widgets/standard_header.dart';
import 'package:peeco/client/pages/widgets/standard_card.dart';

// ─────────────────────────────────────────────
// MODÈLE — Article du panier
// ─────────────────────────────────────────────
class CartItem {
  final String id;
  final String nom;
  final String commercant;
  final String categorie;
  final String imageAsset;
  final double prix;
  final double prixOriginal;

  int quantite;

  CartItem({
    required this.id,
    required this.nom,
    required this.commercant,
    required this.categorie,
    required this.imageAsset,
    required this.prix,
    required this.prixOriginal,
    this.quantite = 1, 
    
  });

  double get sousTotal => prix * quantite;
}

// ─────────────────────────────────────────────
// COULEURS - Using AppConstants now
// ─────────────────────────────────────────────

// ─────────────────────────────────────────────
// CART SCREEN
// ─────────────────────────────────────────────
class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {

  // ── données fictives (à remplacer par votre provider / state management) ──
  final List<CartItem> _items = [
    CartItem(
      id: '1',
      nom: 'Corbeille du Matin',
      commercant: 'Le Moulin Doré',
      categorie: 'Boulangerie',
      imageAsset: 'assets/images/corbeille_matin.png',
      prix: 350,
      prixOriginal: 600,
      quantite: 1,
     
    ),
    CartItem(
      id: '2',
      nom: 'Burger Maison + Frites',
      commercant: "L'Assiette des Angles",
      categorie: 'Restaurant',
      imageAsset: 'assets/images/burger_house2.png',
      prix: 780,
      prixOriginal: 1100,
      quantite: 2,
    ),
    CartItem(
      id: '3',
      nom: 'Panier Légumes Frais',
      commercant: 'Le Panier Frais',
      imageAsset: 'assets/images/legumes_frais.png',
      categorie: 'Superette',
      prix: 450,
      prixOriginal: 700,
      quantite: 1,
    ),
    CartItem(
     id: '4',
    nom: 'Le Moulin Doré',
    commercant: '',
    imageAsset: 'assets/images/moulin_dore.png', 
    categorie: 'Boulangerie',
    prix:450 ,
    prixOriginal: 700,
    quantite: 2,       
    ),
    CartItem(
     id: '5',
     nom: 'Burger House',
      categorie: 'Restaurant',
      commercant: 'Vieux Kouba, Kouba, Alger',
      prix:500,
      prixOriginal: 1.5,
      quantite: 4,
      imageAsset: 'assets/images/burger_house2.png',
    ),
  ];

  // ── totaux ──
  double get _sousTotal  => _items.fold(0, (s, i) => s + i.sousTotal);
  double get _economies  => _items.fold(0, (s, i) => (i.prixOriginal - i.prix) * i.quantite);
  double get _total      => _sousTotal;

  // ── couleur catégorie ──
  Color _catColor(String c) {
    switch (c) {
      case 'Boulangerie': return AppColors.accent;
      case 'Restaurant':  return AppColors.chipDark;
      case 'Superette':   return const Color(0xFF5A9E8B);
      default:            return AppColors.textMuted;
    }
  }

  Object _catIcon(String c) {
    switch (c) {
      case 'Boulangerie': return Image.asset('assets/images/corbeille_matin.png');
      case 'Restaurant':  return Image.asset('assets/images/burger_house.png');
      case 'Superette':   return Image.asset('assets/images/legumes_frais.png');
      default:            return Icons.storefront_outlined;
    }
  }

  void _incrementer(CartItem item) => setState(() => item.quantite++);

  void _decrementer(CartItem item) {
    setState(() {
      if (item.quantite > 1) {
        item.quantite--;
      } else {
        _items.remove(item);
      }
    });
  }

  void _supprimer(CartItem item) {
    setState(() => _items.remove(item));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item.nom} retiré du panier'),
        backgroundColor: AppColors.textDark,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _confirmerCommande() {
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Votre panier est vide'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _ConfirmationSheet(
        total: _total,
        nbArticles: _items.fold(0, (s, i) => s + i.quantite),
        onConfirm: () {
          // Process order
          setState(() {
            _items.clear();
          });
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Commande confirmée ! Vous serez notifié lors de la préparation.'),
              backgroundColor: AppColors.accentGreen,
              duration: Duration(seconds: 3),
            ),
          );
        },
      ),
    );
  }

  // ─────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: StandardHeader(
                    title: 'Mon Panier',
                    showLogo: false,
                    showSearchBar: false,
                    showBackButton: false,
                    trailing: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${_items.fold(0, (s, i) => s + i.quantite)}',
                          style: const TextStyle(
                              fontSize: AppTextSizes.bodySmall,
                              fontWeight: AppFontWeights.extraBold,
                              color: AppColors.white),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              if (_items.isEmpty)
                SliverFillRemaining(child: _emptyState())
              else ...[
                SliverToBoxAdapter(child: _badgeEconomies()),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) => _articleCard(_items[i]),
                    childCount: _items.length,
                  ),
                ),
                SliverToBoxAdapter(child: _recapCommande()),
                const SliverToBoxAdapter(child: SizedBox(height: 130)),
              ],
            ],
          ),
          if (_items.isNotEmpty)
            Positioned(
              bottom: 0, left: 0, right: 0,
              child: _boutonCommander(),
            ),
          // Navigation bar
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: AppNavigationBar(
              selectedIndex: 1, // Cart is typically index 1 (search/cart)
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
  // BADGE ÉCONOMIES
  // ─────────────────────────────────────────────
  Widget _badgeEconomies() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: const Color(0xFFD4EBC5),
          borderRadius: BorderRadius.circular(AppBorderRadius.medium),
          border: Border.all(
              color: const Color(0xFF8AB87A).withOpacity(0.5)),
        ),
        child: Row(
          children: [
            const SizedBox(width: AppSpacing.sm),
            Text(
              'Vous économisez ${_economies.toStringAsFixed(0)} DA sur cette commande !',
              style: const TextStyle(
                fontSize: AppTextSizes.bodySmall,
                fontWeight: AppFontWeights.bold,
                color: Color(0xFF3B6D11),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // CARTE ARTICLE
  // ─────────────────────────────────────────────
  Widget _articleCard(CartItem item) {
    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, 0),
        decoration: BoxDecoration(
          color: AppColors.danger,
          borderRadius: BorderRadius.circular(AppBorderRadius.large),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.lg),
        child: const Icon(Icons.delete_outline, 
            color: AppColors.white, size: 24),
      ),
      onDismissed: (_) => _supprimer(item),
      child: StandardCard(
        title: item.nom,
        subtitle: item.commercant,
        category: item.categorie,
        price: '${item.prix.toStringAsFixed(0)} DA',
        imagePath: item.imageAsset,
        imageWidth: 80,
        imageHeight: 80,
        trailing: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _qtyButton(Icons.add, () => _incrementer(item)),
            const SizedBox(height: AppSpacing.xs),
            Text('${item.quantite}',
                style: const TextStyle(
                    fontSize: AppTextSizes.bodyLarge,
                    fontWeight: AppFontWeights.extraBold,
                    color: AppColors.textDark)),
            const SizedBox(height: AppSpacing.xs),
            _qtyButton(
              item.quantite == 1 ? Icons.delete_outline : Icons.remove,
              () => _decrementer(item),
              danger: item.quantite == 1,
            ),
          ],
        ),
      ),
    );
  }

  Widget _qtyButton(IconData icon, VoidCallback onTap,
      {bool danger = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: danger
              ? AppColors.danger.withOpacity(0.1)
              : AppColors.navBg.withOpacity(0.45),
          shape: BoxShape.circle,
          border: Border.all(
              color: danger
                  ? AppColors.danger.withOpacity(0.3)
                  : AppColors.divider,
              width: 0.8),
        ),
        child: Icon(icon,
            size: 14,
            color: danger ? AppColors.danger : AppColors.textDark),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // RÉCAP COMMANDE
  // ─────────────────────────────────────────────
  Widget _recapCommande() {
    return Container(
      margin: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 0),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(AppBorderRadius.xlarge),
        border: Border.all(color: AppColors.divider.withOpacity(0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Récapitulatif',
              style: TextStyle(
                  fontSize: AppTextSizes.titleSmall,
                  fontWeight: AppFontWeights.extraBold,
                  color: AppColors.textDark)),
          const SizedBox(height: AppSpacing.md),
          _ligneRecap('Sous-total',
              '${_sousTotal.toStringAsFixed(0)} DA'),
          const SizedBox(height: AppSpacing.sm),
          _ligneRecap('Économies',
              '- ${_economies.toStringAsFixed(0)} DA',
              valueColor: const Color(0xFF3B6D11)),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: Divider(color: AppColors.divider, height: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total',
                  style: TextStyle(
                      fontSize: AppTextSizes.titleSmall,
                      fontWeight: AppFontWeights.extraBold,
                      color: AppColors.textDark)),
              Text('${_total.toStringAsFixed(0)} DA',
                  style: const TextStyle(
                      fontSize: AppTextSizes.titleMedium,
                      fontWeight: AppFontWeights.black,
                      color: AppColors.accent)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _ligneRecap(String label, String valeur, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: AppTextSizes.bodySmall, color: AppColors.textMuted)),
        Text(valeur,
            style: TextStyle(
                fontSize: AppTextSizes.bodySmall,
                fontWeight: AppFontWeights.semiBold,
                color: valueColor ?? AppColors.textDark)),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // ÉTAT VIDE
  // ─────────────────────────────────────────────
  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90, height: 90,
              decoration: BoxDecoration(
                color: AppColors.navBg.withOpacity(0.35),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.shopping_cart_outlined,
                  size: 44, color: AppColors.textMuted),
            ),
            const SizedBox(height: 20),
            const Text('Votre panier est vide',
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w800,
                    color: AppColors.textDark)),
            const SizedBox(height: 10),
            const Text(
              'Ajoutez des offres depuis la page principale pour les retrouver ici.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: AppTextSizes.bodySmall, color: AppColors.textMuted, height: 1.55),
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Text('Explorer les offres',
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: AppColors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // BOUTON COMMANDER (sticky bottom)
  // ─────────────────────────────────────────────
  Widget _boutonCommander() {
    return Container(
      padding: EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, 
          MediaQuery.of(context).padding.bottom + AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.scaffold,
        border: Border(
            top: BorderSide(color: AppColors.divider.withOpacity(0.5))),
      ),
      child: StandardButton(
        label: 'Confirmer la commande',
        icon: Icons.check_circle_outline,
        onTap: _confirmerCommande,
      ),
    );
  }
}

// ─────────────────────────────────────────────
// BOTTOM SHEET — CONFIRMATION
// ─────────────────────────────────────────────
class _ConfirmationSheet extends StatelessWidget {
  final double total;
  final int nbArticles;
  final VoidCallback? onConfirm;

  const _ConfirmationSheet({
    required this.total,
    required this.nbArticles,
    this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          20, 20, 20, MediaQuery.of(context).padding.bottom + 20),
      decoration: const BoxDecoration(
        color: Color(0xFFF5F0E3),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40, height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: const Color(0xFFD9D0BF),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Container(
            width: 64, height: 64,
            decoration: const BoxDecoration(
              color: Color(0xFFD4EBC5),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.shopping_bag_outlined,
                size: 30, color: Color(0xFF3B6D11)),
          ),
          const SizedBox(height: 16),
          const Text('Confirmer votre commande ?',
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w800,
                  color: Color(0xFF2C2814))),
          const SizedBox(height: 8),
          Text(
            '$nbArticles article${nbArticles > 1 ? 's' : ''} · ${total.toStringAsFixed(0)} DA',
            style: const TextStyle(
                fontSize: 13.5, color: Color(0xFF8A8070)),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8E0CE),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                          color: const Color(0xFFD9D0BF)),
                    ),
                    child: const Center(
                      child: Text('Annuler',
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              color: Color(0xFF2C2814))),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    if (onConfirm != null) {
                      onConfirm!();
                    } else {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text(
                              'Commande envoyée avec succès !'),
                          backgroundColor: const Color(0xFF3B6D11),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      );
                    }
                  },
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE07B39),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: const Center(
                      child: Text('Commander',
                          style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                              color: Colors.white)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}