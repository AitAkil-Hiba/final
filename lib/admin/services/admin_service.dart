import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config/api_config.dart';
import '../../services/auth_service.dart';
import '../models/signalement_model.dart';
import '../models/merchant_model.dart';
import '../models/client_model.dart';

class AdminService {
  final AuthService _authService = AuthService();
  
  Future<Map<String, String>> _getHeaders() async {
    final token = await _authService.getToken();
    print('   Auth token: ${token?.isNotEmpty == true ? "Present" : "Missing/Empty"}');
    
    if (token?.isEmpty == true) {
      print('  No auth token available');
    }
    
    final headers = {
      'Authorization': 'Bearer ${token ?? ""}',
      'Content-Type': 'application/json',
      ApiConfig.ngrokHeader: ApiConfig.ngrokHeaderValue,
    };
    
    print('    Request headers: ${headers.keys.toList()}');
    return headers;
  }
  
  // ==================== SIGNALEMENTS ====================
  
  Future<SignalementsResponse> getSignalements({String? statut, String? targetType, int page = 0, int size = 50}) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'size': size.toString(),
      };
      if (statut != null) {
        queryParams['statut'] = statut;
      }
      if (targetType != null) {
        queryParams['targetType'] = targetType;
      }
      
      final uri = Uri.parse(ApiConfig.getFullUrl(ApiConfig.adminSignalements))
          .replace(queryParameters: queryParams);
      
      print('     Signalements URL: $uri');
      print('     Query params: $queryParams');
      
      final response = await http.get(uri, headers: await _getHeaders());
      
      print('   GET Signalements: ${response.statusCode}');
      print(' Response size: ${response.body.length} characters');
      
      if (response.body.length > 2000000) {
        throw Exception('Réponse trop volumineuse (${response.body.length} caractères). Veuillez utiliser des filtres ou réduire la taille de la page.');
      }
      
      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(response.body);
          print('     Signalements response type: ${data.runtimeType}');
          
          final signalementsResponse = SignalementsResponse.fromJson(data);
          
          if (signalementsResponse.pagination != null) {
            final pagination = signalementsResponse.pagination!;
            print(' Pagination: page ${pagination.page}/${pagination.totalPages}, '
                  'size ${pagination.size}, total ${pagination.totalElements} elements');
          }
          
          print('     Found ${signalementsResponse.content.length} signalements');
          return signalementsResponse;
        } catch (jsonError) {
          print('  JSON parsing error: $jsonError');
          print('  Response body preview: ${response.body.length > 500 ? response.body.substring(0, 500) + "..." : response.body}');
          throw Exception('Réponse serveur invalide: JSON malformé. Veuillez contacter l\'administrateur système.');
        }
      } else if (response.statusCode == 401) {
        print('     Signalements response body: ${response.body}');
        throw Exception('Erreur d\'authentification (401): Token invalide ou expiré');
      } else {
        print('  Error response body: ${response.body}');
        throw Exception('Erreur lors du chargement des signalements: ${response.statusCode}');
      }
    } catch (e) {
      print('  Get signalements error: $e');
      rethrow;
    }
  }
  
  Future<void> treatSignalement(String signalementId) async {
    try {
      final url = '${ApiConfig.getFullUrl(ApiConfig.adminSignalements)}/$signalementId/traiter';
      final response = await http.patch(
        Uri.parse(url),
        headers: await _getHeaders(),
      );
      
      print('   Treat signalement: ${response.statusCode}');
      print('     Treat signalement response body: ${response.body}');
      
      if (response.statusCode == 200) {
        print('  Signalement treated successfully');
      } else if (response.statusCode == 401) {
        throw Exception('Erreur d\'authentification (401): Token invalide ou expiré');
      } else if (response.statusCode == 404) {
        throw Exception('Signalement non trouvé (ID: $signalementId)');
      } else {
        throw Exception('Erreur lors du traitement du signalement: ${response.statusCode}');
      }
    } catch (e) {
      print('  Treat signalement error: $e');
      rethrow;
    }
  }
  
  Future<void> deleteSignalement(String signalementId) async {
    try {
      final url = '${ApiConfig.getFullUrl(ApiConfig.adminSignalements)}/$signalementId';
      final response = await http.delete(
        Uri.parse(url),
        headers: await _getHeaders(),
      );
      
      print('   DELETE Signalement: ${response.statusCode}');
      print('     DELETE signalement response body: ${response.body}');
      
      if (response.statusCode == 200) {
        print('  Signalement deleted successfully');
      } else if (response.statusCode == 401) {
        throw Exception('Erreur d\'authentification (401): Token invalide ou expiré');
      } else if (response.statusCode == 404) {
        throw Exception('Signalement non trouvé (ID: $signalementId)');
      } else {
        throw Exception('Erreur lors de la suppression: ${response.statusCode}');
      }
    } catch (e) {
      print('  Delete signalement error: $e');
      rethrow;
    }
  }
  
  Future<Map<String, dynamic>> deleteSignalementWithOffer(String signalementId) async {
    try {
      final url = '${ApiConfig.getFullUrl(ApiConfig.adminSignalements)}/$signalementId/with-offre';
      final response = await http.delete(
        Uri.parse(url),
        headers: await _getHeaders(),
      );
      
      print('   DELETE Signalement with Offer: ${response.statusCode}');
      print('     DELETE with offer response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('  Signalement and offer deleted successfully');
        print('     Response data: $data');
        
        return data;
      } else if (response.statusCode == 401) {
        throw Exception('Erreur d\'authentification (401): Token invalide ou expiré');
      } else if (response.statusCode == 404) {
        throw Exception('Signalement non trouvé (ID: $signalementId)');
      } else {
        throw Exception('Erreur lors de la suppression avec offre: ${response.statusCode}');
      }
    } catch (e) {
      print('  Delete signalement with offer error: $e');
      rethrow;
    }
  }
  
  // ==================== COMMERCANTS ====================
  
  Future<List<MerchantAPI>> getMerchants({String? statut}) async {
    try {
      final queryParams = <String, String>{};
      if (statut != null) {
        switch (statut) {
          case 'Validés':
            queryParams['statut'] = 'VALIDE';
            break;
          case 'En attente':
            queryParams['statut'] = 'EN_ATTENTE';
            break;
          case 'Suspendus':
           
            break;
          default:
            break;
        }
      }
      
      final uri = Uri.parse(ApiConfig.getFullUrl(ApiConfig.adminMerchants))
          .replace(queryParameters: queryParams);
      
      print('   GET Merchants: $uri');
      
      final response = await http.get(uri, headers: await _getHeaders());
      
      print('   GET Merchants: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('     Merchants response type: ${data.runtimeType}');
        
        List merchantsList;
        if (data is List) {
          merchantsList = data;
        } else if (data is Map && data['data'] != null) {
          merchantsList = data['data'] as List;
        } else {
          throw Exception('Format de réponse invalide pour les commerçants');
        }
        
        print('     Found ${merchantsList.length} merchants');
        for (var merchant in merchantsList) {
          print('     Merchant: ${merchant['nomCommerce']} - statutValidation: ${merchant['statutValidation']}, actif: ${merchant['actif']}');
        }
        return merchantsList.map((item) => MerchantAPI.fromJson(item)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Erreur d\'authentification (401): Token invalide ou expiré');
      } else if (response.statusCode == 403) {
        throw Exception('Accès refusé (403): Permissions insuffisantes');
      } else if (response.statusCode == 500) {
        print('     Response body: ${response.body}');
        throw Exception('Erreur serveur (500): Le backend a rencontré une erreur');
      } else {
        print('     Response body: ${response.body}');
        throw Exception('Erreur lors du chargement des commerçants: ${response.statusCode}');
      }
    } catch (e) {
      print('  Get merchants error: $e');
      rethrow;
    }
  }
  
  Future<MerchantAPI> getMerchantById(String merchantId) async {
    try {
      final url = '${ApiConfig.getFullUrl(ApiConfig.adminMerchants)}/$merchantId';
      final response = await http.get(
        Uri.parse(url),
        headers: await _getHeaders(),
      );
      
      print(' GET Merchant by ID: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return MerchantAPI.fromJson(data);
      } else if (response.statusCode == 404) {
        throw Exception('Commerçant non trouvé (ID: $merchantId)');
      } else if (response.statusCode == 401) {
        throw Exception('Erreur d\'authentification - Token invalide ou expiré');
      } else if (response.statusCode == 403) {
        throw Exception('Accès refusé - Permissions insuffisantes');
      } else {
        print(' Response body: ${response.body}');
        throw Exception('Erreur lors de la récupération du commerçant: ${response.statusCode}');
      }
    } catch (e) {
      print(' Get merchant by ID error: $e');
      rethrow;
    }
  }
  
  Future<void> validateMerchant(String merchantId, {required String cinExpirationDate}) async {
    try {
      final url = '${ApiConfig.getFullUrl(ApiConfig.adminMerchants)}/$merchantId/validate';
      
      final requestBody = {
        'cinExpirationDate': cinExpirationDate,
        'dateExpiration': cinExpirationDate,
        'rcExpirationDate': cinExpirationDate,
        'expirationDate': cinExpirationDate,
      };
      
      print(' VALIDATE MERCHANT DEBUG ');
      print(' Validate merchant URL: $url');
      print(' Request body: $requestBody');
      print(' cinExpirationDate being sent: "$cinExpirationDate"');
      print(' JSON encoded body: ${jsonEncode(requestBody)}');
      print(' END DEBUG INFO ');
      
      final response = await http.put(
        Uri.parse(url),
        headers: await _getHeaders(),
        body: jsonEncode(requestBody),
      );
      
      print(' Validate merchant: ${response.statusCode}');
      print(' Validate merchant response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print(' Validate merchant parsed response: $data');
        if (data['success'] != true) {
          throw Exception('Échec de la validation: ${data['message'] ?? 'Erreur inconnue'}');
        }
      } else {
        print(' Validate merchant failed response: ${response.body}');
        throw Exception('Erreur lors de la validation du commerçant: ${response.statusCode}');
      }
    } catch (e) {
      print(' Validate merchant error: $e');
      rethrow;
    }
  }
  
  Future<Map<String, dynamic>> rejectMerchant(String merchantId) async {
    try {
      final url = '${ApiConfig.getFullUrl(ApiConfig.adminMerchants)}/$merchantId/reject';
      
      print(' REJECT MERCHANT DEBUG ');
      print(' Reject merchant URL: $url');
      print(' Merchant ID: $merchantId');
      print(' END DEBUG INFO ');
      
      final response = await http.put(
        Uri.parse(url),
        headers: await _getHeaders(),
      );
      
      print(' Reject merchant response: ${response.statusCode}');
      print(' Reject merchant response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          print(' Merchant rejected successfully');
          return data;
        } else {
          throw Exception('Échec du rejet: ${data['message'] ?? 'Erreur inconnue'}');
        }
      } else {
        print(' Reject failed with status: ${response.statusCode}');
        print(' Response body: ${response.body}');
        throw Exception('Erreur lors du rejet: ${response.statusCode}');
      }
    } catch (e) {
      print(' Reject merchant error: $e');
      rethrow;
    }
  }
  
  Future<void> suspendMerchant(String merchantId) async {
    try {
      final url = '${ApiConfig.getFullUrl(ApiConfig.adminMerchants)}/$merchantId/suspend';
      final response = await http.put(
        Uri.parse(url),
        headers: await _getHeaders(),
      );
      
      print('   Suspend merchant: ${response.statusCode}');
      
      if (response.statusCode != 200) {
        throw Exception('Erreur lors de la suspension');
      }
    } catch (e) {
      print(' Suspend merchant error: $e');
      rethrow;
    }
  }
  
  Future<void> reactivateMerchant(String merchantId) async {
    try {
      final url = '${ApiConfig.getFullUrl(ApiConfig.adminMerchants)}/$merchantId/reactivate';
      final response = await http.put(
        Uri.parse(url),
        headers: await _getHeaders(),
      );
      
      print(' Reactivate merchant: ${response.statusCode}');
      
      if (response.statusCode != 200) {
        throw Exception('Erreur lors de la réactivation');
      }
    } catch (e) {
      print(' Reactivate merchant error: $e');
      rethrow;
    }
  }
  
  Future<void> deleteMerchant(String merchantId) async {
    try {
      final url = '${ApiConfig.getFullUrl(ApiConfig.adminMerchantDelete)}/$merchantId';
      final response = await http.delete(
        Uri.parse(url),
        headers: await _getHeaders(),
      );
      
      print(' Delete merchant: ${response.statusCode}');
      
      if (response.statusCode != 200) {
        throw Exception('Erreur lors de la suppression');
      }
    } catch (e) {
      print(' Delete merchant error: $e');
      rethrow;
    }
  }
  
  // ==================== DOCUMENTS PENDING ====================
  
  Future<List<Map<String, dynamic>>> getPendingDocuments() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.getFullUrl(ApiConfig.adminDocumentsPending)),
        headers: await _getHeaders(),
      );
      
      print(' GET Pending documents: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.map((item) => item as Map<String, dynamic>).toList();
      } else {
        throw Exception('Erreur lors du chargement des documents');
      }
    } catch (e) {
      print(' Get pending documents error: $e');
      rethrow;
    }
  }
  
  Future<void> validateDocument(String documentId) async {
    try {
      final url = '${ApiConfig.getFullUrl(ApiConfig.adminDocumentValidate)}/$documentId/validate';
      final response = await http.put(
        Uri.parse(url),
        headers: await _getHeaders(),
      );
      
      print('   Validate document: ${response.statusCode}');
      
      if (response.statusCode != 200) {
        throw Exception('Erreur lors de la validation');
      }
    } catch (e) {
      print(' Validate document error: $e');
      rethrow;
    }
  }
  
  Future<void> rejectDocument(String documentId) async {
    try {
      final url = '${ApiConfig.getFullUrl(ApiConfig.adminDocumentReject)}/$documentId/reject';
      final response = await http.put(
        Uri.parse(url),
        headers: await _getHeaders(),
      );
      
      print(' Reject document: ${response.statusCode}');
      
      if (response.statusCode != 200) {
        throw Exception('Erreur lors du rejet');
      }
    } catch (e) {
      print(' Reject document error: $e');
      rethrow;
    }
  }
  
  // ==================== CLIENTS ====================
  
  Future<List<ClientAPI>> getClients({String? statut}) async {
    try {
      final queryParams = <String, String>{};
      if (statut != null) {
        queryParams['statut'] = statut;
      }
      
      final uri = Uri.parse(ApiConfig.getFullUrl(ApiConfig.adminClients))
          .replace(queryParameters: queryParams);
      
      print(' GET Clients: $uri');
      
      final response = await http.get(uri, headers: await _getHeaders());
      
      print(' GET Clients: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print(' Clients response type: ${data.runtimeType}');
        
        List clientsList;
        if (data is List) {
          clientsList = data;
        } else if (data is Map && data['data'] != null) {
          clientsList = data['data'] as List;
        } else {
          throw Exception('Format de réponse invalide pour les clients');
        }
        
        print('     Found ${clientsList.length} clients');
        return clientsList.map((item) => ClientAPI.fromJson(item)).toList();
      } else {
        throw Exception('Erreur lors du chargement des clients: ${response.statusCode}');
      }
    } catch (e) {
      print(' Get clients error: $e');
      rethrow;
    }
  }
  
  Future<void> suspendClient(String clientId) async {
    try {
      final url = '${ApiConfig.getFullUrl(ApiConfig.adminClientSuspend)}/$clientId/suspend';
      final response = await http.put(
        Uri.parse(url),
        headers: await _getHeaders(),
      );
      
      print(' Suspend client: ${response.statusCode}');
      
      if (response.statusCode != 200) {
        throw Exception('Erreur lors de la suspension');
      }
    } catch (e) {
      print(' Suspend client error: $e');
      rethrow;
    }
  }
  
  Future<void> reactivateClient(String clientId) async {
    try {
      final url = '${ApiConfig.getFullUrl(ApiConfig.adminClientReactivate)}/$clientId/reactivate';
      final response = await http.put(
        Uri.parse(url),
        headers: await _getHeaders(),
      );
    
      print(' Reactivate client: ${response.statusCode}');
      
      if (response.statusCode != 200) {
        throw Exception('Erreur lors de la réactivation');
      }
    } catch (e) {
      print(' Reactivate client error: $e');
      rethrow;
    }
  }
  
  // ==================== STATISTICS ====================
  
  Future<Map<String, dynamic>> getAdminStats() async {
    try {
      final url = ApiConfig.getFullUrl(ApiConfig.adminStats);
      print('GET Admin Stats URL: $url');
      
      final response = await http.get(
        Uri.parse(url),
        headers: await _getHeaders(),
      );
      
      print('GET Admin Stats: ${response.statusCode}');
      print(' Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print(' Stats response: $data');
        return data as Map<String, dynamic>;
      } else if (response.statusCode == 401) {
        throw Exception('Erreur d\'authentification (401): Token invalide ou expiré');
      } else if (response.statusCode == 500) {
        print(' Server error details: ${response.body}');
        throw Exception('Erreur serveur (500): Le backend a rencontré une erreur. Vérifiez les logs du serveur.');
      } else {
        print(' Error response body: ${response.body}');
        throw Exception('Erreur lors du chargement des statistiques: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print(' Get admin stats error: $e');
      rethrow;
    }
  }
  
  Future<List<Map<String, dynamic>>> getMerchantsByCategory() async {
    try {
      final url = '${ApiConfig.getFullUrl(ApiConfig.adminStats)}/merchants-by-category';
      print(' GET Merchants by Category URL: $url');
      
      final response = await http.get(
        Uri.parse(url),
        headers: await _getHeaders(),
      );
      
      print(' GET Merchants by Category: ${response.statusCode}');
      print(' Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print(' Merchants by category response: $data');
        if (data['success'] == true && data['data'] != null) {
          final content = data['data'] as List;
          return content.map((item) => item as Map<String, dynamic>).toList();
        } else {
          throw Exception('Format de réponse invalide pour les statistiques par catégorie');
        }
      } else if (response.statusCode == 500) {
        print(' Server error details for merchants by category: ${response.body}');
        throw Exception('Erreur serveur (500): Le backend a rencontré une erreur pour les statistiques par catégorie.');
      } else {
        print(' Error response body for merchants by category: ${response.body}');
        throw Exception('Erreur lors du chargement des statistiques par catégorie: ${response.statusCode}');
      }
    } catch (e) {
      print(' Get merchants by category error: $e');
      rethrow;
    }
  }
  
  
  Future<Map<String, dynamic>> getUsers({int page = 0, int size = 10, String? role}) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'size': size.toString(),
      };
      if (role != null) {
        queryParams['role'] = role;
      }
      
      final uri = Uri.parse(ApiConfig.getFullUrl(ApiConfig.adminUsers))
          .replace(queryParameters: queryParams);
      
      print(' GET Users: $uri');
      
      final response = await http.get(uri, headers: await _getHeaders());
      
      print(' GET Users: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print(' Users response: $data');
        if (data['success'] == true && data['data'] != null) {
          return data['data'] as Map<String, dynamic>;
        } else {
          throw Exception('Format de réponse invalide pour les utilisateurs');
        }
      } else {
        throw Exception('Erreur lors du chargement des utilisateurs: ${response.statusCode}');
      }
    } catch (e) {
      print(' Get users error: $e');
      rethrow;
    }
  }
  
  Future<void> activateUser(String userId) async {
    try {
      final url = '${ApiConfig.getFullUrl(ApiConfig.adminUsers)}/$userId/activer';
      final response = await http.patch(
        Uri.parse(url),
        headers: await _getHeaders(),
      );
      
      print('   Activate user: ${response.statusCode}');
      
      if (response.statusCode != 200) {
        throw Exception('Erreur lors de l\'activation de l\'utilisateur');
      }
    } catch (e) {
      print('  Activate user error: $e');
      rethrow;
    }
  }
  
  Future<void> deactivateUser(String userId) async {
    try {
      final url = '${ApiConfig.getFullUrl(ApiConfig.adminUsers)}/$userId/desactiver';
      final response = await http.patch(
        Uri.parse(url),
        headers: await _getHeaders(),
      );
      
      print('   Deactivate user: ${response.statusCode}');
      
      if (response.statusCode != 200) {
        throw Exception('Erreur lors de la désactivation de l\'utilisateur');
      }
    } catch (e) {
      print('  Deactivate user error: $e');
      rethrow;
    }
  }
  
  Future<void> deleteUser(String userId) async {
    try {
      final url = '${ApiConfig.getFullUrl(ApiConfig.adminUsers)}/$userId';
      final response = await http.delete(
        Uri.parse(url),
        headers: await _getHeaders(),
      );
      
      print('   Delete user: ${response.statusCode}');
      
      if (response.statusCode != 200) {
        throw Exception('Erreur lors de la suppression de l\'utilisateur');
      }
    } catch (e) {
      print('  Delete user error: $e');
      rethrow;
    }
  }
  
  // ==================== DOCUMENTS ====================

  Future<Map<String, String>> getDocumentHeaders() async {
    return await _getHeaders();
  }

  String getCinFileUrl(String merchantId) {
    return '${ApiConfig.getFullUrl('/api/admin/documents/$merchantId/files/cin')}';
  }

  String getRcFileUrl(String merchantId) {
    return '${ApiConfig.getFullUrl('/api/admin/documents/$merchantId/files/rc')}';
  }

  // ==================== NOTIFICATIONS ====================
  
  Future<Map<String, dynamic>> sendNotification({
    required String titre,
    required String message,
    required String destinataire, 
    List<String>? targetUserIds, 
    String? sousType, 
  }) async {
    try {
      final headers = await _getHeaders();
      
      final requestBody = {
        'titre': titre,
        'message': message,
        'destinataire': destinataire,
        'targetUserIds': targetUserIds ?? [],
      };
      
      if (destinataire == 'COMMERCANT' && sousType != null) {
        requestBody['sousType'] = sousType;
      }
      
      print('    Sending notification: ${jsonEncode(requestBody)}');
      
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/admin/notifications/envoyer'),
        headers: headers,
        body: jsonEncode(requestBody),
      );
      
      print('   Send notification response: ${response.statusCode}');
      print('   Send notification body: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['error'] ?? 'Failed to send notification');
      }
    } catch (e) {
      print('  Send notification error: $e');
      throw Exception('Failed to send notification: $e');
    }
  }
  
  Future<Map<String, dynamic>> getNotificationHistory({String? destinataire}) async {
    try {
      final headers = await _getHeaders();
      
      String url = '${ApiConfig.baseUrl}/api/admin/notifications/historique';
      if (destinataire != null && destinataire != 'all') {
        url += '?destinataire=$destinataire';
      }
      
      print('     Fetching notification history from: $url');
      
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );
      
      print('   Notification history response: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('  Successfully loaded ${data['notifications']?.length ?? 0} notifications');
        return data;
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['error'] ?? 'Failed to fetch notification history');
      }
    } catch (e) {
      print('  Get notification history error: $e');
      throw Exception('Failed to fetch notification history: $e');
    }
  }

  
}