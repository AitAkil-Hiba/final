// ─────────────────────────────────────────────
//  NOTIFICATIONS — Client & Commerçant
//  - Liste avec onglets filtrables
//  - Gestion des préférences (toggles)
//  - Détail notification
// ─────────────────────────────────────────────
// ignore_for_file: curly_braces_in_flow_control_structures, unused_field, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ─────────────────────────────────────────────
// COULEURS
// ─────────────────────────────────────────────
class _C {
  static const scaffold     = Color(0xFFE8E0CE);
  static const accent       = Color(0xFFE07B39);
  static const cardBg       = Color(0xFFF5F0E3);
  static const textDark     = Color(0xFF2C2814);
  static const textMuted    = Color(0xFF8A8070);
  static const navBg        = Color(0xFFB5C49E);
  static const white        = Color(0xFFFFFFFF);
  static const divider      = Color(0xFFD9D0BF);
  static const appBarBg     = Color(0xFFCCD5AE);
  static const appBarBorder = Color(0xFFC8B99A);
  static const green        = Color(0xFF3B6D11);
  static const greenBg      = Color(0xFFD4EBC5);
  static const greenMid     = Color(0xFF6B7C4E);
  static const danger       = Color(0xFFA32D2D);
  static const dangerBg     = Color(0xFFFCEBEB);
  static const warningBg    = Color(0xFFFAEEDA);
  static const warningFg    = Color(0xFF854F0B);
  static const blueBg       = Color(0xFFE6F1FB);
  static const blueFg       = Color(0xFF185FA5);
  static const unread       = Color(0xFFE07B39);
}

// ─────────────────────────────────────────────
// ENUM CATÉGORIE
// ─────────────────────────────────────────────
enum NotifCategorie { activite, paiement, avis, compte }

extension NotifCategorieExt on NotifCategorie {
  String get label {
    switch (this) {
      case NotifCategorie.activite:  return 'Activité';
      case NotifCategorie.paiement:  return 'Paiements';
      case NotifCategorie.avis:      return 'Avis';
      case NotifCategorie.compte:    return 'Compte';
    }
  }

  IconData get icon {
    switch (this) {
      case NotifCategorie.activite:  return Icons.shopping_bag_outlined;
      case NotifCategorie.paiement:  return Icons.payments_outlined;
      case NotifCategorie.avis:      return Icons.star_border_outlined;
      case NotifCategorie.compte:    return Icons.person_outline;
    }
  }

  Color get couleur {
    switch (this) {
      case NotifCategorie.activite:  return _C.greenMid;
      case NotifCategorie.paiement:  return _C.accent;
      case NotifCategorie.avis:      return const Color(0xFFBA7517);
      case NotifCategorie.compte:    return _C.blueFg;
    }
  }

  Color get bg {
    switch (this) {
      case NotifCategorie.activite:  return _C.greenBg;
      case NotifCategorie.paiement:  return _C.warningBg;
      case NotifCategorie.avis:      return const Color(0xFFFFF8E1);
      case NotifCategorie.compte:    return _C.blueBg;
    }
  }
}

// ─────────────────────────────────────────────
// MODÈLE NOTIFICATION
// ─────────────────────────────────────────────
class AppNotification {
  final String id;
  final String titre;
  final String message;
  final NotifCategorie categorie;
  final DateTime date;
  bool lue;

  AppNotification({
    required this.id,
    required this.titre,
    required this.message,
    required this.categorie,
    required this.date,
    this.lue = false,
  });
}

