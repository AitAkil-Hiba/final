import 'package:flutter/material.dart';
import 'profile/profil_commercant.dart';
import 'statistiques_page.dart';
import 'creer_offre/creer_offre_step1.dart';
import 'prof_client_signal/fiche_client_page.dart';

class MesCommandesPage extends StatefulWidget {
  const MesCommandesPage({super.key});

  @override
  State<MesCommandesPage> createState() => _MesCommandesPageState();
}

class _MesCommandesPageState extends State<MesCommandesPage> {
  int _selectedTab = 0;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  static const Color topBarColor = Color(0xFFCCD5AE);
  static const Color backgroundColor = Color(0xFFFEFAE0);
  static const Color cardColor = Color(0xFFF5EED8);
  static const Color orangeColor = Color(0xFFF9AE63);
  static const Color brownColor = Color(0xFF5D4E37);
  static const Color selectedNavColor = Color(0xFFDDCD9E);
  static const Color unselectedNavColor = Color(0xFFE9EDC9);

  // Historique — dynamique, les commandes traitées s'y ajoutent
  final List<Map<String, dynamic>> _historique = [
    {
      'initials': 'K',
      'name': 'Karim B.',
      'status': 'Récupérée',
      'statusOk': true,
      'product': 'Panier boulangerie',
      'date': '19 mars · 13h15',
      'price': '180 da',
      'motif': null,
    },
    {
      'initials': 'AG',
      'name': 'Anfel G.',
      'status': 'Annulée',
      'statusOk': false,
      'product': 'Pain complet × 1',
      'date': '12 mars',
      'price': '90 da',
      'motif': 'Client absent',
    },
  ];

  // Mes commandes — seulement les commandes en attente
  final List<Map<String, dynamic>> _commandes = [
    {
      'initials': 'A',
      'name': 'Amina B',
      'number': '#4872',
      'product': 'Panier boulangerie',
      'qty': 2,
      'time': '17h–19h',
      'price': '360 Da',
    },
    {
      'initials': 'M',
      'name': 'Marwa B',
      'number': '#4871',
      'product': 'Box viennoiseries',
      'qty': 1,
      'time': '19h–20h',
      'price': '120 Da',
    },
    {
      'initials': 'S',
      'name': 'Samir T',
      'number': '#4870',
      'product': 'Panier boulangerie',
      'qty': 1,
      'time': '17h–19h',
      'price': '180 Da',
    },
  ];

  List<Map<String, dynamic>> get _filteredCommandes => _commandes
      .where(
        (c) =>
            c['name'].toString().toLowerCase().contains(_searchQuery) ||
            c['product'].toString().toLowerCase().contains(_searchQuery),
      )
      .toList();

  List<Map<String, dynamic>> get _filteredHistorique => _historique
      .where(
        (c) =>
            c['name'].toString().toLowerCase().contains(_searchQuery) ||
            c['product'].toString().toLowerCase().contains(_searchQuery),
      )
      .toList();

