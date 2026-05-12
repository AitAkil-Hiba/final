/// MockApiService - Service de simulation pour le développement
/// Retourne des données différentes selon l'ID du commerçant connecté
class MockApiService {
  // Base de données mock de commerçants
  static final Map<String, Map<String, dynamic>> _mockMerchants = {
    'merchant_001': {
      'id': 'merchant_001',
      'fullName': 'Ahmed Benali',
      'email': 'ahmed@burgerhouse.dz',
      'nomCommerce': 'Burger House Alger',
      'telephone': '0551234567',
      'adresse': '123 Rue Didouche Mourad, Alger',
      'typeCommerce': 'Restaurant',
      'description': 'Meilleurs burgers d\'Alger depuis 2020',
      'horaires': {'ouverture': '09:00', 'fermeture': '23:00'},
      'rating': 4.5,
      'totalOrders': 342,
      'totalRevenue': 2450000.0,
    },
    'merchant_002': {
      'id': 'merchant_002',
      'fullName': 'Fatima Zohra',
      'email': 'fatima@pizzatime.dz',
      'nomCommerce': 'Pizza Time Oran',
      'telephone': '0419876543',
      'adresse': '45 Avenue des Frères Ben M\'hidi, Oran',
      'typeCommerce': 'Pizzeria',
      'description': 'Pizza italienne authentique',
      'horaires': {'ouverture': '11:00', 'fermeture': '00:00'},
      'rating': 4.2,
      'totalOrders': 256,
      'totalRevenue': 1890000.0,
    },
    'merchant_003': {
      'id': 'merchant_003',
      'fullName': 'Mohamed Rachid',
      'email': 'mohamed@shawarma.dz',
      'nomCommerce': 'Shawarma Express Constantine',
      'telephone': '0314567890',
      'adresse': '78 Rue Cité Emir Abdelkader, Constantine',
      'typeCommerce': 'Fast Food',
      'description': 'Shawarma et grillades express',
      'horaires': {'ouverture': '10:00', 'fermeture': '22:00'},
      'rating': 4.7,
      'totalOrders': 189,
      'totalRevenue': 1230000.0,
    },
  };

  // Données mock pour les offres par commerçant
  static final Map<String, List<Map<String, dynamic>>> _mockOffers = {
    'merchant_001': [
      {
        'id': 'offer_001',
        'titre': 'Combo Burger + Frites',
        'description': 'Délicieux burger maison avec frites fraîches',
        'prix': 1200.0,
        'prixOriginal': 1500.0,
        'remise': 20,
        'image':
            'https://via.placeholder.com/300x200/FF6B35/FFFFFF?text=Burger+Combo',
        'categorie': 'Combos',
        'disponible': true,
        'commandes': 45,
        'note': 4.6,
        'dateCreation': '2024-01-15',
      },
      {
        'id': 'offer_002',
        'titre': 'Menu Famille',
        'description': '4 burgers + 2 portions frites + 4 boissons',
        'prix': 3500.0,
        'prixOriginal': 4200.0,
        'remise': 17,
        'image':
            'https://via.placeholder.com/300x200/4ECDC4/FFFFFF?text=Menu+Famille',
        'categorie': 'Menus',
        'disponible': true,
        'commandes': 23,
        'note': 4.8,
        'dateCreation': '2024-01-20',
      },
    ],
    'merchant_002': [
      {
        'id': 'offer_003',
        'titre': 'Pizza Margherita',
        'description': 'Pizza classique avec tomate, mozzarella et basilic',
        'prix': 1800.0,
        'prixOriginal': null,
        'remise': 0,
        'image':
            'https://via.placeholder.com/300x200/FF6B35/FFFFFF?text=Pizza+Margherita',
        'categorie': 'Pizzas',
        'disponible': true,
        'commandes': 67,
        'note': 4.4,
        'dateCreation': '2024-02-01',
      },
    ],
    'merchant_003': [
      {
        'id': 'offer_004',
        'titre': 'Shawarma Poulet',
        'description': 'Shawarma poulet grillé avec sauce tahini',
        'prix': 800.0,
        'prixOriginal': 1000.0,
        'remise': 20,
        'image':
            'https://via.placeholder.com/300x200/4ECDC4/FFFFFF?text=Shawarma',
        'categorie': 'Sandwichs',
        'disponible': true,
        'commandes': 89,
        'note': 4.7,
        'dateCreation': '2024-01-10',
      },
    ],
  };

  // Données mock pour les commandes par commerçant
  static final Map<String, List<Map<String, dynamic>>> _mockOrders = {
    'merchant_001': [
      {
        'id': 'order_001',
        'clientNom': 'Karim Ben',
        'clientPhone': '0771234567',
        'clientAvatar':
            'https://via.placeholder.com/50x50/FF6B35/FFFFFF?text=KB',
        'montant': 2400.0,
        'statut': 'en_preparation',
        'date': '2024-03-15 14:30',
        'articles': ['Combo Burger + Frites x2', 'Coca-Cola x2'],
        'adresse': 'Rue Hassiba Ben Bouali, Alger',
      },
      {
        'id': 'order_002',
        'clientNom': 'Sofia Mokhtar',
        'clientPhone': '0559876543',
        'clientAvatar':
            'https://via.placeholder.com/50x50/4ECDC4/FFFFFF?text=SM',
        'montant': 3500.0,
        'statut': 'livree',
        'date': '2024-03-15 12:15',
        'articles': ['Menu Famille'],
        'adresse': 'Cité 1200 Logements, Alger',
      },
    ],
    'merchant_002': [
      {
        'id': 'order_003',
        'clientNom': 'Yacine Rezki',
        'clientPhone': '0412345678',
        'clientAvatar':
            'https://via.placeholder.com/50x50/FF6B35/FFFFFF?text=YR',
        'montant': 1800.0,
        'statut': 'en_attente',
        'date': '2024-03-15 19:45',
        'articles': ['Pizza Margherita'],
        'adresse': 'Sidi El Houari, Oran',
      },
    ],
  };