// ─────────────────────────────────────────────
// DONNÉES FICTIVES — CLIENT
// ─────────────────────────────────────────────
final List<AppNotification> _notifsClient = [
  AppNotification(
    id: 'c1',
    titre: 'Commande prête !',
    message: 'Votre "Corbeille du Matin" chez La Maison du Pain est prête à récupérer avant 10h00.',
    categorie: NotifCategorie.activite,
    date: DateTime.now().subtract(const Duration(minutes: 12)),
    lue: false,
  ),
  AppNotification(
    id: 'c2',
    titre: 'Paiement confirmé',
    message: 'Votre paiement de 350 DA pour la commande #LRS-001 a bien été enregistré.',
    categorie: NotifCategorie.paiement,
    date: DateTime.now().subtract(const Duration(minutes: 15)),
    lue: false,
  ),
  AppNotification(
    id: 'c3',
    titre: 'Commande annulée',
    message: 'Votre commande #LRS-004 chez Le Café du Coin a été annulée avec succès.',
    categorie: NotifCategorie.activite,
    date: DateTime.now().subtract(const Duration(minutes: 26)),
    lue: true,
  ),
  AppNotification(
    id: 'c4',
    titre: 'Nouvel avis reçu',
    message: 'La Maison du Pain vous a attribué une note de 5 étoiles. Merci pour votre fidélité !',
    categorie: NotifCategorie.avis,
    date: DateTime.now().subtract(const Duration(hours: 1)),
    lue: true,
  ),
  AppNotification(
    id: 'c5',
    titre: 'Remboursement effectué',
    message: 'Un remboursement de 780 DA a été traité pour votre commande #LRS-002.',
    categorie: NotifCategorie.paiement,
    date: DateTime.now().subtract(const Duration(minutes: 1)),
    lue: false,
  ),
  AppNotification(
    id: 'c6',
    titre: 'Vos informations ont été modifiées',
    message: 'Votre adresse e-mail a été mise à jour avec succès.',
    categorie: NotifCategorie.compte,
    date: DateTime.now().subtract(const Duration(minutes: 6)),
    lue: true,
  ),
  AppNotification(
    id: 'c7',
    titre: 'Nouvelle offre près de vous',
    message: 'Le Panier Frais propose une nouvelle offre à 0.9 km : "Panier Légumes" à 450 DA.',
    categorie: NotifCategorie.activite,
    date: DateTime.now().subtract(const Duration(hours: 2)),
    lue: true,
  ),
  AppNotification(
    id: 'c8',
    titre: 'Mise à jour des conditions',
    message: 'Nos conditions d\'utilisation ont été mises à jour. Consultez-les dans les paramètres.',
    categorie: NotifCategorie.compte,
    date: DateTime.now().subtract(const Duration(minutes: 44)),
    lue: true,
  ),
];

// ─────────────────────────────────────────────
// DONNÉES FICTIVES — COMMERÇANT
// ─────────────────────────────────────────────
final List<AppNotification> _notifsCommercant = [
  AppNotification(
    id: 'm1',
    titre: 'Nouvelle commande reçue',
    message: 'Karim B. a réservé "Panier boulangerie surprise" pour ce soir 17h–19h.',
    categorie: NotifCategorie.activite,
    date: DateTime.now().subtract(const Duration(minutes: 12)),
    lue: false,
  ),
  AppNotification(
    id: 'm2',
    titre: 'Paiement reçu',
    message: 'Vous avez reçu 180 DA pour la réservation #4872 de Karim B.',
    categorie: NotifCategorie.paiement,
    date: DateTime.now().subtract(const Duration(minutes: 15)),
    lue: false,
  ),
  AppNotification(
    id: 'm3',
    titre: 'Commande annulée',
    message: 'Marwa B. a annulé sa réservation #4871 pour ce soir.',
    categorie: NotifCategorie.activite,
    date: DateTime.now().subtract(const Duration(minutes: 26)),
    lue: false,
  ),
  AppNotification(
    id: 'm4',
    titre: 'Nouvelle note attribuée',
    message: 'Samir T. vous a attribué une note de 4 étoiles avec le commentaire "Très bon pain !".',
    categorie: NotifCategorie.avis,
    date: DateTime.now().subtract(const Duration(hours: 5)),
    lue: true,
  ),
  AppNotification(
    id: 'm5',
    titre: 'Client en retard',
    message: 'Yasmine D. n\'a pas encore récupéré sa commande #4869. Le créneau expire dans 30 min.',
    categorie: NotifCategorie.activite,
    date: DateTime.now().subtract(const Duration(hours: 2)),
    lue: true,
  ),
  AppNotification(
    id: 'm6',
    titre: 'Commande non récupérée',
    message: 'La commande #4868 de Ahmed S. n\'a pas été récupérée. Elle a été marquée comme expirée.',
    categorie: NotifCategorie.activite,
    date: DateTime.now().subtract(const Duration(hours: 2, minutes: 27)),
    lue: true,
  ),
  AppNotification(
    id: 'm7',
    titre: 'Activité suspecte détectée',
    message: 'Une connexion inhabituelle a été détectée sur votre compte. Vérifiez vos paramètres.',
    categorie: NotifCategorie.compte,
    date: DateTime.now().subtract(const Duration(minutes: 59)),
    lue: false,
  ),
  AppNotification(
    id: 'm8',
    titre: 'Échec de paiement',
    message: 'Le paiement de 120 DA pour la réservation #4870 a échoué. Contactez le support.',
    categorie: NotifCategorie.paiement,
    date: DateTime.now().subtract(const Duration(minutes: 55)),
    lue: true,
  ),
  AppNotification(
    id: 'm9',
    titre: 'Vos informations ont été modifiées',
    message: 'Votre numéro de téléphone a été mis à jour avec succès.',
    categorie: NotifCategorie.compte,
    date: DateTime.now().subtract(const Duration(minutes: 6)),
    lue: true,
  ),
  AppNotification(
    id: 'm10',
    titre: 'Mise à jour des conditions d\'utilisation',
    message: 'Les nouvelles conditions commerçant sont disponibles. Veuillez les accepter.',
    categorie: NotifCategorie.compte,
    date: DateTime.now().subtract(const Duration(minutes: 44)),
    lue: true,
  ),
];

