import 'package:flutter/material.dart';
import '../admin_shell.dart';
import '../user_distribution.dart';
import '../merchants_by_category.dart';
import '../stats_pages.dart';
import '../signalements.dart';
import '../notifications.dart';

class AdminRouter {
  AdminRouter._();

  static const String shell = '/admin';
  static const String home = '/admin/home';
  static const String userDistribution = '/admin/stats/users';
  static const String merchantsByCategory = '/admin/stats/merchants';
  static const String registrationEvolution = '/admin/stats/registrations';
  static const String reservationsPerDay = '/admin/stats/reservations';
  static const String offerPerformance = '/admin/stats/offers';
  static const String signalements = '/admin/signalements';
  static const String notifications = '/admin/notifications';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case shell:
      case home:
        return _fade(const AdminShell());
      case userDistribution:
       return _fade(UserDistributionPage());
      case merchantsByCategory:
        return _fade(const MerchantsByCategoryPage());
      case registrationEvolution:
        return _fade(const RegistrationEvolutionPage());
      case reservationsPerDay:
        return _fade(const ReservationsPerDayPage());
      case offerPerformance:
        return _fade(const OfferPerformancePage());
      case signalements:
        return _fade(const SignalementsPage());
      case notifications:
        return _fade(const NotificationsPage());
      default:
        return _fade(const AdminShell());
    }
  }

  static PageRouteBuilder<dynamic> _fade(Widget page) => PageRouteBuilder(
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 220),
      );
}
