// offre_detail_screen.dart
// ignore_for_file: deprecated_member_use, prefer_final_fields, unused_field, sort_child_properties_last, sized_box_for_whitespace

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:peeco/client/pages/app_constants.dart';

// ─────────────────────────────────────────────
// MODÈLE — OffreDetail
// ─────────────────────────────────────────────
class OffreDetail {
  final String id;
  final String nom;
  final String commercant;
  final String adresse;
  final String prix;
  final String prixOriginal;
  final String distance;
  final double note;
  final int restants;
  final String creneau;
  final String categorie;
  final String? imageAsset;
  final String description;
  final List<String> contenu;

  const OffreDetail({
    required this.id,
    required this.nom,
    required this.commercant,
    required this.adresse,
    required this.prix,
    required this.prixOriginal,
    required this.distance,
    required this.note,
    required this.restants,
    required this.creneau,
    required this.categorie,
    this.imageAsset,
    required this.description,
    required this.contenu,
  });
}

// ─────────────────────────────────────────────
// COULEURS
// ─────────────────────────────────────────────
class _C {
  static const scaffold    = Color(0xFFE8E0CE);
  static const cardBg      = Color(0xFFF5F0E3);
  static const accent      = Color(0xFFE07B39);
  static const textDark    = Color(0xFF2C2814);
  static const textMuted   = Color(0xFF8A8070);
  static const divider     = Color(0xFFD9D0BF);
  static const chipDark    = Color(0xFF6B7C4E);
  static const white       = Color(0xFFFFFFFF);
  static const navBg       = Color(0xFFB5C49E);
  static const offerCardBg = Color(0xFFC8B99A);
  static const success     = Color(0xFF4CAF50);
  static const warning     = Color(0xFFFF9800);
}

// ─────────────────────────────────────────────
// ÉCRAN DÉTAIL OFFRE
// ─────────────────────────────────────────────
class OffreDetailScreen extends StatefulWidget {
  final OffreDetail offre;
  const OffreDetailScreen({super.key, required this.offre});

  @override
  State<OffreDetailScreen> createState() => _OffreDetailScreenState();
}

class _OffreDetailScreenState extends State<OffreDetailScreen> {
  int _quantity = 1;
  int _serviceMode = 0;
  int _selectedSlot = 0;

  final List<Map<String, dynamic>> _timeSlots = [
    {'label': '13h–14h', 'available': true},
    {'label': '17h–19h', 'available': true},
    {'label': '19h–20h', 'available': false},
  ];

  OffreDetail get o => widget.offre;

  int get _totalPrice {
    final raw = o.prix.replaceAll(RegExp(r'[^0-9]'), '');
    return (int.tryParse(raw) ?? 0) * _quantity;
  }