// ─────────────────────────────────────────────
// NOTIFICATIONS SCREEN
// ─────────────────────────────────────────────
class NotificationsScreen extends StatefulWidget {
  /// [estCommercant] : true → données commerçant, false → données client
  final bool estCommercant;

  const NotificationsScreen({
    super.key,
    this.estCommercant = false,
  });

  @override
  State<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState
    extends State<NotificationsScreen> {
  int _tabIndex = 0; // 0=Tout 1=Activité 2=Paiements 3=Avis 4=Compte

  final List<String> _tabs = [
    'Tout', 'Activité', 'Paiements', 'Avis', 'Compte'
  ];

  List<AppNotification> get _source =>
      widget.estCommercant ? _notifsCommercant : _notifsClient;

  List<AppNotification> get _filtrees {
    if (_tabIndex == 0) return _source;
    final cat = NotifCategorie.values[_tabIndex - 1];
    return _source.where((n) => n.categorie == cat).toList();
  }

  int get _nbNonLues =>
      _source.where((n) => !n.lue).length;

  String _tempsRelatif(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1)  return 'À l\'instant';
    if (diff.inMinutes < 60) return 'Il y a ${diff.inMinutes} min';
    if (diff.inHours < 24)   return 'Il y a ${diff.inHours}h';
    return 'Il y a ${diff.inDays}j';
  }

