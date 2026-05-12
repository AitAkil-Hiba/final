import 'package:flutter/material.dart';

import 'core/core.dart';

import '../services/admin_service.dart';

import '../models/client_model.dart';

import '../models/merchant_model.dart';



class NotificationsPage extends StatefulWidget {

  final Map<String, dynamic>? preselectedMerchant;

  final String? preselectedTitle;

  final String? preselectedMessage;

  final String? preselectedRecipient;

  

  const NotificationsPage({

    super.key, 

    this.preselectedMerchant, 

    this.preselectedTitle,

    this.preselectedMessage,

    this.preselectedRecipient,

  });



  @override

  State<NotificationsPage> createState() => _NotificationsPageState();

}



class _NotificationsPageState extends State<NotificationsPage> {

  int _selectedTab = 0;



  String _selectedAudience = 'all';

  List<String>? _selectedMerchantIds;

  List<String>? _selectedClientIds;



  final TextEditingController _titleController = TextEditingController();

  final TextEditingController _messageController = TextEditingController();

  final ScrollController _scrollController = ScrollController();



  final FocusNode _titleFocus = FocusNode();

  final FocusNode _messageFocus = FocusNode();



  bool _titleError = false;

  bool _messageError = false;



  String _historyFilter = 'all';




  List<MerchantAPI> _allMerchants = [];

  bool _isLoadingMerchants = false;

  String? _merchantsError;




  final AdminService _adminService = AdminService();

  List<ClientAPI> _allClients = [];

  bool _isLoadingClients = false;

  String? _clientsError;



  List<Map<String, dynamic>> _sentNotifications = [];
  
  bool _isLoadingHistory = false;
  String? _historyError;



  String _getInitials(String name) {

    if (name.isEmpty) return '';

    final parts = name.split(' ');

    if (parts.length >= 2) {

      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();

    }

    return name.substring(0, name.length > 2 ? 2 : name.length).toUpperCase();

  }



  Future<void> _loadMerchants() async {

    setState(() {

      _isLoadingMerchants = true;

      _merchantsError = null;

    });



    try {

      print(' Loading merchants...');

      final merchants = await _adminService.getMerchants(); 

      print(' Successfully loaded ${merchants.length} merchants');

      

      setState(() {

        _allMerchants = merchants;

        _isLoadingMerchants = false;

      });

    } catch (e) {

      print(' Error loading merchants: $e');


      setState(() {

        _allMerchants = [];

        _merchantsError = e.toString();

        _isLoadingMerchants = false;

      });

    }

  }



  Future<void> _loadClients() async {

    setState(() {

      _isLoadingClients = true;

      _clientsError = null;

    });



    try {

      print(' Loading clients...');

      final clients = await _adminService.getClients(statut: 'Actif');

      print(' Successfully loaded ${clients.length} clients');

      
      final activeClients = clients.where((client) => client.actif == true).toList();

      print(' Filtered to ${activeClients.length} active clients');

      

      setState(() {

        _allClients = activeClients;

        _isLoadingClients = false;

      });

    } catch (e) {

      print(' Error loading clients: $e');


      setState(() {

        _allClients = [];

        _clientsError = e.toString();

        _isLoadingClients = false;

      });

    }

  }



  Future<void> _loadNotificationHistory() async {

    setState(() {

      _isLoadingHistory = true;

      _historyError = null;

    });



    try {

      print(' Loading notification history...');

      final result = await _adminService.getNotificationHistory(

        destinataire: null,

      );





  print(' Successfully loaded ${result['notifications']?.length ?? 0} notifications');

    

    final notifications = result['notifications'] as List<dynamic>? ?? [];
    
    final allNotificationGroups = <String, List<Map<String, dynamic>>>{}; 
    final processedNotifications = <Map<String, dynamic>>[];
    
    for (final notif in notifications) {
      final notification = notif as Map<String, dynamic>;
      final title = notification['titre'] as String? ?? '';
      final createdAt = notification['createdAt'] as String? ?? '';
      final key = '${title}_${createdAt}';
      
      if (!allNotificationGroups.containsKey(key)) {
        allNotificationGroups[key] = [];
      }
      allNotificationGroups[key]!.add(notification);
    }
    
    for (final group in allNotificationGroups.values) {
      if (group.length > 1) {
        final firstNotif = group.first;
        processedNotifications.add({
          'id': firstNotif['id'],
          'title': firstNotif['titre'] ?? firstNotif['contenu'] ?? '',
          'message': firstNotif['contenu'] ?? '',
          'audience': 'Tous',
          'date': DateTime.tryParse(firstNotif['createdAt'] ?? '') ?? DateTime.now(),
          'type': 'ALL',
          'categorie': firstNotif['categorie'],
          'lue': firstNotif['lue'] ?? false,
          'pushActive': firstNotif['pushActive'] ?? true,
          'referenceId': firstNotif['referenceId'],
          'isAllNotification': true,
        });
      } else {
        final notification = group.first;
        final audience = _mapTypeToAudience(notification['type']);
        processedNotifications.add({
          'id': notification['id'],
          'title': notification['titre'] ?? notification['contenu'] ?? '',
          'message': notification['contenu'] ?? '',
          'audience': audience,
          'date': DateTime.tryParse(notification['createdAt'] ?? '') ?? DateTime.now(),
          'type': notification['type'],
          'categorie': notification['categorie'],
          'lue': notification['lue'] ?? false,
          'pushActive': notification['pushActive'] ?? true,
          'referenceId': notification['referenceId'],
          'isAllNotification': false,
        });
      }
    }
    
    final mappedNotifications = processedNotifications;
    
    final deduplicatedNotifications = <Map<String, dynamic>>[];
    final seenKeys = Set<String>();
    
    for (final notif in mappedNotifications) {
      final title = notif['title'] as String;
      final date = notif['date'] as DateTime;
      final type = notif['type'] as String?;
      final isAll = notif['isAllNotification'] as bool;
      
      final key = '${title}_${date.millisecondsSinceEpoch}_${isAll ? 'ALL' : (type ?? '')}';
      
      if (!seenKeys.contains(key)) {
        seenKeys.add(key);
        deduplicatedNotifications.add(notif);
      }
    }

    setState(() {
      _sentNotifications = deduplicatedNotifications;
      _isLoadingHistory = false;
    });

  } catch (e) {
    print(' Error loading notification history: $e');
    setState(() {
      _sentNotifications = [];
      _historyError = e.toString();
      _isLoadingHistory = false;
    });
  }
}

