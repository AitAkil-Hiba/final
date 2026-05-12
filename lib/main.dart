//////main AMINAAA PERMET D'ACCEDER A PARTIR DE HOME COMMERCANT
/*
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'commerce/pages/accueil_commercant.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Burger House',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('fr', 'FR')],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF8B4513),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const AccueilCommercantPage(),
    );
  }
}*/

//main HIBA qui permet de renterer a partir les pages de conexion
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:peeco/client/client.dart';
import 'package:peeco/admin/admin.dart';
import 'package:peeco/client/pages/home_client_screen.dart';
import 'package:peeco/client/pages/cart_screen.dart';
import 'package:peeco/client/pages/favoris_screen.dart';
import 'package:peeco/client/pages/reservations_screen.dart';
import 'package:peeco/client/pages/profil_client_screen.dart';
import 'package:peeco/client/pages/acces_rapide_screen.dart';
import 'package:peeco/client/pages/carte_screen.dart';
import 'package:peeco/client/pages/offre_detail_screen.dart';
import 'package:peeco/client/pages/profil_commercant_client_screen.dart';
import 'package:peeco/client/notifications_client/notifications_client_page.dart';
import 'package:peeco/client/pages/signalement_screen.dart';
import 'package:peeco/client/pages/laisser_avis_screen.dart';

void main() {
  runApp(const Peeco());
}

class Peeco extends StatelessWidget {
  const Peeco({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Peeco',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFf5a742)),
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('fr', 'FR')],
      locale: const Locale('fr', 'FR'),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.noScaling),
          child: child!,
        );
      },
      initialRoute: '/',
      onGenerateRoute: _onGenerateRoute,
    );
  }

  Route<dynamic> _onGenerateRoute(RouteSettings settings) {
    if (settings.name?.startsWith('/admin') == true) {
      return AdminRouter.onGenerateRoute(settings);
    }

    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const ChoicePage());
      case '/home_client':
        return MaterialPageRoute(builder: (_) => const HomeClientScreen());
      case '/cart':
        return MaterialPageRoute(builder: (_) => const CartScreen());
      case '/favoris':
        return MaterialPageRoute(builder: (_) => const FavorisScreen());
      case '/reservations':
        return MaterialPageRoute(builder: (_) => const ReservationScreen());
      case '/profil_client':
        return MaterialPageRoute(builder: (_) => ProfilClientScreen());
      case '/acces_rapide':
        return MaterialPageRoute(builder: (_) => const AccesRapideScreen());
      case '/carte':
        return MaterialPageRoute(builder: (_) => const CarteScreen());
      case '/notifications_client':
        return MaterialPageRoute(
          builder: (_) => const NotificationsClientPage(),
        );
      case '/signaler_offre':
        final nom = settings.arguments as String? ?? 'Cette offre';
        return MaterialPageRoute(
          builder: (_) =>
              SignalementScreen(type: TypeSignalement.offre, nomCible: nom),
        );
      case '/offre_detail':
        final offre = settings.arguments as OffreDetail?;
        return MaterialPageRoute(
          builder: (_) => OffreDetailScreen(
            offre:
                offre ??
                OffreDetail(
                  id: '',
                  nom: '',
                  commercant: '',
                  adresse: '',
                  prix: '',
                  prixOriginal: '',
                  distance: '',
                  note: 0,
                  restants: 0,
                  creneau: '',
                  categorie: '',
                  description: '',
                  contenu: [],
                ),
          ),
        );
      case '/profil_commercant_client':
        final data = settings.arguments as DonneesCommercant?;
        return MaterialPageRoute(
          builder: (_) => ProfilCommercantClientScreen(commercant: data),
        );
      case '/laisser_avis':
        return MaterialPageRoute(
          builder: (context) => LaisserAvisScreen(
            commercant: AvisCommercant(
              nom: 'LE PANIER FRAIS',
              categorie: 'Superette',
              adresse: 'Laprovale, Kouba',
              distance: 0.9,
              nbOffres: 2,
              imageAsset: 'assets/images/panier_frais.png',
            ),
          ),
        );
      default:
        return MaterialPageRoute(builder: (_) => const ChoicePage());
    }
  }
}
