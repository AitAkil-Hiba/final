import 'package:flutter/material.dart';
import 'package:peeco/client/pages/cart_screen.dart';
import 'package:peeco/client/pages/home_client_screen.dart' hide FiltreScreen;
import 'package:peeco/client/pages/offre_detail_screen.dart';
import 'package:peeco/client/pages/peeco_colors.dart';
import 'package:peeco/client/pages/reservations_screen.dart';
import 'package:peeco/client/pages/profil_commercant_client_screen.dart';
import 'package:peeco/client/pages/profil_client_screen.dart';
import 'package:peeco/client/pages/notifications_screen.dart';
import 'package:peeco/client/pages/acces_rapide_screen.dart';
import 'package:peeco/client/pages/carte_screen.dart';
import 'package:peeco/client/pages/filtre_screen.dart';
import 'package:peeco/client/pages/signalement_screen.dart';
import 'package:peeco/client/pages/laisser_avis_screen.dart';
import 'package:peeco/client/pages/favoris_screen.dart'; 


class PeecoApp extends StatelessWidget {
  const PeecoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Laaisraf',
      debugShowCheckedModeBanner: false,
      theme: peecoTheme(),
      initialRoute: '/home_client',
      routes: {

        // ── Espace CLIENT ───────────────────────────
        '/home_client':            (_) => const HomeClientScreen(),
        '/cart':                   (_) => const CartScreen(),
        '/laisser_avis': (context) => LaisserAvisScreen(
  commercant: AvisCommercant(
    nom: 'LE PANIER FRAIS',
    categorie: 'Superette',
    adresse: 'Laprovale, Kouba',
    distance: 0.9,
    nbOffres: 2,
    imageAsset: 'assets/images/panier_frais.png',
  ),
),
        '/offre_detail': (context) {
          final offre = ModalRoute.of(context)!.settings.arguments
as OffreDetail;
          return OffreDetailScreen(offre: offre);
        },    
         '/reservations':           (_) => const ReservationScreen(),
         
         '/notifications_client':      (_) => const NotificationsScreen(estCommercant: false),

        // Profil commerçant vu par le CLIENT (arguments: DonneesCommercant?)
        '/profil_commercant_client': (context) {
          final data = ModalRoute.of(context)!.settings.arguments
              as DonneesCommercant?;
          return ProfilCommercantClientScreen(commercant: data);
        },

        // Profil CLIENT
        '/profil_client':            (_) => ProfilClientScreen(),

        // Signaler offre
       '/signaler_offre': (context) {
       final nom = ModalRoute.of(context)!.settings.arguments as String? ?? 'Cette offre';
       return SignalementScreen(
       type: TypeSignalement.offre,
       nomCible: nom,
  );
},

      '/carte': (_) => const CarteScreen(),
      '/acces_rapide': (_) => const AccesRapideScreen(),
      '/favoris': (_) => const FavorisScreen(),
      '/filtre_screen': (_) => const FiltreScreen(),
      
     },
      
    );
  }
}