  // Récupérer les infos du commerçant connecté
  static Future<Map<String, dynamic>> getMerchantProfile(
    String merchantId,
  ) async {
    // Simuler un délai réseau
    await Future.delayed(const Duration(milliseconds: 500));

    final merchant = _mockMerchants[merchantId];
    if (merchant == null) {
      // Retourner un commerçant par défaut si l'ID n'existe pas
      return {
        'id': merchantId,
        'fullName': 'Commerçant Inconnu',
        'email': 'unknown@example.com',
        'nomCommerce': 'Commerce Non Configuré',
        'telephone': '0000000000',
        'adresse': 'Adresse non définie',
        'typeCommerce': 'Non spécifié',
        'description': 'Veuillez compléter votre profil',
        'horaires': {'ouverture': '09:00', 'fermeture': '18:00'},
        'rating': 0.0,
        'totalOrders': 0,
        'totalRevenue': 0.0,
      };
    }

    return merchant;
  }

  // Récupérer les offres du commerçant
  static Future<List<Map<String, dynamic>>> getMerchantOffers(
    String merchantId,
  ) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final offers = _mockOffers[merchantId] ?? [];
    return offers;
  }

  // Récupérer les commandes du commerçant
  static Future<List<Map<String, dynamic>>> getMerchantOrders(
    String merchantId,
  ) async {
    await Future.delayed(const Duration(milliseconds: 400));

    final orders = _mockOrders[merchantId] ?? [];
    return orders;
  }

  // Récupérer les statistiques du commerçant
  static Future<Map<String, dynamic>> getMerchantStats(
    String merchantId,
  ) async {
    await Future.delayed(const Duration(milliseconds: 200));

    final merchant = _mockMerchants[merchantId];
    if (merchant == null) {
      return {
        'totalOrders': 0,
        'totalRevenue': 0.0,
        'averageRating': 0.0,
        'activeOffers': 0,
        'monthlyOrders': 0,
        'monthlyRevenue': 0.0,
      };
    }

    final orders = _mockOrders[merchantId] ?? [];
    final offers = _mockOffers[merchantId] ?? [];

    // Calculer les commandes du mois (simulation)
    final now = DateTime.now();
    final monthlyOrders = orders.where((order) {
      final orderDate = DateTime.parse(order['date'].replaceAll(' ', 'T'));
      return orderDate.month == now.month && orderDate.year == now.year;
    }).length;

    final monthlyRevenue = orders
        .where((order) {
          final orderDate = DateTime.parse(order['date'].replaceAll(' ', 'T'));
          return orderDate.month == now.month && orderDate.year == now.year;
        })
        .fold<double>(0.0, (sum, order) => sum + (order['montant'] as double));

    return {
      'totalOrders': merchant['totalOrders'] ?? 0,
      'totalRevenue': merchant['totalRevenue'] ?? 0.0,
      'averageRating': merchant['rating'] ?? 0.0,
      'activeOffers': offers
          .where((offer) => offer['disponible'] == true)
          .length,
      'monthlyOrders': monthlyOrders,
      'monthlyRevenue': monthlyRevenue,
    };
  }

  // Mettre à jour le profil du commerçant
  static Future<bool> updateMerchantProfile(
    String merchantId,
    Map<String, dynamic> updates,
  ) async {
    await Future.delayed(const Duration(milliseconds: 600));

    final merchant = _mockMerchants[merchantId];
    if (merchant != null) {
      merchant.addAll(updates);
      return true;
    }

    return false;
  }

  // Ajouter une nouvelle offre
  static Future<bool> addOffer(
    String merchantId,
    Map<String, dynamic> offer,
  ) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final offers = _mockOffers[merchantId] ?? [];
    offer['id'] = 'offer_${DateTime.now().millisecondsSinceEpoch}';
    offer['dateCreation'] = DateTime.now().toIso8601String().split('T')[0];
    offer['commandes'] = 0;
    offer['note'] = 0.0;

    offers.add(offer);
    _mockOffers[merchantId] = offers;

    return true;
  }

  // Supprimer une offre
  static Future<bool> deleteOffer(String merchantId, String offerId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final offers = _mockOffers[merchantId] ?? [];
    offers.removeWhere((offer) => offer['id'] == offerId);
    _mockOffers[merchantId] = offers;

    return true;
  }

  // Mettre à jour le statut d'une commande
  static Future<bool> updateOrderStatus(
    String merchantId,
    String orderId,
    String newStatus,
  ) async {
    await Future.delayed(const Duration(milliseconds: 400));

    final orders = _mockOrders[merchantId] ?? [];
    for (final order in orders) {
      if (order['id'] == orderId) {
        order['statut'] = newStatus;
        return true;
      }
    }

    return false;
  }
}
