

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:peeco/client/pages/navigation_bar.dart';
import 'package:peeco/client/pages/app_constants.dart';
import 'package:peeco/client/pages/widgets/standard_header.dart';
import 'package:latlong2/latlong.dart';

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
  static const chipDark     = Color(0xFF6B7C4E);
}

// ─────────────────────────────────────────────
// MODÈLE COMMERÇANT SUR CARTE
// ─────────────────────────────────────────────
class MarqueurCommercant {
  final String id;
  final String nom;
  final String categorie;
  final String adresse;
  final double note;
  final int nbOffres;
  final double distance;
  final LatLng position;
  final String? imageAsset;

  const MarqueurCommercant({
    required this.id,
    required this.nom,
    required this.categorie,
    required this.adresse,
    required this.note,
    required this.nbOffres,
    required this.distance,
    required this.position,
    this.imageAsset,
  });
}

// ─────────────────────────────────────────────
// DONNÉES FICTIVES — Zone Kouba, Alger
// ─────────────────────────────────────────────
const LatLng _centreKouba = LatLng(36.7167, 3.1833);
late final String? imageAsset;
final List<MarqueurCommercant> _commercants = [
  MarqueurCommercant(
    id: 'c1',
    nom: 'Le Moulin Doré',
    categorie: 'Boulangerie',
    adresse: 'Laprovale, Kouba',
    note: 4.6,
    nbOffres: 3,
    distance: 0.4,
    position: const LatLng(36.7180, 3.1820),
    imageAsset: 'assets/images/moulin_dore.png', 
  ),
  MarqueurCommercant(
    id: 'c2',
    nom: "L'Assiette des Angles",
    categorie: 'Restaurant',
    adresse: 'Jolie Vue, Kouba',
    note: 3.9,
    nbOffres: 4,
    distance: 1.3,
    position: const LatLng(36.7140, 3.1860),
    imageAsset: 'assets/images/assiette_angles.png', 
  ),
  MarqueurCommercant(
    id: 'c3',
    nom: 'Le Panier Frais',
    categorie: 'Superette',
    adresse: 'Laprovale, Kouba',
    note: 4.6,
    nbOffres: 2,
    distance: 0.9,
    position: const LatLng(36.7155, 3.1800),
    imageAsset: 'assets/images/panier_frais.png', 
  ),
  MarqueurCommercant(
    id: 'c4',
    nom: 'Boulangerie El Baraka',
    categorie: 'Boulangerie',
    adresse: 'Hussein Dey, Alger',
    note: 4.8,
    nbOffres: 5,
    distance: 1.8,
    position: const LatLng(36.7200, 3.1870),
    imageAsset: 'assets/images/corbeille_matin.png', 
  ),
  MarqueurCommercant(
    id: 'c5',
    nom: 'Café du Coin',
    categorie: 'Café',
    adresse: 'Jolie Vue, Kouba',
    note: 4.2,
    nbOffres: 2,
    distance: 2.1,
    position: const LatLng(36.7130, 3.1840),
    imageAsset: 'assets/images/café.png', 
  ),
  MarqueurCommercant(
  id: 'c6',
    nom: 'La Maison du Pain',
    categorie: 'Boulangerie',
    adresse: 'Laprovale, Kouba',
    note: 4.6,
    nbOffres: 2,
    distance: 4 ,
    position: const LatLng(36.7130, 3.1840),
    imageAsset: 'assets/images/offre_maison_pain.png', 
  ),
  MarqueurCommercant(
      id: 'c7',
      nom: 'Burger House',
      categorie: 'Restaurant',
      adresse: 'Vieux Kouba, Kouba, Alger',
      note:5.0,
      distance: 1.5,
      nbOffres: 4,
      position: const LatLng(36.7130, 3.1840),
      imageAsset: 'assets/images/burger_house2.png' ,
  ),
];

// ─────────────────────────────────────────────
// CARTE SCREEN
// ─────────────────────────────────────────────
class CarteScreen extends StatefulWidget {
  const CarteScreen({super.key});

  @override
  State<CarteScreen> createState() => _CarteScreenState();
}

class _CarteScreenState extends State<CarteScreen> {
  // États
  bool _localisationActive = false;
  bool _vueListeActive     = false;
  String _categorieSelectionnee = 'Tout';
  String _recherche = '';
  MarqueurCommercant? _marqueurSelectionne;

