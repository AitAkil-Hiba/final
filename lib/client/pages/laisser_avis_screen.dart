// ─────────────────────────────────────────────
//  LAISSER UN AVIS — Écran dédié
//  2 états : formulaire / confirmation
// ─────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ─────────────────────────────────────────────
// COULEURS (même palette que le projet)
// ─────────────────────────────────────────────
class _C {
  static const scaffold     = Color(0xFFE8E0CE);
  static const accent       = Color(0xFFE07B39);
  static const cardBg       = Color(0xFFF5F0E3);
  static const textDark     = Color(0xFF2C2814);
  static const textMuted    = Color(0xFF8A8070);
  static const white        = Color(0xFFFFFFFF);
  static const divider      = Color(0xFFD9D0BF);
  static const appBarBg     = Color(0xFFCCD5AE);
  static const appBarBorder = Color(0xFFC8B99A);
  static const greenBg      = Color(0xFFD4EBC5);
  static const starEmpty    = Color(0xFFD9D0BF);
  static const sectionBg    = Color(0xFFF0EAD8);
  static const badgeBg      = Color(0xFFCB8A3E);
}

// ─────────────────────────────────────────────
// MODÈLE COMMERÇANT (à remplacer par votre modèle partagé)
// ─────────────────────────────────────────────
class AvisCommercant {
  final String nom;
  final String categorie;
  final String adresse;
  final double distance;
  final int nbOffres;
  final String? imageAsset;

  const AvisCommercant({
    required this.nom,
    required this.categorie,
    required this.adresse,
    required this.distance,
    required this.nbOffres,
    this.imageAsset,
  });
}

// ─────────────────────────────────────────────
// ÉCRAN PRINCIPAL
// ─────────────────────────────────────────────
class LaisserAvisScreen extends StatefulWidget {
  /// Passer le commerçant depuis la page précédente
  final AvisCommercant commercant;

  const LaisserAvisScreen({super.key, required this.commercant});

  @override
  State<LaisserAvisScreen> createState() => _LaisserAvisScreenState();
}

class _LaisserAvisScreenState extends State<LaisserAvisScreen> {
  // ── État global ──
  bool _avisEnvoye = false;

  // ── Notes ──
  int _noteGlobale     = 0;
  int _noteCreneaux    = 0;
  int _noteQualitePrix = 0;

  // ── Commentaire ──
  final TextEditingController _commentaireCtrl = TextEditingController();

