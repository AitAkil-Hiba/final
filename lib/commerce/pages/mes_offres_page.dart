/*import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class MesOffresPage extends StatefulWidget {
  const MesOffresPage({super.key});

  @override
  State<MesOffresPage> createState() => _MesOffresPageState();
}

class _MesOffresPageState extends State<MesOffresPage> {
  static const Color topBarColor = Color(0xFFCCD5AE);
  static const Color backgroundColor = Color(0xFFFEFAE0);
  static const Color cardColor = Color(0xFFE9EDC9);
  static const Color orangeColor = Color(0xFFF9AE63);
  static const Color btnColor = orangeColor;
  static const Color annulerColor = Color(0xFFD7CFC0);
  static const Color brownColor = Color(0xFF5D4E37);
  static const Color overlayColor = Color(0xFFFEFAE0);

  final TextEditingController _searchController = TextEditingController();
  int? _deleteIndex;
  bool _isLoading = false;
  String? _error;

  List<Map<String, dynamic>> _offres = [];

  @override
  void initState() {
    super.initState();
    _loadMyOffers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Charger les offres depuis l'API
  Future<void> _loadMyOffers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await ApiService.getMyOffers(
        page: 0,
        size: 10,
        statut: 'PUBLIEE', // Charger uniquement les offres publiées
      );

      setState(() {
        _isLoading = false;
        // Transformer les données de l'API en format attendu par l'UI
        _offres = (response['offers'] ?? []).map<Map<String, dynamic>>((offer) {
          return {
            'id': offer['id'],
            'title': offer['titre'] ?? 'Sans titre',
            'price': '${offer['prixReduit'] ?? 0}Da',
            'originalPrice': '${offer['prixOriginal'] ?? 0} DA',
            'restants': '${offer['quantiteDisponible'] ?? 0} restants',
            'publiee': _formatDate(offer['createdAt']),
            'expire': '${offer['heureFinRetrait'] ?? 'N/A'}',
            'reservations': '${offer['totalReservations'] ?? '0'}',
            'statut': offer['statut'] ?? 'PUBLIEE',
            'description': offer['description'] ?? '',
          };
        }).toList();
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });

      // Afficher un message d'erreur
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Erreur lors du chargement des offres: ${e.toString()}',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Formater la date
  String _formatDate(String? dateString) {
    if (dateString == null) return "Aujourd'hui";
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      if (date.day == now.day &&
          date.month == now.month &&
          date.year == now.year) {
        return "Aujourd'hui";
      }
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return "Aujourd'hui";
    }
  }

  // Supprimer une offre
  Future<void> _deleteOffer(int index) async {
    final offer = _offres[index];
    final offerId = offer['id'];

    if (offerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ID de l\'offre non trouvé'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      await ApiService.deleteOffer(offerId);

      setState(() {
        _offres.removeAt(index);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Offre supprimée avec succès'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la suppression: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Rafraîchir les offres
  Future<void> _refreshOffers() async {
    await _loadMyOffers();
  }

  // Construire le contenu principal selon l'état
  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3E2723)),
            ),
            SizedBox(height: 16),
            Text(
              'Chargement des offres...',
              style: TextStyle(fontSize: 14, color: Color(0xFF9E9E9E)),
            ),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Color(0xFFE57373)),
            const SizedBox(height: 16),
            const Text(
              'Erreur de chargement',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF3E2723),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Color(0xFF9E9E9E)),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _refreshOffers,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF9AE63),
                foregroundColor: const Color(0xFF3E2723),
              ),
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    if (_offres.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 48, color: Color(0xFF9E9E9E)),
            SizedBox(height: 16),
            Text(
              'Aucune offre active',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF9E9E9E),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Commencez par créer votre première offre',
              style: TextStyle(fontSize: 14, color: Color(0xFF9E9E9E)),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _offres.length,
      itemBuilder: (context, i) => _buildOffreCard(i),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Container(height: 8, color: topBarColor),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(
                          Icons.arrow_back,
                          color: Color(0xFF3E2723),
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Mes offres actives',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF3E2723),
                        ),
                      ),
                      const Spacer(),
                      // Bouton de rafraîchissement
                      IconButton(
                        onPressed: _isLoading ? null : _refreshOffers,
                        icon: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Color(0xFF3E2723),
                                  ),
                                ),
                              )
                            : const Icon(
                                Icons.refresh,
                                color: Color(0xFF3E2723),
                                size: 20,
                              ),
                      ),
                    ],
                  ),
                ),
                // Search bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF424242),
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Rechercher une offre...',
                        hintStyle: TextStyle(
                          fontSize: 13,
                          color: Color(0xFFBDB5A0),
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          size: 18,
                          color: Color(0xFF9E9E9E),
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(child: _buildContent()),
              ],
            ),

            // ── Delete overlay ──
            if (_deleteIndex != null)
              Positioned.fill(
                child: Stack(
                  children: [
                    Container(color: Colors.black.withOpacity(0.15)),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 36,
                        ),
                        decoration: const BoxDecoration(
                          color: overlayColor,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30),
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: orangeColor,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.delete_outline,
                                color: Color(0xFF3E2723),
                                size: 40,
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              "Supprimer l'offre",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF3E2723),
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Êtes-vous sûr de vouloir supprimer cette offre ?\nCette action est irréversible.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF9E9E9E),
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 32),
                            GestureDetector(
                              onTap: () => setState(() => _deleteIndex = null),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                decoration: BoxDecoration(
                                  color: annulerColor,
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: const Center(
                                  child: Text(
                                    'Annuler',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: brownColor,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            GestureDetector(
                              onTap: () async {
                                final indexToDelete = _deleteIndex!;
                                setState(() => _deleteIndex = null);
                                await _deleteOffer(indexToDelete);
                              },
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                decoration: BoxDecoration(
                                  color: orangeColor,
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: const Center(
                                  child: Text(
                                    'Supprimer',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
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

  Widget _buildOffreCard(int index) {
    final offre = _offres[index];
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image + timer
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                child: Container(
                  height: 180,
                  width: double.infinity,
                  color: const Color(0xFFD7CFC0),
                  child: const Center(
                    child: Icon(
                      Icons.bakery_dining,
                      size: 60,
                      color: Color(0xFF8B7355),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.55),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    offre['timer'] as String,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        offre['title'] as String,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF3E2723),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: btnColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        offre['restants'] as String,
                        style: const TextStyle(
                          fontSize: 11,
                          color: brownColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(
                      Icons.chevron_right,
                      size: 18,
                      color: Color(0xFFBDBDBD),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      offre['price'] as String,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: orangeColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      offre['originalPrice'] as String,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF9E9E9E),
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 10,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFCCD5AE),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      _buildStat('Publiée', offre['publiee'] as String),
                      _buildStat('Expire', offre['expire'] as String),
                      _buildStat(
                        'Réservations',
                        offre['reservations'] as String,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {},
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: btnColor,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(
                                Icons.edit_outlined,
                                size: 16,
                                color: brownColor,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Modifier',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: brownColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _deleteIndex = index),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: btnColor,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(
                                Icons.delete_outline,
                                size: 16,
                                color: brownColor,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Supprimer',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: brownColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: Color(0xFF9E9E9E)),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF3E2723),
            ),
          ),
        ],
      ),
    );
  }
}
*/