  // Filtre avancé
  double? _noteMin;         
  double? _distanceMax;     
  bool get _filtreActif => _noteMin != null || _distanceMax != null;

  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showFiltreBottomSheet() {
    double? noteTmp = _noteMin;
    double? distTmp = _distanceMax;

    showModalBottomSheet(
      context: context,
      backgroundColor: _C.cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: _C.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Filtres',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: _C.textDark)),
              const SizedBox(height: 20),

              const Text('Note minimum',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _C.textDark)),
              const SizedBox(height: 8),
              Row(
                children: [null, 3.0, 3.5, 4.0, 4.5].map((val) {
                  final sel = noteTmp == val;
                  return GestureDetector(
                    onTap: () => setModal(() => noteTmp = val),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: sel ? _C.accent : _C.scaffold,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: sel ? _C.accent : _C.divider),
                      ),
                      child: Text(
                        val == null ? 'Tout' : '★ $val+',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: sel ? _C.white : _C.textMuted,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),

              // Distance max
              const Text('Distance maximum',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _C.textDark)),
              const SizedBox(height: 8),
              Row(
                children: [null, 0.5, 1.0, 2.0, 5.0].map((val) {
                  final sel = distTmp == val;
                  return GestureDetector(
                    onTap: () => setModal(() => distTmp = val),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: sel ? _C.accent : _C.scaffold,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: sel ? _C.accent : _C.divider),
                      ),
                      child: Text(
                        val == null ? 'Tout' : '${val.toString().replaceAll('.0', '')} km',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: sel ? _C.white : _C.textMuted,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 28),

              // Boutons
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() { _noteMin = null; _distanceMax = null; });
                        Navigator.pop(ctx);
                      },
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: _C.scaffold,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: _C.divider),
                        ),
                        child: const Center(
                          child: Text('Réinitialiser',
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: _C.textMuted)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() { _noteMin = noteTmp; _distanceMax = distTmp; });
                        Navigator.pop(ctx);
                      },
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: _C.accent,
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: const Center(
                          child: Text('Appliquer',
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: _C.white)),
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

  final MapController _mapController = MapController();
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();

  final List<String> _categories = [
    'Tout', 'Boulangerie', 'Restaurant', 'Café', 'Superette'
  ];

  // Filtrage
  List<MarqueurCommercant> get _commercantsFiltres {
    return _commercants.where((c) {
      final matchCat = _categorieSelectionnee == 'Tout' ||
          c.categorie == _categorieSelectionnee;
      final matchSearch = _recherche.isEmpty ||
          c.nom.toLowerCase().contains(_recherche.toLowerCase()) ||
          c.adresse.toLowerCase().contains(_recherche.toLowerCase());
      final matchNote = _noteMin == null || c.note >= _noteMin!;
      final matchDist = _distanceMax == null || c.distance <= _distanceMax!;
      return matchCat && matchSearch && matchNote && matchDist;
    }).toList()
      ..sort((a, b) => a.distance.compareTo(b.distance));
  }

  // Couleur catégorie
  Color _catColor(String c) {
    switch (c) {
      case 'Boulangerie': return _C.accent;
      case 'Restaurant':  return _C.chipDark;
      case 'Café':        return const Color(0xFF7D5A3C);
      case 'Superette':   return const Color(0xFF5A9E8B);
      default:            return _C.textMuted;
    }
  }

  IconData _catIcon(String c) {
    switch (c) {
      case 'Boulangerie': return Icons.bakery_dining_outlined;
      case 'Restaurant':  return Icons.restaurant_outlined;
      case 'Café':        return Icons.coffee_outlined;
      case 'Superette':   return Icons.shopping_basket_outlined;
      default:            return Icons.storefront_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    return Scaffold(
      backgroundColor: _C.scaffold,
      body: Stack(
        children: [
          Column(
            children: [
              _appBar(),
             
              _filtresCategories(),
              _toggleVue(),
              Expanded(
                child: _localisationActive
                    ? (_vueListeActive ? _vueListe() : _vueCarte())
                    : _promptLocalisation(),
              ),
            ],
          ),

          // ── Fiche commerçant sélectionné ──
          if (_marqueurSelectionne != null && !_vueListeActive)
            Positioned(
              bottom: 0, left: 0, right: 0,
              child: _ficheCommercant(_marqueurSelectionne!),
            ),
          // Navigation bar
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: AppNavigationBar(
              selectedIndex: 1, 
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
  // APP BAR - Using StandardHeader with location like home page
  // ─────────────────────────────────────────────
 Widget _appBar() {
  return StandardHeader(
    title: 'Carte',
    showLogo: true,
    showSearchBar: true,
    showBackButton: false,
    showLocation: true,
    searchHint: 'Rechercher un commerçant...',
  );
}

  // ─────────────────────────────────────────────
  // FILTRES CATÉGORIES
  // ─────────────────────────────────────────────
  Widget _filtresCategories() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 8, 16, 0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _categories.map((cat) {
            final sel = _categorieSelectionnee == cat;
            return GestureDetector(
              onTap: () =>
                  setState(() => _categorieSelectionnee = cat),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: sel ? const Color.fromARGB(238, 204, 213, 174) : const Color.fromARGB(227, 251, 195, 139),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: sel ? _C.chipDark : _C.divider,
                      width: 0.5),
                ),
                child: Text(cat,
                    style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: sel ? _C.textDark : _C.textMuted)),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // TOGGLE CARTE / LISTE
  // ─────────────────────────────────────────────
  Widget _toggleVue() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(150, 8, 16, 10),
      child: Row(
        children: [
          _toggleBtn(Icons.map_outlined, '', !_vueListeActive,
              () => setState(() => _vueListeActive = false)),
          const SizedBox(width: 60),
          _toggleBtn(Icons.list_outlined, '', _vueListeActive,
              () => setState(() => _vueListeActive = true)),
        ],
      ),
    );
  }

  Widget _toggleBtn(IconData icon, String label, bool sel,
      VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
            horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: sel ? const Color.fromARGB(226, 245, 212, 180) : _C.cardBg,
          borderRadius: BorderRadius.circular(60),
          
        ),
        child: Row(
          children: [
            Icon(icon, size: 30,
                color: sel ? _C.textDark : _C.textMuted),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                    fontSize: 5.0,
                    fontWeight: FontWeight.w400,
                    color: sel ? _C.white : _C.textMuted)),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // PROMPT LOCALISATION DÉSACTIVÉE
  // ─────────────────────────────────────────────
  Widget _promptLocalisation() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
            vertical: 40, horizontal: 60),
        decoration: BoxDecoration(
          color: _C.cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _C.divider),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60, height: 60,
              decoration: BoxDecoration(
                color: _C.navBg.withOpacity(0.4),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.map_outlined,
                  size: 40, color: _C.textDark),
            ),
            const SizedBox(height: 16),
            const Text('Activez votre localisation',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: _C.textDark)),
            const SizedBox(height: 8),
            const Text(
              'Activez votre localisation pour découvrir les commerçants près de vous et profiter des meilleures offres autour de vous.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 12.5,
                  color: _C.textMuted,
                  height: 1.55),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () =>
                  setState(() => _localisationActive = true),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: _C.cardBg,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                      color: _C.divider, width: 1.5),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.location_on_outlined,
                        size: 15, color: _C.textDark),
                    SizedBox(width: 6),
                    Text('Activez votre localisation',
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: _C.textDark)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () =>
                  setState(() => _localisationActive = true),
              child: const Text(
                'Entrer une adresse manuellement',
                style: TextStyle(
                  fontSize: 12.5,
                  color: _C.textMuted,
                  decoration: TextDecoration.underline,
                  decorationColor: _C.textMuted,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // VUE CARTE — flutter_map
  // ─────────────────────────────────────────────
  Widget _vueCarte() {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: _centreKouba,
        initialZoom: 14.5,
        onTap: (_, __) =>
            setState(() => _marqueurSelectionne = null),
      ),
      children: [
        // Fond OpenStreetMap
        TileLayer(
          urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
          subdomains: const ['a', 'b', 'c'],
          userAgentPackageName: 'com.laaisraf.app',
          maxZoom: 19,
          tileProvider: NetworkTileProvider(),
          errorTileCallback: (tile, error, stackTrace) {
          debugPrint('Tile error: $error');
  },
        ),

        // Marqueur position utilisateur
        MarkerLayer(
          markers: [
            Marker(
              point: _centreKouba,
              width: 50,
              height: 50,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 240, 234, 230),
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: _C.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: _C.accent.withOpacity(0.4),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        // Marqueurs commerçants
        MarkerLayer(
          markers: _commercantsFiltres.map((c) {
            final isSelected = _marqueurSelectionne?.id == c.id;
            return Marker(
              point: c.position,
              width: isSelected ? 44 : 36,
              height: isSelected ? 44 : 36,
              child: GestureDetector(
                onTap: () => setState(
                    () => _marqueurSelectionne = c),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? _C.accent
                        : _catColor(c.categorie),
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: _C.white, width: 2.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black
                            .withOpacity(0.2),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    _catIcon(c.categorie),
                    size: isSelected ? 22 : 17,
                    color: _C.white,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // VUE LISTE
  // ─────────────────────────────────────────────
  Widget _vueListe() {
    final liste = _commercantsFiltres;
    if (liste.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.storefront_outlined,
                size: 48,
                color: _C.textMuted.withOpacity(0.5)),
            const SizedBox(height: 12),
            const Text('Aucun commerce trouvé',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: _C.textDark)),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 32),
      itemCount: liste.length,
      itemBuilder: (_, i) => _carteCommercant(liste[i]),
    );
  }

  Widget _carteCommercant(MarqueurCommercant c) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(
          context, '/home_client'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: _C.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: _C.divider.withOpacity(0.6)),
        ),
        child: Row(
          children: [
            // Image commerçant (avec fallback icône)
            Container(
              width: 75, height: 75,
              decoration: BoxDecoration(
                color: _catColor(c.categorie)
                    .withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color:
                        _catColor(c.categorie).withOpacity(0.3)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: c.imageAsset != null
                    ? Image.asset(
                        c.imageAsset!,
                        width: 70, height:70,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Icon(
                            _catIcon(c.categorie),
                            color: _catColor(c.categorie), size: 22),
                      )
                    : Icon(_catIcon(c.categorie),
                        color: _catColor(c.categorie), size: 22),
              ),
            ),
            const SizedBox(width: 12),
            // Infos
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(c.nom,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: _C.textDark)),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star,
                              size: 12, color: _C.accent),
                          const SizedBox(width: 2),
                          Text(c.note.toString(),
                              style: const TextStyle(
                                  fontSize: 11.5,
                                  color: _C.textMuted)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(c.categorie,
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _catColor(c.categorie))),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                          Icons.location_on_outlined,
                          size: 11, color: _C.textMuted),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(c.adresse,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 11,
                                color: _C.textMuted)),
                      ),
                      Text('${c.distance} km',
                          style: const TextStyle(
                              fontSize: 11,
                              color: _C.textMuted,
                              fontWeight: FontWeight.w600)),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: _C.accent,
                          borderRadius:
                              BorderRadius.circular(20),
                        ),
                        child: Text(
                            '${c.nbOffres} offres',
                            style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: _C.white)),
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
  }

  // ─────────────────────────────────────────────
  // FICHE COMMERÇANT (tap sur marqueur)
  // ─────────────────────────────────────────────
  Widget _ficheCommercant(MarqueurCommercant c) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _C.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: _C.accent.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              color: _catColor(c.categorie).withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: _catColor(c.categorie).withOpacity(0.3)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: c.imageAsset != null
                  ? Image.asset(
                      c.imageAsset!,
                      width: 70, height: 70,
                      fit: BoxFit.cover,
                      // ignore: unnecessary_underscores
                      errorBuilder: (_, __, ___) => Icon(
                          _catIcon(c.categorie),
                          color: _catColor(c.categorie), size: 24),
                    )
                  : Icon(_catIcon(c.categorie),
                      color: _catColor(c.categorie), size: 24),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(c.nom,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: _C.textDark)),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined,
                        size: 11, color: _C.textMuted),
                    const SizedBox(width: 2),
                    Expanded(
                      child: Text(c.adresse,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 11.5,
                              color: _C.textMuted)),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star,
                        size: 12, color: _C.accent),
                    const SizedBox(width: 3),
                    Text(c.note.toString(),
                        style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: _C.textDark)),
                    const SizedBox(width: 8),
                    Text('${c.distance} km',
                        style: const TextStyle(
                            fontSize: 11,
                            color: _C.textMuted)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: _C.accent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text('${c.nbOffres} offres',
                          style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: _C.white)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Bouton voir
          GestureDetector(
            onTap: () => Navigator.pushNamed(
                context, '/home_client'),
            child: Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: _C.accent,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_forward,
                  color: _C.white, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}