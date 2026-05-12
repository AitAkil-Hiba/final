//=====================================================================================

import 'package:flutter/material.dart';
import 'profile/profil_commercant.dart';
import 'statistiques_page.dart';
import 'mes_commandes_page.dart';
import 'mes_offres_page.dart';
import 'creer_offre/creer_offre_step1.dart';
import 'prof_client_signal/fiche_client_page.dart';
import '../../services/auth_service.dart';
import '../../services/api_service.dart';

class AccueilCommercantPage extends StatefulWidget {
  const AccueilCommercantPage({super.key});

  @override
  State<AccueilCommercantPage> createState() => _AccueilCommercantPageState();
}

class _AccueilCommercantPageState extends State<AccueilCommercantPage> {
  int _selectedNavIndex = 2;

  static const Color topBarColor = Color(0xFFF9AE63);
  static const Color backgroundColor = Color(0xFFFEFAE0);
  static const Color cardColor = Color(0xFFE9EDC9);
  static const Color orangeColor = Color(0xFFE8824A);
  static const Color brownColor = Color(0xFF5D4E37);

  bool _showAllReservations = false;
  bool _isLoading = false;
  Map<String, dynamic>? _merchantProfile;
  List<Map<String, dynamic>> _reservations = [];
  List<Map<String, dynamic>> _offres = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final authService = AuthService();
    final userRole = await authService.getUserRole();

