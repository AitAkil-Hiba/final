import 'package:flutter/material.dart';
import 'core/core.dart';
import 'notifications.dart';
import 'merchant_profile_page.dart';
import 'commercants_page.dart';
import '../services/admin_service.dart';
import '../models/signalement_model.dart';

class SignalementsPage extends StatefulWidget {
  const SignalementsPage({super.key});

  @override
  State<SignalementsPage> createState() => _SignalementsPageState();
}

class _SignalementsPageState extends State<SignalementsPage> {
  String _selectedFilter = 'Tous';
  final List<String> _filters = ['Tous', 'Commerçant', 'Annonce'];

  final ScrollController _scrollController = ScrollController();
  bool _showStatsCard = true;
  
  final AdminService _adminService = AdminService();
  bool _isLoading = true;
  String? _errorMessage;
  
  List<SignalementItem> _signalements = [];
  List<SignalementItemAPI> _apiSignalements = [];
  final Set<String> _suspendedMerchantIds = <String>{};

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadSignalements();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
  
  Future<void> _loadSignalements() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final response = await _adminService.getSignalements(statut: 'EN_ATTENTE', page: 0, size: 20);
      final apiSignalements = response.content;
      _apiSignalements = apiSignalements;
      
      print(' Loaded ${apiSignalements.length} signalements with EN_ATTENTE status');
      if (response.pagination != null) {
        final pagination = response.pagination!;
        print(' Pagination info: ${pagination.totalElements} total, page ${pagination.page}/${pagination.totalPages}');
      }
      
      for (var sig in apiSignalements) {
        print('   - ID: ${sig.id}, Statut: ${sig.statut}, Target: ${sig.targetType}');
      }
      
      final items = apiSignalements.map((api) => SignalementItem(
        id: api.id,
        title: api.offre?.titre ?? (api.commercant?['nomCommerce']?.toString() ?? api.user.fullName),
        subtitle: api.description,
        description: api.description,
        type: api.targetType,
        date: _formatDateTime(api.createdAt),
        status: _getStatusLabel(api.statut),
        targetId: api.merchantId ?? api.user.id,
        raison: api.raison,
      )).toList();
      
