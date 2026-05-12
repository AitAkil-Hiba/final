import 'package:flutter/material.dart';
import 'package:peeco/client/client.dart';

class ClientHome extends StatelessWidget {
  const ClientHome({super.key});

  @override
Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [const Color(0xFFFFFFFF), const Color(0xFFCCD5AE)],
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const SizedBox(height: 20),
              const Text(
                'PEECO - Test Navigation',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              
              // Button 1
              _buildButton(context, 'Accès Rapide', Icons.bookmark, () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const AccesRapideScreen()));
              }),
              
              // Button 2
              _buildButton(context, 'Panier', Icons.shopping_cart, () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen()));
              }),
              
              // Button 3
              _buildButton(context, 'Carte', Icons.map, () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const CarteScreen()));
              }),
              
              // Button 4
              _buildButton(context, 'Filtres', Icons.filter_list, () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const FiltreScreen()));
              }),
              
              // Button 5
              _buildButton(context, 'Laisser Avis', Icons.star, () {
                final sampleMerchant = AvisCommercant(
                  nom: 'Burger House',
                  categorie: 'Restaurant',
                  adresse: 'Laprovale, Kouba',
                  distance: 1.5,
                  nbOffres: 4,
                  imageAsset: null,
                );
                Navigator.push(context, MaterialPageRoute(builder: (_) => LaisserAvisScreen(commercant: sampleMerchant)));
              }),
              
              // Button 6
              _buildButton(context, 'Détail Offre', Icons.info, () {
                final sampleOffre = OffreDetail(
                  id: '1',
                  nom: 'Burger Maison',
                  commercant: 'Burger House',
                  adresse: 'Kouba, Alger',
                  prix: '780 DA',
                  prixOriginal: '1100 DA',
                  distance: '1.5 km',
                  note: 4.8,
                  restants: 5,
                  creneau: '17h-19h',
                  categorie: 'Restaurant',
                  imageAsset: null,
                  description: 'Délicieux burger maison',
                  contenu: ['Burger', 'Frites'],
                );
                Navigator.push(context, MaterialPageRoute(builder: (_) => OffreDetailScreen(offre: sampleOffre)));
              }),
              
              // Button 7
              _buildButton(context, 'Profil Client', Icons.person, () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfilClientScreen()));
              }),
              
              // Button 8
              _buildButton(context, 'Profil Commerçant', Icons.store, () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfilCommercantClientScreen()));
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButton(BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF2C2814),
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 2,
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFFE07B39)),
            const SizedBox(width: 12),
            Text(title, style: const TextStyle(fontSize: 16)),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }
}