    if (userRole == null || userRole != 'COMMERCANT') {
      if (mounted) {
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/login', (route) => false);
      }
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Charger profil réel
      print('🔍 Chargement du profil commerçant...');
      final profile = await ApiService.getCurrentProfile();
      print('📥 Réponse API profil: $profile');

      // Charger réservations réelles
      final ordersResponse = await ApiService.getMyOrders(size: 10);
      print('📥 Réponse API réservations: $ordersResponse');
      final ordersList = ordersResponse['reservations'] as List? ?? [];

      // Charger offres réelles
      print('🔍 Chargement des offres...');
      final offresResponse = await ApiService.getMyOffers(
        size: 10,
        statut: 'PUBLIEE',
      );

      // 🔍 DEBUG - Voir la vraie structure
      print('📦 Clés disponibles dans offresResponse: ${offresResponse.keys}');

      // ✅ CORRECTION - La clé est "offres" (avec un S)
      List offresList = [];

      if (offresResponse['offres'] != null) {
        offresList = offresResponse['offres'] as List;
        print('✅ Trouvé dans "offres": ${offresList.length} offres');
      } else if (offresResponse['content'] != null) {
        offresList = offresResponse['content'] as List;
        print('✅ Trouvé dans "content": ${offresList.length} offres');
      } else if (offresResponse['data'] != null) {
        offresList = offresResponse['data'] as List;
        print('✅ Trouvé dans "data": ${offresList.length} offres');
      } else {
        print('❌ Aucune clé trouvée. Clés: ${offresResponse.keys}');
      }

      print('📊 offresList contient ${offresList.length} offres');

      if (offresList.isNotEmpty) {
        print('📊 Première offre (debug): ${offresList[0]}');
      }

      setState(() {
        _merchantProfile = profile;
        _isLoading = false;

        // Transformer réservations
        _reservations = ordersList.map<Map<String, dynamic>>((order) {
          return {
            'id': order['id']?.toString() ?? '',
            'initials': _getInitials(
              order['clientNom'] ?? order['clientName'] ?? '',
            ),
            'name': order['clientNom'] ?? order['clientName'] ?? 'Client',
            'detail': order['offreTitre'] ?? order['titre'] ?? 'Offre',
            'time': _formatTime(
              order['heureRetrait'] ?? order['dateReservation'] ?? '',
            ),
            'status': _getStatusText(order['statut'] ?? order['status'] ?? ''),
            'statusTone': _getStatusTone(
              order['statut'] ?? order['status'] ?? '',
            ),
            'isIcon':
                (order['statut'] ?? order['status'] ?? '')
                    .toString()
                    .toUpperCase() ==
                'EN_ATTENTE',
          };
        }).toList();

        // Transformer offres
        _offres = offresList.map<Map<String, dynamic>>((offre) {
          return {
            'id': offre['id']?.toString() ?? '',
            'title': offre['titre'] ?? offre['title'] ?? 'Offre',
            'price': '${offre['prixReduit'] ?? offre['prix'] ?? 0} DA',
            'reservations':
                '${offre['quantiteDisponible'] ?? offre['stock'] ?? 0} disponibles',
          };
        }).toList();

        print('📊 FINAL - Réservations: ${_reservations.length}');
        print('📊 FINAL - Offres: ${_offres.length}');
      });
    } catch (e) {
      print('❌ ERREUR dans _loadData: $e');
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur de chargement : ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _getInitials(String fullName) {
    if (fullName.isEmpty) return '';
    final parts = fullName.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return parts[0][0].toUpperCase();
  }

  String _formatTime(String timeString) {
    if (timeString.isEmpty) return '--:--';
    try {
      final time = DateTime.parse(timeString);
      return '${time.hour.toString().padLeft(2, '0')}h${time.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return timeString.replaceAll(':', 'h');
    }
  }

  String _getStatusText(String status) {
    switch (status.toUpperCase()) {
      case 'CONFIRMEE':
      case 'CONFIRMED':
        return 'Confirmé';
      case 'EN_ATTENTE':
      case 'PENDING':
        return 'En attente';
      case 'RECUPEREE':
      case 'COMPLETED':
        return 'Récupéré';
      case 'ANNULEE':
      case 'CANCELLED':
        return 'Annulé';
      default:
        return status.isNotEmpty ? status : 'Inconnu';
    }
  }

  String _getStatusTone(String status) {
    switch (status.toUpperCase()) {
      case 'CONFIRMEE':
      case 'CONFIRMED':
        return 'ok';
      case 'EN_ATTENTE':
      case 'PENDING':
        return 'pending';
      default:
        return 'neutral';
    }
  }

  String get _nomCommerce =>
      _merchantProfile?['nomCommerce'] ??
      _merchantProfile?['commerceName'] ??
      _merchantProfile?['nom'] ??
      'Mon Commerce';

  String get _adresse =>
      _merchantProfile?['adresse'] ?? _merchantProfile?['address'] ?? 'Alger';

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              _buildTopHeader(),
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFFE8824A),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadData,
                        color: orangeColor,
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 18),
                              _buildReservationsSection(),
                              const SizedBox(height: 20),
                              _buildOffresSection(),
                              const SizedBox(height: 16),
                            ],
                          ),
                        ),
                      ),
              ),
              _buildBottomNavBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
      decoration: const BoxDecoration(
        color: topBarColor,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(26),
          bottomRight: Radius.circular(26),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFFFF8E1),
              border: Border.all(color: const Color(0xFF8B7355), width: 1.4),
            ),
            child: ClipOval(
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 32,
                      height: 24,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD2691E),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.lunch_dining,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                    Text(
                      _nomCommerce.length >= 2
                          ? _nomCommerce.substring(0, 2).toUpperCase()
                          : 'MC',
                      style: const TextStyle(
                        fontSize: 6,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF5D4037),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _nomCommerce,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF3E2723),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      size: 14,
                      color: Color(0xFF3E2723),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        _adresse,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF3E2723),
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
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

  Widget _buildReservationsSection() {
    final visible = _showAllReservations
        ? _reservations
        : _reservations.take(3).toList();

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: const [
                Icon(Icons.shopping_cart_outlined, size: 20, color: brownColor),
                SizedBox(width: 8),
                Text(
                  'Réservations du jour',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF3E2723),
                  ),
                ),
              ],
            ),
            GestureDetector(
              onTap: () =>
                  setState(() => _showAllReservations = !_showAllReservations),
              child: Text(
                _showAllReservations ? 'Voir moins' : 'Voir tout',
                style: const TextStyle(
                  fontSize: 13,
                  color: orangeColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_reservations.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Center(
              child: Text(
                'Aucune réservation aujourd\'hui',
                style: TextStyle(fontSize: 14, color: Color(0xFF9E9E9E)),
              ),
            ),
          )
        else
          Column(
            children: List.generate(visible.length, (i) {
              final r = visible[i];
              return Padding(
                padding: EdgeInsets.only(
                  bottom: i == visible.length - 1 ? 0 : 10,
                ),
                child: GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const FicheClientPage()),
                  ),
                  child: _buildReservationCard(
                    initials: r['initials'] as String,
                    name: r['name'] as String,
                    detail: r['detail'] as String,
                    time: r['time'] as String,
                    status: r['status'] as String,
                    statusTone: r['statusTone'] as String,
                    isIcon: r['isIcon'] as bool,
                  ),
                ),
              );
            }),
          ),
      ],
    );
  }

  Widget _buildReservationCard({
    required String initials,
    required String name,
    required String detail,
    required String time,
    required String status,
    required String statusTone,
    bool isIcon = false,
  }) {
    final (badgeBg, badgeFg) = switch (statusTone) {
      'ok' => (const Color(0xFFFFE8D6), orangeColor),
      'pending' => (const Color(0xFFF0EDE6), const Color(0xFF9E9E9E)),
      _ => (const Color(0xFFF0EDE6), const Color(0xFF9E9E9E)),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const FicheClientPage()),
            ),
            child: Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: Color(0xFFD7E0BE),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: isIcon
                    ? const Icon(
                        Icons.person_outline,
                        size: 22,
                        color: Color(0xFF5D4E37),
                      )
                    : Text(
                        initials,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          color: Color(0xFF5D4E37),
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
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: Color(0xFF3E2723),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  detail,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF757575),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                time,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: orangeColor,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: badgeFg,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOffresSection() {
    print('🏠 _buildOffresSection: _offres.length = ${_offres.length}');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: const [
                Icon(Icons.local_offer_outlined, size: 20, color: brownColor),
                SizedBox(width: 8),
                Text(
                  'Mes offres actives',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF3E2723),
                  ),
                ),
              ],
            ),
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MesOffresPage()),
              ),
              child: const Text(
                'Gérer',
                style: TextStyle(
                  fontSize: 13,
                  color: orangeColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // 🔍 Affichage debug temporaire
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            'Debug: ${_offres.length} offre(s) chargée(s)',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ),

        if (_offres.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Column(
                children: [
                  const Text(
                    'Aucune offre active',
                    style: TextStyle(fontSize: 14, color: Color(0xFF9E9E9E)),
                  ),
                  Text(
                    '(Données: ${_offres.length} offres)',
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ],
              ),
            ),
          )
        else
          SizedBox(
            height: 200,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _offres.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final offre = _offres[index];
                return SizedBox(
                  width: 140,
                  child: _buildOffreCard(
                    title: offre['title']!,
                    price: offre['price']!,
                    imageUrl: offre['imageUrl'],
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildOffreCard({
    required String title,
    required String price,
    String? imageUrl,
  }) {
    return Container(
      width: 140,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
            child: Container(
              height: 90,
              width: double.infinity,
              color: const Color(0xFFD7CFC0),
              child: imageUrl != null && imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.bakery_dining,
                          size: 40,
                          color: Color(0xFF8B7355),
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFF8B7355),
                          ),
                        );
                      },
                    )
                  : const Icon(
                      Icons.bakery_dining,
                      size: 40,
                      color: Color(0xFF8B7355),
                    ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF3E2723),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  price,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: orangeColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavBar() {
    final icons = [
      Icons.shopping_bag_outlined,
      Icons.add,
      Icons.home_outlined,
      Icons.show_chart,
      Icons.person_outline,
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      decoration: const BoxDecoration(
        color: Color(0xFFCCD5AE),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(icons.length, (index) {
          final isSelected = _selectedNavIndex == index;
          return GestureDetector(
            onTap: () {
              if (index == 0) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MesCommandesPage()),
                );
                return;
              }
              if (index == 1) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CreerOffreStep1()),
                );
                return;
              }
              if (index == 3) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const StatistiquesPage()),
                );
                return;
              }
              if (index == 4) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfilCommercant()),
                );
                return;
              }
              setState(() => _selectedNavIndex = index);
            },
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFFDDCD9E)
                    : const Color(0xFFE9EDC9),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFB8C49E), width: 1),
              ),
              child: Icon(
                icons[index],
                size: 24,
                color: isSelected
                    ? const Color(0xFF5D4037)
                    : const Color(0xFF7D7D7D),
              ),
            ),
          );
        }),
      ),
    );
  }
}