      setState(() {
        _signalements = items;
        _isLoading = false;
      });
    } catch (e) {
      print(' Error loading signalements: $e');
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
        _signalements = []; 
      });
      _showErrorBanner('Erreur de chargement', e.toString());
    }
  }
  
  String _formatDateTime(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    
    if (diff.inMinutes < 60) {
      return 'Il y a ${diff.inMinutes} min';
    } else if (diff.inHours < 24) {
      return 'Il y a ${diff.inHours}h';
    } else if (diff.inDays < 7) {
      return 'Il y a ${diff.inDays}j';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
  
  String _getStatusLabel(String statut) {
    switch (statut) {
      case 'EN_ATTENTE': return 'En attente';
      case 'TRAITE': return 'Traité';
      default: return statut;
    }
  }

  void _onScroll() {
    if (_scrollController.offset > 50 && _showStatsCard) {
      setState(() {
        _showStatsCard = false;
      });
    } else if (_scrollController.offset <= 50 && !_showStatsCard) {
      setState(() {
        _showStatsCard = true;
      });
    }
  }

  List<SignalementItem> get _filteredSignalements {
   
    List<SignalementItem> allSignalements = _signalements;
    
    if (_suspendedMerchantIds.isNotEmpty) {
      final beforeFilter = allSignalements.length;
      allSignalements = allSignalements.where((s) {
        try {
          final apiSig = _apiSignalements.firstWhere(
            (api) => api.id == s.id,
            orElse: () => _apiSignalements.isNotEmpty 
                ? _apiSignalements.first 
                : SignalementItemAPI(
                    id: '',
                    raison: '',
                    description: '',
                    statut: '',
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                    user: SignalementUser(id: '', fullName: '', email: ''),
                  ),
          );
          
          if (apiSig.targetType == 'Commerçant' && apiSig.commercant != null) {
            final merchantId = apiSig.commercant?['id']?.toString();
            return !_suspendedMerchantIds.contains(merchantId);
          }
          return true;
        } catch (e) {
          print(' Error filtering signalement: $e');
          return true;
        }
      }).toList();
      
      print(' Filtered out ${beforeFilter - allSignalements.length} signalements for suspended merchants');
    }
    
    if (_selectedFilter == 'Tous') {
      return allSignalements;
    }
    return allSignalements.where((s) => s.type == _selectedFilter).toList();
  }

  void _showDetailsDialog(BuildContext context, SignalementItem item) {
    final apiSignalement = _apiSignalements.firstWhere(
      (api) => api.id == item.id,
      orElse: () => SignalementItemAPI(
        id: item.id,
        raison: item.raison ?? '',
        description: item.description,
        statut: item.status == 'En attente' ? 'EN_ATTENTE' : 'TRAITE',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        user: SignalementUser(id: item.targetId, fullName: item.title, email: ''),
      ),
    );
    
    final r = _Responsive(context);
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(r.scale(28))),
        child: Container(
          padding: EdgeInsets.all(r.scale(24)),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(r.scale(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Détails du signalement',
                    style: AppTextStyles.pageTitle
                        .copyWith(fontSize: r.fontSize(20)),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close_rounded, size: r.scale(20)),
                  ),
                ],
              ),
              SizedBox(height: r.scale(16)),
              _DetailRow(label: 'Type', value: apiSignalement.targetType),
              if (apiSignalement.offre != null) ...[
                _DetailRow(label: 'Offre signalée', value: apiSignalement.offre!.titre),
              ],
              if (apiSignalement.commercant != null) ...[
                _DetailRow(label: 'Commerçant signalé', value: apiSignalement.commercant?['nomCommerce']?.toString() ?? 'N/A'),
              ],
              _DetailRow(label: 'Signalé par', value: apiSignalement.user.fullName),
              _DetailRow(label: 'Raison', value: _getRaisonLabel(apiSignalement.raison)),
              SizedBox(height: r.scale(12)),
              const Divider(),
              SizedBox(height: r.scale(12)),
              Text(
                'Description',
                style: AppTextStyles.statLabel
                    .copyWith(fontSize: r.fontSize(12)),
              ),
              SizedBox(height: r.scale(4)),
              Text(
                apiSignalement.description,
                style: AppTextStyles.bodyMedium
                    .copyWith(fontSize: r.fontSize(14)),
              ),
              SizedBox(height: r.scale(12)),
              Text(
                'Date',
                style: AppTextStyles.statLabel
                    .copyWith(fontSize: r.fontSize(12)),
              ),
              SizedBox(height: r.scale(4)),
              Text(
                _formatDateTime(apiSignalement.createdAt),
                style: AppTextStyles.bodyMedium
                    .copyWith(fontSize: r.fontSize(14)),
              ),
              SizedBox(height: r.scale(16)),
              if (item.type == 'Commerçant' || item.type == 'Annonce') ...[
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _navigateToMerchantProfile(item);
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: r.vp(12)),
                      backgroundColor: const Color(0xFFCCD5AE).withOpacity(0.15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(r.scale(30)),
                      ),
                    ),
                    child: Text(
                      'Voir profil commerçant',
                      style: TextStyle(
                        fontFamily: AppFonts.plusJakarta,
                        fontSize: r.fontSize(14),
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF8B5E3C),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _getRaisonLabel(String? raison) {
    switch (raison) {
      case 'ARNAQUE':
        return 'Arnaque';
      case 'PRODUIT_NON_CONFORME':
        return 'Produit non conforme';
      case 'COMPORTEMENT':
        return 'Comportement';
      case 'FAUX_AVIS':
        return 'Faux avis';
      default:
        return 'Autre';
    }
  }

  String _getWarningTitle() {
    return 'AVERTISSEMENT - SIGNALEMENT';
  }

  String _getWarningMessage(SignalementItem item) {
    String reasonText = '';
    switch (item.raison) {
      case 'ARNAQUE':
        reasonText = 'Arnaque signalée';
        break;
      case 'PRODUIT_NON_CONFORME':
        reasonText = 'Produit non conforme à la description';
        break;
      case 'COMPORTEMENT':
        reasonText = 'Comportement inapproprié signalé';
        break;
      case 'FAUX_AVIS':
        reasonText = 'Faux avis signalé';
        break;
      default:
        reasonText = 'Signalement reçu';
    }
    
    String warningMessage = 'Bonjour ${item.title},\n\n';
    warningMessage += 'Nous avons reçu un signalement concernant votre compte. ';
    warningMessage += 'Raison: $reasonText.\n\n';
    warningMessage += 'Détail du signalement: "${item.description}"\n\n';
    warningMessage += 'Nous vous invitons à régulariser votre situation dans les plus brefs délais. ';
    warningMessage += 'Un non-respect des règles pourrait entraîner la suspension de votre compte.\n\n';
    warningMessage += 'Cordialement,\nL\'équipe de modération.';
    
    return warningMessage;
  }

  void _showSuccessBanner(String message, String subtitle) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (ctx) => _SuccessBanner(
        message: message,
        subtitle: subtitle,
        onDone: () => entry.remove(),
      ),
    );
    overlay.insert(entry);
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

  Future<bool?> _showDeleteNotificationConfirmation(String title) {
    final r = _Responsive(context);
    return showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(r.scale(28))),
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
                'Supprimer le signalement',
                style: AppTextStyles.listItemTitle.copyWith(
                    fontSize: r.fontSize(18), fontWeight: FontWeight.w700),
              ),
              SizedBox(height: r.scale(16)),
              Text(
                'Êtes-vous sûr de vouloir supprimer ce signalement ?',
                style: AppTextStyles.bodyMedium
                    .copyWith(fontSize: r.fontSize(14)),
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
                  '"$title"',
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
                'Cette action ne fait que supprimer le signalement, elle ne supprime pas le contenu signalé.',
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
                        padding: EdgeInsets.symmetric(
                            vertical: r.scale(12)),
                        backgroundColor: const Color(0xFFE8E8E8),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(r.scale(30)),
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
                        padding: EdgeInsets.symmetric(
                            vertical: r.scale(12)),
                        backgroundColor: Colors.red.withOpacity(0.1),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(r.scale(30)),
                        ),
                      ),
                      child: Text(
                        'Supprimer',
                        style: TextStyle(
                          fontFamily: AppFonts.plusJakarta,
                          fontSize: r.fontSize(14),
                          fontWeight: FontWeight.w600,
                          color: Colors.red,
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

  Future<bool?> _showSuspendConfirmation(String name) {
    final r = _Responsive(context);
    return showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(r.scale(28))),
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
                style: AppTextStyles.listItemTitle.copyWith(
                    fontSize: r.fontSize(18), fontWeight: FontWeight.w700),
              ),
              SizedBox(height: r.scale(16)),
              Text(
                'Êtes-vous sûr de vouloir suspendre ce commerçant ?',
                style: AppTextStyles.bodyMedium
                    .copyWith(fontSize: r.fontSize(14)),
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
                'Cette action est réversible. Le commerçant ne pourra plus publier d\'offres jusqu\'à ce que vous réactiviez son compte.',
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
                        padding: EdgeInsets.symmetric(
                            vertical: r.scale(12)),
                        backgroundColor: const Color(0xFFE8E8E8),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(r.scale(30)),
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
                        padding: EdgeInsets.symmetric(
                            vertical: r.scale(12)),
                        backgroundColor:
                            const Color(0xFFE07B39).withOpacity(0.1),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(r.scale(30)),
                        ),
                      ),
                      child: Text(
                        'Suspendre',
                        style: TextStyle(
                          fontFamily: AppFonts.plusJakarta,
                          fontSize: r.fontSize(14),
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFE07B39),
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

  Future<bool?> _showDeleteAnnonceConfirmation(String title) {
    final r = _Responsive(context);
    return showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(r.scale(28))),
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
                'Supprimer l\'annonce',
                style: AppTextStyles.listItemTitle.copyWith(
                    fontSize: r.fontSize(18), fontWeight: FontWeight.w700),
              ),
              SizedBox(height: r.scale(16)),
              Text(
                'Êtes-vous sûr de vouloir supprimer cette annonce ?',
                style: AppTextStyles.bodyMedium
                    .copyWith(fontSize: r.fontSize(14)),
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
                  '"$title"',
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
                'Cette action est irréversible. L\'annonce sera définitivement supprimée de la plateforme.',
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
                        padding: EdgeInsets.symmetric(
                            vertical: r.scale(12)),
                        backgroundColor: const Color(0xFFE8E8E8),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(r.scale(30)),
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
                        padding: EdgeInsets.symmetric(
                            vertical: r.scale(12)),
                        backgroundColor:
                            const Color(0xFFE07B39).withOpacity(0.1),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(r.scale(30)),
                        ),
                      ),
                      child: Text(
                        'Supprimer',
                        style: TextStyle(
                          fontFamily: AppFonts.plusJakarta,
                          fontSize: r.fontSize(14),
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFE07B39),
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

  void _deleteSignalement(String id, String title) async {
    final confirm = await _showDeleteNotificationConfirmation(title);
    if (confirm == true) {
      setState(() => _isLoading = true);
      try {
        await _adminService.deleteSignalement(id);
        await _loadSignalements();
        _showSuccessBanner('Signalement supprimé', 'Le signalement a été supprimé');
      } catch (e) {
        _showErrorBanner('Erreur', e.toString());
        setState(() => _isLoading = false);
      }
    }
  }

  void _suspendCommercant(String merchantId, String name, String signalementId) async {
    final confirm = await _showSuspendConfirmation(name);
    if (confirm == true) {
      setState(() => _isLoading = true);
      try {
        print(' Suspending merchant: $merchantId');
        await _adminService.suspendMerchant(merchantId);
        print(' Merchant suspended');
        
        setState(() {
          _suspendedMerchantIds.add(merchantId);
        });
        print(' Added merchant $merchantId to suspended list');
        
        print(' Treating signalement: $signalementId');
        await _adminService.treatSignalement(signalementId);
        print(' Signalement treated');
        
        await Future.delayed(Duration(milliseconds: 500));
        
        print(' Refreshing signalements list...');
        await _loadSignalements();
        _showSuccessBanner('Commerçant suspendu', '$name a été suspendu');
      } catch (e) {
        _showErrorBanner('Erreur', e.toString());
        setState(() => _isLoading = false);
      }
    }
  }

  void _deleteAnnonce(String id, String title) async {
    final confirm = await _showDeleteAnnonceConfirmation(title);
    if (confirm == true) {
      setState(() => _isLoading = true);
      try {
        print(' Deleting signalement with offer: $id');
        final response = await _adminService.deleteSignalementWithOffer(id);
        print(' Signalement and offer deleted');
        
        final data = response['data'] as Map<String, dynamic>;
        final reservationsAnnulees = data['reservationsAnnulees'] as int? ?? 0;
        final offreSupprimee = data['offreSupprimee'] as bool? ?? false;
        
        await _loadSignalements();
        
        String subtitle = '$title a été supprimée';
        if (offreSupprimee && reservationsAnnulees > 0) {
          subtitle += ' ($reservationsAnnulees réservation${reservationsAnnulees > 1 ? 's' : ''} annulée${reservationsAnnulees > 1 ? 's' : ''})';
        }
        
        _showSuccessBanner('Annonce supprimée', subtitle);
      } catch (e) {
        _showErrorBanner('Erreur', e.toString());
        setState(() => _isLoading = false);
      }
    }
  }

  SignalementItemAPI? _getApiSignalementById(String signalementId) {
    for (final sig in _apiSignalements) {
      if (sig.id == signalementId) return sig;
    }
    return null;
  }

  String _resolveMerchantIdForItem(SignalementItem item) {
    final apiSignalement = _getApiSignalementById(item.id);
    return apiSignalement?.merchantId ??
        item.targetId;
  }

  String _resolveMerchantNameForItem(SignalementItem item) {
    final apiSignalement = _getApiSignalementById(item.id);
    return apiSignalement?.merchantName ??
        item.title;
  }

  void _navigateToNotificationsWithMerchant(SignalementItem item) {
    final merchantId = _resolveMerchantIdForItem(item);
    final merchantName = _resolveMerchantNameForItem(item);
    final merchantData = {
      'id': merchantId,
      'name': merchantName,
      'initials': merchantName.substring(0, 2).toUpperCase(),
      'status': 'Validé',
    };
    
    final warningTitle = _getWarningTitle();
    final warningMessage = _getWarningMessage(item);
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NotificationsPage(
          preselectedMerchant: merchantData,
          preselectedTitle: warningTitle,
          preselectedMessage: warningMessage,
        ),
      ),
    );
  }

  void _navigateToMerchantProfile(SignalementItem item) {
    final merchantId = _resolveMerchantIdForItem(item);
    final merchantName = _resolveMerchantNameForItem(item);
    final merchant = CommercantItem(
      id: merchantId,
      name: merchantName,
      initials: merchantName.substring(0, 2).toUpperCase(),
      email: '${merchantName.toLowerCase().replaceAll(' ', '.')}@example.com',
      status: 'ACTIF',
      statusType: CommercantStatus.active,
      registeredDate: DateTime.now().subtract(const Duration(days: 30)),
      lastConnection: DateTime.now().subtract(const Duration(hours: 2)),
    );
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MerchantProfilePage(merchant: merchant),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final r = _Responsive(context);
    final totalCount = _signalements.length;
    final todayCount =
        _signalements.where((s) => s.date.contains('h')).length;

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
                padding: EdgeInsets.fromLTRB(
                    r.hp(20), r.vp(20), r.hp(20), r.vp(4)),
                child: Text(
                  'Signalements',
                  style: AppTextStyles.pageTitle
                      .copyWith(fontSize: r.fontSize(28)),
                ),
              ),

              SizedBox(height: r.vp(8)),

              AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: _showStatsCard ? 1.0 : 0.0,
                child: AnimatedSize(
                  duration: const Duration(milliseconds: 200),
                  child: _showStatsCard
                      ? Padding(
                          padding: EdgeInsets.symmetric(horizontal: r.hp(20)),
                          child: Container(
                            padding: EdgeInsets.all(r.scale(20)),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(r.scale(24)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Flexible(
                                  flex: 2,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '$totalCount',
                                        style: TextStyle(
                                          fontFamily: AppFonts.plusJakarta,
                                          fontSize: r.fontSize(42),
                                          fontWeight: FontWeight.w800,
                                          color: const Color.fromARGB(255, 60, 60, 60),
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(height: r.vp(4)),
                                      Text(
                                        'SIGNALEMENTS',
                                        style: AppTextStyles.statLabel.copyWith(
                                          fontSize: r.fontSize(11),
                                          letterSpacing: 1,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: r.hp(12)),
                                
                                Flexible(
                                  flex: 1,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: r.hp(10), vertical: r.vp(6)),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFCCD5AE),
                                      borderRadius: BorderRadius.circular(r.scale(20)),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.arrow_upward_rounded,
                                          size: r.scale(14),
                                          color: Colors.black,
                                        ),
                                        SizedBox(width: r.hp(4)),
                                        Flexible(
                                          child: Text(
                                            '+$todayCount aujourd\'hui',
                                            style: AppTextStyles.statDelta.copyWith(
                                              color: Colors.black,
                                              fontSize: r.fontSize(12),
                                              fontWeight: FontWeight.w600,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                            softWrap: false,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
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
                              padding: EdgeInsets.symmetric(
                                  horizontal: r.hp(16),
                                  vertical: r.vp(8)),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFFCCD5AE)
                                    : const Color(0xFFFAEDCD),
                                borderRadius:
                                    BorderRadius.circular(r.scale(30)),
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
                    : _filteredSignalements.isEmpty
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
                                Icons.shield_outlined,
                                size: r.scale(40),
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: r.vp(10)),
                            Text(
                              'Aucun signalement',
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
                        padding: EdgeInsets.fromLTRB(
                            r.hp(20), 0, r.hp(20), r.vp(100)),
                        itemCount: _filteredSignalements.length,
                        separatorBuilder: (_, __) =>
                            SizedBox(height: r.vp(12)),
                        itemBuilder: (_, index) {
                          final item = _filteredSignalements[index];
                          final isAnnonce = item.type == 'Annonce';
                          return _SignalementCard(
                            item: item,
                            isAnnonce: isAnnonce,
                            onView: () =>
                                _showDetailsDialog(context, item),
                            onAction: () {
                              if (isAnnonce) {
                                _deleteAnnonce(item.id, item.title);
                              } else {
                                _suspendCommercant(
                                  _resolveMerchantIdForItem(item),
                                  _resolveMerchantNameForItem(item),
                                  item.id,
                                );
                              }
                            },
                            onDelete: () =>
                                _deleteSignalement(item.id, item.title),
                            onCardTap: () => _navigateToNotificationsWithMerchant(item),
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

class SignalementItem {
  final String id;
  final String title;
  final String subtitle;
  final String description;
  final String type;
  final String date;
  final String status;
  final String targetId;
  final String? raison;
  bool isRead; 

  SignalementItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.type,
    required this.date,
    required this.status,
    required this.targetId,
    this.raison,
    this.isRead = false, 
  });
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final r = _Responsive(context);
    return Padding(
      padding: EdgeInsets.only(bottom: r.vp(8)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: r.hp(100),
            child: Text(
              label,
              style:
                  AppTextStyles.statLabel.copyWith(fontSize: r.fontSize(12)),
            ),
          ),
          SizedBox(width: r.hp(8)),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodyMedium
                  .copyWith(fontSize: r.fontSize(14)),
            ),
          ),
        ],
      ),
    );
  }
}

class _SignalementCard extends StatelessWidget {
  const _SignalementCard({
    required this.item,
    required this.isAnnonce,
    required this.onView,
    required this.onAction,
    required this.onDelete,
    required this.onCardTap,
  });

  final SignalementItem item;
  final bool isAnnonce;
  final VoidCallback onView;
  final VoidCallback onAction;
  final VoidCallback onDelete;
  final VoidCallback onCardTap;

  String _getRaisonLabel(String? raison) {
    switch (raison) {
      case 'ARNAQUE':
        return 'Arnaque';
      case 'CONTENU_INAPPROPRIE':
        return 'Contenu inapproprié';
      case 'SPAM':
        return 'Spam';
      case 'HARCELEMENT':
        return 'Harcèlement';
      case 'FAUSSE_INFORMATION':
        return 'Fausse information';
      case 'VIOLATION_DROITS':
        return 'Violation des droits';
      case 'AUTRE':
        return 'Autre';
      default:
        return raison ?? 'Non spécifié';
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = _Responsive(context);

    final Color badgeColor =
        isAnnonce ? const Color(0xFFF8B068) : const Color(0xFFA8C88A);

    return GestureDetector(
      onTap: onCardTap,
      child: Container(
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    item.date,
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: r.fontSize(12),
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Flexible(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: r.hp(10), vertical: r.vp(4)),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(r.scale(12)),
                    ),
                    child: Text(
                      item.type.toUpperCase(),
                      style: AppTextStyles.statDelta.copyWith(
                        color: badgeColor,
                        fontSize: r.fontSize(11),
                        fontWeight: FontWeight.w700,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: r.vp(12)),
            Text(
              item.title,
              style: AppTextStyles.listItemTitle.copyWith(
                fontSize: r.fontSize(16),
                fontWeight: FontWeight.w700,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: r.vp(6)),
            Container(
              padding: EdgeInsets.symmetric(horizontal: r.hp(12), vertical: r.vp(6)),
              decoration: BoxDecoration(
                color: const Color(0xFFF8B068).withOpacity(0.1),
                borderRadius: BorderRadius.circular(r.scale(20)),
              ),
              child: Text(
                _getRaisonLabel(item.raison),
                style: AppTextStyles.bodySmall.copyWith(
                  fontSize: r.fontSize(12),
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFF8B068),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(height: r.vp(8)),
            Row(
              children: [
                Icon(Icons.format_quote,
                    size: r.scale(14), color: AppColors.textMuted),
                SizedBox(width: r.hp(4)),
                Expanded(
                  child: Text(
                    item.description,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: r.fontSize(13),
                      fontStyle: FontStyle.italic,
                      color: AppColors.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
              ],
            ),
            SizedBox(height: r.vp(12)),
            Align(
              alignment: Alignment.centerRight,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton(
                      onPressed: onView,
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                            horizontal: r.hp(16), vertical: r.vp(8)),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        backgroundColor:
                            const Color(0xFFA8C88A).withOpacity(0.1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(r.scale(30)),
                        ),
                      ),
                      child: Text(
                        'Voir',
                        style: TextStyle(
                          fontFamily: AppFonts.plusJakarta,
                          fontSize: r.fontSize(13),
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFA8C88A),
                        ),
                      ),
                    ),
                    SizedBox(width: r.hp(8)),
                    TextButton(
                      onPressed: onAction,
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                            horizontal: r.hp(16), vertical: r.vp(8)),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        backgroundColor:
                            const Color(0xFFE07B39).withOpacity(0.1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(r.scale(30)),
                        ),
                      ),
                      child: Text(
                        isAnnonce ? 'Supprimer' : 'Suspendre',
                        style: TextStyle(
                          fontFamily: AppFonts.plusJakarta,
                          fontSize: r.fontSize(13),
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFE07B39),
                        ),
                      ),
                    ),
                    SizedBox(width: r.hp(8)),
                    TextButton(
                      onPressed: onDelete,
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                            horizontal: r.hp(12), vertical: r.vp(8)),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        backgroundColor: Colors.red.withOpacity(0.1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(r.scale(30)),
                        ),
                      ),
                      child: Icon(
                        Icons.close_rounded,
                        size: r.scale(16),
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SuccessBanner extends StatefulWidget {
  const _SuccessBanner({
    required this.message,
    required this.subtitle,
    required this.onDone,
  });
  final String message;
  final String subtitle;
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
              padding: EdgeInsets.symmetric(
                  horizontal: r.hp(18), vertical: r.vp(14)),
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
                            color: Colors.black54,
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
              padding: EdgeInsets.symmetric(
                  horizontal: r.hp(18), vertical: r.vp(14)),
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