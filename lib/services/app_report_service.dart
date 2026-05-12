import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/app_report.dart';
import 'auth_service.dart';

class AppReportService {
  final AuthService _authService = AuthService();

  Future<Map<String, String>> _headers() async {
    final token = await _authService.getToken();
    return {
      'Authorization': 'Bearer ${token ?? ""}',
      'Content-Type': 'application/json',
      ApiConfig.ngrokHeader: ApiConfig.ngrokHeaderValue,
    };
  }

  Future<String> submitReport({
    required String subject,
    required String description,
  }) async {
    final response = await http.post(
      Uri.parse(ApiConfig.getFullUrl(ApiConfig.profileReport)),
      headers: await _headers(),
      body: jsonEncode({
        'subject': subject,
        'description': description,
      }),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return (data['reportId'] ?? '').toString();
    }

    if (response.statusCode == 400) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      throw ApiException(message: (data['error'] ?? 'Requête invalide').toString());
    }
    if (response.statusCode == 401) {
      throw ApiException(message: 'Session expirée. Veuillez vous reconnecter.');
    }

    throw ApiException(message: 'Erreur serveur lors de l\'envoi de la demande.');
  }

  Future<List<AppReport>> getAdminReports() async {
    final response = await http.get(
      Uri.parse(ApiConfig.getFullUrl(ApiConfig.adminReports)),
      headers: await _headers(),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data is List) {
        return data
            .map((item) => AppReport.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    }

    if (response.statusCode == 401) {
      throw ApiException(message: 'Accès refusé. Connectez-vous en admin.');
    }

    throw ApiException(message: 'Erreur serveur lors du chargement des demandes.');
  }

  Future<AppReportStatus> updateStatus({
    required String reportId,
    required AppReportStatus status,
  }) async {
    final uri = Uri.parse(
      '${ApiConfig.getFullUrl(ApiConfig.adminReports)}/$reportId/status',
    ).replace(queryParameters: {'status': status.apiValue});

    final response = await http.patch(uri, headers: await _headers());

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return AppReportStatusX.fromApiValue((data['newStatus'] ?? '').toString());
    }
    if (response.statusCode == 404) {
      throw ApiException(message: 'Demande non trouvée.');
    }

    throw ApiException(message: 'Erreur lors de la mise à jour du statut.');
  }
}
