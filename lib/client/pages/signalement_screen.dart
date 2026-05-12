// ─────────────────────────────────────────────
//  SIGNALEMENT — Client
//  - SignalementScreen : formulaire (commerçant ou offre)
//  - Confirmation après envoi
// ─────────────────────────────────────────────
// ignore_for_file: unused_field, deprecated_member_use

import 'package:flutter/material.dart';

// ─────────────────────────────────────────────
// COULEURS
// ─────────────────────────────────────────────
class _C {
  static const bg       = Color(0xFFF5F0E3);
  static const card     = Color(0xFFFFFFFF);
  static const accent   = Color(0xFFE07B39);
  static const textDark = Color(0xFF2C2814);
  static const textMut  = Color(0xFF8A8070);
  static const divider  = Color(0xFFD9D0BF);
  static const green    = Color(0xFF6B7C4E);
  static const greenBg  = Color(0xFFD4EBC5);
  static const greenDk  = Color(0xFF3B6D11);
  static const red      = Color(0xFFD64545);
  static const redBg    = Color(0xFFFFEBEB);
  static const input    = Color(0xFFF0EDE0);
}

// ─────────────────────────────────────────────
// ENUM TYPE SIGNALEMENT
// ─────────────────────────────────────────────
enum TypeSignalement { commercant, offre }

// ─────────────────────────────────────────────
// SIGNALEMENT SCREEN
// ─────────────────────────────────────────────
class SignalementScreen extends StatefulWidget {
  final TypeSignalement type;

  /// Nom affiché dans le titre (commerçant ou offre)
  final String nomCible;

  const SignalementScreen({
    super.key,
    required this.type,
    required this.nomCible,
  });

  @override
  State<SignalementScreen> createState() =>
      _SignalementScreenState();
}

