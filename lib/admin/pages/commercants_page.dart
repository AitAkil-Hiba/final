import 'package:flutter/material.dart';
import 'core/core.dart';
import 'account_verification_page.dart';
import 'merchant_profile_page.dart';
import '../services/admin_service.dart';
import '../models/merchant_model.dart';

class CommercantsPage extends StatefulWidget {
  const CommercantsPage({super.key, this.initialFilter});

  final String? initialFilter;

  @override
  State<CommercantsPage> createState() => _CommercantsPageState();
}

class _CommercantsPageState extends State<CommercantsPage> {
  String _selectedFilter = 'Tous';
  final List<String> _filters = ['Tous', 'Validés', 'En attente', 'Suspendus'];
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final AdminService _adminService = AdminService();
  bool _isLoading = true;
  String? _errorMessage;

  List<CommercantItem> _commercants = [];

  @override
  void initState() {
    super.initState();
    _loadMerchants();
    if (widget.initialFilter != null && _filters.contains(widget.initialFilter)) {
      _selectedFilter = widget.initialFilter!;
    }
  }

  Future<void> _loadMerchants() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final apiMerchants = await _adminService.getMerchants(statut: _selectedFilter);
      
      for (var api in apiMerchants) {
        final statusLabel = _getStatusLabel(api.statutValidation, api.actif);
        final statusType = _getStatusType(api.statutValidation, api.actif);
        print(' Merchant ${api.nomCommerce}:');
        print('   - Backend: statutValidation=${api.statutValidation}, actif=${api.actif}');
        print('   - Mapped: status=$statusLabel, statusType=$statusType');
      }
      
      final items = apiMerchants.map((api) => CommercantItem(
        id: api.id,
        name: api.nomCommerce,
        initials: _getInitials(api.nomCommerce),
        email: api.email,
        status: _getStatusLabel(api.statutValidation, api.actif),
        statusType: _getStatusType(api.statutValidation, api.actif),
        registeredDate: api.createdAt ?? DateTime.now(), 
        lastConnection: api.updatedAt,
      )).toList();
      
