import 'package:flutter/material.dart';
import 'core/core.dart';
import '../services/admin_service.dart';
import '../models/client_model.dart';

class ClientsPage extends StatefulWidget {
  const ClientsPage({super.key});

  @override
  State<ClientsPage> createState() => _ClientsPageState();
}

class _ClientsPageState extends State<ClientsPage> {
  String _selectedFilter = 'Tous';
  final List<String> _filters = ['Tous', 'Actifs', 'Suspendus'];
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final AdminService _adminService = AdminService();
  bool _isLoading = true;
  String? _errorMessage;

  List<ClientItem> _clients = [];

  @override
  void initState() {
    super.initState();
    _loadClients();
  }

  Future<void> _loadClients() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final apiClients = await _adminService.getClients();
      
      final items = apiClients.map((api) => ClientItem(
        id: api.id,
        name: api.fullName,
        initials: _getInitials(api.fullName),
        email: api.email,
        status: api.status,
        statusType: api.actif ? ClientStatus.active : ClientStatus.suspended,
        registeredDate: api.dateInscription,
        lastConnection: DateTime.now(),
        reservations: 0, 
        cancellations: 0,
      )).toList();
      
      setState(() {
        _clients = items;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
      _showErrorBanner('Erreur de chargement', e.toString());
    }
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '';
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, name.length > 2 ? 2 : name.length).toUpperCase();
  }

  void _showErrorBanner(String message, String subtitle) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (ctx) => _ErrorBanner(
        message: message,
        subtitle: subtitle,
        onDone: () => entry.remove(),
      ),
    );
    overlay.insert(entry);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<ClientItem> get _filteredClients {
    List<ClientItem> result = [..._clients];
    
    switch (_selectedFilter) {
      case 'Actifs':
        result = result.where((c) => c.statusType == ClientStatus.active).toList();
        break;
      case 'Suspendus':
        result = result.where((c) => c.statusType == ClientStatus.suspended).toList();
        break;
      case 'Inactifs':
        result = result.where((c) => c.statusType == ClientStatus.inactive).toList();
        break;
    }
    
    if (_searchQuery.isNotEmpty) {
      result = result.where((c) =>
        c.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        c.email.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }
    
    return result;
  }

  void _showClientDetails(ClientItem client) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ClientDetailsPage(client: client),
      ),
    );
  }

  void _suspendClient(ClientItem client) async {
    final confirm = await _showSuspendConfirmation(client.name);
    if (confirm == true) {
      setState(() => _isLoading = true);
      try {
        await _adminService.suspendClient(client.id);
        await _loadClients();
        _showSuccessBanner('Client suspendu');
      } catch (e) {
        _showErrorBanner('Erreur', e.toString());
        setState(() => _isLoading = false);
      }
    }
  }

  void _reactivateClient(ClientItem client) async {
    final confirm = await _showReactivateConfirmation(client.name);
    if (confirm == true) {
      setState(() => _isLoading = true);
      try {
        await _adminService.reactivateClient(client.id);
        await _loadClients();
        _showSuccessBanner('Client réactivé');
      } catch (e) {
        _showErrorBanner('Erreur', e.toString());
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSuccessBanner(String message) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (ctx) => _SuccessBanner(
        message: message,
        onDone: () => entry.remove(),
      ),
    );
    overlay.insert(entry);
  }

  Future<bool?> _showSuspendConfirmation(String name) {
    final r = _Responsive(context);
    return showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(r.scale(28))),
        backgroundColor: Colors.white,
        child: Container(
          padding: EdgeInsets.all(r.scale(24)),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(r.scale(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Suspendre le client',
                style: AppTextStyles.listItemTitle.copyWith(fontSize: r.fontSize(18), fontWeight: FontWeight.w700),
              ),
              SizedBox(height: r.scale(16)),
              Text(
                'Êtes-vous sûr de vouloir suspendre ce client ?',
                style: AppTextStyles.bodyMedium.copyWith(fontSize: r.fontSize(14)),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: r.scale(8)),
              Container(
                padding: EdgeInsets.all(r.scale(12)),
                decoration: BoxDecoration(
                  color: const Color(0xFFFDF5E6),
                  borderRadius: BorderRadius.circular(r.scale(12)),
                ),
                child: Text(
                  '"$name"',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    fontSize: r.fontSize(14),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: r.scale(8)),
              Text(
                'Cette action est réversible. Le client ne pourra plus effectuer de réservations.',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textMuted,
                  fontSize: r.fontSize(12),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: r.scale(24)),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: r.scale(12)),
                        backgroundColor: const Color(0xFFE8E8E8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(r.scale(30)),
                        ),
                      ),
                      child: Text(
                        'Annuler',
                        style: TextStyle(
                          fontFamily: AppFonts.plusJakarta,
                          fontSize: r.fontSize(14),
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: r.scale(12)),
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: r.scale(12)),
                        backgroundColor: const Color(0xFFF8B068).withOpacity(0.1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(r.scale(30)),
                        ),
                      ),
                      child: Text(
                        'Suspendre',
                        style: TextStyle(
                          fontFamily: AppFonts.plusJakarta,
                          fontSize: r.fontSize(14),
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFF8B068),
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

  Future<bool?> _showReactivateConfirmation(String name) {
    final r = _Responsive(context);
    return showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(r.scale(28))),
        backgroundColor: Colors.white,
        child: Container(
          padding: EdgeInsets.all(r.scale(24)),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(r.scale(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Réactiver le client',
                style: AppTextStyles.listItemTitle.copyWith(fontSize: r.fontSize(18), fontWeight: FontWeight.w700),
              ),
              SizedBox(height: r.scale(16)),
              Text(
                'Êtes-vous sûr de vouloir réactiver ce client ?',
                style: AppTextStyles.bodyMedium.copyWith(fontSize: r.fontSize(14)),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: r.scale(8)),
              Container(
                padding: EdgeInsets.all(r.scale(12)),
                decoration: BoxDecoration(
                  color: const Color(0xFFFDF5E6),
                  borderRadius: BorderRadius.circular(r.scale(12)),
                ),
                child: Text(
                  '"$name"',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    fontSize: r.fontSize(14),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: r.scale(24)),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: r.scale(12)),
                        backgroundColor: const Color(0xFFE8E8E8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(r.scale(30)),
                        ),
                      ),
                      child: Text(
                        'Annuler',
                        style: TextStyle(
                          fontFamily: AppFonts.plusJakarta,
                          fontSize: r.fontSize(14),
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: r.scale(12)),
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: r.scale(12)),
                        backgroundColor: const Color(0xFFA8C88A).withOpacity(0.15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(r.scale(30)),
                        ),
                      ),
                      child: Text(
                        'Réactiver',
                        style: TextStyle(
                          fontFamily: AppFonts.plusJakarta,
                          fontSize: r.fontSize(14),
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFA8C88A),
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

  @override
  Widget build(BuildContext context) {
    final r = _Responsive(context);
    final totalCount = _filteredClients.length;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: appGradient,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(r.hp(8), r.vp(12), r.hp(20), 0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.arrow_back_ios_new_rounded, 
                          size: r.scale(20),
                          color: AppColors.textPrimary),
                    ),
                    SizedBox(width: r.hp(8)),
                    Text('Clients', style: TextStyle(
                      fontFamily: AppFonts.plusJakarta,
                      fontSize: r.fontSize(24),
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.5,
                    )),
                    const Spacer(),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: r.hp(12), vertical: r.vp(8)),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(r.scale(30)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.people_outline_rounded, size: r.scale(16)),
                          SizedBox(width: r.hp(4)),
                          Text(
                            '$totalCount',
                            style: TextStyle(
                              fontFamily: AppFonts.plusJakarta,
                              fontSize: r.fontSize(14),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: r.vp(12)),
              
              Padding(
                padding: EdgeInsets.symmetric(horizontal: r.hp(20)),
                child: SizedBox(
                  height: r.scale(48),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(r.scale(30)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                      style: TextStyle(
                        fontFamily: AppFonts.plusJakarta,
                        fontSize: r.fontSize(14),
                      ),
                      decoration: InputDecoration(
                        hintText: 'Rechercher un utilisateur...',
                        hintStyle: TextStyle(
                          fontFamily: AppFonts.plusJakarta,
                          fontSize: r.fontSize(13),
                          color: AppColors.textMuted,
                        ),
                        prefixIcon: Icon(Icons.search, size: r.scale(18), color: AppColors.textMuted),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: r.hp(16), vertical: r.vp(12)),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: Icon(Icons.close_rounded, size: r.scale(18), color: AppColors.textMuted),
                                onPressed: () {
                                  setState(() {
                                    _searchController.clear();
                                    _searchQuery = '';
                                  });
                                },
                              )
                            : null,
                      ),
                    ),
                  ),
                ),
              ),
              
              SizedBox(height: r.vp(12)),
              
              Center(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: r.hp(20)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: _filters.map((filter) {
                        final isSelected = _selectedFilter == filter;
                        return Padding(
                          padding: EdgeInsets.symmetric(horizontal: r.hp(6)),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedFilter = filter;
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: r.hp(16), vertical: r.vp(8)),
                              decoration: BoxDecoration(
                                color: isSelected 
                                    ? const Color(0xFFCCD5AE)
                                    : const Color(0xFFFAEDCD),
                                borderRadius: BorderRadius.circular(r.scale(30)),
                                border: isSelected ? null : Border.all(
                                  color: const Color(0xFFE8DEC8),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                filter,
                                style: TextStyle(
                                  fontFamily: AppFonts.plusJakarta,
                                  fontSize: r.fontSize(13),
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
              
              SizedBox(height: r.vp(16)),
              
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _filteredClients.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: r.scale(70),
                              height: r.scale(70),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.5),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.people_outline_rounded,
                                size: r.scale(40),
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                            SizedBox(height: r.vp(10)),
                            Text(
                              'Aucun client',
                              style: AppTextStyles.pageTitle.copyWith(
                                fontSize: r.fontSize(20),
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        controller: _scrollController,
                        padding: EdgeInsets.fromLTRB(r.hp(20), 0, r.hp(20), r.vp(100)),
                        itemCount: _filteredClients.length,
                        separatorBuilder: (_, __) => SizedBox(height: r.vp(12)),
                        itemBuilder: (_, index) {
                          final client = _filteredClients[index];
                          return _ClientCard(
                            client: client,
                            onViewProfile: () => _showClientDetails(client),
                            onAction: () {
                              if (client.statusType == ClientStatus.suspended) {
                                _reactivateClient(client);
                              } else {
                                _suspendClient(client);
                              }
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum ClientStatus { active, suspended, inactive }

class ClientItem {
  final String id;
  final String name;
  final String initials;
  final String email;
  final String status;
  final ClientStatus statusType;
  final DateTime registeredDate;
  final DateTime lastConnection;
  final int reservations;
  final int cancellations;

  ClientItem({
    required this.id,
    required this.name,
    required this.initials,
    required this.email,
    required this.status,
    required this.statusType,
    required this.registeredDate,
    required this.lastConnection,
    required this.reservations,
    required this.cancellations,
  });

  ClientItem copyWith({
    String? id,
    String? name,
    String? initials,
    String? email,
    String? status,
    ClientStatus? statusType,
    DateTime? registeredDate,
    DateTime? lastConnection,
    int? reservations,
    int? cancellations,
  }) {
    return ClientItem(
      id: id ?? this.id,
      name: name ?? this.name,
      initials: initials ?? this.initials,
      email: email ?? this.email,
      status: status ?? this.status,
      statusType: statusType ?? this.statusType,
      registeredDate: registeredDate ?? this.registeredDate,
      lastConnection: lastConnection ?? this.lastConnection,
      reservations: reservations ?? this.reservations,
      cancellations: cancellations ?? this.cancellations,
    );
  }
}

class _ClientCard extends StatelessWidget {
  const _ClientCard({
    required this.client,
    required this.onViewProfile,
    required this.onAction,
  });

  final ClientItem client;
  final VoidCallback onViewProfile;
  final VoidCallback onAction;

  Color get _statusColor {
    switch (client.statusType) {
      case ClientStatus.active:
        return const Color(0xFFA8C88A);
      case ClientStatus.suspended:
        return const Color(0xFFF8B068);
      case ClientStatus.inactive:
        return const Color(0xFFAAAAAA);
    }
  }

  String get _actionLabel {
    switch (client.statusType) {
      case ClientStatus.active:
        return 'Suspendre';
      case ClientStatus.suspended:
        return 'Réactiver';
      case ClientStatus.inactive:
        return 'Suspendre';
    }
  }

  Color get _actionColor {
    switch (client.statusType) {
      case ClientStatus.active:
        return const Color(0xFFF8B068);
      case ClientStatus.suspended:
        return const Color(0xFFA8C88A);
      case ClientStatus.inactive:
        return const Color(0xFFF8B068);
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = _Responsive(context);

    return Container(
      padding: EdgeInsets.all(r.scale(16)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(r.scale(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: r.scale(52),
                height: r.scale(52),
                decoration: BoxDecoration(
                  color: const Color(0xFFCCD5AE).withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    client.initials,
                    style: TextStyle(
                      fontFamily: AppFonts.plusJakarta,
                      fontSize: r.fontSize(18),
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF5C4A2A),
                    ),
                  ),
                ),
              ),
              SizedBox(width: r.hp(14)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      client.name,
                      style: AppTextStyles.listItemTitle.copyWith(
                        fontSize: r.fontSize(16),
                        fontWeight: FontWeight.w700,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: r.vp(2)),
                    Text(
                      client.email,
                      style: AppTextStyles.bodySmall.copyWith(fontSize: r.fontSize(12)),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: r.hp(10), vertical: r.vp(4)),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(r.scale(12)),
                ),
                child: Text(
                  client.status,
                  style: TextStyle(
                    fontFamily: AppFonts.plusJakarta,
                    fontSize: r.fontSize(11),
                    fontWeight: FontWeight.w700,
                    color: _statusColor,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: r.vp(14)),
          Align(
            alignment: Alignment.centerRight,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton(
                    onPressed: onViewProfile,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: r.hp(16), vertical: r.vp(8)),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      backgroundColor: const Color(0xFFCCD5AE).withOpacity(0.15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(r.scale(30)),
                      ),
                    ),
                    child: Text(
                      'Voir le profil',
                      style: TextStyle(
                        fontFamily: AppFonts.plusJakarta,
                        fontSize: r.fontSize(13),
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF8B5E3C),
                      ),
                    ),
                  ),
                  SizedBox(width: r.hp(8)),
                  TextButton(
                    onPressed: onAction,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: r.hp(16), vertical: r.vp(8)),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      backgroundColor: _actionColor.withOpacity(0.1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(r.scale(30)),
                      ),
                    ),
                    child: Text(
                      _actionLabel,
                      style: TextStyle(
                        fontFamily: AppFonts.plusJakarta,
                        fontSize: r.fontSize(13),
                        fontWeight: FontWeight.w600,
                        color: _actionColor,
                      ),
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
}

class _SuccessBanner extends StatefulWidget {
  const _SuccessBanner({
    required this.message,
    required this.onDone,
  });
  final String message;
  final VoidCallback onDone;

  @override
  State<_SuccessBanner> createState() => _SuccessBannerState();
}

class _SuccessBannerState extends State<_SuccessBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<Offset> _slide;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 380));
    _slide = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();
    Future.delayed(const Duration(milliseconds: 2400), () {
      if (mounted) _ctrl.reverse().then((_) => widget.onDone());
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = _Responsive(context);
    final bannerBottom = MediaQuery.of(context).viewInsets.bottom + r.vp(20);
    final navbarHeight = kBottomNavigationBarHeight;
    final finalBottom = bannerBottom + navbarHeight + r.vp(8);

    return Positioned(
      bottom: finalBottom,
      left: r.hp(20),
      right: r.hp(20),
      child: SlideTransition(
        position: _slide,
        child: FadeTransition(
          opacity: _fade,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: r.hp(18), vertical: r.vp(14)),
              decoration: BoxDecoration(
                color: const Color(0xFFCCD5AE),
                borderRadius: BorderRadius.circular(r.scale(30)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.10),
                    blurRadius: 18,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: r.scale(32),
                    height: r.scale(32),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.check_rounded,
                        size: r.scale(18), color: Colors.black87),
                  ),
                  SizedBox(width: r.hp(12)),
                  Expanded(
                    child: Text(
                      widget.message,
                      style: TextStyle(
                        fontFamily: AppFonts.plusJakarta,
                        fontSize: r.fontSize(13),
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatefulWidget {
  const _ErrorBanner({
    required this.message,
    required this.subtitle,
    required this.onDone,
  });
  final String message;
  final String subtitle;
  final VoidCallback onDone;

  @override
  State<_ErrorBanner> createState() => _ErrorBannerState();
}

class _ErrorBannerState extends State<_ErrorBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<Offset> _slide;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 380));
    _slide = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();
    Future.delayed(const Duration(milliseconds: 2400), () {
      if (mounted) _ctrl.reverse().then((_) => widget.onDone());
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = _Responsive(context);
    final bannerBottom = MediaQuery.of(context).viewInsets.bottom + r.vp(20);
    final navbarHeight = kBottomNavigationBarHeight;
    final finalBottom = bannerBottom + navbarHeight + r.vp(8);

    return Positioned(
      bottom: finalBottom,
      left: r.hp(20),
      right: r.hp(20),
      child: SlideTransition(
        position: _slide,
        child: FadeTransition(
          opacity: _fade,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: r.hp(18), vertical: r.vp(14)),
              decoration: BoxDecoration(
                color: const Color(0xFFF8B068).withOpacity(0.95),
                borderRadius: BorderRadius.circular(r.scale(30)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.10),
                    blurRadius: 18,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: r.scale(32),
                    height: r.scale(32),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.close_rounded,
                        size: r.scale(18), color: Colors.black87),
                  ),
                  SizedBox(width: r.hp(12)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.message,
                          style: TextStyle(
                            fontFamily: AppFonts.plusJakarta,
                            fontSize: r.fontSize(13),
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          widget.subtitle,
                          style: TextStyle(
                            fontFamily: AppFonts.plusJakarta,
                            fontSize: r.fontSize(11),
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ClientDetailsPage extends StatelessWidget {
  const ClientDetailsPage({super.key, required this.client});

  final ClientItem client;

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _formatDateTime(DateTime date) {
    return '${_formatDate(date)} à ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final r = _Responsive(context);
    final isSuspended = client.statusType == ClientStatus.suspended;
    final statusColor = isSuspended 
        ? const Color(0xFFF8B068)
        : client.statusType == ClientStatus.active
            ? const Color(0xFFA8C88A)
            : const Color(0xFFAAAAAA);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: appGradient,
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(r.hp(8), r.vp(12), r.hp(20), 0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: r.scale(20),
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: r.hp(12), vertical: r.vp(6)),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(r.scale(20)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Text(
                        client.status,
                        style: TextStyle(
                          fontFamily: AppFonts.plusJakarta,
                          fontSize: r.fontSize(12),
                          fontWeight: FontWeight.w700,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: r.hp(20)),
                  child: Column(
                    children: [
                      SizedBox(height: r.vp(20)),
                      
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(vertical: r.vp(24)),
                        child: Column(
                          children: [
                            Container(
                              width: r.scale(100),
                              height: r.scale(100),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [Color(0xFFCCD5AE), Color(0xFFA8C88A)],
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  client.initials,
                                  style: TextStyle(
                                    fontFamily: AppFonts.plusJakarta,
                                    fontSize: r.fontSize(36),
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: r.vp(16)),
                            Text(
                              client.name,
                              style: TextStyle(
                                fontFamily: AppFonts.plusJakarta,
                                fontSize: r.fontSize(22),
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF1A1A1A),
                              ),
                            ),
                            SizedBox(height: r.vp(6)),
                            Text(
                              client.email,
                              style: TextStyle(
                                fontFamily: AppFonts.plusJakarta,
                                fontSize: r.fontSize(14),
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      SizedBox(height: r.vp(8)),
                      
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: r.vp(16)),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(r.scale(20)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.04),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    '${client.reservations}',
                                    style: TextStyle(
                                      fontFamily: AppFonts.plusJakarta,
                                      fontSize: r.fontSize(28),
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFF1A1A1A),
                                    ),
                                  ),
                                  SizedBox(height: r.vp(4)),
                                  Text(
                                    'Réservations',
                                    style: AppTextStyles.statLabel.copyWith(fontSize: r.fontSize(11)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      SizedBox(height: r.vp(20)),
                      
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(r.scale(20)),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(r.scale(24)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: r.scale(32),
                                  height: r.scale(32),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFCCD5AE).withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(r.scale(10)),
                                  ),
                                  child: Icon(
                                    Icons.info_outline_rounded,
                                    size: r.scale(18),
                                    color: const Color(0xFF8B5E3C),
                                  ),
                                ),
                                SizedBox(width: r.hp(12)),
                                Text(
                                  'Informations',
                                  style: TextStyle(
                                    fontFamily: AppFonts.plusJakarta,
                                    fontSize: r.fontSize(16),
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF1A1A1A),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: r.vp(20)),
                            _DetailItem(
                              label: 'Date d\'inscription',
                              value: _formatDateTime(client.registeredDate),
                              r: r,
                            ),
                            Divider(color: const Color(0xFFE8DEC8), height: r.vp(24)),
                            _DetailItem(
                              label: 'Dernière connexion',
                              value: _formatDateTime(client.lastConnection),
                              r: r,
                            ),
                          ],
                        ),
                      ),
                      
                      SizedBox(height: r.vp(30)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailItem extends StatelessWidget {
  const _DetailItem({
    required this.label,
    required this.value,
    required this.r,
    this.valueColor,
  });

  final String label;
  final String value;
  final _Responsive r;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: AppFonts.plusJakarta,
            fontSize: r.fontSize(13),
            color: AppColors.textSecondary,
          ),
        ),
        Flexible(
          child: Text(
            value,
            style: TextStyle(
              fontFamily: AppFonts.plusJakarta,
              fontSize: r.fontSize(14),
              fontWeight: FontWeight.w600,
              color: valueColor ?? AppColors.textPrimary,
            ),
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}

class _Responsive {
  _Responsive(BuildContext context)
      : _size = MediaQuery.of(context).size,
        _textScale = MediaQuery.of(context).textScaler;

  final Size _size;
  final TextScaler _textScale;

  static const double _baseWidth = 390.0;
  static const double _baseHeight = 844.0;

  double get _widthRatio => (_size.width / _baseWidth).clamp(0.5, 1.4);
  double get _heightRatio => (_size.height / _baseHeight).clamp(0.5, 1.4);

  double scale(double value) => value * ((_widthRatio + _heightRatio) / 2);
  double hp(double value) => value * _widthRatio;
  double vp(double value) => value * _heightRatio;
  double fontSize(double value) => _textScale.scale(value * _widthRatio);
}