// home_client_screen.dart
// ignore_for_file: deprecated_member_use, sized_box_for_whitespace, no_leading_underscores_for_local_identifiers, unused_element, avoid_unnecessary_containers, unused_label, dead_code, unnecessary_underscores

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:peeco/client/pages/offre_detail_screen.dart';
import 'package:peeco/client/pages/profil_commercant_client_screen.dart';
import 'package:peeco/client/pages/navigation_bar.dart';
import 'package:location/location.dart';
import 'package:peeco/client/pages/app_constants.dart';
import 'package:peeco/client/pages/filtre_screen.dart';

// ─────────────────────────────────────────────
// MODÈLE — Offre près de vous
// ─────────────────────────────────────────────
class NearbyOffer {
  final String id;
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
  final String? imageAsset;
  final String description;
  final List<String> contenu;

  const NearbyOffer({
    required this.id,
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
    this.imageAsset,
    required this.description,
    required this.contenu,
  });
}

// ─────────────────────────────────────────────
// WIDGET ÉTOILES
// ─────────────────────────────────────────────
class StarRating extends StatelessWidget {
  final double note;
  final double size;

  const StarRating({super.key, required this.note, this.size = 12});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.star, size: size, color: const Color(0xFFF5A623)),
        const SizedBox(width: 3),
        Text(
          note.toStringAsFixed(1),
          style: TextStyle(fontSize: size * 0.9, fontWeight: FontWeight.w600, color: const Color(0xFFF5A623)),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// ÉCRAN PRINCIPAL
// ─────────────────────────────────────────────
class HomeClientScreen extends StatefulWidget {
  const HomeClientScreen({super.key});

  @override
  State<HomeClientScreen> createState() => _HomeClientScreenState();
}

class _HomeClientScreenState extends State<HomeClientScreen> {
  bool _locationEnabled = false;
  int _selectedNavIndex = 2;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  LocationData? _currentLocation;
  final Location _locationService = Location();
  bool _locationServiceEnabled = false;
  PermissionStatus? _permissionGranted;

  // État filtres — mémorisé entre les ouvertures
  FiltreResultat _filtres = FiltreResultat.vide();

  final List<OffreDetail> _specialOffers = const [
    OffreDetail(
      id: 'o1',
      nom: 'Corbeille du Matin',
      commercant: 'La Maison du Pain',
      adresse: 'Laprovale, Oued Smar',
      prix: '350 DA',
      prixOriginal: '600 DA',
      distance: '0.4 km',
      note: 4.6,
      restants: 5,
      creneau: '07:00 – 10:00',
      categorie: 'Boulangerie',
      imageAsset: 'assets/images/legumes_frais.png',
      description: 'Profitez d\'une corbeille généreuse préparée chaque matin.',
      contenu: ['1 baguette tradition', '2 croissants', '1 pain de campagne', '2 pains au chocolat'],
    ),
    OffreDetail(
      id: 'o2',
      nom: 'Double Cheese Burger',
      commercant: 'Burger House',
      adresse: 'Jolie vue, Oued Smar',
      prix: '780 DA',
      prixOriginal: '1100 DA',
      distance: '1.3 km',
      note: 4.2,
      restants: 2,
      creneau: '12:00 – 15:00',
      categorie: 'Restaurant',
      imageAsset: 'assets/images/offre_burger.png',
      description: 'Notre burger maison préparé avec des ingrédients frais.',
      contenu: ['1 burger', '1 portion de frites', '1 boisson'],
    ),
    OffreDetail(
      id: 'o3',
      nom: 'Panier Légumes Bio',
      commercant: 'Le Panier Frais',
      adresse: 'Laprovale, Oued Smar',
      prix: '450 DA',
      prixOriginal: '700 DA',
      distance: '0.9 km',
      note: 4.7,
      restants: 3,
      creneau: '15:00 – 18:00',
      categorie: 'Superette',
      imageAsset: 'assets/images/panier_frais.png',
      description: 'Panier de légumes frais et bio.',
      contenu: ['5 tomates', '3 concombres', '1 salade', '2 oignons'],
    ),
  ];

  final List<NearbyOffer> _nearbyOffers = const [
    NearbyOffer(
      id: 'n1',
      nom: 'Pain Frais',
      commercant: 'Boulangerie El Baraka',
      adresse: 'Rue des Orangers, Oued Smar',
      prix: '90 DA',
      prixOriginal: '150 DA',
      distance: '0.3 km',
      note: 4.8,
      restants: 8,
      creneau: '08:00 – 10:00',
      categorie: 'Boulangerie',
      imageAsset: 'assets/images/moulin_dore.png',
      description: 'Pain frais du matin.',
      contenu: ['1 baguette', '1 pain complet'],
    ),
    NearbyOffer(
      id: 'n2',
      nom: 'Panier Fruits Légumes',
      commercant: 'Superette La Provinciale',
      adresse: 'Cité Sidi Yacine, Oued Smar',
      prix: '350 DA',
      prixOriginal: '500 DA',
      distance: '0.5 km',
      note: 4.2,
      restants: 4,
      creneau: '14:00 – 17:00',
      categorie: 'Superette',
      imageAsset: 'assets/images/legumes_frais.png',
      description: 'Panier de fruits et légumes frais.',
      contenu: ['Pommes', 'Bananes', 'Tomates', 'Salade'],
    ),
    NearbyOffer(
      id: 'n3',
      nom: 'Menu Midi Express',
      commercant: 'Pizzeria Le Vésuve',
      adresse: 'Laprovale, Oued Smar',
      prix: '550 DA',
      prixOriginal: '850 DA',
      distance: '0.8 km',
      note: 4.5,
      restants: 3,
      creneau: '12:00 – 14:00',
      categorie: 'Restaurant',
      imageAsset: 'assets/images/burger_house2.png',
      description: 'Menu complet du midi.',
      contenu: ['Pizza', 'Boisson', 'Dessert'],
    ),
    NearbyOffer(
      id: 'n4',
      nom: 'Croissants x6',
      commercant: 'Boulangerie Le Fournil',
      adresse: 'Jolie Vue, Oued Smar',
      prix: '180 DA',
      prixOriginal: '300 DA',
      distance: '1.1 km',
      note: 4.3,
      restants: 6,
      creneau: '09:00 – 11:00',
      categorie: 'Boulangerie',
      imageAsset: 'assets/images/moulin_dore.png',
      description: 'Croissants frais du matin.',
      contenu: ['6 croissants au beurre'],
    ),
    NearbyOffer(
      id: 'n5',
      nom: 'Café Gourmand',
      commercant: 'Café Le Central',
      adresse: 'Centre commercial, Oued Smar',
      prix: '120 DA',
      prixOriginal: '200 DA',
      distance: '1.4 km',
      note: 4.0,
      restants: 5,
      creneau: '15:00 – 17:00',
      categorie: 'Café',
      imageAsset: 'assets/images/café.png',
      description: 'Café + pâtisserie.',
      contenu: ['Café', 'Pâtisserie orientale'],
    ),
  ];

  List<OffreDetail> get _filteredSpecialOffers {
    if (_searchQuery.isEmpty) return _specialOffers;
    return _specialOffers.where((o) =>
      o.nom.toLowerCase().contains(_searchQuery.toLowerCase()) ||
      o.commercant.toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();
  }

  List<NearbyOffer> get _filteredNearbyOffers {
    if (_searchQuery.isEmpty) return _nearbyOffers;
    return _nearbyOffers.where((o) =>
      o.nom.toLowerCase().contains(_searchQuery.toLowerCase()) ||
      o.commercant.toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();
  }

  @override
  void initState() {
    super.initState();
    _checkLocationService();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _checkLocationService() async {
    _locationServiceEnabled = await _locationService.serviceEnabled();
    if (!_locationServiceEnabled) {
      _locationServiceEnabled = await _locationService.requestService();
      if (!_locationServiceEnabled) return;
    }
    _permissionGranted = await _locationService.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await _locationService.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) return;
    }
  }

  Future<void> _enableLocation() async {
    await _checkLocationService();
    if (_locationServiceEnabled && _permissionGranted == PermissionStatus.granted) {
      // Show nearby offers immediately, then fetch precise location in background
      setState(() => _locationEnabled = true);
      _locationService.getLocation().then((loc) {
        if (mounted) setState(() => _currentLocation = loc);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez activer la localisation'),
          backgroundColor: AppColors.accent,
        ),
      );
    }
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _searchQuery = '';
    });
    FocusScope.of(context).unfocus();
  }

  Future<void> _openFilters() async {
    // ouvrirFiltres() est la fonction helper officielle dans filtre_screen.dart
    final result = await ouvrirFiltres(context, _filtres);
    if (result != null) {
      setState(() => _filtres = result);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${result.nbActifs} filtre(s) appliqué(s)'),
          backgroundColor: AppColors.accent,
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  // ─────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    return PopScope(
      canPop: false,
      child: Scaffold(
      backgroundColor: AppColors.scaffold,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _appBar()),
              SliverToBoxAdapter(child: _sectionHeader('Catégories', '')),
              SliverToBoxAdapter(child: _categories()),
              SliverToBoxAdapter(child: _sectionHeader('Offres spéciales', '')),
              SliverToBoxAdapter(child: _offersCarousel()),
              SliverToBoxAdapter(child: _sectionHeader('Près de vous', 'Voir tout')),
              SliverToBoxAdapter(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 350),
                  child: _locationEnabled
                      ? _nearbyOffersList(key: const ValueKey('offers'))
                      : _locationPrompt(key: const ValueKey('prompt')),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 110)),
            ],
          ),
          Positioned(bottom: 74, right: 16, child: _cartFab()),
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: AppNavigationBar(
              selectedIndex: _selectedNavIndex,
              onTap: (index) {
                setState(() => _selectedNavIndex = index);
                AppNavigationBar.handleNavigation(context, index);
              },
            ),
          ),
        ],
      ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // APP BAR — UNE SEULE barre de recherche
  // Le doublon venait du StandardHeader (standard_header.dart) qui
  // affiche aussi une barre quand showSearchBar: true. On n'utilise
  // PAS StandardHeader ici, on a notre propre _appBar() custom.
  // ─────────────────────────────────────────────
  Widget _appBar() {
    return Container(
      decoration: BoxDecoration(
         color: Color(0xFFCCD5AE),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFFC8B99A), width: 2),
      ),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 20,
        bottom: 20,
        left: 20,
        right: 20,
      ),
      child: Column(
        children: [
          // Ligne 1 : Logo + Localisation
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Image.asset(
                'assets/images/laaisraf_logo.png',
                height: 40,
                errorBuilder: (_, __, ___) => Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(8)),
                  child: const Center(child: Text('P', style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold))),
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/acces_rapide'),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.location_on_outlined, size: 15, color: AppColors.textDark),
                    const SizedBox(width: 5),
                    Text(
                      _locationEnabled ? 'Oued Smar, Alger' : 'Localisation',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark),
                    ),
                    const SizedBox(width: 10),
                    const Icon(Icons.keyboard_arrow_down, size: 20, color: AppColors.textDark),
                  ],
                ),
              ),
              const SizedBox(width: 40),
            ],
          ),
          const SizedBox(height: 16),

          // Ligne 2 : Barre de recherche décorative
          Container(
            height: 45,
            decoration: BoxDecoration(
              color: const Color(0xFFCCD1AE),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: AppColors.textMuted, width: 0.5),
            ),
            child: Row(
              children: [
                const SizedBox(width: 30),
                const Icon(
                  Icons.search,
                  color: AppColors.chipDark,
                  size: 20,
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Rechercher...',
                    style: TextStyle(
                      color: AppColors.chipDark,
                      fontSize: 14,
                    ),
                  ),
                ),
                Container(width: 1, height: 30, color: AppColors.divider),
                // Bouton filtres avec badge
                GestureDetector(
                  onTap: _openFilters,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Icon(
                          Icons.tune,
                          color: _filtres.nbActifs > 0 ? AppColors.accent : AppColors.chipDark,
                          size: 20,
                        ),
                        if (_filtres.nbActifs > 0)
                          Positioned(
                            right: -6, top: -6,
                            child: Container(
                              width: 14, height: 14,
                              decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle),
                              child: Center(
                                child: Text(
                                  '${_filtres.nbActifs}',
                                  style: const TextStyle(fontSize: 8, color: Colors.white, fontWeight: FontWeight.w800),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 4),
              ],
            ),
          ),
                  ],
      ),
    );
  }

  Widget _sectionHeader(String title, String action) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 16, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textDark)),
          if (action.isNotEmpty)
            GestureDetector(
              onTap: action == 'Voir tout' ? () => Navigator.pushNamed(context, '/carte') : null,
              child: Text(action, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.accent)),
            ),
        ],
      ),
    );
  }

  Widget _categories() {
    final cats = ['Épicerie', 'Boulangerie', 'Boucherie', 'Superette', 'Restaurant', 'Café', 'Autre'];
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        itemCount: cats.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
          decoration: BoxDecoration(color: const Color(0xFFCCD5AE), borderRadius: BorderRadius.circular(20)),
          child: Center(child: Text(cats[i], style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black))),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // CARROUSEL — même couleur AppColors.cardBg que "Près de vous" + étoiles
  // ─────────────────────────────────────────────
  Widget _offersCarousel() {
    final offers = _filteredSpecialOffers;
    if (offers.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Center(child: Column(children: [
          Icon(Icons.search_off, size: 48, color: AppColors.textMuted),
          SizedBox(height: 8),
          Text('Aucune offre trouvée', style: TextStyle(color: AppColors.textMuted)),
        ])),
      );
    }
    return SizedBox(
      height: 220,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: offers.length,
        itemBuilder: (_, i) {
          final offre = offers[i];
          return GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/offre_detail', arguments: offre),
            child: Container(
              width: 195,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: AppColors.cardBg,                          // ← même couleur que les cartes nearby
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.divider.withOpacity(0.6)),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 3))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    child: SizedBox(
                      height: 110, width: double.infinity,
                      child: Image.asset(
                        offre.imageAsset ?? '',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: AppColors.accent.withOpacity(0.15),
                          child: Center(child: Icon(Icons.local_offer, size: 40, color: AppColors.accent)),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(offre.nom,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textDark),
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            StarRating(note: offre.note, size: 12),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(offre.prix,
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.accent)),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: offre.restants <= 2 ? Colors.orange : Colors.green,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text('${offre.restants} restant${offre.restants > 1 ? 's' : ''}',
                                  style: const TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.w600)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _locationPrompt({Key? key}) {
    return Padding(
      key: key,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.divider),
        ),
        child: Column(
          children: [
            Container(
              width: 58, height: 58,
              decoration: BoxDecoration(color: const Color(0xFFB5C49E).withOpacity(0.45), shape: BoxShape.circle),
              child: const Icon(Icons.map_outlined, size: 34, color: AppColors.textDark),
            ),
            const SizedBox(height: 12),
            const Text('Activez votre localisation',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textDark)),
            const SizedBox(height: 8),
            const Text(
              'Activez votre localisation pour découvrir les offres près de chez vous.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12.5, color: AppColors.textMuted, height: 1.55),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: _enableLocation,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: AppColors.divider, width: 1.5),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.location_on_outlined, size: 15, color: AppColors.textDark),
                    SizedBox(width: 6),
                    Text('Activer la localisation',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textDark)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/acces_rapide'),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.edit_location_alt_outlined, size: 14, color: AppColors.accent),
                  SizedBox(width: 5),
                  Text(
                    'Entrer une adresse manuellement',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.accent,
                      decoration: TextDecoration.underline,
                      decorationColor: AppColors.accent,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _nearbyOffersList({Key? key}) {
    final offers = _filteredNearbyOffers;
    if (offers.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 32),
        child: Center(child: Column(children: [
          Icon(Icons.search_off, size: 48, color: AppColors.textMuted),
          SizedBox(height: 8),
          Text('Aucune offre trouvée', style: TextStyle(color: AppColors.textMuted)),
        ])),
      );
    }
    return Padding(
      key: key,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(children: offers.map((o) => _nearbyOfferCard(o)).toList()),
    );
  }

  Widget _nearbyOfferCard(NearbyOffer offer) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/offre_detail', arguments: OffreDetail(
          id: offer.id, nom: offer.nom, commercant: offer.commercant,
          adresse: offer.adresse, prix: offer.prix, prixOriginal: offer.prixOriginal,
          distance: offer.distance, note: offer.note, restants: offer.restants,
          creneau: offer.creneau, categorie: offer.categorie, imageAsset: offer.imageAsset,
          description: offer.description, contenu: offer.contenu,
        ));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.divider.withOpacity(0.6)),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 70, height: 70,
                child: Image.asset(
                  offer.imageAsset ?? '', fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: AppColors.accent.withOpacity(0.2),
                    child: Icon(Icons.local_offer, size: 30, color: AppColors.accent),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(offer.nom, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textDark)),
                  const SizedBox(height: 2),
                  Text(offer.commercant, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                  const SizedBox(height: 3),
                  Row(children: [
                    StarRating(note: offer.note, size: 11),
                  ]),
                  const SizedBox(height: 3),
                  Row(children: [
                    const Icon(Icons.location_on_outlined, size: 11, color: AppColors.textMuted),
                    const SizedBox(width: 2),
                    Expanded(child: Text(offer.adresse, overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 11, color: AppColors.textMuted))),
                  ]),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(offer.prix, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.accent)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: offer.restants <= 2 ? Colors.orange : Colors.green,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text('${offer.restants} restant${offer.restants > 1 ? 's' : ''}',
                      style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _cartFab() {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/cart'),
      child: Container(
        width: 50, height: 50,
        decoration: BoxDecoration(
          color: const Color(0xFFE8A45A),
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: const Icon(Icons.shopping_cart_outlined, color: AppColors.textDark, size: 26),
      ),
    );
  }
}