      if (mounted) {
        setState(() {
          _commercants = items;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
        _showErrorBanner('Erreur de chargement', e.toString());
      }
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

  String _getStatusLabel(String status, bool actif) {
    if (!actif) {
      return 'suspendu';
    }
    
    switch (status) {
      case 'VALIDE':
        return 'valide'; 
      case 'EN_ATTENTE':
        return 'en attente';
      case 'REJETE':
        return 'REJETE'; 
      default:
        return status;
    }
  }

  CommercantStatus _getStatusType(String status, bool actif) {
    if (!actif) {
      return CommercantStatus.suspended;
    }
    
    switch (status) {
      case 'VALIDE':
        return CommercantStatus.active; 
      case 'EN_ATTENTE':
        return CommercantStatus.pending; 
      case 'REJETE':
        return CommercantStatus.rejected; 
      default:
        return CommercantStatus.pending;
    }
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

  List<CommercantItem> get _filteredCommercants {
    List<CommercantItem> result = [..._commercants];

    print(' Filtering merchants - Total: ${result.length}, Filter: $_selectedFilter');

    final beforeRejected = result.length;
    result = result.where((c) => c.statusType != CommercantStatus.rejected).toList();
    print('   - After removing rejected: ${result.length} (removed ${beforeRejected - result.length})');

    switch (_selectedFilter) {
      case 'Validés':
        final beforeActive = result.length;
        result = result.where((c) => c.statusType == CommercantStatus.active).toList();
        print('   - After Validés filter: ${result.length} (removed ${beforeActive - result.length})');
        if (result.isNotEmpty) {
          print('   - Validés merchants: ${result.map((c) => '${c.name}(${c.status})').join(', ')}');
        }
        break;
      case 'En attente':
        final beforePending = result.length;
        result = result.where((c) => c.statusType == CommercantStatus.pending).toList();
        print('   - After En attente filter: ${result.length} (removed ${beforePending - result.length})');
        if (result.isNotEmpty) {
          print('   - En attente merchants: ${result.map((c) => '${c.name}(${c.status})').join(', ')}');
        }
        break;
      case 'Suspendus':
        final beforeSuspended = result.length;
        result = result.where((c) => c.statusType == CommercantStatus.suspended).toList();
        print('   - After Suspendus filter: ${result.length} (removed ${beforeSuspended - result.length})');
        if (result.isNotEmpty) {
          print('   - Suspendus merchants: ${result.map((c) => '${c.name}(${c.status})').join(', ')}');
        }
        break;
      case 'Tous':
        print('   - Showing all non-rejected merchants: ${result.length}');
        break;
    }

    if (_searchQuery.isNotEmpty) {
      final beforeSearch = result.length;
      result = result.where((c) =>
        c.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        c.email.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
      print('   - After search filter: ${result.length} (removed ${beforeSearch - result.length})');
    }

    print('   - Final result: ${result.length} merchants');
    return result;
  }

  void _showCommercantDetails(CommercantItem commercant) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MerchantProfilePage(merchant: commercant),
      ),
    );
  }

  void _verifyCommercant(CommercantItem commercant) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AccountVerificationPage(merchant: commercant),
      ),
    ).then((result) async {
      if (result == true) {
        print(' Merchant was approved, refreshing list...');
        setState(() => _isLoading = true);
        try {
          await _loadMerchants();
          _showSuccessBanner('Commerçant validé');
        } catch (e) {
          _showErrorBanner('Erreur', e.toString());
          setState(() => _isLoading = false);
        }
      } else if (result == false) {
        print(' Merchant was rejected, removing from local state...');
        setState(() {
          _commercants.removeWhere((m) => m.id == commercant.id);
          _showSuccessBanner('Commerçant rejeté et supprimé');
        });
      } else if (result is String) {
        print(' Merchant was rejected and deleted, removing from local state... ID: $result');
        setState(() {
          _commercants.removeWhere((m) => m.id == result);
          _showSuccessBanner('Commerçant rejeté et supprimé');
        });
      }
    });
  }

  void _suspendCommercant(CommercantItem commercant) async {
    final confirm = await _showSuspendConfirmation(commercant.name);
    if (confirm == true) {
      setState(() => _isLoading = true);
      try {
        print(' Suspending merchant: ${commercant.id}');
        await _adminService.suspendMerchant(commercant.id);
        print(' Suspend API call successful');
        
        setState(() {
          final index = _commercants.indexWhere((c) => c.id == commercant.id);
          if (index != -1) {
            _commercants[index] = _commercants[index].copyWith(
              status: 'SUSPENDU',
              statusType: CommercantStatus.suspended,
            );
          }
        });
        
        await _loadMerchants();
        _showSuccessBanner('Commerçant suspendu');
      } catch (e) {
        print(' Suspend error: $e');
        _showErrorBanner('Erreur', e.toString());
        setState(() => _isLoading = false);
      }
    }
  }

  void _reactivateCommercant(CommercantItem commercant) async {
    final confirm = await _showReactivateConfirmation(commercant.name);
    if (confirm == true) {
      setState(() => _isLoading = true);
      try {
        print(' Reactivating merchant: ${commercant.id}');
        await _adminService.reactivateMerchant(commercant.id);
        print(' Reactivate API call successful');
        
        setState(() {
          final index = _commercants.indexWhere((c) => c.id == commercant.id);
          if (index != -1) {
            _commercants[index] = _commercants[index].copyWith(
              status: 'ACTIF',
              statusType: CommercantStatus.active,
            );
          }
        });
        
        await _loadMerchants();
        _showSuccessBanner('Commerçant réactivé');
      } catch (e) {
        print(' Reactivate error: $e');
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
                'Suspendre le commerçant',
                style: AppTextStyles.listItemTitle.copyWith(fontSize: r.fontSize(18), fontWeight: FontWeight.w700),
              ),
              SizedBox(height: r.scale(16)),
              Text(
                'Êtes-vous sûr de vouloir suspendre ce commerçant ?',
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
                'Réactiver le commerçant',
                style: AppTextStyles.listItemTitle.copyWith(fontSize: r.fontSize(18), fontWeight: FontWeight.w700),
              ),
              SizedBox(height: r.scale(16)),
              Text(
                'Êtes-vous sûr de vouloir réactiver ce commerçant ?',
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
    final totalCount = _filteredCommercants.length;

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
                      icon: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: r.scale(20),
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(width: r.hp(8)),
                    Text('Commerçants', style: TextStyle(
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
                          Icon(Icons.storefront_outlined, size: r.scale(16)),
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
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                              _loadMerchants();
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
                    : _filteredCommercants.isEmpty
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
                                Icons.storefront_outlined,
                                size: r.scale(40),
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                            SizedBox(height: r.vp(10)),
                            Text(
                              'Aucun commerçant',
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
                        itemCount: _filteredCommercants.length,
                        separatorBuilder: (_, __) => SizedBox(height: r.vp(12)),
                        itemBuilder: (_, index) {
                          final commercant = _filteredCommercants[index];
                          final isActive = commercant.statusType == CommercantStatus.active;
                          final isPending = commercant.statusType == CommercantStatus.pending;
                          final isSuspended = commercant.statusType == CommercantStatus.suspended;

                          return _CommercantCard(
                            commercant: commercant,
                            onViewProfile: () => _showCommercantDetails(commercant),
                            onPrimaryAction: () {
                              if (isPending) {
                                _verifyCommercant(commercant);
                              } else if (isSuspended) {
                                _reactivateCommercant(commercant);
                              } else if (isActive) {
                                _suspendCommercant(commercant);
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

  double scale(double value) =>
      value * ((_widthRatio + _heightRatio) / 2);

  double hp(double value) => value * _widthRatio;

  double vp(double value) => value * _heightRatio;

  double fontSize(double value) =>
      _textScale.scale(value * _widthRatio);
}

enum CommercantStatus { active, pending, suspended, rejected }

class CommercantItem {
  final String id;
  final String name;
  final String initials;
  final String email;
  final String status;
  final CommercantStatus statusType;
  final DateTime registeredDate;
  final DateTime? lastConnection;

  CommercantItem({
    required this.id,
    required this.name,
    required this.initials,
    required this.email,
    required this.status,
    required this.statusType,
    required this.registeredDate,
    this.lastConnection,
  });

  CommercantItem copyWith({
    String? id,
    String? name,
    String? initials,
    String? email,
    String? status,
    CommercantStatus? statusType,
    DateTime? registeredDate,
    DateTime? lastConnection,
  }) {
    return CommercantItem(
      id: id ?? this.id,
      name: name ?? this.name,
      initials: initials ?? this.initials,
      email: email ?? this.email,
      status: status ?? this.status,
      statusType: statusType ?? this.statusType,
      registeredDate: registeredDate ?? this.registeredDate,
      lastConnection: lastConnection ?? this.lastConnection,
    );
  }
}

class _CommercantCard extends StatelessWidget {
  const _CommercantCard({
    required this.commercant,
    required this.onViewProfile,
    required this.onPrimaryAction,
  });

  final CommercantItem commercant;
  final VoidCallback onViewProfile;
  final VoidCallback onPrimaryAction;

  Color get _statusColor {
    switch (commercant.statusType) {
      case CommercantStatus.active:
        return const Color(0xFFA8C88A);
      case CommercantStatus.pending:
        return const Color(0xFFF8B068);
      case CommercantStatus.suspended:
        return const Color(0xFFAAAAAA);
      case CommercantStatus.rejected:
        return const Color(0xFFE07B39); 
    }
  }

  String get _actionLabel {
    switch (commercant.statusType) {
      case CommercantStatus.active:
        return 'Suspendre';
      case CommercantStatus.pending:
        return 'Vérifier';
      case CommercantStatus.suspended:
        return 'Réactiver';
      case CommercantStatus.rejected:
        return 'Rejeté'; 
    }
  }

  Color get _actionColor {
    switch (commercant.statusType) {
      case CommercantStatus.active:
        return const Color(0xFFF8B068);
      case CommercantStatus.pending:
        return const Color(0xFFA8C88A);
      case CommercantStatus.suspended:
        return const Color(0xFFA8C88A);
      case CommercantStatus.rejected:
        return const Color(0xFFCCCCCC); 
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
                    commercant.initials,
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
                      commercant.name,
                      style: AppTextStyles.listItemTitle.copyWith(
                        fontSize: r.fontSize(16),
                        fontWeight: FontWeight.w700,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: r.vp(2)),
                    Text(
                      commercant.email,
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
                  commercant.status,
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
                  if (commercant.statusType != CommercantStatus.pending) ...[
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
                  ],
                  TextButton(
                    onPressed: onPrimaryAction,
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