  String _mapTypeToAudience(String? type) {
    if (type == null) return 'Tous';

    
    switch (type) {

      case 'ADMIN_CLIENT':

        return 'Clients';

      case 'ADMIN_AVERTISSEMENT':

      case 'ADMIN_DECLARATION':

        return 'Commerçants';

      default:

        return 'Tous';

    }

  }



  @override

  void initState() {

    super.initState();

    _loadMerchants();

    _loadClients();

    _loadNotificationHistory(); 

    _titleFocus.addListener(() {

      if (_titleFocus.hasFocus) _scrollTo(180);

    });

    _messageFocus.addListener(() {

      if (_messageFocus.hasFocus) _scrollTo(340);

    });

    

    WidgetsBinding.instance.addPostFrameCallback((_) {

      if (widget.preselectedTitle != null && widget.preselectedTitle!.isNotEmpty) {

        _titleController.text = widget.preselectedTitle!;

      }

      

      if (widget.preselectedMessage != null && widget.preselectedMessage!.isNotEmpty) {

        _messageController.text = widget.preselectedMessage!;

      }

      

      

      if (widget.preselectedMerchant != null) {

        final merchant = widget.preselectedMerchant!;

        final merchantId = merchant['id'] as String;

        


        _determineUserTypeAndSetSelection(merchantId, merchant);

      }

    });

  }



  Future<void> _determineUserTypeAndSetSelection(String merchantId, Map<String, dynamic> merchant) async {
  final existingMerchant = _allMerchants.cast<MerchantAPI?>().firstWhere(
    (m) => m?.id == merchantId,
    orElse: () => null,
  );
  
  if (existingMerchant != null) {
    setState(() {
      _selectedAudience = 'merchants';
      _selectedMerchantIds = [merchantId];
    });
    return;
  }
  
  final existingClient = _allClients.cast<ClientAPI?>().firstWhere(
    (c) => c?.id == merchantId,
    orElse: () => null,
  );
  
  if (existingClient != null) {
    setState(() {
      _selectedAudience = 'clients';
      _selectedClientIds = [merchantId];
    });
    return;
  }
  
  if (_isLoadingMerchants || _isLoadingClients) {
    await Future.delayed(Duration(milliseconds: 500));
    await _determineUserTypeAndSetSelection(merchantId, merchant);
    return;
  }
  
 
  print(' User with ID $merchantId not found in merchants or clients lists');
}



  void _scrollTo(double offset) {

    Future.delayed(const Duration(milliseconds: 300), () {

      if (_scrollController.hasClients) {

        _scrollController.animateTo(

          offset,

          duration: const Duration(milliseconds: 300),

          curve: Curves.easeOut,

        );

      }

    });

  }



  @override

  void dispose() {

    _titleController.dispose();

    _messageController.dispose();

    _scrollController.dispose();

    _titleFocus.dispose();

    _messageFocus.dispose();

    super.dispose();

  }



  List<Map<String, dynamic>> get _filteredHistory {

    if (_historyFilter == 'all') {


      return _sentNotifications;

    } else if (_historyFilter == 'merchants') {


      return _sentNotifications.where((n) => n['audience'] == 'Commerçants').toList();

    } else if (_historyFilter == 'clients') {


      return _sentNotifications.where((n) => n['audience'] == 'Clients').toList();

    }


    return _sentNotifications;

  }

  bool _isAllNotification(Map<String, dynamic> notification, List<dynamic> allNotifications) {

    final title = notification['titre'] as String?;

    final createdAt = notification['createdAt'] as String?;

    if (title == null || createdAt == null) return false;


    final clientNotifications = allNotifications.where((n) => 

      n['type'] == 'ADMIN_CLIENT' && 

      n['titre'] == title && 

      n['createdAt'] == createdAt

    ).toList();

    final merchantNotifications = allNotifications.where((n) => 

      n['type'] == 'ADMIN_AVERTISSEMENT' && 

      n['titre'] == title && 

      n['createdAt'] == createdAt

    ).toList();

    return clientNotifications.isNotEmpty && merchantNotifications.isNotEmpty;

  }

  


  void _onHistoryFilterChanged(String filter) {

    setState(() {

      _historyFilter = filter;

    });

    _loadNotificationHistory();

  }



  String _audienceSummary() {

    if (_selectedAudience == 'all') return 'Tous les utilisateurs';

    if (_selectedAudience == 'merchants') {

      if (_selectedMerchantIds == null) return 'Tous les commerçants';

      return '${_selectedMerchantIds!.length} commerçant(s) sélectionné(s)';

    }

    if (_selectedClientIds == null) return 'Tous les clients';

    return '${_selectedClientIds!.length} client(s) sélectionné(s)';

  }



  void _onAudienceTap(String value) {

    if (value == 'all') {

      setState(() => _selectedAudience = 'all');

      return;

    }

    _showAudienceChoiceModal(value);

  }



