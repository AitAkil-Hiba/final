
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'laisser_avis_screen.dart';
import 'offre_detail_screen.dart';
import 'package:peeco/client/pages/navigation_bar.dart';
import 'package:peeco/client/pages/app_constants.dart';
import 'package:peeco/client/pages/widgets/standard_header.dart';

// ─────────────────────────────────────────────
// COULEURS
// ─────────────────────────────────────────────

// ─────────────────────────────────────────────
// MODÈLE RÉSERVATION
// ─────────────────────────────────────────────
enum ReservationStatut { enCours, validee, annulee }

class Reservation {
  final String id;
  final String commercant;
  final String soustitre;
  final String adresse;
  final String prix;
  final String distance;
  final String creneau;
  final String quantite;
  final String codeRetrait;
  final String imageAsset;
  final ReservationStatut statut;
  final bool confirme;
  final double? note;
  final String? date;
  final String? economie;
  final String? motifAnnulation;
  final OffreDetail? offreDetail;

  const Reservation({
    required this.id,
    required this.commercant,
    required this.soustitre,
    required this.adresse,
    required this.prix,
    required this.distance,
    required this.creneau,
    required this.quantite,
    required this.codeRetrait,
    required this.imageAsset,
    required this.statut,
    this.confirme = false,
    this.note,
    this.date,
    this.economie,
    this.motifAnnulation,
    this.offreDetail,
  });
}

// ─────────────────────────────────────────────
// ÉCRAN PRINCIPAL
// ─────────────────────────────────────────────
class ReservationScreen extends StatefulWidget {
  const ReservationScreen({super.key});

  @override
  State<ReservationScreen> createState() => _ReservationScreenState();
}