  int get _savings {
    final prixN = int.tryParse(o.prix.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    final origN = int.tryParse(o.prixOriginal.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    return origN - prixN;
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    return Scaffold(
      backgroundColor: _C.scaffold,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _heroImage()),
              SliverToBoxAdapter(
                child: Container(
                  decoration: const BoxDecoration(
                    color: _C.scaffold,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _titleSection(),
                        const SizedBox(height: 20),
                        _statsRow(),
                        const SizedBox(height: 20),
                        _priceSection(),
                        const SizedBox(height: 24),
                        _infoCard(Icons.access_time_outlined, 'Créneau disponible', o.creneau, _C.accent),
                        const SizedBox(height: 16),
                        _infoCard(Icons.store_outlined, 'Commerçant', o.commercant, _C.chipDark),
                        const SizedBox(height: 16),
                        _infoCard(Icons.location_on_outlined, 'Adresse', o.adresse, _C.textMuted),
                        const SizedBox(height: 24),
                        _divider(),
                        const SizedBox(height: 16),
                        _descriptionSection(),
                        const SizedBox(height: 16),
                        _divider(),
                        const SizedBox(height: 16),
                        _contentSection(),
                        const SizedBox(height: 16),
                        _divider(),
                        const SizedBox(height: 16),
                        _serviceModeSection(),
                        const SizedBox(height: 16),
                        _divider(),
                        const SizedBox(height: 16),
                        _timeSlotsSection(),
                        const SizedBox(height: 16),
                        _divider(),
                        const SizedBox(height: 16),
                        _quantitySection(),
                        const SizedBox(height: 140),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          Positioned(bottom: 0, left: 0, right: 0, child: _bottomBar()),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // HERO IMAGE
  // ─────────────────────────────────────────────
  Widget _heroImage() {
    return SizedBox(
      height: 340,
      child: Stack(
        children: [
          Positioned.fill(
            child: o.imageAsset != null
                ? Image.asset(o.imageAsset!, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(color: _C.offerCardBg))
                : Container(color: _C.offerCardBg),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black.withOpacity(0.5), Colors.transparent],
                ),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 16,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 40, height: 40,
                decoration: const BoxDecoration(color: _C.white, shape: BoxShape.circle),
                child: const Icon(Icons.arrow_back_ios_new, size: 18, color: _C.textDark),
              ),
            ),
          ),
          Positioned(
            bottom: 16, left: 16, right: 16,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _C.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, size: 14, color: _C.accent),
                      const SizedBox(width: 4),
                      Text(o.note.toString(), style: const TextStyle(fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: o.restants <= 2 ? _C.warning : _C.success,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('${o.restants} restants', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // TITLE SECTION
  // ─────────────────────────────────────────────
  Widget _titleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: _C.chipDark.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(o.categorie, style: const TextStyle(fontSize: 11, color: _C.chipDark, fontWeight: FontWeight.w600)),
        ),
        const SizedBox(height: 12),
        Text(o.nom, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: _C.textDark, height: 1.2)),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // STATS ROW
  // ─────────────────────────────────────────────
  Widget _statsRow() {
    return Row(
      children: [
        _statChip(Icons.shopping_bag_outlined, '${o.restants} restants'),
        const SizedBox(width: 12),
        _statChip(Icons.access_time_outlined, o.creneau),
        const SizedBox(width: 12),
        _statChip(Icons.location_on_outlined, o.distance),
      ],
    );
  }

  Widget _statChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: _C.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _C.divider),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: _C.accent),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // PRICE SECTION
  // ─────────────────────────────────────────────
  Widget _priceSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [const Color(0xFFFAEDCD), const Color(0xFFF5F0E3)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _C.accent.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Prix', style: TextStyle(fontSize: 12, color: _C.textMuted)),
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(o.prix, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: _C.accent)),
                  const SizedBox(width: 8),
                  Text(o.prixOriginal, style: const TextStyle(fontSize: 14, color: _C.textMuted, decoration: TextDecoration.lineThrough)),
                ],
              ),
            ],
          ),
          if (_savings > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _C.success.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Text('Économie', style: TextStyle(fontSize: 10, color: _C.textMuted)),
                  Text('-$_savings DA', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: _C.success)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // INFO CARD
  // ─────────────────────────────────────────────
  Widget _infoCard(IconData icon, String label, String value, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _C.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _C.divider.withOpacity(0.6)),
      ),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(color: iconColor.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 11, color: _C.textMuted)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _C.textDark)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // DESCRIPTION SECTION
  // ─────────────────────────────────────────────
  Widget _descriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Description', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _C.textDark)),
        const SizedBox(height: 8),
        Text(o.description, style: const TextStyle(fontSize: 13, color: _C.textMuted, height: 1.5)),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // CONTENT SECTION
  // ─────────────────────────────────────────────
  Widget _contentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Contenu', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _C.textDark)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _C.cardBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _C.divider.withOpacity(0.6)),
          ),
          child: Column(
            children: o.contenu.map((item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Icon(Icons.check_circle, size: 16, color: _C.accent),
                  const SizedBox(width: 10),
                  Expanded(child: Text(item, style: const TextStyle(fontSize: 13))),
                ],
              ),
            )).toList(),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // SERVICE MODE SECTION
  // ─────────────────────────────────────────────
  Widget _serviceModeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Mode de service', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _C.textDark)),
        const SizedBox(height: 10),
        Row(
          children: [
            _serviceButton(0, Icons.shopping_bag_outlined, 'À emporter'),
            const SizedBox(width: 12),
            _serviceButton(1, Icons.local_taxi_outlined, 'Livraison'),
          ],
        ),
      ],
    );
  }

  Widget _serviceButton(int index, IconData icon, String label) {
    final selected = _serviceMode == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _serviceMode = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? _C.accent : _C.cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: selected ? _C.accent : _C.divider),
          ),
          child: Column(
            children: [
              Icon(icon, size: 28, color: selected ? Colors.white : _C.textMuted),
              const SizedBox(height: 6),
              Text(label,
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: selected ? Colors.white : _C.textDark)),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // TIME SLOTS SECTION
  // ─────────────────────────────────────────────
  Widget _timeSlotsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Créneaux disponibles', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _C.textDark)),
        const SizedBox(height: 10),
        Row(
          children: List.generate(_timeSlots.length, (i) {
            final slot = _timeSlots[i];
            final available = slot['available'] as bool;
            final selected = _selectedSlot == i && available;
            return Padding(
              padding: EdgeInsets.only(right: i < _timeSlots.length - 1 ? 10 : 0),
              child: GestureDetector(
                onTap: available ? () => setState(() => _selectedSlot = i) : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: selected ? _C.accent : _C.cardBg,
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: selected ? _C.accent : (available ? _C.divider : _C.divider)),
                  ),
                  child: Text(
                    slot['label'] as String,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: selected ? Colors.white : (available ? _C.textDark : _C.textMuted),
                      decoration: !available ? TextDecoration.lineThrough : TextDecoration.none,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // QUANTITY SECTION
  // ─────────────────────────────────────────────
  Widget _quantitySection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Quantité', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _C.textDark)),
        Row(
          children: [
            GestureDetector(
              onTap: () => setState(() => _quantity = (_quantity > 1 ? _quantity - 1 : 1)),
              child: Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: _C.cardBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _C.divider),
                ),
                child: const Icon(Icons.remove, size: 20, color: _C.textDark),
              ),
            ),
            const SizedBox(width: 16),
            Text('$_quantity', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: _C.textDark)),
            const SizedBox(width: 16),
            GestureDetector(
              onTap: () => setState(() => _quantity = (_quantity < o.restants ? _quantity + 1 : o.restants)),
              child: Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: _C.accent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.add, size: 20, color: Colors.white),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // BOTTOM BAR
  // ─────────────────────────────────────────────
  Widget _bottomBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 12, 20, MediaQuery.of(context).padding.bottom + 12),
      decoration: BoxDecoration(
        color: _C.cardBg,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 12, offset: const Offset(0, -4))],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Total à payer', style: TextStyle(fontSize: 12, color: _C.textMuted)),
                  Text('$_totalPrice DA', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: _C.accent)),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/cart'),
                child: Container(
                  height: 54,
                  decoration: BoxDecoration(
                    color: _C.accent,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [BoxShadow(color: _C.accent.withOpacity(0.35), blurRadius: 10, offset: const Offset(0, 4))],
                  ),
                  child: const Center(
                    child: Text('Ajouter au panier',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _divider() => Divider(color: _C.divider.withOpacity(0.7), height: 1);
}