import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:peeco/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config_clean.dart';

class ApiService {
  static const String _tokenKey = 'peeco_jwt_token';

  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    print('🔑 Token: ${token != null ? "✓ Présent" : "✗ Absent"}');
    return token;
  }

  static Future<Map<String, String>> _getHeaders({
    bool includeAuth = true,
  }) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (includeAuth) {
      final token = await _getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  static dynamic _handleResponse(http.Response response) {
    print('🔵 Status: ${response.statusCode}');
    print('🔵 Body: ${response.body}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return {'message': 'Success'};
      return json.decode(response.body);
    } else {
      final errorBody = response.body.isNotEmpty
          ? json.decode(response.body)
          : {'message': 'Request failed'};
      throw Exception(
        errorBody['message'] ?? 'API Error: ${response.statusCode}',
      );
    }
  }

  // ==================== AUTHENTICATION ====================

  static Future<Map<String, dynamic>> registerMerchant({
    required String fullName,
    required String email,
    required String password,
    String? telephone,
    required String nomCommerce,
    String? typeCommerce,
    String? adresse,
    String? description,
    required String numeroRc,
    required String siret,
    required String cinPasseportUrl,
    required String extraitRcUrl,
    String? brochureUrl,
  }) async {
    final headers = await _getHeaders(includeAuth: false);
    final body = {
      'fullName': fullName,
      'email': email,
      'password': password,
      'nomCommerce': nomCommerce,
      'numeroRc': numeroRc,
      'siret': siret,
      'cinPasseportUrl': cinPasseportUrl,
      'extraitRcUrl': extraitRcUrl,
    };
    if (telephone != null) body['telephone'] = telephone;
    if (typeCommerce != null) body['typeCommerce'] = typeCommerce;
    if (adresse != null) body['adresse'] = adresse;
    if (description != null) body['description'] = description;
    if (brochureUrl != null) body['brochureUrl'] = brochureUrl;

    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.registerMerchant}'),
      headers: headers,
      body: json.encode(body),
    );
    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> verifyEmail({
    required String email,
    required String verificationCode,
  }) async {
    final headers = await _getHeaders(includeAuth: false);
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.verifyEmail}'),
      headers: headers,
      body: json.encode({'email': email, 'verificationCode': verificationCode}),
    );
    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final headers = await _getHeaders(includeAuth: false);
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.login}'),
      headers: headers,
      body: json.encode({'email': email, 'password': password}),
    );
    final result = _handleResponse(response);
    if (result['token'] != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, result['token']);
      print('✅ Token stocké');
    }
    return result;
  }

  static Future<Map<String, dynamic>> getCurrentUser() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.me}'),
      headers: headers,
    );
    return _handleResponse(response);
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    print('🔓 Token supprimé');
  }

  // ==================== DOCUMENTS ====================

  static Future<String?> uploadCinFile(File file) async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('No authentication token');
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.uploadCin}'),
      );
      request.headers['Authorization'] = 'Bearer $token';
      request.files.add(await http.MultipartFile.fromPath('file', file.path));
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = json.decode(responseBody);
        return data['url'] ?? data['fileUrl'] ?? data['data'];
      }
      return null;
    } catch (e) {
      print('❌ Upload CIN error: $e');
      return null;
    }
  }

  static Future<String?> uploadRcFile(File file) async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('No authentication token');
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.uploadRc}'),
      );
      request.headers['Authorization'] = 'Bearer $token';
      request.files.add(await http.MultipartFile.fromPath('file', file.path));
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = json.decode(responseBody);
        return data['url'] ?? data['fileUrl'] ?? data['data'];
      }
      return null;
    } catch (e) {
      print('❌ Upload RC error: $e');
      return null;
    }
  }

  static Future<String?> uploadBrochureFile(File file) async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('No authentication token');
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.uploadBrochure}'),
      );
      request.headers['Authorization'] = 'Bearer $token';
      request.files.add(await http.MultipartFile.fromPath('file', file.path));
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = json.decode(responseBody);
        return data['url'] ?? data['fileUrl'] ?? data['data'];
      }
      return null;
    } catch (e) {
      print('❌ Upload Brochure error: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>> getMerchantDocuments() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.getMerchantDocuments}'),
      headers: headers,
    );
    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> updateMerchantDocument({
    required String documentId,
    required String documentType,
    required File file,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('No authentication token');
      final request = http.MultipartRequest(
        'PUT',
        Uri.parse(
          '${ApiConfig.baseUrl}${ApiConfig.updateMerchantDocument}/$documentId',
        ),
      );
      request.headers['Authorization'] = 'Bearer $token';
      request.fields['documentType'] = documentType;
      request.files.add(await http.MultipartFile.fromPath('file', file.path));
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return json.decode(responseBody);
      }
      throw Exception('Failed to update document');
    } catch (e) {
      throw Exception('Update document error: $e');
    }
  }

  static Future<Map<String, dynamic>> deleteMerchantDocument(
    String documentId,
  ) async {
    final headers = await _getHeaders();
    final response = await http.delete(
      Uri.parse(
        '${ApiConfig.baseUrl}${ApiConfig.deleteMerchantDocument}/$documentId',
      ),
      headers: headers,
    );
    return _handleResponse(response);
  }

  // ==================== OFFRES ====================

  static Future<Map<String, dynamic>> createOffer({
    required String titre,
    String? description,
    String? typeNourriture,
    required double prixOriginal,
    required double prixReduit,
    required int quantiteDisponible,
    required String heureDebutRetrait,
    required String heureFinRetrait,
    String? dateExpiration,
    String? allergenes,
    String? preferencesAlim,
  }) async {
    final headers = await _getHeaders();
    final body = {
      'titre': titre,
      'prixOriginal': prixOriginal,
      'prixReduit': prixReduit,
      'quantiteDisponible': quantiteDisponible,
      'heureDebutRetrait': heureDebutRetrait,
      'heureFinRetrait': heureFinRetrait,
    };
    if (description != null) body['description'] = description;
    if (typeNourriture != null) body['typeNourriture'] = typeNourriture;
    if (dateExpiration != null) body['dateExpiration'] = dateExpiration;
    if (allergenes != null) body['allergenes'] = allergenes;
    if (preferencesAlim != null) body['preferencesAlim'] = preferencesAlim;

    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.createOffer}'),
      headers: headers,
      body: json.encode(body),
    );
    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> getMyOffers({
    int page = 0,
    int size = 10,
    String? statut,
  }) async {
    final headers = await _getHeaders();
    // PUBLIEE par défaut selon contrat
    final String statutParam = statut ?? 'PUBLIEE';
    final String queryParams = '?page=$page&size=$size&statut=$statutParam';
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.getMyOffers}$queryParams'),
      headers: headers,
    );
    return _handleResponse(response);
  }

  static Future<void> uploadOfferImages({
    required String offerId,
    required List<File> photos,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('No authentication token');
      for (final photo in photos) {
        final request = http.MultipartRequest(
          'POST',
          // ✅ /{id}/images ajouté dynamiquement
          Uri.parse(
            '${ApiConfig.baseUrl}${ApiConfig.offerImages}/$offerId/images',
          ),
        );
        request.headers['Authorization'] = 'Bearer $token';
        request.files.add(
          await http.MultipartFile.fromPath('file', photo.path),
        );
        final response = await request.send();
        final responseBody = await response.stream.bytesToString();
        print('🖼️ Upload image: ${response.statusCode} - $responseBody');
      }
    } catch (e) {
      throw Exception('Upload images error: $e');
    }
  }

  static Future<Map<String, dynamic>> updateOffer({
    required String offerId,
    String? titre,
    String? description,
    String? typeNourriture,
    double? prixOriginal,
    double? prixReduit,
    int? quantiteDisponible,
    String? heureDebutRetrait,
    String? heureFinRetrait,
    String? dateExpiration,
    String? allergenes,
    String? preferencesAlim,
  }) async {
    final headers = await _getHeaders();
    final body = <String, dynamic>{};
    if (titre != null) body['titre'] = titre;
    if (description != null) body['description'] = description;
    if (typeNourriture != null) body['typeNourriture'] = typeNourriture;
    if (prixOriginal != null) body['prixOriginal'] = prixOriginal;
    if (prixReduit != null) body['prixReduit'] = prixReduit;
    if (quantiteDisponible != null)
      body['quantiteDisponible'] = quantiteDisponible;
    if (heureDebutRetrait != null)
      body['heureDebutRetrait'] = heureDebutRetrait;
    if (heureFinRetrait != null) body['heureFinRetrait'] = heureFinRetrait;
    if (dateExpiration != null) body['dateExpiration'] = dateExpiration;
    if (allergenes != null) body['allergenes'] = allergenes;
    if (preferencesAlim != null) body['preferencesAlim'] = preferencesAlim;

    final response = await http.put(
      // ✅ /{id} ajouté dynamiquement
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.updateOffer}/$offerId'),
      headers: headers,
      body: json.encode(body),
    );
    return _handleResponse(response);
  }
  //===================================
  /*
  static Future<Map<String, dynamic>> updateOffer(
    String offerId, {
    required String titre,
    String? description,
    required double prixOriginal,
    required double prixReduit,
    required int quantiteDisponible,
    required String heureDebutRetrait,
    required String heureFinRetrait,
    required String dateExpiration,
    String? preferencesAlim,
    String? typeNourriture,
    String? allergenes,
  }) async {
    final token = await AuthService().getToken();

    final body = {
      'titre': titre,
      'description': description ?? '',
      'prixOriginal': prixOriginal,
      'prixReduit': prixReduit,
      'quantiteDisponible': quantiteDisponible,
      'heureDebutRetrait': heureDebutRetrait,
      'heureFinRetrait': heureFinRetrait,
      'dateExpiration': dateExpiration,
      'preferencesAlim': preferencesAlim ?? '',
      'typeNourriture': typeNourriture ?? '',
      'allergenes': allergenes ?? '',
    };

    final response = await http.put(
      Uri.parse('${ApiConfig.baseUrl}/offres/$offerId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Erreur lors de la mise à jour: ${response.statusCode}');
    }
  }*/

  static Future<Map<String, dynamic>> deleteOffer(String offerId) async {
    final headers = await _getHeaders();
    final response = await http.delete(
      //  /{id} ajouté dynamiquement
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.deleteOffer}/$offerId'),
      headers: headers,
    );
    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> archiveOffer(String offerId) async {
    final headers = await _getHeaders();
    final response = await http.patch(
      //  /{id}/archiver ajouté dynamiquement
      Uri.parse(
        '${ApiConfig.baseUrl}${ApiConfig.archiveOffer}/$offerId/archiver',
      ),
      headers: headers,
    );
    return _handleResponse(response);
  }

  // ==================== RÉSERVATIONS ====================

  static Future<Map<String, dynamic>> getMyOrders({
    int page = 0,
    int size = 10,
    String? statut,
  }) async {
    final headers = await _getHeaders();
    String queryParams = '?page=$page&size=$size';
    if (statut != null) queryParams += '&statut=$statut';

    final response = await http.get(
      //  Corrigé — /api/reservations/mes-offres selon contrat
      Uri.parse(
        '${ApiConfig.baseUrl}${ApiConfig.getMyReservations}$queryParams',
      ),
      headers: headers,
    );
    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> confirmReservation(
    String reservationId,
  ) async {
    final headers = await _getHeaders();
    final response = await http.patch(
      //  /{id}/confirmer ajouté dynamiquement
      Uri.parse(
        '${ApiConfig.baseUrl}${ApiConfig.confirmReservation}/$reservationId/confirmer',
      ),
      headers: headers,
    );
    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> validatePickup({
    required String reservationId,
    required String pickupCode,
  }) async {
    final headers = await _getHeaders();
    final response = await http.patch(
      //  /{id}/recuperer ajouté dynamiquement
      Uri.parse(
        '${ApiConfig.baseUrl}${ApiConfig.validatePickup}/$reservationId/recuperer',
      ),
      headers: headers,
      body: json.encode({'pickupCode': pickupCode}),
    );
    return _handleResponse(response);
  }

  // ==================== STATISTIQUES ====================

  static Future<Map<String, dynamic>> getMerchantStatistics() async {
    final headers = await _getHeaders();
    final response = await http.get(
      //  Corrigé — /api/statistiques/commercant selon contrat
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.merchantStats}'),
      headers: headers,
    );
    return _handleResponse(response);
  }

  // ==================== AVIS ====================

  static Future<Map<String, dynamic>> getMerchantReviews({
    required String merchantId,
    int page = 0,
    int size = 10,
  }) async {
    final headers = await _getHeaders(includeAuth: false);
    final String queryParams = '?page=$page&size=$size';
    // Corrigé — /api/commercants/{id}/reviews selon contrat
    final url =
        '${ApiConfig.baseUrl}${ApiConfig.getMerchantReviews}/$merchantId/reviews$queryParams';
    final response = await http.get(Uri.parse(url), headers: headers);
    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> createReview({
    required String orderId,
    required int note,
    String? commentaire,
  }) async {
    final headers = await _getHeaders();
    final body = <String, dynamic>{'orderId': orderId, 'note': note};
    if (commentaire != null) body['commentaire'] = commentaire;
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.createReview}'),
      headers: headers,
      body: json.encode(body),
    );
    return _handleResponse(response);
  }

  // ==================== NOTIFICATIONS ====================

  static Future<Map<String, dynamic>> getNotifications({
    int page = 0,
    int size = 20,
  }) async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse(
        '${ApiConfig.baseUrl}${ApiConfig.getNotifications}?page=$page&size=$size',
      ),
      headers: headers,
    );
    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> getNotificationBadge() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.notificationBadge}'),
      headers: headers,
    );
    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> markNotificationRead(
    String notifId,
  ) async {
    final headers = await _getHeaders();
    final response = await http.patch(
      Uri.parse(
        '${ApiConfig.baseUrl}${ApiConfig.markNotificationRead}/$notifId/lue',
      ),
      headers: headers,
    );
    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> markAllNotificationsRead() async {
    final headers = await _getHeaders();
    final response = await http.patch(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.markAllRead}'),
      headers: headers,
    );
    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> getNotificationPreferences() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.notificationPreferences}'),
      headers: headers,
    );
    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> updateNotificationPreferences(
    Map<String, dynamic> preferences,
  ) async {
    final headers = await _getHeaders();
    final response = await http.put(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.notificationPreferences}'),
      headers: headers,
      body: json.encode(preferences),
    );
    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> registerFcmToken(String token) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.fcmToken}'),
      headers: headers,
      body: json.encode({'token': token}),
    );
    return _handleResponse(response);
  }

  // ==================== PROFIL ====================

  static Future<Map<String, dynamic>> getCurrentProfile() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.me}'),
      headers: headers,
    );
    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> updateProfile({
    required String fullName,
    required String email,
    String? telephone,
    String? nomCommerce,
    String? typeCommerce,
    String? adresse,
    String? description,
    String? numeroRc,
    String? siret,
    String? wilaya,
    String? commune,
  }) async {
    final headers = await _getHeaders();
    final body = <String, dynamic>{'fullName': fullName, 'email': email};
    if (nomCommerce != null) body['nomCommerce'] = nomCommerce;
    if (telephone != null) body['telephone'] = telephone;
    if (typeCommerce != null) body['typeCommerce'] = typeCommerce;
    if (adresse != null) body['adresse'] = adresse;
    if (description != null) body['description'] = description;
    if (numeroRc != null) body['numeroRc'] = numeroRc;
    if (siret != null) body['siret'] = siret;
    if (wilaya != null) body['wilaya'] = wilaya;
    if (commune != null) body['commune'] = commune;

    final response = await http.put(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.updateProfile}'),
      headers: headers,
      body: json.encode(body),
    );
    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> uploadProfilePhoto(File imageFile) async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('No authentication token');
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.profilePhoto}'),
      );
      request.headers['Authorization'] = 'Bearer $token';
      request.files.add(
        await http.MultipartFile.fromPath('file', imageFile.path),
      );
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return json.decode(responseBody);
      }
      throw Exception('Failed to upload profile photo');
    } catch (e) {
      throw Exception('Profile photo upload error: $e');
    }
  }

  static Future<Map<String, dynamic>> updateProfileImage(File imageFile) async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('No authentication token');
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.profileImage}'),
      );
      request.headers['Authorization'] = 'Bearer $token';
      request.files.add(
        await http.MultipartFile.fromPath('image', imageFile.path),
      );
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return json.decode(responseBody);
      }
      throw Exception('Failed to upload profile image');
    } catch (e) {
      throw Exception('Profile image upload error: $e');
    }
  }
}