class _ReservationScreenState extends State<ReservationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final int _selectedNavIndex = 3;

  static final OffreDetail _offreBurger = OffreDetail(
    id: 'o2',
    nom: 'Box Burger House',
    commercant: 'Burger House',
    adresse: 'Laprovale, Kouba, Alger',
    prix: '550Da',
    prixOriginal: '900Da',
    distance: '0.9km',
    note: 4.3,
    restants: 5,
    creneau: '17h–19h',
    categorie: 'Box alimentaire',
    imageAsset: 'assets/images/burger_house2.png',
    description: 'Box surprise composée de burgers, frites et boissons invendus du jour.',
    contenu: ['1 burger', '1 portion de frites', '1 boisson', '1 surprise'],
  );

  final List<Reservation> _reservations = [
    Reservation(
      id: 'r1',
      commercant: 'Kouba Shop',
      soustitre: 'Box alimentaire · Produits du quotidien',
      adresse: 'Laprovale, Kouba, Alger',
      prix: '500 DA',
      distance: '0.9 km',
      creneau: '17h-19h',
      quantite: '1 panier',
      codeRetrait: '4872',
      imageAsset: 'assets/images/kouba_shop.png',
      statut: ReservationStatut.enCours,
      confirme: true,
    ),
    Reservation(
      id: 'r2',
      commercant: 'Burger House',
      soustitre: 'Box alimentaire · Menu surprise',
      adresse: 'Laprovale, Kouba, Alger',
      prix: '550 DA',
      distance: '0.9 km',
      creneau: '17h-19h',
      quantite: '1 panier',
      codeRetrait: '1234',
      imageAsset: 'assets/images/burger_house2.png',
      statut: ReservationStatut.enCours,
      confirme: false,
      offreDetail: _offreBurger,
    ),
    Reservation(
      id: 'r3',
      commercant: 'Burger House',
      soustitre: 'Offre spéciale · Burger · frites',
      adresse: 'Vieux Kouba, Kouba, Alger',
      prix: '550 DA',
      distance: '1.2 km',
      creneau: '12h-14h',
      quantite: '1 menu',
      codeRetrait: '5678',
      imageAsset: 'assets/images/burger_house2.png',
      statut: ReservationStatut.validee,
      confirme: true,
      date: '18 mars 2025',
      economie: '220 DA',
      note: 4.5,
    ),
    Reservation(
      id: 'r4',
      commercant: 'Kouba Shop',
      soustitre: 'Box alimentaire · fruits & légumes',
      adresse: 'Laprovale, Kouba, Alger',
      prix: '500 DA',
      distance: '0.1 km',
      creneau: '17h-19h',
      quantite: '1 panier',
      codeRetrait: '9012',
      imageAsset: 'assets/images/kouba_shop.png',
      statut: ReservationStatut.validee,
      confirme: true,
      date: '19 mars 2025',
      economie: '300 DA',
      note: null,
    ),
    Reservation(
      id: 'r5',
      commercant: 'La Maison du Pain',
      soustitre: 'Box boulangerie · pains & viennoiseries',
      adresse: 'Laprovale, Kouba, Alger',
      prix: '90 DA',
      distance: '1.5 km',
      creneau: '13h-14h',
      quantite: '1 panier',
      codeRetrait: '0000',
      imageAsset: 'assets/images/offre_maison_pain.png',
      statut: ReservationStatut.annulee,
      date: '12 mars 2025',
      motifAnnulation: 'Changement de plan',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Reservation> get _enCours =>
      _reservations.where((r) => r.statut == ReservationStatut.enCours).toList();
  List<Reservation> get _validees =>
      _reservations.where((r) => r.statut == ReservationStatut.validee).toList();
  List<Reservation> get _annulees =>
      _reservations.where((r) => r.statut == ReservationStatut.annulee).toList();

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      body: Stack(
        children: [
          Column(
            children: [
              _buildHeader(),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildEnCoursList(),
                    _buildValideesList(),
                    _buildAnnuleesList(),
                  ],
                ),
              ),
            ],
          ),
          Positioned(bottom: 74, right: 16, child: _cartFab()),
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: AppNavigationBar(
              selectedIndex: 3,
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
  // HEADER + TABBAR
  // ─────────────────────────────────────────────
  Widget _buildHeader() {
    return Column(
      children: [
        StandardHeader(
          title: 'Mes réservations',
          showLogo: false,
          showSearchBar: false,
          showBackButton: false,
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: AppColors.divider.withOpacity(0.5)),
          ),
          child: TabBar(
            controller: _tabController,
            labelColor: AppColors.accent,
            unselectedLabelColor: AppColors.textMuted,
            labelStyle: const TextStyle(
              fontSize: AppTextSizes.bodySmall,
              fontWeight: AppFontWeights.bold,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: AppTextSizes.bodySmall,
              fontWeight: AppFontWeights.medium,
            ),
            indicator: BoxDecoration(
              color: AppColors.accent.withOpacity(0.15),
              borderRadius: BorderRadius.circular(30),
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            dividerColor: Colors.transparent,
            tabs: const [
              Tab(text: 'En cours'),
              Tab(text: 'Validées'),
              Tab(text: 'Annulées'),
            ],
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // ONGLET "EN COURS"
  // ─────────────────────────────────────────────
  Widget _buildEnCoursList() {
    if (_enCours.isEmpty) return _emptyState('Aucune réservation en cours');
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
      itemCount: _enCours.length,
      itemBuilder: (_, i) => _enCoursCard(_enCours[i]),
    );
  }

  Widget _enCoursCard(Reservation r) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider.withOpacity(0.6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header avec statut
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: r.confirme 
                  ? AppColors.accentGreen.withOpacity(0.1)
                  : AppColors.accent.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: r.confirme ? AppColors.accentGreen : AppColors.accent,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  r.confirme ? 'Confirmée' : 'En attente de confirmation',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: r.confirme ? AppColors.accentGreen : AppColors.accent,
                  ),
                ),
                const Spacer(),
                Text(
                  r.prix,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.accent,
                  ),
                ),
              ],
            ),
          ),
          
          // Contenu principal
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: SizedBox(
                    width: 80,
                    height: 80,
                    child: Image.asset(
                      r.imageAsset,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(
                        color: AppColors.offerCardBg,
                        child: const Icon(Icons.storefront_outlined,
                            size: 32, color: AppColors.textMuted),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        r.commercant,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        r.soustitre,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined,
                              size: 12, color: AppColors.textMuted),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              r.adresse,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 11, color: AppColors.textMuted),
                            ),
                          ),
                          Text(
                            r.distance,
                            style: const TextStyle(
                                fontSize: 11, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Étapes
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _stepsRow(confirme: r.confirme),
          ),
          
          const SizedBox(height: 16),

          // Code de retrait (si confirmé)
          if (r.confirme) ...[
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.scaffold,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.divider),
              ),
              child: Column(
                children: [
                  const Text(
                    'Code de retrait',
                    style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    r.codeRetrait,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 6,
                      color: AppColors.accent,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Infos supplémentaires
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _infoChip(Icons.access_time, r.creneau),
                const SizedBox(width: 12),
                _infoChip(Icons.shopping_bag_outlined, r.quantite),
              ],
            ),
          ),
          
          const SizedBox(height: 16),

          // Boutons
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: _outlineButton(
                    label: r.confirme ? 'Itinéraire' : "Voir l'offre",
                    icon: r.confirme ? Icons.directions_outlined : Icons.visibility_outlined,
                    onTap: () {
                      if (!r.confirme && r.offreDetail != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => OffreDetailScreen(offre: r.offreDetail!),
                          ),
                        );
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _filledButton(
                    label: 'Annuler',
                    icon: Icons.close_outlined,
                    onTap: () => _showAnnulationDialog(r),
                    isDanger: true,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // ÉTAPES
  // ─────────────────────────────────────────────
  Widget _stepsRow({required bool confirme}) {
    final steps = [
      {'label': 'Réservé', 'done': true},
      {'label': 'Confirmé', 'done': confirme},
      {'label': 'Retrait', 'done': false},
      {'label': 'Avis', 'done': false},
    ];

    return Row(
      children: List.generate(steps.length * 2 - 1, (i) {
        if (i.isOdd) {
          final leftDone = steps[(i ~/ 2)]['done'] as bool;
          return Expanded(
            child: Container(
              height: 2,
              color: leftDone ? AppColors.accent : AppColors.divider,
            ),
          );
        }
        final idx = i ~/ 2;
        final step = steps[idx];
        final done = step['done'] as bool;
        
        return Column(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: done ? AppColors.accent : AppColors.divider.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: done
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
            const SizedBox(height: 4),
            Text(
              step['label'] as String,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: done ? AppColors.accent : AppColors.textMuted,
              ),
            ),
          ],
        );
      }),
    );
  }

  // ─────────────────────────────────────────────
  // ONGLET "VALIDÉES"
  // ─────────────────────────────────────────────
  Widget _buildValideesList() {
    if (_validees.isEmpty) return _emptyState('Aucune réservation validée');
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
      itemCount: _validees.length,
      itemBuilder: (_, i) => _valideeCard(_validees[i]),
    );
  }

  Widget _valideeCard(Reservation r) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider.withOpacity(0.6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Badge validé
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.accentGreen.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle, size: 14, color: AppColors.accentGreen),
                const SizedBox(width: 8),
                const Text(
                  'Commande validée',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.accentGreen,
                  ),
                ),
                const Spacer(),
                Text(
                  r.prix,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.accent,
                  ),
                ),
              ],
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: SizedBox(
                        width: 70,
                        height: 70,
                        child: Image.asset(
                          r.imageAsset,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Container(
                            color: AppColors.offerCardBg,
                            child: const Icon(Icons.storefront_outlined,
                                size: 28, color: AppColors.textMuted),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            r.commercant,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textDark,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            r.soustitre,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textMuted,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.calendar_today,
                                  size: 10, color: AppColors.textMuted),
                              const SizedBox(width: 4),
                              Text(
                                r.date ?? '',
                                style: const TextStyle(
                                    fontSize: 11, color: AppColors.textMuted),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                const Divider(color: AppColors.divider),
                const SizedBox(height: 12),
                
                Row(
                  children: [
                    _metaChip(Icons.access_time, 'Créneau', r.creneau),
                    const SizedBox(width: 16),
                    _metaChip(Icons.trending_down, 'Économie', r.economie ?? '-'),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                if (r.note == null)
                  _outlineButton(
                    label: 'Laisser un avis',
                    icon: Icons.star_outline,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => LaisserAvisScreen(
                          commercant: AvisCommercant(
                            nom: r.commercant,
                            categorie: r.soustitre.split(' · ')[0],
                            adresse: r.adresse,
                            distance: double.tryParse(r.distance.replaceAll('km', '').trim()) ?? 0.0,
                            nbOffres: 1,
                            imageAsset: r.imageAsset,
                          ),
                        ),
                      ),
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        ...List.generate(
                          5,
                          (i) => Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Icon(
                              i < (r.note ?? 0).floor() ? Icons.star : Icons.star_border,
                              size: 18,
                              color: AppColors.accent,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${r.note?.toStringAsFixed(1)}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // ONGLET "ANNULÉES"
  // ─────────────────────────────────────────────
  Widget _buildAnnuleesList() {
    if (_annulees.isEmpty) return _emptyState('Aucune réservation annulée');
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
      itemCount: _annulees.length,
      itemBuilder: (_, i) => _annuleeCard(_annulees[i]),
    );
  }

  Widget _annuleeCard(Reservation r) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider.withOpacity(0.6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.danger.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.cancel_outlined, size: 14, color: AppColors.danger),
                const SizedBox(width: 8),
                const Text(
                  'Réservation annulée',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.danger,
                  ),
                ),
                const Spacer(),
                Text(
                  r.prix,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMuted,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
              ],
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Opacity(
                    opacity: 0.6,
                    child: SizedBox(
                      width: 70,
                      height: 70,
                      child: Image.asset(
                        r.imageAsset,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Container(
                          color: AppColors.offerCardBg,
                          child: const Icon(Icons.storefront_outlined,
                              size: 28, color: AppColors.textMuted),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        r.commercant,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        r.soustitre,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today,
                              size: 10, color: AppColors.textMuted),
                          const SizedBox(width: 4),
                          Text(
                            r.date ?? '',
                            style: const TextStyle(
                                fontSize: 11, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.dangerBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, size: 14, color: AppColors.danger),
                  const SizedBox(width: 8),
                  Text(
                    r.motifAnnulation ?? 'Annulation',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.danger,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // WIDGETS UTILITAIRES
  // ─────────────────────────────────────────────
  Widget _infoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.scaffold,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.textMuted),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: AppColors.textDark),
          ),
        ],
      ),
    );
  }

  Widget _metaChip(IconData icon, String label, String value) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 12, color: AppColors.textMuted),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 9, color: AppColors.textMuted),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _outlineButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.scaffold,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: AppColors.textDark),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filledButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    bool isDanger = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isDanger ? AppColors.danger.withOpacity(0.1) : AppColors.accent,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isDanger ? AppColors.danger.withOpacity(0.3) : Colors.transparent,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: isDanger ? AppColors.danger : Colors.white),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDanger ? AppColors.danger : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState(String message) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.divider.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.inbox_outlined,
              size: 40,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _cartFab() {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/cart'),
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: AppColors.accent,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.accent.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(
          Icons.shopping_cart_outlined,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // DIALOGUE ANNULATION
  // ─────────────────────────────────────────────
  void _showAnnulationDialog(Reservation r) {
    String? _selectedReason;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setLocal) => Container(
          decoration: const BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 50,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.danger.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.cancel_outlined,
                    size: 30, color: AppColors.danger),
              ),
              const SizedBox(height: 16),
              const Text(
                'Annuler la réservation ?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Dites-nous pourquoi vous annulez.\nCela aide les commerçants à mieux planifier.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textMuted,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              ...['Changement de plan', 'Erreur de commande', 'Prix trop élevé', 'Autre raison']
                  .map((reason) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: GestureDetector(
                      onTap: () => setLocal(() => _selectedReason = reason),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _selectedReason == reason
                              ? AppColors.accent.withOpacity(0.1)
                              : AppColors.scaffold,
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: _selectedReason == reason
                                ? AppColors.accent
                                : AppColors.divider,
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          reason,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _selectedReason == reason
                                ? AppColors.accent
                                : AppColors.textDark,
                          ),
                        ),
                      ),
                    ),
                  )),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: AppColors.scaffold,
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: AppColors.divider),
                        ),
                        child: const Center(
                          child: Text(
                            "Garder",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textDark,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Réservation annulée'),
                            backgroundColor: AppColors.danger,
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: AppColors.danger,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Center(
                          child: Text(
                            "Confirmer",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}