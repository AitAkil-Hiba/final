class ApiConfig {
  // Backend URL (mise à jour avec la nouvelle URL)
  static const String baseUrl = 'https://tissue-squishy-refresh.ngrok-free.dev';
  //'https://disarray-striking-overbill.ngrok-free.dev';

  // Header requis pour ngrok - À AJOUTER DANS TOUS LES APPELS HTTP
  static const String ngrokHeader = 'ngrok-skip-browser-warning';
  static const String ngrokHeaderValue = 'true';

  // ==================== AUTHENTIFICATION (vos endpoints existants) ====================
  static const String register = '/api/auth/register';
  static const String registerMerchant = '/api/auth/register-merchant-upload';
  static const String login = '/api/auth/login';
  static const String verifyEmail = '/api/auth/verify-email';
  static const String resendVerification = '/api/auth/resend-verification';
  static const String forgotPassword = '/api/auth/forgot-password';
  static const String resetPassword = '/api/auth/reset-password';
  static const String me = '/api/auth/me';
  static const String googleAuth = '/oauth2/authorization/google';

  // ==================== PROFIL UTILISATEUR  ====================
  static const String profileImage = '/api/user/profile-image';
  static const String profileReport = '/api/profile/report';

  // ==================== DOCUMENTS  ====================
  static const String uploadCin = '/api/merchant/upload-cin';
  static const String uploadRc = '/api/merchant/upload-rc';
  static const String uploadBrochure = '/api/merchant/upload-brochure';
  static const String uploadDocument = '/api/merchant/upload-document';

  // ==================== OFFRES  ====================
  static const String createOffer = '/api/offers/create';
  static const String getOffers = '/api/offers';
  static const String getOfferById = '/api/offers';
  static const String updateOffer = '/api/offers';
  static const String deleteOffer = '/api/offers';

  // ==================== RÉSERVATIONS (vos endpoints existants) ====================
  static const String createOrder = '/api/orders/create';
  static const String getOrders = '/api/orders';
  static const String getOrderById = '/api/orders';
  static const String updateOrderStatus = '/api/orders';

  // ==================== AVIS (vos endpoints existants) ====================
  static const String createReview = '/api/reviews/create';
  static const String getReviews = '/api/reviews';
  static const String getMerchantReviews = '/api/reviews/merchant';

  // ==================== SIGNALEMENTS (vos endpoints existants) ====================
  static const String createReport = '/api/reports/create';
  static const String getReports = '/api/reports';
  static const String updateReportStatus = '/api/reports';

  // ==================== STATISTIQUES (vos endpoints existants) ====================
  static const String merchantStats = '/api/stats/merchant';
  // Note: adminStats moved to ADMIN ENDPOINTS section below

  // ==================== RECHERCHE (vos endpoints existants) ====================
  static const String searchMerchants = '/api/search/merchants';
  static const String searchOffers = '/api/search/offers';

  // ==================== ADMIN ENDPOINTS (API CONTRACT) ====================
  // Signalements
  static const String adminSignalements = '/api/admin/signalements';
  static const String adminSignalementTreat = '/api/admin/signalements';
  static const String adminSignalementDelete = '/api/admin/signalements';
  static const String adminSignalementDeleteWithOffer =
      '/api/admin/signalements';

  // Documents
  static const String adminDocumentsPending = '/api/admin/documents/pending';
  static const String adminDocumentValidate = '/api/admin/documents';
  static const String adminDocumentReject = '/api/admin/documents';

  // Commerçants
  static const String adminMerchants = '/api/admin/merchants';
  static const String adminMerchantValidate = '/api/admin/merchants';
  static const String adminMerchantReject = '/api/admin/merchants';
  static const String adminMerchantSuspend = '/api/admin/merchants';
  static const String adminMerchantReactivate = '/api/admin/merchants';
  static const String adminMerchantDelete = '/api/admin/merchants';

  // Clients
  static const String adminClients = '/api/admin/clients';
  static const String adminClientSuspend = '/api/admin/clients';
  static const String adminClientReactivate = '/api/admin/clients';
  static const String adminClientDelete = '/api/admin/clients';

  // Statistiques et rapports
  static const String adminStats = '/api/admin/stats';
  static const String adminStatsRegistrations =
      '/api/admin/stats/registrations';
  static const String adminStatsReservations = '/api/admin/stats/reservations';
  static const String adminStatsOffers = '/api/admin/stats/offers';
  static const String adminStatsMerchantsByCategory =
      '/api/admin/stats/merchants-by-category';
  static const String adminReports = '/api/admin/reports';

  // Utilisateurs
  static const String adminUsers = '/api/admin/users';
  static const String adminUserActivate = '/api/admin/users';
  static const String adminUserDeactivate = '/api/admin/users';
  static const String adminUserDelete = '/api/admin/users';

  // Helper method to get full URL
  static String getFullUrl(String endpoint) {
    return '$baseUrl$endpoint';
  }
}
