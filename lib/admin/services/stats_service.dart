import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config/api_config.dart';
import '../../services/auth_service.dart';
import '../models/stats_model.dart';

class StatsService {
  final AuthService _authService = AuthService();
  
  Future<Map<String, String>> _getHeaders() async {
    final token = await _authService.getToken();
    print('   Stats Auth token: ${token?.isNotEmpty == true ? "Present" : "Missing/Empty"}');
    
    if (token?.isEmpty == true) {
      print('  No auth token available for stats');
    }
    
    final headers = {
      'Authorization': 'Bearer ${token ?? ""}',
      'Content-Type': 'application/json',
      ApiConfig.ngrokHeader: ApiConfig.ngrokHeaderValue,
    };
    
    return headers;
  }

  Future<AdminStats> getAdminStats() async {
    try {
      final uri = Uri.parse(ApiConfig.getFullUrl(ApiConfig.adminStats));
      
      print('     Admin Stats URL: $uri');
      
      final response = await http.get(uri, headers: await _getHeaders());
      
      print('     GET Admin Stats: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(response.body);
          print('     Admin Stats response type: ${data.runtimeType}');
          
          final adminStats = AdminStats.fromJson(data);
          
          print('     Admin Stats loaded successfully');
          return adminStats;
        } catch (jsonError) {
          print('  JSON parsing error for admin stats: $jsonError');
          print('  Response body preview: ${response.body.length > 500 ? response.body.substring(0, 500) + "..." : response.body}');
          throw Exception('Réponse serveur invalide: JSON malformé pour les statistiques admin');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Erreur d\'authentification (401): Token invalide ou expiré');
      } else {
        print('  Admin Stats error response body: ${response.body}');
        throw Exception('Erreur lors du chargement des statistiques admin: ${response.statusCode}');
      }
    } catch (e) {
      print('  Get admin stats error: $e');
      rethrow;
    }
  }

  Future<RegistrationStats> getRegistrationStats({DateTime? startDate, DateTime? endDate}) async {
    try {
      final queryParams = <String, String>{};
      if (startDate != null) {
        queryParams['start_date'] = startDate.toIso8601String().split('T')[0];
      }
      if (endDate != null) {
        queryParams['end_date'] = endDate.toIso8601String().split('T')[0];
      }
      
      final uri = Uri.parse(ApiConfig.getFullUrl(ApiConfig.adminStatsRegistrations))
          .replace(queryParameters: queryParams);
      
      print('     Registration Stats URL: $uri');
      
      final response = await http.get(uri, headers: await _getHeaders());
      
      print('     GET Registration Stats: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(response.body);
          print('     Registration Stats response type: ${data.runtimeType}');
          
          final registrationStats = RegistrationStats.fromJson(data);
          
          print('     Registration Stats loaded successfully');
          return registrationStats;
        } catch (jsonError) {
          print('  JSON parsing error for registration stats: $jsonError');
          throw Exception('Réponse serveur invalide: JSON malformé pour les statistiques d\'inscription');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Erreur d\'authentification (401): Token invalide ou expiré');
      } else {
        print('  Registration Stats error response body: ${response.body}');
        throw Exception('Erreur lors du chargement des statistiques d\'inscription: ${response.statusCode}');
      }
    } catch (e) {
      print('  Get registration stats error: $e');
      rethrow;
    }
  }

  Future<ReservationStats> getReservationStats({DateTime? startDate, DateTime? endDate}) async {
    try {
      final queryParams = <String, String>{};
      if (startDate != null) {
        queryParams['start_date'] = startDate.toIso8601String().split('T')[0];
      }
      if (endDate != null) {
        queryParams['end_date'] = endDate.toIso8601String().split('T')[0];
      }
      
      final uri = Uri.parse(ApiConfig.getFullUrl(ApiConfig.adminStatsReservations))
          .replace(queryParameters: queryParams);
      
      print('     Reservation Stats URL: $uri');
      
      final response = await http.get(uri, headers: await _getHeaders());
      
      print('     GET Reservation Stats: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(response.body);
          print('     Reservation Stats response type: ${data.runtimeType}');
          
          final reservationStats = ReservationStats.fromJson(data);
          
          print('     Reservation Stats loaded successfully');
          return reservationStats;
        } catch (jsonError) {
          print('  JSON parsing error for reservation stats: $jsonError');
          throw Exception('Réponse serveur invalide: JSON malformé pour les statistiques de réservation');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Erreur d\'authentification (401): Token invalide ou expiré');
      } else {
        print('  Reservation Stats error response body: ${response.body}');
        throw Exception('Erreur lors du chargement des statistiques de réservation: ${response.statusCode}');
      }
    } catch (e) {
      print('  Get reservation stats error: $e');
      rethrow;
    }
  }

  Future<OfferStats> getOfferStats() async {
    try {
      final uri = Uri.parse(ApiConfig.getFullUrl(ApiConfig.adminStatsOffers));
      
      print('     Offer Stats URL: $uri');
      
      final response = await http.get(uri, headers: await _getHeaders());
      
      print('     GET Offer Stats: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(response.body);
          print('     Offer Stats response type: ${data.runtimeType}');
          print('     Offer Stats response data: $data');
          
          Map<String, dynamic> offerData = {};
          if (data is Map<String, dynamic>) {
            if (data.containsKey('data')) {
              offerData = data['data'] ?? {};
            } else {
              offerData = data;
            }
          }
          
          final offerStats = OfferStats.fromJson(offerData);
          
          print('     Offer Stats loaded successfully');
          return offerStats;
        } catch (jsonError) {
          print('  JSON parsing error for offer stats: $jsonError');
          print('  Response body: ${response.body}');
          throw Exception('Réponse serveur invalide: JSON malformé pour les statistiques d\'offres');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Erreur d\'authentification (401): Token invalide ou expiré');
      } else {
        print('  Offer Stats error response body: ${response.body}');
        throw Exception('Erreur lors du chargement des statistiques d\'offres: ${response.statusCode}');
      }
    } catch (e) {
      print('  Get offer stats error: $e');
      rethrow;
    }
  }

  Future<List<MerchantCategoryStats>> getMerchantsByCategory() async {
    try {
      final uri = Uri.parse(ApiConfig.getFullUrl(ApiConfig.adminStatsMerchantsByCategory));
      
      print('     Merchants by Category URL: $uri');
      
      final response = await http.get(uri, headers: await _getHeaders());
      
      print('     GET Merchants by Category: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(response.body);
          print('     Merchants by Category response type: ${data.runtimeType}');
          
          List<dynamic> merchantsList = [];
          if (data is Map<String, dynamic>) {
            merchantsList = data['data'] ?? [];
          } else if (data is List) {
            merchantsList = data;
          }
          
          final merchantCategoryStats = merchantsList
              .map((e) => MerchantCategoryStats.fromJson(e))
              .toList();
          
          print('     Merchants by Category loaded successfully: ${merchantCategoryStats.length} categories');
          return merchantCategoryStats;
        } catch (jsonError) {
          print('  JSON parsing error for merchants by category: $jsonError');
          throw Exception('Réponse serveur invalide: JSON malformé pour les statistiques de commerçants par catégorie');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Erreur d\'authentification (401): Token invalide ou expiré');
      } else {
        print('  Merchants by Category error response body: ${response.body}');
        throw Exception('Erreur lors du chargement des statistiques de commerçants par catégorie: ${response.statusCode}');
      }
    } catch (e) {
      print('  Get merchants by category error: $e');
      rethrow;
    }
  }
}
