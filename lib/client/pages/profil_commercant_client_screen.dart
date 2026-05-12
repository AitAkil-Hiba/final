// ─────────────────────────────────────────────
//  PROFIL COMMERÇANT — VU PAR LE CLIENT
//  Route : '/profil_commercant_client'
//  Accès : tap sur une carte commerce dans HomeClientScreen
//
//  Usage :
//    Navigator.pushNamed(
//      context,
//      '/profil_commercant_client',
//      arguments: DonneesCommercant(...),  // optionnel
//    );
// ─────────────────────────────────────────────
// ignore_for_file: unused_field, deprecated_member_use
 
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
 
// ─────────────────────────────────────────────
// COULEURS
// ─────────────────────────────────────────────
class _C {
  static const scaffold   = Color(0xFFE8E0CE);
  static const accent     = Color(0xFFE07B39);
  static const accentBg   = Color(0xFFFAEEDA);
  static const cardBg     = Color(0xFFF5F0E3);
  static const textDark   = Color(0xFF2C2814);
  static const textMuted  = Color(0xFF8A8070);
  static const navBg      = Color(0xFFB5C49E);
  static const green      = Color(0xFF3B6D11);
  static const greenBg    = Color(0xFFD4EBC5);
  static const greenMid   = Color(0xFF6B7C4E);
  static const white      = Color(0xFFFFFFFF);
  static const divider    = Color(0xFFD9D0BF);
  static const appBarBg   = Color(0xFFCCD5AE);
}
 
// ─────────────────────────────────────────────
// MODÈLE — à déplacer dans models/ si souhaité
// ─────────────────────────────────────────────
class DonneesCommercant {
  final String nom;
  final String email;
  final String adresse;
  final int    nbOffres;
  final int    nbReservations;
  final double note;
  final String revenus;
  final String description;
  final String? logoAsset; // chemin asset ou null → initiales
 
  const DonneesCommercant({
    required this.nom,
    required this.email,
    required this.adresse,
    required this.nbOffres,
    required this.nbReservations,
    required this.note,
    required this.revenus,
    required this.description,
    this.logoAsset,
  });
}
 
// ─────────────────────────────────────────────
// ÉCRAN
// ─────────────────────────────────────────────
class ProfilCommercantClientScreen extends StatelessWidget {
  final DonneesCommercant? commercant;
 
  const ProfilCommercantClientScreen({super.key, this.commercant});
 
  // Données fictives par défaut (démo / Burger House de la maquette)
  static const _demo = DonneesCommercant(
    nom:            'Burger House',
    email:          'Burgerhouse@email.com',
    adresse:        'Laprovale, Kouba',
    nbOffres:       47,
    nbReservations: 312,
    note:           4.8,
    revenus:        '28 400 DA',
    description:
        'Burger House est un restaurant spécialisé dans les burgers '
        'gourmands préparés avec des ingrédients frais et de qualité. '
        'Nous proposons une variété de menus savoureux, allant des '
        'classiques aux créations originales pour satisfaire tous les '
        'goûts. Chaque plat est soigneusement préparé à la commande, '
        'accompagné de frites croustillantes et de boissons '
        'rafraîchissantes. Notre objectif est d\'offrir une expérience '
        'rapide, délicieuse et conviviale.',
    logoAsset: null,
  );
 