//==============================================================================
//==============================================================================

import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class MesOffresPage extends StatefulWidget {
  const MesOffresPage({super.key});

  @override
  State<MesOffresPage> createState() => _MesOffresPageState();
}

class _MesOffresPageState extends State<MesOffresPage> {
  static const Color topBarColor = Color(0xFFCCD5AE);
  static const Color backgroundColor = Color(0xFFFEFAE0);
  static const Color cardColor = Color(0xFFE9EDC9);
  static const Color orangeColor = Color(0xFFF9AE63);
  static const Color btnColor = orangeColor;
  static const Color annulerColor = Color(0xFFD7CFC0);
  static const Color brownColor = Color(0xFF5D4E37);
  static const Color overlayColor = Color(0xFFFEFAE0);

  final TextEditingController _searchController = TextEditingController();
  int? _deleteIndex;
  bool _isLoading = false;
  String? _error;

  List<Map<String, dynamic>> _offres = [];

  @override
  void initState() {
    super.initState();
    _loadMyOffers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Charger les offres depuis l'API
  Future<void> _loadMyOffers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await ApiService.getMyOffers(
        page: 0,
        size: 10,
        statut: 'PUBLIEE',
      );

      setState(() {
        _isLoading = false;
        // ✅ CORRECTION: Utiliser "offres" (français) au lieu de "offers"
        final offresData = response['offres'] as List? ?? [];

        _offres = offresData.map<Map<String, dynamic>>((offer) {
          return {
            'id': offer['id']?.toString() ?? '',
            'title': offer['titre']?.toString() ?? 'Sans titre',
            'price': offer['prixReduit'] != null
                ? '${offer['prixReduit']} Da'
                : '0 Da',
            'originalPrice': offer['prixOriginal'] != null
                ? '${offer['prixOriginal']} DA'
                : '0 DA',
            'restants': offer['quantiteDisponible'] != null
                ? '${offer['quantiteDisponible']} restants'
                : '0 restants',
            'publiee': _formatDate(offer['createdAt']?.toString()),
            'expire': offer['heureFinRetrait']?.toString() ?? 'N/A',
            'reservations': offer['nombreReservations']?.toString() ?? '0',
            'statut': offer['statut']?.toString() ?? 'PUBLIEE',
            'description': offer['description']?.toString() ?? '',
          };
        }).toList();
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Formater la date (version corrigée pour accepter null)
  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return "Aujourd'hui";
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      if (date.day == now.day &&
          date.month == now.month &&
          date.year == now.year) {
        return "Aujourd'hui";
      }
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return "Aujourd'hui";
    }
  }

  // Supprimer une offre
  Future<void> _deleteOffer(int index) async {
    final offer = _offres[index];
    final offerId = offer['id'];

    if (offerId == null || offerId.toString().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ID de l\'offre non trouvé'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      await ApiService.deleteOffer(offerId.toString());

      setState(() {
        _offres.removeAt(index);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Offre supprimée avec succès'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Rafraîchir les offres
  Future<void> _refreshOffers() async {
    await _loadMyOffers();
  }

  // Construire le contenu principal selon l'état
  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3E2723)),
            ),
            SizedBox(height: 16),
            Text(
              'Chargement des offres...',
              style: TextStyle(fontSize: 14, color: Color(0xFF9E9E9E)),
            ),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Color(0xFFE57373)),
            const SizedBox(height: 16),
            const Text(
              'Erreur de chargement',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF3E2723),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Color(0xFF9E9E9E)),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _refreshOffers,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF9AE63),
                foregroundColor: const Color(0xFF3E2723),
              ),
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    if (_offres.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 48, color: Color(0xFF9E9E9E)),
            SizedBox(height: 16),
            Text(
              'Aucune offre active',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF9E9E9E),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Commencez par créer votre première offre',
              style: TextStyle(fontSize: 14, color: Color(0xFF9E9E9E)),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _offres.length,
      itemBuilder: (context, i) => _buildOffreCard(i),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Container(height: 8, color: topBarColor),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(
                          Icons.arrow_back,
                          color: Color(0xFF3E2723),
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Mes offres actives',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF3E2723),
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: _isLoading ? null : _refreshOffers,
                        icon: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Color(0xFF3E2723),
                                  ),
                                ),
                              )
                            : const Icon(
                                Icons.refresh,
                                color: Color(0xFF3E2723),
                                size: 20,
                              ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF424242),
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Rechercher une offre...',
                        hintStyle: TextStyle(
                          fontSize: 13,
                          color: Color(0xFFBDB5A0),
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          size: 18,
                          color: Color(0xFF9E9E9E),
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(child: _buildContent()),
              ],
            ),

            // Delete overlay
            if (_deleteIndex != null)
              Positioned.fill(
                child: Stack(
                  children: [
                    Container(color: Colors.black.withOpacity(0.15)),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 36,
                        ),
                        decoration: const BoxDecoration(
                          color: overlayColor,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30),
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: orangeColor,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.delete_outline,
                                color: Color(0xFF3E2723),
                                size: 40,
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              "Supprimer l'offre",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF3E2723),
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Êtes-vous sûr de vouloir supprimer cette offre ?\nCette action est irréversible.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF9E9E9E),
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 32),
                            GestureDetector(
                              onTap: () => setState(() => _deleteIndex = null),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                decoration: BoxDecoration(
                                  color: annulerColor,
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: const Center(
                                  child: Text(
                                    'Annuler',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: brownColor,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            GestureDetector(
                              onTap: () async {
                                final indexToDelete = _deleteIndex!;
                                setState(() => _deleteIndex = null);
                                await _deleteOffer(indexToDelete);
                              },
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                decoration: BoxDecoration(
                                  color: orangeColor,
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: const Center(
                                  child: Text(
                                    'Supprimer',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
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

  Widget _buildOffreCard(int index) {
    final offre = _offres[index];
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                child: Container(
                  height: 180,
                  width: double.infinity,
                  color: const Color(0xFFD7CFC0),
                  child: const Center(
                    child: Icon(
                      Icons.bakery_dining,
                      size: 60,
                      color: Color(0xFF8B7355),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.55),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    offre['expire'] as String,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        offre['title'] as String,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF3E2723),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: btnColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        offre['restants'] as String,
                        style: const TextStyle(
                          fontSize: 11,
                          color: brownColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(
                      Icons.chevron_right,
                      size: 18,
                      color: Color(0xFFBDBDBD),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      offre['price'] as String,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: orangeColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      offre['originalPrice'] as String,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF9E9E9E),
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 10,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFCCD5AE),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      _buildStat('Publiée', offre['publiee'] as String),
                      _buildStat('Expire', offre['expire'] as String),
                      _buildStat(
                        'Réservations',
                        offre['reservations'] as String,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {},
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: btnColor,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(
                                Icons.edit_outlined,
                                size: 16,
                                color: brownColor,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Modifier',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: brownColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _deleteIndex = index),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: btnColor,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(
                                Icons.delete_outline,
                                size: 16,
                                color: brownColor,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Supprimer',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: brownColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: Color(0xFF9E9E9E)),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF3E2723),
            ),
          ),
        ],
      ),
    );
  }
}

//==============================================================================
//=============================================================================
//la version ou il modifie l'offre et la supprime
/*
import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../pages/creer_offre/creer_offre_step1.dart';

class MesOffresPage extends StatefulWidget {
  const MesOffresPage({super.key});

  @override
  State<MesOffresPage> createState() => _MesOffresPageState();
}

class _MesOffresPageState extends State<MesOffresPage> {
  static const Color topBarColor = Color(0xFFCCD5AE);
  static const Color backgroundColor = Color(0xFFFEFAE0);
  static const Color cardColor = Color(0xFFE9EDC9);
  static const Color orangeColor = Color(0xFFF9AE63);
  static const Color btnColor = orangeColor;
  static const Color annulerColor = Color(0xFFD7CFC0);
  static const Color brownColor = Color(0xFF5D4E37);
  static const Color overlayColor = Color(0xFFFEFAE0);

  final TextEditingController _searchController = TextEditingController();
  int? _deleteIndex;
  bool _isLoading = false;
  String? _error;

  List<Map<String, dynamic>> _allOffres = [];
  List<Map<String, dynamic>> _filteredOffres = [];

  @override
  void initState() {
    super.initState();
    _loadMyOffers();
    _searchController.addListener(_filterOffres);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterOffres);
    _searchController.dispose();
    super.dispose();
  }

  void _filterOffres() {
    final query = _searchController.text.toLowerCase().trim();
    if (query.isEmpty) {
      setState(() {
        _filteredOffres = List.from(_allOffres);
      });
    } else {
      setState(() {
        _filteredOffres = _allOffres.where((offre) {
          final title = offre['title']?.toString().toLowerCase() ?? '';
          final description =
              offre['description']?.toString().toLowerCase() ?? '';
          return title.contains(query) || description.contains(query);
        }).toList();
      });
    }
  }

  Future<void> _loadMyOffers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await ApiService.getMyOffers(
        page: 0,
        size: 50,
        statut: 'PUBLIEE',
      );

      setState(() {
        _isLoading = false;
        final offresData = response['offres'] as List? ?? [];

        _allOffres = offresData.map<Map<String, dynamic>>((offer) {
          String? imageUrl;
          final images = offer['images'] as List?;
          if (images != null && images.isNotEmpty) {
            imageUrl = images[0]?.toString();
          }

          return {
            'id': offer['id']?.toString() ?? '',
            'title': offer['titre']?.toString() ?? 'Sans titre',
            'description': offer['description']?.toString() ?? '',
            'price': offer['prixReduit'] != null
                ? '${offer['prixReduit']} Da'
                : '0 Da',
            'originalPrice': offer['prixOriginal'] != null
                ? '${offer['prixOriginal']} DA'
                : '0 DA',
            'restants': offer['quantiteDisponible'] != null
                ? '${offer['quantiteDisponible']} restants'
                : '0 restants',
            'publiee': _formatDate(offer['createdAt']?.toString()),
            'expire': offer['heureFinRetrait']?.toString() ?? 'N/A',
            'reservations': offer['nombreReservations']?.toString() ?? '0',
            'statut': offer['statut']?.toString() ?? 'PUBLIEE',
            'imageUrl': imageUrl,
            // Données complètes pour la modification
            'prixOriginalValue': offer['prixOriginal'],
            'prixReduitValue': offer['prixReduit'],
            'quantiteDisponible': offer['quantiteDisponible'],
            'dateExpiration': offer['dateExpiration'],
            'heureDebutRetrait': offer['heureDebutRetrait'],
            'heureFinRetrait': offer['heureFinRetrait'],
            'typeNourriture': offer['typeNourriture'],
            'allergenes': offer['allergenes'],
            'preferencesAlim': offer['preferencesAlim'],
            'images': images ?? [],
          };
        }).toList();

        _filteredOffres = List.from(_allOffres);
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return "Aujourd'hui";
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      if (date.day == now.day &&
          date.month == now.month &&
          date.year == now.year) {
        return "Aujourd'hui";
      }
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return "Aujourd'hui";
    }
  }

  Future<void> _deleteOffer(int index) async {
    final offer = _filteredOffres[index];
    final offerId = offer['id'];

    if (offerId == null || offerId.toString().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ID de l\'offre non trouvé'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      await ApiService.deleteOffer(offerId.toString());

      setState(() {
        _allOffres.removeWhere((o) => o['id'] == offerId);
        _filteredOffres.removeAt(index);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Offre supprimée avec succès'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _editOffer(Map<String, dynamic> offer) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreerOffreStep1(
          isEditing: true,
          offreId: offer['id'],
          offerData: offer,
        ),
      ),
    ).then((_) => _loadMyOffers());
  }

  Future<void> _refreshOffres() async {
    await _loadMyOffers();
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3E2723)),
            ),
            SizedBox(height: 16),
            Text(
              'Chargement des offres...',
              style: TextStyle(fontSize: 14, color: Color(0xFF9E9E9E)),
            ),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Color(0xFFE57373)),
            const SizedBox(height: 16),
            const Text(
              'Erreur de chargement',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF3E2723),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Color(0xFF9E9E9E)),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _refreshOffres,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF9AE63),
                foregroundColor: const Color(0xFF3E2723),
              ),
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    if (_filteredOffres.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.inbox_outlined,
              size: 48,
              color: Color(0xFF9E9E9E),
            ),
            const SizedBox(height: 16),
            Text(
              _searchController.text.isEmpty
                  ? 'Aucune offre active'
                  : 'Aucun résultat pour "${_searchController.text}"',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF9E9E9E),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _searchController.text.isEmpty
                  ? 'Commencez par créer votre première offre'
                  : 'Essayez un autre terme de recherche',
              style: const TextStyle(fontSize: 14, color: Color(0xFF9E9E9E)),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _filteredOffres.length,
      itemBuilder: (context, i) => _buildOffreCard(i),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Container(height: 8, color: topBarColor),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(
                          Icons.arrow_back,
                          color: Color(0xFF3E2723),
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Mes offres actives',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF3E2723),
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: _isLoading ? null : _refreshOffres,
                        icon: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Color(0xFF3E2723),
                                  ),
                                ),
                              )
                            : const Icon(
                                Icons.refresh,
                                color: Color(0xFF3E2723),
                                size: 20,
                              ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF424242),
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Rechercher une offre...',
                        hintStyle: TextStyle(
                          fontSize: 13,
                          color: Color(0xFFBDB5A0),
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          size: 18,
                          color: Color(0xFF9E9E9E),
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(child: _buildContent()),
              ],
            ),

            if (_deleteIndex != null)
              Positioned.fill(
                child: Stack(
                  children: [
                    Container(color: Colors.black.withOpacity(0.15)),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 36,
                        ),
                        decoration: const BoxDecoration(
                          color: overlayColor,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30),
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: orangeColor,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.delete_outline,
                                color: Color(0xFF3E2723),
                                size: 40,
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              "Supprimer l'offre",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF3E2723),
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Êtes-vous sûr de vouloir supprimer cette offre ?\nCette action est irréversible.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF9E9E9E),
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 32),
                            GestureDetector(
                              onTap: () => setState(() => _deleteIndex = null),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                decoration: BoxDecoration(
                                  color: annulerColor,
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: const Center(
                                  child: Text(
                                    'Annuler',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: brownColor,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            GestureDetector(
                              onTap: () async {
                                final indexToDelete = _deleteIndex!;
                                setState(() => _deleteIndex = null);
                                await _deleteOffer(indexToDelete);
                              },
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                decoration: BoxDecoration(
                                  color: orangeColor,
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: const Center(
                                  child: Text(
                                    'Supprimer',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
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

  Widget _buildOffreCard(int index) {
    final offre = _filteredOffres[index];
    final hasImage =
        offre['imageUrl'] != null && offre['imageUrl'].toString().isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                child: Container(
                  height: 180,
                  width: double.infinity,
                  color: const Color(0xFFD7CFC0),
                  child: hasImage
                      ? Image.network(
                          offre['imageUrl']!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(
                              child: Icon(
                                Icons.bakery_dining,
                                size: 60,
                                color: Color(0xFF8B7355),
                              ),
                            );
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const Center(
                              child: CircularProgressIndicator(
                                color: Color(0xFF8B7355),
                              ),
                            );
                          },
                        )
                      : const Center(
                          child: Icon(
                            Icons.bakery_dining,
                            size: 60,
                            color: Color(0xFF8B7355),
                          ),
                        ),
                ),
              ),
              Positioned(
                bottom: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.55),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    offre['expire'] as String,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        offre['title'] as String,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF3E2723),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: btnColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        offre['restants'] as String,
                        style: const TextStyle(
                          fontSize: 11,
                          color: brownColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(
                      Icons.chevron_right,
                      size: 18,
                      color: Color(0xFFBDBDBD),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      offre['price'] as String,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: orangeColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      offre['originalPrice'] as String,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF9E9E9E),
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 10,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFCCD5AE),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      _buildStat('Publiée', offre['publiee'] as String),
                      _buildStat('Expire', offre['expire'] as String),
                      _buildStat(
                        'Réservations',
                        offre['reservations'] as String,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _editOffer(offre),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: btnColor,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(
                                Icons.edit_outlined,
                                size: 16,
                                color: brownColor,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Modifier',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: brownColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _deleteIndex = index),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: btnColor,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(
                                Icons.delete_outline,
                                size: 16,
                                color: brownColor,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Supprimer',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: brownColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: Color(0xFF9E9E9E)),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF3E2723),
            ),
          ),
        ],
      ),
    );
  }
} */
