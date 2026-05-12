class RegisterRequest {
  final String email;
  final String password;
  final String fullName;
  final String? telephone;
  final String? role;
  
  RegisterRequest({
    required this.email,
    required this.password,
    required this.fullName,
    this.telephone,
    this.role,
  });
  
  Map<String, dynamic> toJson() => {
    'email': email,
    'password': password,
    'fullName': fullName,
    if (telephone != null) 'telephone': telephone,
    if (role != null) 'role': role,
  };
}

class LoginRequest {
  final String email;
  final String password;
  
  LoginRequest({
    required this.email,
    required this.password,
  });
  
  Map<String, dynamic> toJson() => {
    'email': email,
    'password': password,
  };
}

class LoginResponse {
  final String token;
  final String userId;
  final String role; 
  
  LoginResponse({
    required this.token,
    required this.userId,
    required this.role,
  });
  
  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['token'],
      userId: json['userId'],
      role: json['role'],
    );
  }
}

class MerchantRegisterRequest {
  final String email;
  final String password;
  final String fullName;
  final String? telephone;
  final String nomCommerce;
  final String numeroRc;
  final String? adresse;
  final String? typeCommerce;
  final String? description;
  final String? heureOuverture;
  final String? heureFermeture;
  
  MerchantRegisterRequest({
    required this.email,
    required this.password,
    required this.fullName,
    this.telephone,
    required this.nomCommerce,
    required this.numeroRc,
    this.adresse,
    this.typeCommerce,
    this.description,
    this.heureOuverture,
    this.heureFermeture,
  });
}

class MerchantRegisterResponse {
  final String id;
  final String email;
  final String? documentId;
  final String? documentStatus;
  final bool requiresVerification;
  final bool requiresAdminValidation;
  
  MerchantRegisterResponse({
    required this.id,
    required this.email,
    this.documentId,
    this.documentStatus,
    required this.requiresVerification,
    required this.requiresAdminValidation,
  });
  
  factory MerchantRegisterResponse.fromJson(Map<String, dynamic> json) {
    return MerchantRegisterResponse(
      id: json['id'],
      email: json['email'],
      documentId: json['documentId'],
      documentStatus: json['documentStatus'],
      requiresVerification: json['requiresVerification'] ?? false,
      requiresAdminValidation: json['requiresAdminValidation'] ?? false,
    );
  }
}