class _SignalementScreenState
    extends State<SignalementScreen> {
  // ── État formulaire ──
  String? _motifSelectionne;
  
  final _descCtrl = TextEditingController();
  final List<String> _preuves = []; // noms fictifs
  bool _envoye = false;

  // ── Motifs selon le type ──
  List<String> get _motifs =>
      widget.type == TypeSignalement.commercant
          ? [
              'Informations incorrectes / fausses',
              'Comportement inapproprié',
              'Commerce inexistant',
              'Photos trompeuses',
              'Escroquerie / fraude',
              'Autre',
            ]
          : [
              'Offre incorrecte ou trompeuse',
              'Prix non conforme',
              'Offre expirée toujours visible',
              'Contenu inapproprié',
              'Suspicion de fraude',
              'Autre',
            ];

  bool get _peutEnvoyer =>
      _motifSelectionne != null &&
      _descCtrl.text.trim().isNotEmpty;

  @override
  void dispose() {
    _descCtrl.dispose();
    super.dispose();
  }

  // ── Ajout preuve fictive ──
  void _ajouterPreuve() {
    final noms = [
      'photo_preuve_1.jpg',
      'capture_écran.png',
      'document.pdf',
      'photo_2.jpg',
    ];
    if (_preuves.length < 3) {
      setState(() => _preuves.add(
          noms[_preuves.length % noms.length]));
    }
  }

  void _envoyer() {
    if (!_peutEnvoyer) return;
    setState(() => _envoye = true);
  }

  // ─────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.bg,
      appBar: AppBar(
        backgroundColor: _C.bg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios,
              size: 18, color: _C.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.type == TypeSignalement.commercant
              ? 'Signaler un commerçant'
              : 'Signaler une offre',
          style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: _C.textDark),
        ),
      ),
      body: _envoye ? _confirmation() : _formulaire(),
    );
  }

  // ─────────────────────────────────────────────
  // FORMULAIRE
  // ─────────────────────────────────────────────
  Widget _formulaire() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sous-titre
          Text(
            widget.type == TypeSignalement.commercant
                ? 'Aidez-nous à maintenir une plateforme fiable en signalant tout comportement inapproprié.'
                : 'Une offre incorrecte ou suspecte ? Aidez-nous à la vérifier.',
            style: const TextStyle(
                fontSize: 13,
                color: _C.textMut,
                height: 1.5),
          ),
          const SizedBox(height: 20),

          // Cible signalée
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: _C.accent.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: _C.accent.withOpacity(0.25)),
            ),
            child: Row(
              children: [
                Icon(
                  widget.type ==
                          TypeSignalement.commercant
                      ? Icons.storefront_outlined
                      : Icons.local_offer_outlined,
                  size: 18,
                  color: _C.accent,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.nomCible,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _C.textDark),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Motif — dropdown
          _label('Motif du signalement'),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 14),
            decoration: BoxDecoration(
              color: _C.input,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _C.divider),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _motifSelectionne,
                isExpanded: true,
                hint: const Text(
                  'Choisir un motif…',
                  style: TextStyle(
                      fontSize: 13, color: _C.textMut),
                ),
                icon: const Icon(
                    Icons.keyboard_arrow_down,
                    color: _C.textMut),
                style: const TextStyle(
                    fontSize: 13, color: _C.textDark),
                dropdownColor: _C.bg,
                borderRadius: BorderRadius.circular(14),
                items: _motifs
                    .map((m) => DropdownMenuItem(
                          value: m,
                          child: Text(m),
                        ))
                    .toList(),
                onChanged: (v) =>
                    setState(() => _motifSelectionne = v),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Description
          _label('Motif de signalement'),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: _C.input,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _C.divider),
            ),
            child: TextField(
              controller: _descCtrl,
              maxLines: 5,
              onChanged: (_) => setState(() {}),
              style: const TextStyle(
                  fontSize: 13, color: _C.textDark),
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText:
                    'Expliquez votre signalement en quelques détails…',
                hintStyle: TextStyle(
                    fontSize: 13, color: _C.textMut),
                contentPadding: EdgeInsets.all(14),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Preuves
          _label('Ajouter des preuves (optionnel)'),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _C.input,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: _C.divider,
                  style: BorderStyle.solid),
            ),
            child: Column(
              children: [
                // Fichiers ajoutés
                ..._preuves.map((p) => Padding(
                      padding: const EdgeInsets.only(
                          bottom: 8),
                      child: Row(
                        children: [
                          Icon(
                            p.endsWith('.pdf')
                                ? Icons
                                    .picture_as_pdf_outlined
                                : Icons.image_outlined,
                            size: 16,
                            color: _C.textMut,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(p,
                                style: const TextStyle(
                                    fontSize: 12,
                                    color: _C.textDark)),
                          ),
                          GestureDetector(
                            onTap: () => setState(
                                () => _preuves.remove(p)),
                            child: const Icon(Icons.close,
                                size: 16,
                                color: _C.textMut),
                          ),
                        ],
                      ),
                    )),

                // Bouton ajouter
                if (_preuves.length < 3)
                  GestureDetector(
                    onTap: _ajouterPreuve,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius:
                            BorderRadius.circular(10),
                        border: Border.all(
                            color: _C.divider,
                            style: BorderStyle.solid),
                      ),
                      child: const Row(
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_photo_alternate_outlined,
                              size: 18, color: _C.textMut),
                          SizedBox(width: 8),
                          Text(
                            'Ajouter une photo ou un fichier',
                            style: TextStyle(
                                fontSize: 12,
                                color: _C.textMut),
                          ),
                        ],
                      ),
                    ),
                  ),

                if (_preuves.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      '${_preuves.length}/3 fichier(s) ajouté(s)',
                      style: const TextStyle(
                          fontSize: 10,
                          color: _C.textMut),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Bouton envoyer
          GestureDetector(
            onTap: _peutEnvoyer ? _envoyer : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: double.infinity,
              height: 54,
              decoration: BoxDecoration(
                color: _peutEnvoyer
                    ? _C.accent
                    : _C.accent.withOpacity(0.4),
                borderRadius: BorderRadius.circular(30),
                boxShadow: _peutEnvoyer
                    ? [
                        BoxShadow(
                          color:
                              _C.accent.withOpacity(0.35),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [],
              ),
              child: const Row(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  Icon(Icons.send_outlined,
                      color: Colors.white, size: 18),
                  SizedBox(width: 10),
                  Text('Envoyer le signalement',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Colors.white)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // CONFIRMATION
  // ─────────────────────────────────────────────
  Widget _confirmation() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icône succès
            Container(
              width: 90, height: 90,
              decoration: BoxDecoration(
                color: _C.accent.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                size: 50,
                color: _C.accent,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Merci pour votre contribution',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: _C.textDark),
            ),
            const SizedBox(height: 10),
            const Text(
              'Signalement envoyé avec succès.\nNotre équipe examinera votre signalement dans les plus brefs délais.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 13,
                  color: _C.textMut,
                  height: 1.6),
            ),
            const SizedBox(height: 32),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 32, vertical: 14),
                decoration: BoxDecoration(
                  color: _C.accent.withOpacity(0.12),
                  borderRadius:
                      BorderRadius.circular(30),
                  border: Border.all(
                      color: _C.accent.withOpacity(0.3)),
                ),
                child: const Text('Retour',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: _C.accent)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String t) => Text(t,
      style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: _C.textDark));
}