  @override
  Widget build(BuildContext context) {
    final d = commercant ?? _demo;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
 
    return Scaffold(
      backgroundColor: _C.scaffold,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _appBar(context, d.nom)),
          SliverToBoxAdapter(child: _heroLogo(d)),
          SliverToBoxAdapter(child: _carteStats(d)),
          SliverToBoxAdapter(child: _carteRevenus(d)),
          SliverToBoxAdapter(child: _carteLocalisation(context, d)),
          SliverToBoxAdapter(child: _carteDescription(d)),
          const SliverToBoxAdapter(child: SizedBox(height: 110)),
        ],
      ),
      bottomNavigationBar: _boutonOffres(context, d),
    );
  }
 
  // ─────────────────────────────────────────────
  // APP BAR — Retour + Signaler
  // ─────────────────────────────────────────────
  Widget _appBar(BuildContext context, String nomCommercant) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        bottom: 12, left: 16, right: 20,
      ),
      decoration: BoxDecoration(
        color: _C.appBarBg,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Row(
        children: [
          // Retour
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 38, height: 38,
              decoration: BoxDecoration(
                color: _C.white.withOpacity(0.6),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  size: 16, color: _C.textDark),
            ),
          ),
          const Spacer(),
 
          // Signaler
          GestureDetector(
            onTap: () => Navigator.pushNamed(
              context,
              '/signaler_commercant',
              arguments: nomCommercant,
            ),
            child: Row(
              children: const [
                Icon(Icons.flag_outlined, size: 16, color: _C.textDark),
                SizedBox(width: 4),
                Text('Signaler',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _C.textDark)),
              ],
            ),
          ),
        ],
      ),
    );
  }
 
  // ─────────────────────────────────────────────
  // HERO — Logo + nom + email + badge
  // ─────────────────────────────────────────────
  Widget _heroLogo(DonneesCommercant d) {
    final initiales = d.nom.length >= 2
        ? d.nom.substring(0, 2).toUpperCase()
        : d.nom.toUpperCase();
 
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: _C.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _C.divider.withOpacity(0.6)),
      ),
      child: Column(
        children: [
          // Logo
          Container(
            width: 90, height: 90,
            decoration: BoxDecoration(
              color: _C.greenMid,
              shape: BoxShape.circle,
              border: Border.all(color: _C.navBg, width: 3),
              image: d.logoAsset != null
                  ? DecorationImage(
                      image: AssetImage(d.logoAsset!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: d.logoAsset == null
                ? Center(
                    child: Text(initiales,
                        style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: _C.white)),
                  )
                : null,
          ),
          const SizedBox(height: 14),
 
          // Nom
          Text(d.nom,
              style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  color: _C.textDark)),
          const SizedBox(height: 4),
 
          // Email
          Text(d.email,
              style: const TextStyle(
                  fontSize: 12, color: _C.textMuted)),
          const SizedBox(height: 10),
 
          // Badge "Profil Commerçant"
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              color: _C.greenMid.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _C.greenMid.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.storefront_outlined,
                    size: 13, color: _C.greenMid),
                SizedBox(width: 5),
                Text('Profil Commerçant',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: _C.greenMid)),
              ],
            ),
          ),
        ],
      ),
    );
  }
 
  // ─────────────────────────────────────────────
  // CARTE STATS — Offres / Réservations / Note
  // ─────────────────────────────────────────────
  Widget _carteStats(DonneesCommercant d) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: _C.cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _C.divider.withOpacity(0.6)),
      ),
      child: Row(
        children: [
          _statItem('${d.nbOffres}', 'Offres publiées'),
          _divV(),
          _statItem('${d.nbReservations}', 'Réservations'),
          _divV(),
          _statNote(d.note),
        ],
      ),
    );
  }
 
  Widget _statItem(String val, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(val,
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: _C.textDark)),
          const SizedBox(height: 3),
          Text(label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 10.5, color: _C.textMuted)),
        ],
      ),
    );
  }
 
  Widget _statNote(double note) {
    return Expanded(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.star_rounded,
                  size: 16, color: Color(0xFFFFC107)),
              const SizedBox(width: 3),
              Text(note.toStringAsFixed(1),
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: _C.textDark)),
            ],
          ),
          const SizedBox(height: 3),
          const Text('Note moyenne',
              style: TextStyle(fontSize: 10.5, color: _C.textMuted)),
        ],
      ),
    );
  }
 
  Widget _divV() =>
      Container(width: 1, height: 44, color: _C.divider);
 
  // ─────────────────────────────────────────────
  // CARTE REVENUS RÉCUPÉRÉS
  // (visible sur le profil public — comme dans la maquette)
  // ─────────────────────────────────────────────
  Widget _carteRevenus(DonneesCommercant d) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: _C.cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _C.divider.withOpacity(0.6)),
      ),
      child: Column(
        children: [
          Text(d.revenus,
              style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: _C.accent)),
          const SizedBox(height: 3),
          const Text('Revenus récupérés',
              style: TextStyle(fontSize: 12, color: _C.textMuted)),
        ],
      ),
    );
  }
 
  // ─────────────────────────────────────────────
  // CARTE LOCALISATION
  // ─────────────────────────────────────────────
  Widget _carteLocalisation(BuildContext context, DonneesCommercant d) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _C.cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _C.divider.withOpacity(0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Localisation',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: _C.textDark)),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/carte'),
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: _C.scaffold,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _C.divider),
              ),
              child: Row(
                children: [
                  const Icon(Icons.location_on_outlined,
                      size: 18, color: _C.accent),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(d.adresse,
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: _C.textDark)),
                  ),
                  const Icon(Icons.arrow_forward_ios,
                      size: 13, color: _C.textMuted),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
 
  // ─────────────────────────────────────────────
  // CARTE DESCRIPTION
  // ─────────────────────────────────────────────
  Widget _carteDescription(DonneesCommercant d) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _C.cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _C.divider.withOpacity(0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('À propos de ${d.nom}',
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: _C.textDark)),
          const SizedBox(height: 10),
          Text(d.description,
              style: const TextStyle(
                  fontSize: 12.5,
                  color: _C.textMuted,
                  height: 1.65)),
        ],
      ),
    );
  }
 
  // ─────────────────────────────────────────────
  // BOUTON BAS — Voir les offres
  // ─────────────────────────────────────────────
  Widget _boutonOffres(BuildContext context, DonneesCommercant d) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          16, 12, 16,
          MediaQuery.of(context).padding.bottom + 16),
      decoration: BoxDecoration(
        color: _C.scaffold,
        border: Border(
            top: BorderSide(color: _C.divider.withOpacity(0.4))),
      ),
      child: GestureDetector(
        onTap: () => Navigator.pushNamed(
          context,
          '/offre_commercant',
          arguments: d.nom,
        ),
        child: Container(
          height: 54,
          decoration: BoxDecoration(
            color: _C.cardBg,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: _C.divider),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Center(
            child: Text(
              '${d.nbOffres} offres disponibles',
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: _C.textDark),
            ),
          ),
        ),
      ),
    );
  }
}