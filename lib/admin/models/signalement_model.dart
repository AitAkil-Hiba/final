class SignalementUser {
  final String id;
  final String fullName;
  final String email;
  
  SignalementUser({required this.id, required this.fullName, required this.email});
  
  factory SignalementUser.fromJson(Map<String, dynamic> json) {
    try {
      return SignalementUser(
        id: json['id']?.toString() ?? '',
        fullName: json['fullName']?.toString() ?? json['nom']?.toString() ?? (json['prenom'] != null ? '${json['prenom']} ${json['nom']}' : 'Utilisateur inconnu'),
        email: json['email']?.toString() ?? '',
      );
    } catch (e) {
      print('  Error parsing SignalementUser: $e');
      return SignalementUser(
        id: json['id']?.toString() ?? '',
        fullName: 'Utilisateur inconnu',
        email: '',
      );
    }
  }
}

class SignalementOffre {
  final String id;
  final String titre;
  final String? merchantId;
  final String? merchantName;
  
  SignalementOffre({
    required this.id,
    required this.titre,
    this.merchantId,
    this.merchantName,
  });
  
  factory SignalementOffre.fromJson(Map<String, dynamic> json) {
    try {
      final commercant = json['commercant'];
      final commercantMap = commercant is Map ? commercant : null;
      return SignalementOffre(
        id: json['id']?.toString() ?? '',
        titre: json['titre']?.toString() ?? json['title']?.toString() ?? 'Offre sans titre',
        merchantId: commercantMap?['id']?.toString(),
        merchantName: commercantMap?['nomCommerce']?.toString(),
      );
    } catch (e) {
      print('  Error parsing SignalementOffre: $e');
      return SignalementOffre(
        id: json['id']?.toString() ?? '',
        titre: 'Offre sans titre',
        merchantId: null,
        merchantName: null,
      );
    }
  }
}

class SignalementItemAPI {
  final String id;
  final String raison;
  final String description;
  final String statut; 
  final DateTime createdAt;
  final DateTime updatedAt;
  final SignalementUser user;
  final SignalementOffre? offre;
  final dynamic commercant; 
  
  SignalementItemAPI({
    required this.id,
    required this.raison,
    required this.description,
    required this.statut,
    required this.createdAt,
    required this.updatedAt,
    required this.user,
    this.offre,
    this.commercant,
  });
  
  factory SignalementItemAPI.fromJson(Map<String, dynamic> json) {
    try {
      final commercantData = json['commercant'];
      
      return SignalementItemAPI(
        id: json['id']?.toString() ?? '',
        raison: json['raison']?.toString() ?? '',
        description: json['description']?.toString() ?? '',
        statut: json['statut']?.toString() ?? 'EN_ATTENTE',
        createdAt: json['createdAt'] != null 
            ? DateTime.parse(json['createdAt']) 
            : DateTime.now(),
        updatedAt: json['updatedAt'] != null 
            ? DateTime.parse(json['updatedAt']) 
            : DateTime.now(),
        user: SignalementUser.fromJson(json['user'] ?? {}),
        offre: json['offre'] != null ? SignalementOffre.fromJson(json['offre']) : null,
        commercant: commercantData,
      );
    } catch (e) {
      print('  Error parsing SignalementItemAPI: $e');
      print('  JSON data: $json');
      rethrow;
    }
  }
  
  String get targetTitle => offre?.titre ?? user.fullName;
  String get targetType => offre != null ? 'Annonce' : 'Commerçant';
  String? get merchantId =>
      commercant?['id']?.toString() ?? offre?.merchantId;
  String? get merchantName =>
      commercant?['nomCommerce']?.toString() ?? offre?.merchantName;
}

class PaginationInfo {
  final int page;
  final int size;
  final int totalElements;
  final int totalPages;
  final bool first;
  final bool last;
  final bool empty;
  
  PaginationInfo({
    required this.page,
    required this.size,
    required this.totalElements,
    required this.totalPages,
    required this.first,
    required this.last,
    required this.empty,
  });
  
  factory PaginationInfo.fromJson(Map<String, dynamic> json) {
    return PaginationInfo(
      page: json['page'] ?? 0,
      size: json['size'] ?? 0,
      totalElements: json['totalElements'] ?? 0,
      totalPages: json['totalPages'] ?? 0,
      first: json['first'] ?? true,
      last: json['last'] ?? true,
      empty: json['empty'] ?? false,
    );
  }
}

class SignalementsResponse {
  final bool success;
  final String message;
  final List<SignalementItemAPI> content;
  final PaginationInfo? pagination;
  
  SignalementsResponse({
    required this.success,
    required this.message,
    required this.content,
    this.pagination,
  });
  
  factory SignalementsResponse.fromJson(Map<String, dynamic> json) {
    try {
      final data = json['data'] as Map<String, dynamic>?;
      final contentList = data?['content'] as List? ?? [];
      
      PaginationInfo? pagination;
      if (data != null && data['pagination'] != null) {
        pagination = PaginationInfo.fromJson(data['pagination'] as Map<String, dynamic>);
      }
      
      return SignalementsResponse(
        success: json['success'] ?? false,
        message: json['message'] ?? '',
        content: contentList.map((item) => SignalementItemAPI.fromJson(item)).toList(),
        pagination: pagination,
      );
    } catch (e) {
      print('  Error parsing SignalementsResponse: $e');
      rethrow;
    }
  }
}