  void _showAudienceChoiceModal(String audienceType) {

    final r = _Responsive(context);

    final label = audienceType == 'merchants' ? 'Commerçants' : 'Clients';

    showModalBottomSheet(

      context: context,

      backgroundColor: Colors.transparent,

      isScrollControlled: true,

      builder: (ctx) => Container(

        decoration: const BoxDecoration(

          color: Colors.white,

          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),

        ),

        padding: EdgeInsets.fromLTRB(r.hp(24), r.vp(20), r.hp(24), r.vp(36)),

        child: Column(

          mainAxisSize: MainAxisSize.min,

          children: [

            _sheetHandle(),

            SizedBox(height: r.vp(24)),

            Text(

              'Destinataires — $label',

              style: TextStyle(

                fontFamily: AppFonts.plusJakarta,

                fontSize: r.fontSize(17),

                fontWeight: FontWeight.w700,

                color: Colors.black,

              ),

            ),

            SizedBox(height: r.vp(8)),

            Text(

              'Comment souhaitez-vous envoyer cette notification ?',

              style: TextStyle(

                fontFamily: AppFonts.plusJakarta,

                fontSize: r.fontSize(13),

                color: AppColors.textSecondary,

              ),

              textAlign: TextAlign.center,

            ),

            SizedBox(height: r.vp(28)),

            _ChoiceOptionTile(

              icon: Icons.people_outline,

              title: 'Envoyer à tous',

              subtitle: 'Notifier tous les $label sans distinction',

              color: const Color(0xFFCCD5AE),

              onTap: () {

                Navigator.pop(ctx);

                setState(() {

                  _selectedAudience = audienceType;

                  if (audienceType == 'merchants') {

                    _selectedMerchantIds = null;

                  } else {

                    _selectedClientIds = null;

                  }

                });

              },

            ),

            SizedBox(height: r.vp(12)),

            _ChoiceOptionTile(

              icon: Icons.tune_rounded,

              title: 'Personnaliser',

              subtitle: 'Choisir des $label spécifiques',

              color: const Color(0xFFFAEDCD),

              borderColor: const Color(0xFFE8DEC8),

              onTap: () {

                Navigator.pop(ctx);

                _showUserSelectionModal(audienceType);

              },

            ),

            SizedBox(height: r.vp(8)),

          ],

        ),

      ),

    );

  }



  void _showUserSelectionModal(String audienceType) {

    final r = _Responsive(context);

    final isMerchant = audienceType == 'merchants';

    final users = isMerchant ? _allMerchants : _allClients;

  


    String searchQuery = '';

    final Set<String> selected = Set.from(

      isMerchant ? (_selectedMerchantIds ?? []) : (_selectedClientIds ?? []),

    );



    showModalBottomSheet(

      context: context,

      backgroundColor: Colors.transparent,

      isScrollControlled: true,

      builder: (ctx) {

        return StatefulBuilder(

          builder: (ctx, setModalState) {

            List<dynamic> filtered;

            if (isMerchant) {

              final allowedMerchants = (users as List<MerchantAPI>)

                  .where((u) => u.actif && u.statutValidation == 'VALIDE')

                  .toList();

              filtered = allowedMerchants

                  .where((u) =>

                      searchQuery.isEmpty ||

                      u.nomCommerce.toLowerCase().contains(searchQuery.toLowerCase()) ||

                      u.fullName.toLowerCase().contains(searchQuery.toLowerCase()))

                  .toList();

            } else {


              final clientList = users as List<ClientAPI>;

              filtered = clientList

                  .where((u) =>

                      searchQuery.isEmpty ||

                      u.fullName.toLowerCase().contains(searchQuery.toLowerCase()))

                  .toList();

            }



            return Container(

              height: MediaQuery.of(context).size.height * 0.82,

              decoration: const BoxDecoration(

                color: Colors.white,

                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),

              ),

              child: Column(

                children: [

                  SizedBox(height: r.vp(12)),

                  _sheetHandle(),

                  SizedBox(height: r.vp(16)),

                  Padding(

                    padding: EdgeInsets.symmetric(horizontal: r.hp(20)),

                    child: Text(

                      isMerchant

                          ? 'Sélectionner des commerçants'

                          : 'Sélectionner des clients',

                      style: TextStyle(

                        fontFamily: AppFonts.plusJakarta,

                        fontSize: r.fontSize(16),

                        fontWeight: FontWeight.w700,

                        color: Colors.black,

                      ),

                    ),

                  ),

                  SizedBox(height: r.vp(14)),

                  Padding(

                    padding: EdgeInsets.symmetric(horizontal: r.hp(20)),

                    child: Container(

                      decoration: BoxDecoration(

                        color: const Color(0xFFF5F5F5),

                        borderRadius: BorderRadius.circular(r.scale(30)),

                      ),

                      child: TextField(

                        style: TextStyle(

                            fontFamily: AppFonts.plusJakarta, 

                            fontSize: r.fontSize(13)),

                        onChanged: (v) => setModalState(() => searchQuery = v),

                        decoration: InputDecoration(

                          hintText: 'Rechercher un utilisateur...',

                          hintStyle: TextStyle(

                            fontFamily: AppFonts.plusJakarta,

                            fontSize: r.fontSize(13),

                            color: AppColors.textMuted,

                          ),

                          prefixIcon: Icon(Icons.search,

                              size: r.scale(18), color: AppColors.textMuted),

                          border: InputBorder.none,

                          contentPadding: EdgeInsets.symmetric(

                              horizontal: r.hp(12), vertical: r.vp(14)),

                        ),

                      ),

                    ),

                  ),

                  SizedBox(height: r.vp(12)),

                  SizedBox(height: r.vp(12)),

                  Expanded(

                    child: isMerchant && _isLoadingMerchants

                        ? Center(

                            child: Column(

                              mainAxisAlignment: MainAxisAlignment.center,

                              children: [

                                CircularProgressIndicator(),

                                SizedBox(height: r.vp(16)),

                                Text(

                                  'Chargement des commerçants...',

                                  style: TextStyle(

                                    fontFamily: AppFonts.plusJakarta,

                                    fontSize: r.fontSize(14),

                                    color: AppColors.textMuted,

                                  ),

                                ),

                              ],

                            ),

                          )

                        : isMerchant && _merchantsError != null

                        ? Center(

                            child: Column(

                              mainAxisAlignment: MainAxisAlignment.center,

                              children: [

                                Icon(Icons.error_outline, size: r.scale(48), color: Colors.red),

                                SizedBox(height: r.vp(16)),

                                Text(

                                  'Erreur de chargement',

                                  style: TextStyle(

                                    fontFamily: AppFonts.plusJakarta,

                                    fontSize: r.fontSize(16),

                                    color: Colors.red,

                                    fontWeight: FontWeight.w600,

                                  ),

                                ),

                                SizedBox(height: r.vp(8)),

                                Text(

                                  'Veuillez réessayer plus tard',

                                  style: TextStyle(

                                    fontFamily: AppFonts.plusJakarta,

                                    fontSize: r.fontSize(13),

                                    color: AppColors.textMuted,

                                  ),

                                ),

                                SizedBox(height: r.vp(16)),

                                ElevatedButton(

                                  onPressed: _loadMerchants,

                                  style: ElevatedButton.styleFrom(

                                    backgroundColor: const Color(0xFFCCD5AE),

                                    foregroundColor: Colors.black,

                                  ),

                                  child: Text('Réessayer'),

                                ),

                              ],

                            ),

                          )

                        : !isMerchant && _isLoadingClients

                        ? Center(

                            child: Column(

                              mainAxisAlignment: MainAxisAlignment.center,

                              children: [

                                CircularProgressIndicator(),

                                SizedBox(height: r.vp(16)),

                                Text(

                                  'Chargement des clients...',

                                  style: TextStyle(

                                    fontFamily: AppFonts.plusJakarta,

                                    fontSize: r.fontSize(14),

                                    color: AppColors.textMuted,

                                  ),

                                ),

                              ],

                            ),

                          )

                        : !isMerchant && _clientsError != null

                        ? Center(

                            child: Column(

                              mainAxisAlignment: MainAxisAlignment.center,

                              children: [

                                Icon(Icons.error_outline, size: r.scale(48), color: Colors.red),

                                SizedBox(height: r.vp(16)),

                                Text(

                                  'Erreur de chargement',

                                  style: TextStyle(

                                    fontFamily: AppFonts.plusJakarta,

                                    fontSize: r.fontSize(16),

                                    color: Colors.red,

                                    fontWeight: FontWeight.w600,

                                  ),

                                ),

                                SizedBox(height: r.vp(8)),

                                Text(

                                  'Veuillez réessayer plus tard',

                                  style: TextStyle(

                                    fontFamily: AppFonts.plusJakarta,

                                    fontSize: r.fontSize(13),

                                    color: AppColors.textMuted,

                                  ),

                                ),

                                SizedBox(height: r.vp(16)),

                                ElevatedButton(

                                  onPressed: _loadClients,

                                  style: ElevatedButton.styleFrom(

                                    backgroundColor: const Color(0xFFCCD5AE),

                                    foregroundColor: Colors.black,

                                  ),

                                  child: Text('Réessayer'),

                                ),

                              ],

                            ),

                          )

                        : filtered.isEmpty

                        ? Center(

                            child: Text(

                              'Aucun résultat',

                              style: TextStyle(

                                fontFamily: AppFonts.plusJakarta,

                                fontSize: r.fontSize(13),

                                color: AppColors.textMuted,

                              ),

                            ),

                          )

                        : ListView.separated(

                            padding: EdgeInsets.symmetric(horizontal: r.hp(20)),

                            itemCount: filtered.length,

                            separatorBuilder: (_, __) => SizedBox(height: r.vp(8)),

                            itemBuilder: (_, i) {

                              final user = filtered[i];

                              final String id;

                              final String name;

                              final String initials;


                              

                              if (isMerchant) {


                                final merchant = user as MerchantAPI;

                                id = merchant.id;

                                name = merchant.nomCommerce.isNotEmpty ? merchant.nomCommerce : merchant.fullName;

                                initials = _getInitials(name);

                              } else {


                                final client = user as ClientAPI;

                                id = client.id;

                                name = client.fullName;

                                initials = _getInitials(client.fullName);


                              }

                              final isSelected = selected.contains(id);

                              return GestureDetector(

                                onTap: () => setModalState(() {

                                  if (isSelected) {

                                    selected.remove(id);

                                  } else {

                                    selected.add(id);

                                  }

                                }),

                                child: Container(

                                  padding: EdgeInsets.symmetric(

                                      horizontal: r.hp(14), vertical: r.vp(12)),

                                  decoration: BoxDecoration(

                                    color: isSelected

                                        ? const Color(0xFFCCD5AE)

                                            .withOpacity(0.18)

                                        : const Color(0xFFFAEDCD)

                                            .withOpacity(0.55),

                                    borderRadius: BorderRadius.circular(r.scale(30)),

                                    border: Border.all(

                                      color: isSelected

                                          ? const Color(0xFFCCD5AE)

                                          : const Color(0xFFE8DEC8),

                                      width: isSelected ? 1.5 : 1,

                                    ),

                                  ),

                                  child: Row(

                                    children: [

                                      Container(

                                        width: r.scale(38),

                                        height: r.scale(38),

                                        decoration: BoxDecoration(

                                          color: isSelected

                                              ? const Color(0xFFCCD5AE)

                                              : const Color(0xFFE8DEC8),

                                          shape: BoxShape.circle,

                                        ),

                                        child: Center(

                                          child: Text(initials,

                                              style: TextStyle(

                                                fontFamily: AppFonts.plusJakarta,

                                                fontSize: r.fontSize(12),

                                                fontWeight: FontWeight.w700,

                                                color: Colors.black,

                                              )),

                                        ),

                                      ),

                                      SizedBox(width: r.hp(12)),

                                      Expanded(

                                        child: Column(

                                          crossAxisAlignment: CrossAxisAlignment.start,

                                          children: [

                                            Text(name,

                                                style: TextStyle(

                                                  fontFamily: AppFonts.plusJakarta,

                                                  fontSize: r.fontSize(14),

                                                  fontWeight: FontWeight.w500,

                                                  color: Colors.black,

                                                ),

                                                overflow: TextOverflow.ellipsis,

                                              ),

                                          ],

                                        ),

                                      ),

                                      Container(

                                        width: r.scale(24),

                                        height: r.scale(24),

                                        decoration: BoxDecoration(

                                          shape: BoxShape.circle,

                                          color: isSelected

                                              ? const Color(0xFFCCD5AE)

                                              : Colors.transparent,

                                          border: Border.all(

                                            color: isSelected

                                                ? const Color(0xFFCCD5AE)

                                                : const Color(0xFFCDCDCD),

                                            width: 1.5,

                                          ),

                                        ),

                                        child: isSelected

                                            ? Icon(Icons.check,

                                                size: r.scale(14), color: Colors.white)

                                            : null,

                                      ),

                                    ],

                                  ),

                                ),

                              );

                            },

                          ),

                  ),

                  Padding(

                    padding: EdgeInsets.fromLTRB(r.hp(20), r.vp(12), r.hp(20), r.vp(28)),

                    child: SizedBox(

                      width: double.infinity,

                      child: ElevatedButton(

                        onPressed: selected.isEmpty ? null : () {

                          Navigator.pop(ctx);

                          setState(() {

                            _selectedAudience = audienceType;

                            if (isMerchant) {

                              _selectedMerchantIds = selected.toList();

                            } else {

                              _selectedClientIds = selected.toList();

                            }

                          });

                        },

                        style: ElevatedButton.styleFrom(

                          backgroundColor: const Color(0xFFCCD5AE),

                          side: const BorderSide(

                              color: Color(0xFFE8DEC8), width: 1.5),

                          disabledBackgroundColor: const Color(0xFFE0E0E0),

                          foregroundColor: Colors.black,

                          padding: EdgeInsets.symmetric(vertical: r.vp(14)),

                          shape: RoundedRectangleBorder(

                            borderRadius: BorderRadius.circular(r.scale(30)),

                          ),

                          elevation: 0,

                        ),

                        child: Text(

                          selected.isEmpty

                              ? 'Valider la sélection'

                              : 'Valider la sélection (${selected.length})',

                          style: TextStyle(

                            fontFamily: AppFonts.plusJakarta,

                            fontSize: r.fontSize(14),

                            fontWeight: FontWeight.w700,

                            color: Colors.black,

                          ),

                        ),

                      ),

                    ),

                  ),

                ],

              ),

            );

          },

        );

      },

    );

  }



  void _sendNotification() async {

    final r = _Responsive(context);

    final titleEmpty = _titleController.text.trim().isEmpty;

    final messageEmpty = _messageController.text.trim().isEmpty;



    if (titleEmpty || messageEmpty) {

      setState(() {

        _titleError = titleEmpty;

        _messageError = messageEmpty;

      });

      return;

    }



    setState(() {

      _titleError = false;

      _messageError = false;

    });



    FocusScope.of(context).unfocus();



    try {

      print(' Sending notification to API...');

      String actualAudience = '';

      int recipientCount = 0;



      if (_selectedAudience == 'all') {


        await _adminService.sendNotification(

          titre: _titleController.text.trim(),

          message: _messageController.text.trim(),

          destinataire: 'CLIENT',

          targetUserIds: null,

          sousType: 'ADMIN_CLIENT',

        );

        await _adminService.sendNotification(

          titre: _titleController.text.trim(),

          message: _messageController.text.trim(),

          destinataire: 'COMMERCANT',

          targetUserIds: null,

          sousType: 'ADMIN_AVERTISSEMENT',

        );

        actualAudience = 'Tous';

        recipientCount = _allClients.length + _allMerchants.length;

      } else if (_selectedAudience == 'merchants') {

        if (_selectedMerchantIds == null) {

       

          await _adminService.sendNotification(

            titre: _titleController.text.trim(),

            message: _messageController.text.trim(),

            destinataire: 'COMMERCANT',

            targetUserIds: null,

            sousType: 'ADMIN_AVERTISSEMENT',

          );

          actualAudience = 'Commerçants';

          recipientCount = _allMerchants.length;

        } else {


          await _adminService.sendNotification(

            titre: _titleController.text.trim(),

            message: _messageController.text.trim(),

            destinataire: 'COMMERCANT',

            targetUserIds: _selectedMerchantIds,

            sousType: 'ADMIN_AVERTISSEMENT',

          );

          actualAudience = 'Commerçants';

          recipientCount = _selectedMerchantIds!.length;

        }

      } else if (_selectedAudience == 'clients') {

        if (_selectedClientIds == null) {


          await _adminService.sendNotification(

            titre: _titleController.text.trim(),

            message: _messageController.text.trim(),

            destinataire: 'CLIENT',

            targetUserIds: null,

            sousType: 'ADMIN_CLIENT',

          );

          actualAudience = 'Clients';

          recipientCount = _allClients.length;

        } else {


          await _adminService.sendNotification(

            titre: _titleController.text.trim(),

            message: _messageController.text.trim(),

            destinataire: 'CLIENT',

            targetUserIds: _selectedClientIds,

            sousType: 'ADMIN_CLIENT',

          );

          actualAudience = 'Clients';

          recipientCount = _selectedClientIds!.length;

        }

      }



      print('Notification sent successfully');



      setState(() {

        _titleController.clear();

        _messageController.clear();

      });

      _loadNotificationHistory();

      _showSuccessBanner('$actualAudience ($recipientCount destinataires)');

    } catch (e) {

      print(' Failed to send notification: $e');

      _showErrorBanner(e.toString());

    }

  }



  String _getAudienceLabel() {

    if (_selectedAudience == 'all') return 'Tous';

    if (_selectedAudience == 'merchants') return 'Commerçants';

    return 'Clients';

  }



  void _showSuccessBanner(String audienceLabel) {

    final overlay = Overlay.of(context);

    late OverlayEntry entry;

    entry = OverlayEntry(

      builder: (ctx) => _SuccessBanner(

        audienceLabel: audienceLabel,

        onDone: () => entry.remove(),

      ),

    );

    overlay.insert(entry);

  }



  void _showErrorBanner(String errorMessage) {

    final overlay = Overlay.of(context);

    late OverlayEntry entry;

    entry = OverlayEntry(

      builder: (ctx) => _ErrorBanner(

        message: errorMessage,

        onDone: () => entry.remove(),

      ),

    );

    overlay.insert(entry);

  }



  @override

  Widget build(BuildContext context) {

    final r = _Responsive(context);

    return Scaffold(

      resizeToAvoidBottomInset: true,

      body: Container(

        width: double.infinity,

        height: double.infinity,

        decoration: appGradient,

        child: SafeArea(

          child: Column(

            crossAxisAlignment: CrossAxisAlignment.start,

            children: [

              Padding(

                padding: EdgeInsets.fromLTRB(r.hp(20), r.vp(20), r.hp(20), r.vp(20)),

                child: Text('Notifications', 

                  style: AppTextStyles.pageTitle.copyWith(fontSize: r.fontSize(28))),

              ),

              Padding(

                padding: EdgeInsets.symmetric(horizontal: r.hp(20), vertical: r.vp(8)),

                child: Container(

                  decoration: BoxDecoration(

                    color: Colors.white,

                    borderRadius: BorderRadius.circular(r.scale(40)),

                    boxShadow: [

                      BoxShadow(

                        color: Colors.black.withOpacity(0.04),

                        blurRadius: r.scale(8),

                        offset: const Offset(0, 2),

                      ),

                    ],

                  ),

                  child: Row(children: [

                    _buildTabButton('Envoyer', 0),

                    _buildTabButton('Historique', 1),

                  ]),

                ),

              ),

              Expanded(

                child: _selectedTab == 0

                    ? _buildSendTab()

                    : _buildHistoryTab(),

              ),

            ],

          ),

        ),

      ),

    );

  }



  Widget _buildTabButton(String label, int index) {

    final r = _Responsive(context);

    final isSelected = _selectedTab == index;

    return Expanded(

      child: GestureDetector(

        onTap: () => setState(() => _selectedTab = index),

        child: Container(

          padding: EdgeInsets.symmetric(vertical: r.vp(13)),

          decoration: BoxDecoration(

            color: isSelected ? const Color(0xFFCCD5AE) : Colors.white,

            borderRadius: BorderRadius.circular(r.scale(40)),

          ),

          child: Center(

            child: Text(

              label,

              style: TextStyle(

                fontFamily: AppFonts.plusJakarta,

                fontSize: r.fontSize(13),

                fontWeight: FontWeight.w600,

                color: isSelected ? Colors.black : AppColors.textSecondary,

              ),

            ),

          ),

        ),

      ),

    );

  }



  Widget _buildSendTab() {

    final r = _Responsive(context);

    return SingleChildScrollView(

      controller: _scrollController,

      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,

      padding: EdgeInsets.fromLTRB(r.hp(20), r.vp(8), r.hp(20), r.vp(120)),

      child: Column(

        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          SizedBox(height: r.vp(30)),

          Text(

            'Destinataires',

            style: AppTextStyles.statLabel.copyWith(

              fontSize: r.fontSize(12),

              fontWeight: FontWeight.w600,

              color: AppColors.textSecondary,

            ),

          ),

          SizedBox(height: r.vp(12)),

          Row(

            children: [

              Expanded(

                child: _buildAudienceChip(

                    'Tous', 'all', Icons.people_outline,

                    showArrow: false),

              ),

              SizedBox(width: r.hp(8)),

              Expanded(

                child: _buildAudienceChip(

                    'Clients', 'clients', Icons.person_outline,

                    showArrow: true),

              ),

              SizedBox(width: r.hp(8)),

              Expanded(

                child: _buildAudienceChip(

                    'Commerçants', 'merchants', Icons.storefront_outlined,

                    showArrow: true),

              ),

            ],

          ),

          if (_selectedAudience != 'all') ...[

            SizedBox(height: r.vp(10)),

            Padding(

              padding: EdgeInsets.only(left: r.hp(4)),

              child: Text(

                _audienceSummary(),

                style: TextStyle(

                  fontFamily: AppFonts.plusJakarta,

                  fontSize: r.fontSize(11),

                  color: AppColors.textSecondary,

                  fontStyle: FontStyle.italic,

                ),

              ),

            ),

          ],

          SizedBox(height: r.vp(40)),

          _buildInputSection(

            label: 'Titre',

            hasError: _titleError,

            errorText: 'Veuillez remplir le titre',

            child: TextField(

              controller: _titleController,

              focusNode: _titleFocus,

              style: AppTextStyles.inputText.copyWith(fontSize: r.fontSize(14)),

              onChanged: (_) {

                if (_titleError) setState(() => _titleError = false);

              },

              decoration: _inputDecoration('Entrez le titre ici',

                  hasError: _titleError),

            ),

          ),

          SizedBox(height: r.vp(4)),

          _buildInputSection(

            label: 'Message',

            hasError: _messageError,

            errorText: 'Veuillez rédiger un message',

            child: TextField(

              controller: _messageController,

              focusNode: _messageFocus,

              maxLines: 4,

              style: AppTextStyles.inputText.copyWith(fontSize: r.fontSize(14)),

              onChanged: (_) {

                if (_messageError) setState(() => _messageError = false);

              },

              decoration: _inputDecoration('Rédigez votre message...',

                  hasError: _messageError),

            ),

          ),

          SizedBox(height: r.vp(24)),

          Align(

            alignment: Alignment.centerRight,

            child: SizedBox(

              width: r.hp(130),

              child: ElevatedButton(

                onPressed: _sendNotification,

                style: ElevatedButton.styleFrom(

                  backgroundColor: const Color(0xFFCCD5AE),

                  side: const BorderSide(

                      color: Color(0xFFE8DEC8), width: 1.5),

                  foregroundColor: Colors.black,

                  padding: EdgeInsets.symmetric(vertical: r.vp(12)),

                  shape: RoundedRectangleBorder(

                    borderRadius: BorderRadius.circular(r.scale(30)),

                  ),

                  elevation: 0,

                ),

                child: Row(

                  mainAxisAlignment: MainAxisAlignment.center,

                  children: [

                    Icon(Icons.send_rounded,

                        size: r.scale(16), color: Colors.black),

                    SizedBox(width: r.hp(6)),

                    Text(

                      'Envoyer',

                      style: TextStyle(

                        fontFamily: AppFonts.plusJakarta,

                        fontSize: r.fontSize(13),

                        fontWeight: FontWeight.w700,

                        color: Colors.black,

                      ),

                    ),

                  ],

                ),

              ),

            ),

          ),

        ],

      ),

    );

  }



  Widget _buildInputSection({

    required String label,

    required Widget child,

    bool hasError = false,

    String? errorText,

  }) {

    final r = _Responsive(context);

    return Padding(

      padding: EdgeInsets.symmetric(vertical: r.vp(8)),

      child: Column(

        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          Text(

            label,

            style: AppTextStyles.statLabel.copyWith(

              fontSize: r.fontSize(12),

              fontWeight: FontWeight.w600,

              color: AppColors.textSecondary,

            ),

          ),

          SizedBox(height: r.vp(8)),

          child,

          if (hasError && errorText != null) ...[

            SizedBox(height: r.vp(6)),

            Row(

              children: [

                Icon(Icons.info_outline_rounded, size: r.scale(12), color: Colors.red),

                SizedBox(width: r.hp(4)),

                Text(

                  errorText,

                  style: TextStyle(

                    fontFamily: AppFonts.plusJakarta,

                    fontSize: r.fontSize(11),

                    color: Colors.red,

                  ),

                ),

              ],

            ),

          ],

        ],

      ),

    );

  }



  InputDecoration _inputDecoration(String hint, {bool hasError = false}) {

    final r = _Responsive(context);

    return InputDecoration(

      hintText: hint,

      hintStyle: AppTextStyles.inputText.copyWith(color: AppColors.textMuted, fontSize: r.fontSize(14)),

      border: OutlineInputBorder(

        borderRadius: BorderRadius.circular(r.scale(16)),

        borderSide: BorderSide.none,

      ),

      enabledBorder: OutlineInputBorder(

        borderRadius: BorderRadius.circular(r.scale(16)),

        borderSide: hasError

            ? BorderSide(color: Colors.red.withOpacity(0.6), width: 1)

            : BorderSide.none,

      ),

      focusedBorder: OutlineInputBorder(

        borderRadius: BorderRadius.circular(r.scale(16)),

        borderSide: BorderSide.none,

      ),

      contentPadding: EdgeInsets.symmetric(horizontal: r.hp(16), vertical: r.vp(14)),

      filled: true,

      fillColor: AppColors.cardBg,

    );

  }



  Widget _buildAudienceChip(

    String label,

    String value,

    IconData icon, {

    required bool showArrow,

  }) {

    final r = _Responsive(context);

    final isSelected = _selectedAudience == value;

    return GestureDetector(

      onTap: () => _onAudienceTap(value),

      child: Container(

        width: double.infinity,

        padding: EdgeInsets.symmetric(horizontal: r.hp(8), vertical: r.vp(10)),

        decoration: BoxDecoration(

          color: isSelected ? const Color(0xFFCCD5AE) : Colors.white,

          borderRadius: BorderRadius.circular(r.scale(30)),

          border: Border.all(

            color: const Color(0xFFE8DEC8),

            width: isSelected ? 1.8 : 1.0,

          ),

        ),

        child: Row(

          mainAxisAlignment: MainAxisAlignment.center,

          children: [

            Icon(icon, size: r.scale(16), color: Colors.black87),

            SizedBox(width: r.hp(6)),

            Flexible(

              child: Text(

                label,

                overflow: TextOverflow.ellipsis,

                style: TextStyle(

                  fontFamily: AppFonts.plusJakarta,

                  fontSize: r.fontSize(13),

                  fontWeight: FontWeight.w500,

                  color: Colors.black87,

                ),

              ),

            ),

            if (showArrow) ...[

              SizedBox(width: r.hp(4)),

              Icon(Icons.north_east_rounded,

                  size: r.scale(13), color: Colors.black87),

            ],

          ],

        ),

      ),

    );

  }



  Widget _buildHistoryTab() {

    final r = _Responsive(context);

    return Column(

      children: [

        Padding(

          padding: EdgeInsets.symmetric(horizontal: r.hp(20), vertical: r.vp(8)),

          child: SingleChildScrollView(

            scrollDirection: Axis.horizontal,

            physics: const BouncingScrollPhysics(),

            child: Row(

              children: [

                _buildHistoryFilterChip('Tous', 'all'),

                SizedBox(width: r.hp(10)),

                _buildHistoryFilterChip('Commerçants', 'merchants'),

                SizedBox(width: r.hp(10)),

                _buildHistoryFilterChip('Clients', 'clients'),

              ],

            ),

          ),

        ),

        SizedBox(height: r.vp(8)),

        Expanded(

          child: _filteredHistory.isEmpty

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

                        child: Icon(Icons.history_outlined,

                            size: r.scale(36), color: Colors.white),

                      ),

                      SizedBox(height: r.vp(16)),

                      Text(

                        'Aucun historique',

                        style: AppTextStyles.pageTitle.copyWith(

                          fontSize: r.fontSize(20),

                          color: Colors.white,

                        ),

                      ),

                    ],

                  ),

                )

              : ListView.separated(

                  padding: EdgeInsets.fromLTRB(r.hp(20), r.vp(8), r.hp(20), r.vp(100)),

                  itemCount: _filteredHistory.length,

                  separatorBuilder: (_, __) => SizedBox(height: r.vp(12)),

                  itemBuilder: (_, index) {

                    final notification = _filteredHistory[index];

                    return _HistoryNotificationCard(

                      notification: notification,

                    );

                  },

                ),

        ),

      ],

    );

  }



  Widget _buildHistoryFilterChip(String label, String value) {

    final r = _Responsive(context);

    final isSelected = _historyFilter == value;

    return GestureDetector(

      onTap: () => _onHistoryFilterChanged(value),

      child: Container(

        padding: EdgeInsets.symmetric(horizontal: r.hp(16), vertical: r.vp(8)),

        decoration: BoxDecoration(

          color: isSelected

              ? const Color(0xFFCCD5AE)

              : const Color(0xFFFAEDCD),

          borderRadius: BorderRadius.circular(r.scale(30)),

          border: Border.all(

            color: isSelected ? Colors.transparent : const Color(0xFFE8DEC8),

          ),

        ),

        child: Text(

          label,

          style: TextStyle(

            fontFamily: AppFonts.plusJakarta,

            fontSize: r.fontSize(13),

            fontWeight: FontWeight.w400,

            color: isSelected ? Colors.black : const Color(0xFF6B6B6B),

          ),

        ),

      ),

    );

  }



  Widget _sheetHandle() {

    final r = _Responsive(context);

    return Container(

      width: r.hp(40),

      height: r.scale(4),

      decoration: BoxDecoration(

        color: const Color(0xFFE0E0E0),

        borderRadius: BorderRadius.circular(r.scale(2)),

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



class _SuccessBanner extends StatefulWidget {

  const _SuccessBanner({

    required this.audienceLabel,

    required this.onDone,

  });

  final String audienceLabel;

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

    final bannerBottom = r.vp(20) + kBottomNavigationBarHeight + r.vp(8);



    return Positioned(

      bottom: bannerBottom,

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

                    blurRadius: r.scale(18),

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

                          'Notification envoyée',

                          style: TextStyle(

                            fontFamily: AppFonts.plusJakarta,

                            fontSize: r.fontSize(13),

                            fontWeight: FontWeight.w700,

                            color: Colors.black,

                          ),

                        ),

                        Text(

                          'Envoyée à : ${widget.audienceLabel}',

                          style: TextStyle(

                            fontFamily: AppFonts.plusJakarta,

                            fontSize: r.fontSize(11),

                            color: Colors.black54,

                          ),

                          overflow: TextOverflow.ellipsis,

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



class _ChoiceOptionTile extends StatelessWidget {

  const _ChoiceOptionTile({

    required this.icon,

    required this.title,

    required this.subtitle,

    required this.color,

    this.borderColor,

    required this.onTap,

  });



  final IconData icon;

  final String title;

  final String subtitle;

  final Color color;

  final Color? borderColor;

  final VoidCallback onTap;



  @override

  Widget build(BuildContext context) {

    final r = _Responsive(context);

    return GestureDetector(

      onTap: onTap,

      child: Container(

        width: double.infinity,

        padding: EdgeInsets.symmetric(horizontal: r.hp(18), vertical: r.vp(16)),

        decoration: BoxDecoration(

          color: color,

          borderRadius: BorderRadius.circular(r.scale(30)),

          border: borderColor != null

              ? Border.all(color: borderColor!, width: 1)

              : null,

        ),

        child: Row(

          children: [

            Container(

              width: r.scale(42),

              height: r.scale(42),

              decoration: BoxDecoration(

                color: Colors.white.withOpacity(0.6),

                shape: BoxShape.circle,

              ),

              child: Icon(icon, size: r.scale(20), color: Colors.black87),

            ),

            SizedBox(width: r.hp(14)),

            Expanded(

              child: Column(

                crossAxisAlignment: CrossAxisAlignment.start,

                children: [

                  Text(title,

                      style: TextStyle(

                        fontFamily: AppFonts.plusJakarta,

                        fontSize: r.fontSize(14),

                        fontWeight: FontWeight.w700,

                        color: Colors.black,

                      )),

                  SizedBox(height: r.vp(2)),

                  Text(subtitle,

                      style: TextStyle(

                        fontFamily: AppFonts.plusJakarta,

                        fontSize: r.fontSize(12),

                        color: Colors.black54,

                      )),

                ],

              ),

            ),

          ],

        ),

      ),

    );

  }

}



class _HistoryNotificationCard extends StatelessWidget {

  const _HistoryNotificationCard({

    required this.notification,

  });

  final Map<String, dynamic> notification;



  
  Widget _sheetHandle(BuildContext context) {
    final r = _Responsive(context);
    return Container(
      width: r.hp(40),
      height: r.scale(4),
      decoration: BoxDecoration(
        color: const Color(0xFFE0E0E0),
        borderRadius: BorderRadius.circular(r.scale(2)),
      ),
    );
  }

  void _showNotificationDetails(BuildContext context) {
    final r = _Responsive(context);
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: EdgeInsets.fromLTRB(r.hp(24), r.vp(20), r.hp(24), r.vp(36)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sheetHandle(ctx),
            SizedBox(height: r.vp(24)),
            Text(
              'Détails de la notification',
              style: TextStyle(
                fontFamily: AppFonts.plusJakarta,
                fontSize: r.fontSize(17),
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
            SizedBox(height: r.vp(20)),
            
            Text(
              'Titre',
              style: TextStyle(
                fontFamily: AppFonts.plusJakarta,
                fontSize: r.fontSize(12),
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: r.vp(6)),
            Text(
              notification['title'] ?? '',
              style: TextStyle(
                fontFamily: AppFonts.plusJakarta,
                fontSize: r.fontSize(14),
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
            SizedBox(height: r.vp(16)),
            
            Text(
              'Contenu',
              style: TextStyle(
                fontFamily: AppFonts.plusJakarta,
                fontSize: r.fontSize(12),
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: r.vp(6)),
            Text(
              notification['message'] ?? '',
              style: TextStyle(
                fontFamily: AppFonts.plusJakarta,
                fontSize: r.fontSize(14),
                color: Colors.black,
                height: 1.4,
              ),
            ),
            SizedBox(height: r.vp(16)),
            
            Text(
              'Destinataire',
              style: TextStyle(
                fontFamily: AppFonts.plusJakarta,
                fontSize: r.fontSize(12),
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: r.vp(6)),
            Text(
              notification['audience'] ?? '',
              style: TextStyle(
                fontFamily: AppFonts.plusJakarta,
                fontSize: r.fontSize(14),
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
            SizedBox(height: r.vp(16)),
            
            Text(
              'Type',
              style: TextStyle(
                fontFamily: AppFonts.plusJakarta,
                fontSize: r.fontSize(12),
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: r.vp(6)),
            Text(
              notification['type'] ?? '',
              style: TextStyle(
                fontFamily: AppFonts.plusJakarta,
                fontSize: r.fontSize(14),
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
            SizedBox(height: r.vp(16)),
            
            Text(
              'Date d\'envoi',
              style: TextStyle(
                fontFamily: AppFonts.plusJakarta,
                fontSize: r.fontSize(12),
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: r.vp(6)),
            Text(
              _formatDate(notification['date']),
              style: TextStyle(
                fontFamily: AppFonts.plusJakarta,
                fontSize: r.fontSize(14),
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
            SizedBox(height: r.vp(20)),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFCCD5AE),
                  foregroundColor: Colors.black,
                  padding: EdgeInsets.symmetric(vertical: r.vp(14)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(r.scale(30)),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Fermer',
                  style: TextStyle(
                    fontFamily: AppFonts.plusJakarta,
                    fontSize: r.fontSize(14),
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {

    return '${date.day} ${_month(date.month)} ${date.year.toString().substring(2)} '

        '${date.hour}:${date.minute.toString().padLeft(2, '0')}';

  }



  String _month(int m) {

    const months = [

      'Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Juin',

      'Juil', 'Août', 'Sep', 'Oct', 'Nov', 'Déc',

    ];

    return months[m - 1];

  }



  @override

  Widget build(BuildContext context) {

    final r = _Responsive(context);

    final audience = notification['audience'] as String;

    final isMerchant = audience == 'Commerçants';

    final isAll = audience == 'Tous';



    final audienceColor = isAll

        ? const Color(0xFF9E9E9E)

        : isMerchant

            ? const Color(0xFFA8C88A)

            : const Color(0xFFF8B068);



    return GestureDetector(

      onTap: () => _showNotificationDetails(context),

      child: Container(

        padding: EdgeInsets.all(r.scale(16)),

        decoration: BoxDecoration(

          color: Colors.white,

          borderRadius: BorderRadius.circular(r.scale(28)),

          boxShadow: [

            BoxShadow(

              color: Colors.black.withOpacity(0.04),

              blurRadius: r.scale(8),

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

              Expanded(

                child: Text(

                  notification['title'],

                  style: AppTextStyles.listItemTitle.copyWith(

                    fontSize: r.fontSize(16),

                    fontWeight: FontWeight.w700,

                  ),

                  overflow: TextOverflow.ellipsis,

                ),

              ),

            ],

          ),

          SizedBox(height: r.vp(8)),

          Text(

            notification['message'],

            style: AppTextStyles.bodySmall.copyWith(fontSize: r.fontSize(12), height: 1.4),

            maxLines: 2,

            overflow: TextOverflow.ellipsis,

          ),

          SizedBox(height: r.vp(12)),

          Row(

            children: [

              Icon(Icons.calendar_today_outlined,

                  size: r.scale(12), color: AppColors.textMuted),

              SizedBox(width: r.hp(6)),

              Text(

                _formatDate(notification['date']),

                style: AppTextStyles.bodySmall

                    .copyWith(fontSize: r.fontSize(11), color: AppColors.textMuted),

              ),

              
            ],

          ),

        ],

      ),

      ),

    );

  }

}



class _ErrorBanner extends StatefulWidget {

  final String message;

  final VoidCallback onDone;

  

  const _ErrorBanner({

    required this.message,

    required this.onDone,

  });



  @override

  State<_ErrorBanner> createState() => _ErrorBannerState();

}



class _ErrorBannerState extends State<_ErrorBanner> with SingleTickerProviderStateMixin {

  late final AnimationController _ctrl;

  late final Animation<Offset> _slide;

  late final Animation<double> _fade;



  @override

  void initState() {

    super.initState();

    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 380));

    _slide = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(

      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),

    );

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

    final navbarHeight = kBottomNavigationBarHeight;

    final finalBottom = navbarHeight + 20;



    return Positioned(

      bottom: finalBottom,

      left: 20,

      right: 20,

      child: SlideTransition(

        position: _slide,

        child: FadeTransition(

          opacity: _fade,

          child: Material(

            color: Colors.transparent,

            child: Container(

              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),

              decoration: BoxDecoration(

                color: Colors.red.withOpacity(0.9),

                borderRadius: BorderRadius.circular(30),

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

                    width: 32,

                    height: 32,

                    decoration: BoxDecoration(

                      color: Colors.white.withOpacity(0.5),

                      shape: BoxShape.circle,

                    ),

                    child: const Icon(Icons.error_rounded, size: 18, color: Colors.white),

                  ),

                  const SizedBox(width: 12),

                  Expanded(

                    child: Column(

                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [

                        Text(

                          'Erreur',

                          style: const TextStyle(

                            fontFamily: 'PlusJakartaSans',

                            fontSize: 13,

                            fontWeight: FontWeight.w700,

                            color: Colors.white,

                          ),

                        ),

                        Text(

                          widget.message,

                          style: const TextStyle(

                            fontFamily: 'PlusJakartaSans',

                            fontSize: 11,

                            color: Colors.white70,

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