  void _toutMarquerLu() {
    setState(() {
      for (final n in _source) n.lue = true;
    });
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
          _tabBar(),
          Expanded(
            child: _filtrees.isEmpty
                ? _emptyState()
                : ListView.builder(
                    padding:
                        const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    itemCount: _filtrees.length,
                    itemBuilder: (_, i) =>
                        _notifCard(_filtrees[i]),
                  ),
          ),
        ],
      ),
    );
  }

  // ── AppBar ──────────────────────────────────
  Widget _appBar() {
    return Container(
      decoration: BoxDecoration(
        color: _C.appBarBg,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: _C.appBarBorder, width: 3),
      ),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        bottom: 14, left: 16, right: 16,
      ),
      child: Row(
        children: [
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
          const Text('Notifications',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: _C.textDark)),
          const Spacer(),
          // Actions : badge non-lues + tout marquer lu
          Row(
            children: [
              if (_nbNonLues > 0)
                GestureDetector(
                  onTap: _toutMarquerLu,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: _C.accent.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: _C.accent.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Text('$_nbNonLues',
                            style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: _C.accent)),
                        const SizedBox(width: 4),
                        const Icon(Icons.done_all,
                            size: 13, color: _C.accent),
                      ],
                    ),
                  ),
                ),
              const SizedBox(width: 8),
              // Bouton gestion
              GestureDetector(
                onTap: () => _ouvrirGestion(),
                child: Container(
                  width: 38, height: 38,
                  decoration: BoxDecoration(
                    color: _C.white.withOpacity(0.6),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.tune_outlined,
                      size: 17, color: _C.textDark),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Tabs ────────────────────────────────────
  Widget _tabBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(_tabs.length, (i) {
            final sel = i == _tabIndex;
            // Nombre non lus pour ce tab
            int nbNl = 0;
            if (i == 0) {
              nbNl = _nbNonLues;
            } else {
              final cat = NotifCategorie.values[i - 1];
              nbNl = _source
                  .where((n) =>
                      n.categorie == cat && !n.lue)
                  .length;
            }
            return GestureDetector(
              onTap: () =>
                  setState(() => _tabIndex = i),
              child: AnimatedContainer(
                duration:
                    const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: sel ? _C.accent : _C.cardBg,
                  borderRadius:
                      BorderRadius.circular(20),
                  border: Border.all(
                      color:
                          sel ? _C.accent : _C.divider,
                      width: 1.5),
                ),
                child: Row(
                  children: [
                    Text(_tabs[i],
                        style: TextStyle(
                            fontSize: 12.5,
                            fontWeight:
                                FontWeight.w700,
                            color: sel
                                ? _C.white
                                : _C.textMuted)),
                    if (nbNl > 0) ...[
                      const SizedBox(width: 5),
                      Container(
                        width: 16, height: 16,
                        decoration: BoxDecoration(
                          color: sel
                              ? _C.white
                                  .withOpacity(0.3)
                              : _C.accent,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text('$nbNl',
                              style: TextStyle(
                                  fontSize: 9,
                                  fontWeight:
                                      FontWeight.w900,
                                  color: sel
                                      ? _C.white
                                      : _C.white)),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  // ── Carte notification ──────────────────────
  Widget _notifCard(AppNotification n) {
    return GestureDetector(
      onTap: () {
        setState(() => n.lue = true);
        _ouvrirDetail(n);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: n.lue
              ? _C.cardBg
              : _C.white.withOpacity(0.7),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: n.lue
                ? _C.divider.withOpacity(0.6)
                : _C.accent.withOpacity(0.25),
            width: n.lue ? 1 : 1.5,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icône catégorie
            Container(
              width: 42, height: 42,
              decoration: BoxDecoration(
                color: n.categorie.bg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(n.categorie.icon,
                  size: 20,
                  color: n.categorie.couleur),
            ),
            const SizedBox(width: 12),

            // Contenu
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(n.titre,
                            style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: n.lue
                                    ? FontWeight.w600
                                    : FontWeight.w800,
                                color: _C.textDark),
                            maxLines: 1,
                            overflow:
                                TextOverflow.ellipsis),
                      ),
                      if (!n.lue)
                        Container(
                          width: 8, height: 8,
                          margin: const EdgeInsets.only(
                              left: 6),
                          decoration: const BoxDecoration(
                            color: _C.unread,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(n.message,
                      style: const TextStyle(
                          fontSize: 12,
                          color: _C.textMuted,
                          height: 1.4),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 5),
                  Text(_tempsRelatif(n.date),
                      style: const TextStyle(
                          fontSize: 11,
                          color: _C.textMuted,
                          fontWeight: FontWeight.w500)),
                ],
              ),
            ),

            const SizedBox(width: 6),
            const Icon(Icons.arrow_forward_ios,
                size: 12, color: _C.textMuted),
          ],
        ),
      ),
    );
  }

  // ── État vide ────────────────────────────────
  Widget _emptyState() {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                color: _C.navBg.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                  Icons.notifications_off_outlined,
                  size: 38,
                  color: _C.textMuted),
            ),
            const SizedBox(height: 18),
            const Text('Aucune notification',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: _C.textDark)),
            const SizedBox(height: 8),
            const Text(
              'Vous serez notifié ici dès qu\'il y a de l\'activité.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 13,
                  color: _C.textMuted,
                  height: 1.55),
            ),
          ],
        ),
      ),
    );
  }

  // ── Détail notification ──────────────────────
  void _ouvrirDetail(AppNotification n) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        padding: EdgeInsets.fromLTRB(
            20, 20, 20,
            MediaQuery.of(context).padding.bottom + 24),
        decoration: const BoxDecoration(
          color: Color(0xFFF5F0E3),
          borderRadius: BorderRadius.vertical(
              top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                margin:
                    const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                    color: _C.divider,
                    borderRadius:
                        BorderRadius.circular(2)),
              ),
            ),
            Row(
              children: [
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    color: n.categorie.bg,
                    borderRadius:
                        BorderRadius.circular(14),
                  ),
                  child: Icon(n.categorie.icon,
                      size: 24,
                      color: n.categorie.couleur),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(n.categorie.label,
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight:
                                  FontWeight.w700,
                              color:
                                  n.categorie.couleur)),
                      Text(n.titre,
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight:
                                  FontWeight.w900,
                              color: _C.textDark)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(color: _C.divider),
            const SizedBox(height: 12),
            Text(n.message,
                style: const TextStyle(
                    fontSize: 14,
                    color: _C.textDark,
                    height: 1.65)),
            const SizedBox(height: 12),
            Text(_tempsRelatif(n.date),
                style: const TextStyle(
                    fontSize: 12, color: _C.textMuted)),
          ],
        ),
      ),
    );
  }

  // ── Gestion des notifications ────────────────
  void _ouvrirGestion() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) =>
          _GestionNotificationsSheet(
              estCommercant: widget.estCommercant),
    );
  }
}

