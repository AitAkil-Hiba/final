class ApiConfig {
  static const String baseUrl = 'https://tissue-squishy-refresh.ngrok-free.dev';
  //'https://disarray-striking-overbill.ngrok-free.dev';

  // ========================================
  // AUTHENTIFICATION
  // ========================================
  static const String register = '/api/auth/register';
  static const String registerMerchant = '/api/auth/register-merchant';
  static const String login = '/api/auth/login';
  static const String verifyEmail = '/api/auth/verify-email';
  static const String resendVerification = '/api/auth/resend-verification';
  static const String forgotPassword = '/api/auth/forgot-password';
  static const String resetPassword = '/api/auth/reset-password';
  static const String me = '/api/auth/me';
  static const String googleAuth = '/oauth2/authorization/google';

  // ========================================
  // PROFIL
  // ========================================
  static const String profileImage = '/api/user/profile-image';
  static const String updateProfile = '/api/profile';
  static const String profilePhoto = '/api/profile/photo';
  static const String deleteProfile = '/api/profile';
  static const String fcmToken = '/api/profile/fcm-token';

  // ========================================
  // DOCUMENTS
  // ========================================
  static const String uploadCin = '/api/merchant/upload-cin';
  static const String uploadRc = '/api/merchant/upload-rc';
  static const String uploadBrochure = '/api/merchant/upload-brochure';
  static const String getMerchantDocuments = '/api/merchant/documents';
  static const String updateMerchantDocument = '/api/merchant/documents';
  static const String deleteMerchantDocument = '/api/merchant/documents';
  static const String uploadDocument = '/api/merchant/upload-document';

  // ========================================
  // OFFRES
  // ========================================
  static const String createOffer = '/api/offres';
  static const String getOffers = '/api/offres';
  static const String getMyOffers = '/api/offres/mes-offres';
  static const String getOfferById = '/api/offres';
  static const String updateOffer =
      '/api/offres'; //  + /{id} ajouté dynamiquement
  static const String deleteOffer =
      '/api/offres'; // + /{id} ajouté dynamiquement
  static const String offerImages =
      '/api/offres'; // + /{id}/images ajouté dynamiquement
  static const String archiveOffer =
      '/api/offres'; // + /{id}/archiver ajouté dynamiquement
  static const String searchOffers = '/api/offres/recherche';

  // ========================================
  // RÉSERVATIONS
  // ========================================
  static const String getMyReservations =
      '/api/reservations/mes-offres'; // selon contrat
  static const String confirmReservation =
      '/api/reservations'; // + /{id}/confirmer dynamiquement
  static const String validatePickup =
      '/api/reservations'; //  + /{id}/recuperer dynamiquement

  // ========================================
  // STATISTIQUES
  // ========================================
  static const String merchantStats = '/api/statistiques/commercant';
  static const String adminStats = '/api/stats/admin';

  // ========================================
  // AVIS
  // ========================================
  static const String getMerchantReviews =
      '/api/commercants'; //  /{id}/reviews dynamiquement
  static const String createReview = '/api/reviews/create';
  static const String getReviews = '/api/reviews';

  // ========================================
  // NOTIFICATIONS
  // ========================================
  static const String getNotifications = '/api/notifications';
  static const String notificationBadge = '/api/notifications/badge';
  static const String markNotificationRead =
      '/api/notifications'; //  /{id}/lue dynamiquement
  static const String markAllRead = '/api/notifications/lue';
  static const String notificationPreferences =
      '/api/notifications/preferences';

  // ========================================
  // SIGNALEMENTS
  // ========================================
  static const String createReport = '/api/reports/create';
  static const String getReports = '/api/reports';
  static const String updateReportStatus = '/api/reports';

  // ========================================
  // RECHERCHE
  // ========================================
  static const String searchMerchants = '/api/search/merchants';

  // ========================================
  // UTILITAIRES
  // ========================================
  static String getFullUrl(String endpoint) {
    return '$baseUrl$endpoint';
  }
}
