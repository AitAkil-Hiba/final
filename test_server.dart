// Serveur de test pour l'API commerçant
// Lancez avec: dart run test_server.dart

import 'dart:io';
import 'dart:convert';

void main() async {
  final server = await HttpServer.bind('localhost', 8084);
  print('🚀 Serveur de test démarré sur http://localhost:8084');
  print('📡 Testez avec votre application Flutter');
  print('⏹️  Arrêtez avec Ctrl+C');

  await for (HttpRequest request in server) {
    print('📨 ${request.method} ${request.uri.path}');

    // CORS headers
    final headers = <String, String>{
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, PATCH, OPTIONS',
      'Access-Control-Allow-Headers': 'Content-Type, Authorization',
      'Content-Type': 'application/json',
    };

    try {
      if (request.method == 'OPTIONS') {
        headers.forEach(
          (key, value) => request.response.headers.set(key, value),
        );
        request.response.statusCode = 200;
        request.response.close();
        continue;
      }

      // Endpoint /api/offers
      if (request.uri.path == '/api/offers' && request.method == 'GET') {
        final mockOffers = [
          {
            'id': '1',
            'titre': 'Panier boulangerie',
            'description': 'Délicieux pain frais et viennoiseries',
            'prixOriginal': 450.0,
            'prixReduit': 180.0,
            'quantiteDisponible': 2,
            'heureDebutRetrait': '17:00',
            'heureFinRetrait': '19:00',
            'createdAt': DateTime.now().toIso8601String(),
            'statut': 'PUBLIEE',
            'totalReservations': 5,
          },
          {
            'id': '2',
            'titre': 'Panier surprise',
            'description': 'Assortiment surprise de produits frais',
            'prixOriginal': 400.0,
            'prixReduit': 160.0,
            'quantiteDisponible': 6,
            'heureDebutRetrait': '18:00',
            'heureFinRetrait': '21:00',
            'createdAt': DateTime.now().toIso8601String(),
            'statut': 'PUBLIEE',
            'totalReservations': 10,
          },
        ];

        final response = {
          'offers': mockOffers,
          'page': 0,
          'size': 10,
          'totalElements': 2,
          'totalPages': 1,
        };

        headers.forEach(
          (key, value) => request.response.headers.set(key, value),
        );
        request.response.statusCode = 200;
        request.response.write(json.encode(response));
        request.response.close();

        print('✅ GET /api/offres - ${mockOffers.length} offres retournées');
      }
      // Endpoint DELETE /api/offers/{id}
      else if (request.uri.path.startsWith('/api/offers/') &&
          request.method == 'DELETE') {
        final offerId = request.uri.path.split('/').last;

        final response = {
          'message': 'Offre $offerId supprimée avec succès',
          'id': offerId,
        };

        headers.forEach(
          (key, value) => request.response.headers.set(key, value),
        );
        request.response.statusCode = 200;
        request.response.write(json.encode(response));
        request.response.close();

        print('✅ DELETE /api/offres/$offerId - Offre supprimée');
      }
      // Endpoint /api/auth/me (test auth)
      else if (request.uri.path == '/api/auth/me' && request.method == 'GET') {
        final response = {
          'id': 'merchant_123',
          'fullName': 'Test Commercant',
          'email': 'test@example.com',
          'nomCommerce': 'Boulangerie Test',
        };

        headers.forEach(
          (key, value) => request.response.headers.set(key, value),
        );
        request.response.statusCode = 200;
        request.response.write(json.encode(response));
        request.response.close();

        print('✅ GET /api/auth/me - Profil utilisateur');
      }
      // Autres endpoints
      else {
        headers.forEach(
          (key, value) => request.response.headers.set(key, value),
        );
        request.response.statusCode = 404;
        request.response.write(json.encode({'error': 'Endpoint non trouvé'}));
        request.response.close();

        print('❌ ${request.method} ${request.uri.path} - Endpoint non trouvé');
      }
    } catch (e) {
      print('🔴 Erreur: $e');
      headers.forEach((key, value) => request.response.headers.set(key, value));
      request.response.statusCode = 500;
      request.response.write(json.encode({'error': 'Erreur serveur: $e'}));
      request.response.close();
    }
  }
}