  void _handleAction(Map<String, dynamic> commande, bool accepted) {
    setState(() {
      _commandes.remove(commande);
      _historique.insert(0, {
        'initials': commande['initials'],
        'name': commande['name'],
        'status': accepted ? 'Acceptée' : 'Refusée',
        'statusOk': accepted,
        'product': commande['product'],
        'date': 'Aujourd\'hui',
        'price': commande['price'],
        'motif': accepted ? null : 'Refusée par le commerçant',
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Container(height: 8, color: topBarColor),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                ],
              ),
            ),
            _buildTabs(),
            Expanded(
              child: _selectedTab == 0
                  ? _buildMesCommandesTab()
                  : _buildHistoriqueTab(),
            ),
            _buildBottomNavBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE0D8C8), width: 1)),
      ),
      child: Row(
        children: [_buildTab('Mes commandes', 0), _buildTab('Historique', 1)],
      ),
    );
  }

  Widget _buildTab(String label, int index) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() {
          _selectedTab = index;
          _searchController.clear();
          _searchQuery = '';
        }),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? orangeColor : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isSelected ? orangeColor : const Color(0xFF9E9E9E),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
        style: const TextStyle(fontSize: 13, color: Color(0xFF424242)),
        decoration: InputDecoration(
          hintText: 'Chercher client, offre...',
          hintStyle: const TextStyle(fontSize: 13, color: Color(0xFFBDB5A0)),
          prefixIcon: const Icon(
            Icons.search,
            size: 18,
            color: Color(0xFF9E9E9E),
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                  child: const Icon(
                    Icons.close,
                    size: 18,
                    color: Color(0xFF9E9E9E),
                  ),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  // ── MES COMMANDES TAB ──
  Widget _buildMesCommandesTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: _buildSearchBar(),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: const Text(
            "Aujourd'hui · 19 mars 2026",
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(0xFF757575),
            ),
          ),
        ),
        Expanded(
          child: _filteredCommandes.isEmpty
              ? const Center(
                  child: Text(
                    'Aucune commande',
                    style: TextStyle(fontSize: 14, color: Color(0xFF9E9E9E)),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  itemCount: _filteredCommandes.length,
                  itemBuilder: (context, i) =>
                      _buildCommandeItem(_filteredCommandes[i]),
                ),
        ),
      ],
    );
  }

  Widget _buildCommandeItem(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Avatar cliquable
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const FicheClientPage()),
            ),
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: const Color(0xFFCCD5AE),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  item['initials'] as String,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: brownColor,
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
                Row(
                  children: [
                    Text(
                      item['name'] as String,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Color(0xFF3E2723),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      item['number'] as String,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF9E9E9E),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      item['price'] as String,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: orangeColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Text(
                      '${item['product']} X ',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF9E9E9E),
                      ),
                    ),
                    Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD7CFC0),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Center(
                        child: Text(
                          '${item['qty']}',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: brownColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  item['time'] as String,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF9E9E9E),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Boutons action
          Row(
            children: [
              _buildActionBtn(
                icon: Icons.close,
                bg: const Color(0xFFD7CFC0),
                iconColor: const Color(0xFF5D4E37),
                onTap: () => _handleAction(item, false),
              ),
              const SizedBox(width: 6),
              _buildActionBtn(
                icon: Icons.check,
                bg: orangeColor,
                iconColor: Colors.white,
                onTap: () => _handleAction(item, true),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionBtn({
    required IconData icon,
    required Color bg,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 16, color: iconColor),
      ),
    );
  }

  // ── HISTORIQUE TAB ──
  Widget _buildHistoriqueTab() {
    return Column(
      children: [
        Padding(padding: const EdgeInsets.all(16), child: _buildSearchBar()),
        Expanded(
          child: _filteredHistorique.isEmpty
              ? const Center(
                  child: Text(
                    'Aucun historique',
                    style: TextStyle(fontSize: 14, color: Color(0xFF9E9E9E)),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _filteredHistorique.length,
                  itemBuilder: (context, i) =>
                      _buildHistoriqueItem(_filteredHistorique[i]),
                ),
        ),
      ],
    );
  }

  Widget _buildHistoriqueItem(Map<String, dynamic> item) {
    final bool isOk = item['statusOk'] as bool;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const FicheClientPage()),
                ),
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCCD5AE),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      item['initials'] as String,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        color: brownColor,
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
                    Row(
                      children: [
                        Text(
                          item['name'] as String,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: Color(0xFF3E2723),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: isOk
                                ? const Color(0xFFDFF0D8)
                                : const Color(0xFFFFE8D6),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isOk ? Icons.check : Icons.close,
                                size: 11,
                                color: isOk
                                    ? const Color(0xFF4CAF50)
                                    : orangeColor,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                item['status'] as String,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: isOk
                                      ? const Color.fromARGB(255, 120, 196, 122)
                                      : orangeColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item['product'] as String,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF9E9E9E),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    item['price'] as String,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: orangeColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item['date'] as String,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF9E9E9E),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 6),
              const Icon(
                Icons.chevron_right,
                size: 16,
                color: Color(0xFFBDBDBD),
              ),
            ],
          ),
          if (item['motif'] != null) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFEDE8D8),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Motif :  ${item['motif']}',
                style: const TextStyle(fontSize: 12, color: Color(0xFF9E9E9E)),
              ),
            ),
          ],
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: topBarColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(icons.length, (index) {
          final isSelected = index == 0;
          return GestureDetector(
            onTap: () {
              if (index == 0) return;
              if (index == 1) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CreerOffreStep1()),
                );
                return;
              }
              if (index == 2) {
                Navigator.popUntil(context, (route) => route.isFirst);
                return;
              }
              if (index == 3) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const StatistiquesPage()),
                );
                return;
              }
              if (index == 4) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfilCommercant()),
                );
                return;
              }
            },
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: isSelected ? selectedNavColor : unselectedNavColor,
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