// ─────────────────────────────────────────────
// GESTION DES NOTIFICATIONS (bottom sheet)
// ─────────────────────────────────────────────
class _GestionNotificationsSheet extends StatefulWidget {
  final bool estCommercant;
  const _GestionNotificationsSheet(
      {required this.estCommercant});

  @override
  State<_GestionNotificationsSheet> createState() =>
      _GestionNotificationsSheetState();
}

class _GestionNotificationsSheetState
    extends State<_GestionNotificationsSheet> {
  bool _tout      = true;
  bool _activite  = true;
  bool _paiements = true;
  bool _avis      = false;
  bool _compte    = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          24, 24, 24,
          MediaQuery.of(context).padding.bottom + 24),
      decoration: const BoxDecoration(
        color: Color(0xFFF5F0E3),
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40, height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                  color: _C.divider,
                  borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const Text('Gestion des notifications',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: _C.textDark)),
          const SizedBox(height: 4),
          const Text(
              'Gérez les notifications que vous souhaitez recevoir',
              style: TextStyle(
                  fontSize: 12.5, color: _C.textMuted)),
          const SizedBox(height: 24),

          // Toggle principal
          _toggleLigne('Tout', _tout, (v) {
            setState(() {
              _tout = v;
              _activite = v;
              _paiements = v;
              _avis = v;
              _compte = v;
            });
          }),

          const SizedBox(height: 8),

          // Sous-catégories
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _C.white.withOpacity(0.5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: _C.divider.withOpacity(0.6)),
            ),
            child: Column(
              children: [
                _toggleLigne('Activité', _activite, (v) {
                  setState(() => _activite = v);
                  _majTout();
                }),
                const Divider(
                    color: _C.divider, height: 20),
                _toggleLigne('Paiements', _paiements,
                    (v) {
                  setState(() => _paiements = v);
                  _majTout();
                }),
                const Divider(
                    color: _C.divider, height: 20),
                _toggleLigne('Avis', _avis, (v) {
                  setState(() => _avis = v);
                  _majTout();
                }),
                const Divider(
                    color: _C.divider, height: 20),
                _toggleLigne('Compte', _compte, (v) {
                  setState(() => _compte = v);
                  _majTout();
                }),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Bouton sauvegarder
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context)
                  .showSnackBar(
                const SnackBar(
                  content: Text(
                      'Préférences de notifications sauvegardées'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: Container(
              width: double.infinity,
              height: 54,
              decoration: BoxDecoration(
                color: _C.accent,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: _C.accent.withOpacity(0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Center(
                child: Text('Sauvegarder',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: _C.white)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _toggleLigne(
      String label, bool val, ValueChanged<bool> onChange) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: _C.textDark)),
        Switch(
          value: val,
          onChanged: onChange,
          activeColor: _C.accent,
          trackColor: MaterialStateProperty.resolveWith(
              (states) => states
                      .contains(MaterialState.selected)
                  ? _C.accent.withOpacity(0.3)
                  : _C.divider),
        ),
      ],
    );
  }

  void _majTout() {
    setState(() {
      _tout = _activite && _paiements && _avis && _compte;
    });
  }
}