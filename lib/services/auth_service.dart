import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../config/api_config.dart';
import '../models/auth_models.dart';

class AuthService {
  static const String _tokenKey = 'peeco_jwt_token';
  static const String _userIdKey = 'user_id';
  static const String _userRoleKey = 'user_role';
  static const String _userEmailKey = 'user_email';
  
  
  Future<String?> uploadCinFile(File file) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.uploadCin}'),
      );
      
      request.files.add(await http.MultipartFile.fromPath('file', file.path));
      
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      
      print('    Upload CIN response: ${response.statusCode}');
      print('    Upload CIN body: $responseBody');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(responseBody);
        return data['url'] ?? data['fileUrl'] ?? data['data'];
      }
      return null;
    } catch (e) {
      print('  Upload CIN error: $e');
      return null;
    }
  }
  
  Future<String?> uploadRcFile(File file) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.uploadRc}'),
      );
      
      request.files.add(await http.MultipartFile.fromPath('file', file.path));
      
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      
      print('    Upload RC response: ${response.statusCode}');
      print('    Upload RC body: $responseBody');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(responseBody);
        return data['url'] ?? data['fileUrl'] ?? data['data'];
      }
      return null;
    } catch (e) {
      print('  Upload RC error: $e');
      return null;
    }
  }
  
  
  Future<Map<String, dynamic>?> register(RegisterRequest request) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.register}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(request.toJson()),
      );
      
      print('   Register response: ${response.statusCode}');
      print('   Register body: ${response.body}');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data;
      }
      
      final errorData = jsonDecode(response.body);
      final backendMessage = errorData['message'] ?? '';
      String frenchMessage;
      if (backendMessage.toLowerCase().contains('email already used') ||
          backendMessage.toLowerCase().contains('email already exists')) {
        frenchMessage = 'Cet email est déjà utilisé';
      } else if (backendMessage.toLowerCase().contains('required')) {
        frenchMessage = 'Veuillez remplir tous les champs obligatoires';
      } else {
        frenchMessage = backendMessage.isNotEmpty ? backendMessage : 'Erreur lors de l\'inscription';
      }
      throw ApiException(
        message: frenchMessage,
        statusCode: response.statusCode,
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      print('  Register error: $e');
      throw ApiException(message: 'Erreur réseau. Vérifiez votre connexion.');
    }
  }
  
  Future<MerchantRegisterResponse?> registerMerchantWithFiles({
    required MerchantRegisterRequest request,
    required File cinPasseport,
    required File extraitRc,
    File? brochure,
  }) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.registerMerchant}');
      final multipartRequest = http.MultipartRequest('POST', uri);
      
      multipartRequest.fields['email'] = request.email;
      multipartRequest.fields['password'] = request.password;
      multipartRequest.fields['fullName'] = request.fullName;
      multipartRequest.fields['nomCommerce'] = request.nomCommerce;
      multipartRequest.fields['numeroRc'] = request.numeroRc;
      if (request.telephone != null) {
        multipartRequest.fields['telephone'] = request.telephone!;
      }
      if (request.adresse != null) {
        multipartRequest.fields['adresse'] = request.adresse!;
      }
      if (request.typeCommerce != null) {
        multipartRequest.fields['typeCommerce'] = request.typeCommerce!;
      }
      if (request.description != null) {
        multipartRequest.fields['description'] = request.description!;
      }
      if (request.heureOuverture != null) {
        multipartRequest.fields['heureOuverture'] = request.heureOuverture!;
      }
      if (request.heureFermeture != null) {
        multipartRequest.fields['heureFermeture'] = request.heureFermeture!;
      }
      
      multipartRequest.files.add(
        await http.MultipartFile.fromPath('cinPasseport', cinPasseport.path),
      );
      multipartRequest.files.add(
        await http.MultipartFile.fromPath('extraitRc', extraitRc.path),
      );
      if (brochure != null) {
        multipartRequest.files.add(
          await http.MultipartFile.fromPath('brochure', brochure.path),
        );
      }
      
      
      final response = await multipartRequest.send();
      final responseBody = await response.stream.bytesToString();
      
      print('   Register Merchant response: ${response.statusCode}');
      print('   Register Merchant body: $responseBody');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(responseBody);
        return MerchantRegisterResponse.fromJson(data);
      }
      
      final errorData = jsonDecode(responseBody);
      throw ApiException(
        message: errorData['message'] ?? 'Erreur lors de l\'inscription commerçant',
        statusCode: response.statusCode,
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      print('  Register merchant error: $e');
      throw ApiException(message: 'Erreur réseau. Vérifiez votre connexion.');
    }
  }
  
  
  Future<Map<String, dynamic>?> verifyEmail(String email, String code) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.verifyEmail}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'verificationCode': code,
        }),
      );
      
      print('   Verify email response: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      
      final errorData = jsonDecode(response.body);
      final backendMessage = errorData['message'] ?? '';
      String frenchMessage;
      if (backendMessage.toLowerCase().contains('email already verified')) {
        frenchMessage = 'Cet email est déjà vérifié';
      } else if (backendMessage.toLowerCase().contains('invalid verification code')) {
        frenchMessage = 'Code de vérification invalide';
      } else if (backendMessage.toLowerCase().contains('verification code expired')) {
        frenchMessage = 'Code de vérification expiré';
      } else if (backendMessage.toLowerCase().contains('user not found')) {
        frenchMessage = 'Utilisateur non trouvé';
      } else {
        frenchMessage = backendMessage.isNotEmpty ? backendMessage : 'Code de vérification invalide';
      }
      throw ApiException(
        message: frenchMessage,
        statusCode: response.statusCode,
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: 'Erreur lors de la vérification');
    }
  }
  
  Future<void> resendVerificationCode(String email) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.resendVerification}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );
      
      print('   Resend verification response: ${response.statusCode}');
      
      if (response.statusCode != 200) {
        final errorData = jsonDecode(response.body);
        throw ApiException(
          message: errorData['message'] ?? 'Erreur lors de l\'envoi du code',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: 'Erreur réseau');
    }
  }
  
  
  Future<Map<String, dynamic>?> forgotPassword(String email) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.forgotPassword}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );
      
      print('   Forgot password response: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      
      final errorData = jsonDecode(response.body);
      final backendMessage = errorData['message'] ?? '';
      String frenchMessage;
      if (backendMessage.toLowerCase().contains('email is required')) {
        frenchMessage = 'Veuillez saisir votre email';
      } else {
        frenchMessage = backendMessage.isNotEmpty ? backendMessage : 'Erreur lors de l\'envoi';
      }
      throw ApiException(
        message: frenchMessage,
        statusCode: response.statusCode,
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: 'Erreur réseau. Vérifiez votre connexion.');
    }
  }
  
  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.resetPassword}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'code': code,
          'newPassword': newPassword,
        }),
      );
      
      print('   Reset password response: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        return;
      }
      
      final errorData = jsonDecode(response.body);
      final backendMessage = errorData['message'] ?? '';
      String frenchMessage;
      if (backendMessage.toLowerCase().contains('invalid or expired code')) {
        frenchMessage = 'Code invalide ou expiré';
      } else if (backendMessage.toLowerCase().contains('user not found')) {
        frenchMessage = 'Utilisateur non trouvé';
      } else if (backendMessage.toLowerCase().contains('required')) {
        frenchMessage = 'Veuillez remplir tous les champs';
      } else {
        frenchMessage = backendMessage.isNotEmpty ? backendMessage : 'Erreur lors du changement de mot de passe';
      }
      throw ApiException(
        message: frenchMessage,
        statusCode: response.statusCode,
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: 'Erreur réseau. Vérifiez votre connexion.');
    }
  }
  
  
  Future<LoginResponse> login(LoginRequest request) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.login}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(request.toJson()),
      );
      
      print('   Login response: ${response.statusCode}');
      print('   Login body: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final loginResponse = LoginResponse.fromJson(data);
        
        await _saveAuthData(
          token: loginResponse.token,
          userId: loginResponse.userId,
          role: loginResponse.role,
          email: request.email,
        );
        
        return loginResponse;
      }
      
      final errorData = jsonDecode(response.body);
      final backendMessage = errorData['message'] ?? '';
      String frenchMessage;
      if (backendMessage.toLowerCase().contains('email not verified')) {
        frenchMessage = 'Email non vérifié. Veuillez vérifier votre email.';
      } else if (backendMessage.toLowerCase().contains('invalid credentials')) {
        frenchMessage = 'Email ou mot de passe incorrect';
      } else if (backendMessage.toLowerCase().contains('identifier and password are required')) {
        frenchMessage = 'Veuillez saisir votre email et mot de passe';
      } else {
        frenchMessage = backendMessage.isNotEmpty ? backendMessage : 'Email ou mot de passe incorrect';
      }
      throw ApiException(
        message: frenchMessage,
        statusCode: response.statusCode,
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: 'Erreur réseau. Vérifiez votre connexion.');
    }
  }
  
  
  Future<Map<String, dynamic>> getProfile() async {
    final token = await getToken();
    if (token == null) {
      throw ApiException(message: 'Non authentifié', statusCode: 401);
    }
    
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.me}'),
        headers: await getAuthHeaders(),
      );
      
      print('   Get profile response: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 401) {
        await logout();
        throw ApiException(message: 'Session expirée. Veuillez vous reconnecter.', statusCode: 401);
      } else if (response.statusCode == 403) {
        final data = jsonDecode(response.body);
        if (data['requiresVerification'] == true) {
          throw ApiException(
            message: 'Veuillez vérifier votre email',
            statusCode: 403,
            requiresVerification: true,
          );
        }
        throw ApiException(message: 'Accès non autorisé', statusCode: 403);
      }
      
      throw ApiException(message: 'Erreur lors du chargement du profil');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: 'Erreur réseau');
    }
  }
  
  Future<bool> uploadProfileImage(String imagePath) async {
    final token = await getToken();
    if (token == null) return false;
    
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.profileImage}'),
      );
      
      request.headers['Authorization'] = 'Bearer $token';
      request.files.add(await http.MultipartFile.fromPath('image', imagePath));
      
      final response = await request.send();
      print('   Upload profile image response: ${response.statusCode}');
      
      return response.statusCode == 200;
    } catch (e) {
      print('  Upload error: $e');
      return false;
    }
  }
  
  
  Future<LoginResponse> signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
      );
      
      await googleSignIn.signOut();
      
      final GoogleSignInAccount? account = await googleSignIn.signIn();
      
      if (account == null) {
        throw ApiException(message: 'Connexion Google annulée');
      }
      
      final GoogleSignInAuthentication auth = await account.authentication;
      final String? idToken = auth.idToken;
      
      if (idToken == null) {
        throw ApiException(message: 'Erreur d\'authentification Google');
      }
      
      print('  Google Sign-In: ${account.email}');
      
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/auth/google'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'idToken': idToken,
          'email': account.email,
          'fullName': account.displayName ?? '',
          'photoUrl': account.photoUrl,
          'role': 'CLIENT',
        }),
      );
      
      print('   Google auth response: ${response.statusCode}');
      print('   Google auth body: ${response.body}');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final loginResponse = LoginResponse.fromJson(data);
        
        await _saveAuthData(
          token: loginResponse.token,
          userId: loginResponse.userId,
          role: loginResponse.role,
          email: account.email,
        );
        
        return loginResponse;
      }
      
      final errorData = jsonDecode(response.body);
      final backendMessage = errorData['message'] ?? '';
      String frenchMessage;
      if (backendMessage.toLowerCase().contains('email already used')) {
        frenchMessage = 'Cet email est déjà utilisé avec une autre méthode';
      } else if (backendMessage.toLowerCase().contains('invalid token')) {
        frenchMessage = 'Token Google invalide';
      } else {
        frenchMessage = backendMessage.isNotEmpty ? backendMessage : 'Erreur lors de l\'authentification Google';
      }
      throw ApiException(
        message: frenchMessage,
        statusCode: response.statusCode,
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      print('  Google Sign-In error: $e');
      throw ApiException(message: 'Erreur lors de la connexion avec Google');
    }
  }
  
  
  Future<void> _saveAuthData({
    required String token,
    required String userId,
    required String role,
    required String email,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_userIdKey, userId);
    await prefs.setString(_userRoleKey, role);
    await prefs.setString(_userEmailKey, email);
  }
  
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }
  
  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }
  
  Future<String?> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userRoleKey);
  }
  
  Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userEmailKey);
  }
  
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
  
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_userRoleKey);
    await prefs.remove(_userEmailKey);
  }
  
  Future<Map<String, String>> getAuthHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }
}

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final bool requiresVerification;
  
  ApiException({
    required this.message,
    this.statusCode,
    this.requiresVerification = false,
  });
  
  @override
  String toString() => message;
}