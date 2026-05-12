class DocumentUrls {
  final String? cinUrl;
  final String? passportUrl;
  final String? rcUrl;
  
  DocumentUrls({this.cinUrl, this.passportUrl, this.rcUrl});
  
  factory DocumentUrls.fromJson(Map<String, dynamic> json) => DocumentUrls(
    cinUrl: json['cinUrl'],
    passportUrl: json['passportUrl'],
    rcUrl: json['rcUrl'],
  );
}

class DocumentLegal {
  final String id;
  final String statut; 
  final DateTime? dateExpiration;
  final DocumentUrls? documentUrls;
  
  DocumentLegal({
    required this.id,
    required this.statut,
    this.dateExpiration,
    this.documentUrls,
  });
  
  factory DocumentLegal.fromJson(Map<String, dynamic> json) => DocumentLegal(
    id: json['id'],
    statut: json['statut'],
    dateExpiration: json['dateExpiration'] != null ? DateTime.parse(json['dateExpiration']) : null,
    documentUrls: json['documentUrls'] != null ? DocumentUrls.fromJson(json['documentUrls']) : null,
  );
}

class MerchantAPI {
  final String id;
  final String fullName;
  final String nomCommerce;
  final String email;
  final String? telephone;
  final String statutValidation; 
  final String? typeCommerce;
  final String? adresse;
  final DocumentLegal? documentLegal;
  final bool actif;
  final bool isVerified;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? merchantId; 
  final String? commerceName;
  final String? commerceType; 
  final String? address; 
  final String? documentId; 
  final String? numeroRc; 
  final String? cinPasseportUrl; 
  final String? extraitRcUrl; 
  final String? brochureUrl; 
  final DateTime? cinExpirationDate; 
  final String? statut; 
  final String? heureOuverture; 
  final String? heureFermeture; 
  
  MerchantAPI({
    required this.id,
    required this.fullName,
    required this.nomCommerce,
    required this.email,
    this.telephone,
    required this.statutValidation,
    this.typeCommerce,
    this.adresse,
    this.documentLegal,
    this.actif = true,
    this.isVerified = false,
    this.createdAt,
    this.updatedAt,
    this.merchantId,
    this.commerceName,
    this.commerceType,
    this.address,
    this.documentId,
    this.numeroRc,
    this.cinPasseportUrl,
    this.extraitRcUrl,
    this.brochureUrl,
    this.cinExpirationDate,
    this.statut,
    this.heureOuverture,
    this.heureFermeture,
  });
  
  factory MerchantAPI.fromJson(Map<String, dynamic> json) {
    final id = json['id'] ?? json['merchantId'] ?? json['userId'] ?? '';
    final nomCommerce = json['nomCommerce'] ?? json['commerceName'] ?? '';
    final adresse = json['adresse'] ?? json['address'] ?? '';
    final typeCommerce = json['typeCommerce'] ?? json['commerceType'] ?? '';
    
    return MerchantAPI(
      id: id,
      fullName: json['fullName'] ?? '',
      nomCommerce: nomCommerce,
      email: json['email'] ?? '',
      telephone: json['telephone'],
      statutValidation: json['statutValidation'] ?? json['statutValidation'] ?? 'EN_ATTENTE',
      typeCommerce: typeCommerce,
      adresse: adresse,
      documentLegal: json['documentLegal'] != null ? DocumentLegal.fromJson(json['documentLegal']) : null,
      actif: json['actif'] ?? true,
      isVerified: json['isVerified'] ?? false,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      merchantId: json['merchantId'],
      commerceName: json['commerceName'],
      commerceType: json['commerceType'],
      address: json['address'],
      documentId: json['documentId'],
      numeroRc: json['numeroRc'],
      cinPasseportUrl: json['cinPasseportUrl'],
      extraitRcUrl: json['extraitRcUrl'],
      brochureUrl: json['brochureUrl'],
      cinExpirationDate: json['cinExpirationDate'] != null ? DateTime.parse(json['cinExpirationDate']) : null,
      statut: json['statut'],
      heureOuverture: json['heureOuverture'],
      heureFermeture: json['heureFermeture'],
    );
  }
}