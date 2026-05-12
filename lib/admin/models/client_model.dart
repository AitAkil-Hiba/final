class ClientAPI {
  final String id;
  final String fullName;
  final String email;
  final String? telephone;
  final bool actif;
  final DateTime dateInscription;
  final DateTime updatedAt;
  
  ClientAPI({
    required this.id,
    required this.fullName,
    required this.email,
    this.telephone,
    required this.actif,
    required this.dateInscription,
    required this.updatedAt,
  });
  
  factory ClientAPI.fromJson(Map<String, dynamic> json) {
    DateTime dateInscription;
    if (json['dateInscription'] != null) {
      final dateStr = json['dateInscription'].toString();
      if (dateStr.length == 10) { 
        dateInscription = DateTime.parse('${dateStr}T00:00:00');
      } else {
        dateInscription = DateTime.parse(dateStr);
      }
    } else {
      dateInscription = DateTime.now();
    }
    
    return ClientAPI(
      id: json['id'] ?? '',
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      telephone: json['telephone'] ?? '',
      actif: json['actif'] ?? true,
      dateInscription: dateInscription,
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }
  
  String get status => actif ? 'Actif' : 'Suspendu';
}