  @override
  void dispose() {
    _commentaireCtrl.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    return Scaffold(
      backgroundColor: _C.scaffold,
      body: Column(
        children: [
          _appBar(),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              child: _avisEnvoye
                  ? _vueConfirmation(key: const ValueKey('confirm'))
                  : _vueFormulaire(key: const ValueKey('form')),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // APP BAR
  // ─────────────────────────────────────────────
  Widget _appBar() {
    return Container(
      decoration: const BoxDecoration(
        color: _C.appBarBg,
        border: Border(bottom: BorderSide(color: _C.appBarBorder, width: 1)),
      ),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        bottom: 14,
        left: 16,
        right: 16,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back, color: _C.textDark, size: 22),
          ),
          const SizedBox(width: 12),
          const Text(
            'Laisser un avis',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: _C.textDark,
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // CARTE COMMERÇANT (réutilisée dans les 2 vues)
  // ─────────────────────────────────────────────
  Widget _carteCommercant() {
    final c = widget.commercant;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: _C.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _C.divider),
      ),
      child: Row(
        children: [
          // Image / fallback
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: 64, height: 64,
              child: c.imageAsset != null
                  ? Image.asset(
                      c.imageAsset!,
                      fit: BoxFit.cover,
                      // ignore: unnecessary_underscores
                      errorBuilder: (_, __, ___) => _imageFallback(c.categorie),
                    )
                  : _imageFallback(c.categorie),
            ),
          ),
          const SizedBox(width: 12),

          // Infos
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  c.nom,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: _C.textDark,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined,
                        size: 11, color: _C.textMuted),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text(
                        c.adresse,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 11, color: _C.textMuted),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Distance + badge offres
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${c.distance} km',
                style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _C.textMuted),
              ),
              const SizedBox(height: 4),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: BoxDecoration(
                  color: _C.accent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${c.nbOffres} offres',
                  style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: _C.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _imageFallback(String categorie) {
    IconData icon;
    switch (categorie) {
      case 'Boulangerie': icon = Icons.bakery_dining_outlined; break;
      case 'Restaurant':  icon = Icons.restaurant_outlined;   break;
      case 'Café':        icon = Icons.coffee_outlined;       break;
      case 'Superette':   icon = Icons.shopping_basket_outlined; break;
      default:            icon = Icons.storefront_outlined;
    }
    return Container(
      color: _C.greenBg,
      child: Center(child: Icon(icon, color: _C.textMuted, size: 28)),
    );
  }

  // ─────────────────────────────────────────────
  // VUE 1 — FORMULAIRE
  // ─────────────────────────────────────────────
  Widget _vueFormulaire({Key? key}) {
    return SingleChildScrollView(
      key: key,
      padding: const EdgeInsets.only(bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Carte commerçant
          _carteCommercant(),

          const SizedBox(height: 20),

          // ── Note globale ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Icon(Icons.star_border_rounded,
                    size: 18, color: _C.textDark),
                const SizedBox(width: 6),
                const Text(
                  'Note globale',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: _C.textDark),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _etoiles(
              note: _noteGlobale,
              taille: 38,
              onChanged: (v) => setState(() => _noteGlobale = v),
            ),
          ),

          const SizedBox(height: 22),

          // ── Détails de l'expérience ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Icon(Icons.tune_rounded,
                    size: 18, color: _C.textDark),
                const SizedBox(width: 6),
                const Text(
                  'Détails de l\'expérience',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: _C.textDark),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Sous-critère 1
          _sousCritere(
            label: 'Respect du créneau',
            note: _noteCreneaux,
            onChanged: (v) => setState(() => _noteCreneaux = v),
          ),
          const SizedBox(height: 10),

          // Sous-critère 2
          _sousCritere(
            label: 'Rapport qualité/prix',
            note: _noteQualitePrix,
            onChanged: (v) => setState(() => _noteQualitePrix = v),
          ),

          const SizedBox(height: 22),

          // ── Laisser un commentaire ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Icon(Icons.chat_bubble_outline_rounded,
                    size: 18, color: _C.textDark),
                const SizedBox(width: 6),
                const Text(
                  'Laisser un commentaire',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: _C.textDark),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              decoration: BoxDecoration(
                color: _C.cardBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _C.divider),
              ),
              child: TextField(
                controller: _commentaireCtrl,
                maxLines: 4,
                style: const TextStyle(fontSize: 13, color: _C.textDark),
                decoration: const InputDecoration(
                  hintText: 'Partagez votre expérience avec ce commerçant...',
                  hintStyle: TextStyle(fontSize: 12.5, color: _C.textMuted),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(14),
                ),
              ),
            ),
          ),

          const SizedBox(height: 32),

          // ── Bouton Envoyer ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GestureDetector(
              onTap: _noteGlobale > 0 ? _envoyerAvis : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  color: _noteGlobale > 0
                      ? _C.badgeBg
                      : _C.divider,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Center(
                  child: Text(
                    'Envoyer',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: _noteGlobale > 0
                          ? _C.white
                          : _C.textMuted,
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // ── Passer ──
          Center(
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Text(
                'Passer, noter plus tard',
                style: TextStyle(
                  fontSize: 12,
                  color: _C.textMuted,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // VUE 2 — CONFIRMATION
  // ─────────────────────────────────────────────
  Widget _vueConfirmation({Key? key}) {
    return Column(
      key: key,
      children: [
        // Carte commerçant (même en haut)
        _carteCommercant(),

        // Note globale affichée (lecture seule)
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
          child: Row(
            children: [
              const Icon(Icons.star_border_rounded,
                  size: 18, color: _C.textDark),
              const SizedBox(width: 6),
              const Text(
                'Note globale',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _C.textDark),
              ),
            ],
          ),
        ),

        // Zone confirmation (fond arrondi)
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(top: 16),
            decoration: const BoxDecoration(
              color: _C.sectionBg,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icône poignée de main
                Container(
                  width: 90, height: 90,
                  decoration: BoxDecoration(
                    color: _C.badgeBg,
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: const Color(0xFFC49558), width: 4),
                  ),
                  child: const Icon(
                    Icons.handshake_outlined,
                    size: 44,
                    color: _C.white,
                  ),
                ),

                const SizedBox(height: 22),

                const Text(
                  'Merci pour votre avis !',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: _C.textDark,
                  ),
                ),

                const SizedBox(height: 10),

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    'Votre retour aide la communauté à faire de meilleurs choix et encourage les commerçants à s\'améliorer.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: _C.textMuted,
                      height: 1.6,
                    ),
                  ),
                ),

                const SizedBox(height: 36),

                // Bouton retour
                GestureDetector(
                  onTap: () =>
                      Navigator.pushNamedAndRemoveUntil(
                          context, '/reservations', (r) => false),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 14),
                    decoration: BoxDecoration(
                      color: _C.sectionBg,
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                          color: _C.appBarBorder, width: 1.5),
                    ),
                    child: const Text(
                      'Retour a mes reservations',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _C.textDark,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // WIDGET ÉTOILES (interactif)
  // ─────────────────────────────────────────────
  Widget _etoiles({
    required int note,
    required double taille,
    required ValueChanged<int> onChanged,
  }) {
    return Row(
      children: List.generate(5, (i) {
        final remplie = i < note;
        return GestureDetector(
          onTap: () => onChanged(i + 1),
          child: Padding(
            padding: const EdgeInsets.only(right: 6),
            child: Icon(
              remplie ? Icons.star_rounded : Icons.star_border_rounded,
              size: taille,
              color: remplie ? _C.accent : _C.starEmpty,
            ),
          ),
        );
      }),
    );
  }

  // ─────────────────────────────────────────────
  // SOUS-CRITÈRE (card avec étoiles)
  // ─────────────────────────────────────────────
  Widget _sousCritere({
    required String label,
    required int note,
    required ValueChanged<int> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _C.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _C.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _C.textDark,
            ),
          ),
          const SizedBox(height: 8),
          _etoiles(note: note, taille: 28, onChanged: onChanged),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // ACTION ENVOYER
  // ─────────────────────────────────────────────
  void _envoyerAvis() {
    // {
    //   noteGlobale    : _noteGlobale,
    //   noteCreneaux   : _noteCreneaux,
    //   noteQualitePrix: _noteQualitePrix,
    //   commentaire    : _commentaireCtrl.text,
    //   commercantId   : widget.commercant.nom,
    // }
    setState(() => _avisEnvoye = true);
  }
}