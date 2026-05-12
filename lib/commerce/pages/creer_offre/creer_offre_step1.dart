import 'dart:io';
import 'package:flutter/material.dart';
import 'creer_offre_step2.dart';

// Modèle global pour partager les données entre les 4 étapes
class NouvelleOffreData {
  static final NouvelleOffreData _instance = NouvelleOffreData._internal();
  factory NouvelleOffreData() => _instance;
  NouvelleOffreData._internal();

  // Étape 1
  String nom = '';
  String description = '';
  List<String> filtres = [];

  // Étape 2
  String prixOriginal = '';
  String prixReduit = '';
  int stock = 1;

  // Étape 3
  DateTime? dateFin;
  String creneau = '';
  String? creneauPersonnalise;
  TimeOfDay? retraitDebut;
  TimeOfDay? retraitFin;

  // Étape 4
  final List<File> photos = [];

  /// Payload "prêt backend" (hors upload images).
  /// Les images doivent être envoyées en multipart (voir `photos`).
  Map<String, dynamic> toApiPayload() {
    return {
      'nom': nom,
      'description': description,
      'filtres': filtres,
      'prixOriginal': prixOriginal,
      'prixReduit': prixReduit,
      'stock': stock,
      'dateFin': dateFin?.toIso8601String(),
      'creneauRetrait': creneau == 'Personnalisé'
          ? creneauPersonnalise
          : creneau,
      'retraitDebut': retraitDebut != null
          ? '${retraitDebut!.hour.toString().padLeft(2, '0')}:${retraitDebut!.minute.toString().padLeft(2, '0')}'
          : null,
      'retraitFin': retraitFin != null
          ? '${retraitFin!.hour.toString().padLeft(2, '0')}:${retraitFin!.minute.toString().padLeft(2, '0')}'
          : null,
    };
  }

  void reset() {
    nom = '';
    description = '';
    filtres = [];
    prixOriginal = '';
    prixReduit = '';
    stock = 1;
    dateFin = null;
    creneau = '';
    creneauPersonnalise = null;
    retraitDebut = null;
    retraitFin = null;
    photos.clear();
  }
}

class CreerOffreStep1 extends StatefulWidget {
  const CreerOffreStep1({super.key});

  @override
  State<CreerOffreStep1> createState() => _CreerOffreStep1State();
}

class _CreerOffreStep1State extends State<CreerOffreStep1> {
  static const Color topBarColor = Color(0xFFCCD5AE);
  static const Color backgroundColor = Color(0xFFFEFAE0);
  static const Color cardColor = Color(0xFFF5EED8);
  static const Color orangeColor = Color(0xFFE8824A);
  static const Color brownColor = Color(0xFF5D4E37);
  static const Color selectedFilterColor = Color(0xFFCCD5AE);

  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final NouvelleOffreData _data = NouvelleOffreData();

  final List<String> _availableFiltres = [
    'Sans gluten',
    'Sans lactose',
    'Sans sucre',
    'Végétarien',
    'Healthy',
  ];

  @override
  void initState() {
    super.initState();
    // Restaure les données si on revient en arrière
    _nomController.text = _data.nom;
    _descController.text = _data.description;
  }

  @override
  void dispose() {
    _nomController.dispose();
    _descController.dispose();
    super.dispose();
  }

  bool get _isValid =>
      _nomController.text.trim().isNotEmpty &&
      _descController.text.trim().isNotEmpty;

  void _handleNext() {
    if (!_isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez remplir le nom et la description'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    // Sauvegarde les données
    _data.nom = _nomController.text.trim();
    _data.description = _descController.text.trim();

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CreerOffreStep2()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Container(height: 8, color: topBarColor),
            // App bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () =>
                        Navigator.popUntil(context, (route) => route.isFirst),
                    child: const Icon(
                      Icons.arrow_back,
                      color: Color(0xFF3E2723),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Nouvelle offre',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF3E2723),
                    ),
                  ),
                ],
              ),
            ),
            // Progress tabs
            _buildProgressTabs(0),
            const SizedBox(height: 24),
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nom de l'offre
                    const Text(
                      "Nom de l'offre",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF3E2723),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        controller: _nomController,
                        onChanged: (_) => setState(() {}),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF424242),
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Panier boulangerie surprise ...',
                          hintStyle: TextStyle(
                            fontSize: 14,
                            color: Color(0xFFBDB5A0),
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Description
                    const Text(
                      'Description courte',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF3E2723),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        controller: _descController,
                        onChanged: (_) => setState(() {}),
                        maxLines: 5,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF424242),
                        ),
                        decoration: const InputDecoration(
                          hintText:
                              'Décrivez le contenu du panier ( pain, viennoiseries ...)',
                          hintStyle: TextStyle(
                            fontSize: 14,
                            color: Color(0xFFBDB5A0),
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Filtres alimentaires
                    const Text(
                      'Filtres alimentaires',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF3E2723),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: _availableFiltres.map((filtre) {
                        final isSelected = _data.filtres.contains(filtre);
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              if (isSelected) {
                                _data.filtres.remove(filtre);
                              } else {
                                _data.filtres.add(filtre);
                              }
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? selectedFilterColor
                                  : cardColor,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFFB8C49E)
                                    : Colors.transparent,
                              ),
                            ),
                            child: Text(
                              filtre,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: isSelected
                                    ? brownColor
                                    : const Color(0xFF424242),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
            // Buttons
            _buildButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressTabs(int currentStep) {
    final steps = ['Informations', 'Prix & stock', 'Créneau', 'Photo & aperçu'];
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE0D8C8), width: 1)),
      ),
      child: Row(
        children: List.generate(steps.length, (i) {
          final isActive = i == currentStep;
          return Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isActive ? topBarColor : Colors.transparent,
                    width: 2,
                  ),
                ),
              ),
              child: Text(
                steps[i],
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  color: isActive
                      ? const Color(0xFF3E2723)
                      : const Color(0xFF9E9E9E),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildButtons() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      child: Column(
        children: [
          // Suivant
          GestureDetector(
            onTap: _handleNext,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: _isValid ? topBarColor : topBarColor.withOpacity(0.5),
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Center(
                child: Text(
                  'Suivant',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF3E2723),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Retour
          GestureDetector(
            onTap: () => Navigator.popUntil(context, (route) => route.isFirst),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: orangeColor,
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Center(
                child: Text(
                  'Retour',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


/*

//=============================================================================================
//============================================================================================

import 'dart:io';
import 'package:flutter/material.dart';
import 'creer_offre_step2.dart';

// Modèle global pour partager les données entre les 4 étapes
class NouvelleOffreData {
  static final NouvelleOffreData _instance = NouvelleOffreData._internal();
  factory NouvelleOffreData() => _instance;
  NouvelleOffreData._internal();

  // Mode édition
  bool isEditing = false;
  String? editingOfferId;

  // Étape 1
  String nom = '';
  String description = '';
  List<String> filtres = [];

  // Étape 2
  String prixOriginal = '';
  String prixReduit = '';
  int stock = 1;

  // Étape 3
  DateTime? dateFin;
  String creneau = '';
  String? creneauPersonnalise;
  TimeOfDay? retraitDebut;
  TimeOfDay? retraitFin;

  // Étape 4
  final List<File> photos = [];
  List<String> existingImages = []; // Pour les images déjà existantes

  /// Payload "prêt backend" (hors upload images)
  Map<String, dynamic> toApiPayload() {
    return {
      'titre': nom,
      'description': description,
      'prixOriginal': double.tryParse(prixOriginal) ?? 0,
      'prixReduit': double.tryParse(prixReduit) ?? 0,
      'quantiteDisponible': stock,
      'dateExpiration': dateFin?.toIso8601String(),
      'heureDebutRetrait': _formatRetraitTime(retraitDebut, creneau, true),
      'heureFinRetrait': _formatRetraitTime(retraitFin, creneau, false),
      'typeNourriture': '',
      'allergenes': '',
      'preferencesAlim': filtres.isNotEmpty ? filtres.join(',') : null,
    };
  }

  //=============================

  //============
  String _formatRetraitTime(TimeOfDay? time, String creneau, bool isStart) {
    if (creneau == 'Personnalisé' && time != null) {
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    }
    if (creneau != 'Personnalisé' && creneau.isNotEmpty) {
      final parts = creneau.split('–');
      if (parts.length == 2) {
        final timeStr = isStart ? parts[0].trim() : parts[1].trim();
        return timeStr.replaceAll('h', ':00');
      }
    }
    return '';
  }

  void reset() {
    isEditing = false;
    editingOfferId = null;
    nom = '';
    description = '';
    filtres = [];
    prixOriginal = '';
    prixReduit = '';
    stock = 1;
    dateFin = null;
    creneau = '';
    creneauPersonnalise = null;
    retraitDebut = null;
    retraitFin = null;
    photos.clear();
    existingImages.clear();
  }

  void loadFromOffer(Map<String, dynamic> offer) {
    isEditing = true;
    editingOfferId = offer['id']?.toString();
    nom = offer['titre']?.toString() ?? '';
    description = offer['description']?.toString() ?? '';
    prixOriginal = (offer['prixOriginal'] ?? 0).toString();
    prixReduit = (offer['prixReduit'] ?? 0).toString();
    stock = offer['quantiteDisponible'] ?? 1;

    if (offer['dateExpiration'] != null) {
      dateFin = DateTime.tryParse(offer['dateExpiration'].toString());
    }

    final debut = offer['heureDebutRetrait']?.toString() ?? '';
    final fin = offer['heureFinRetrait']?.toString() ?? '';
    if (debut.isNotEmpty && fin.isNotEmpty) {
      creneau = '$debut–$fin';
    }

    // Charger les images existantes
    final images = offer['images'] as List?;
    if (images != null && images.isNotEmpty) {
      existingImages = List<String>.from(images);
    }
  }
}

class CreerOffreStep1 extends StatefulWidget {
  final bool isEditing;
  final Map<String, dynamic>? offerData;
  final String? offreId;

  const CreerOffreStep1({
    super.key,
    this.isEditing = false,
    this.offerData,
    this.offreId,
  });

  @override
  State<CreerOffreStep1> createState() => _CreerOffreStep1State();
}

class _CreerOffreStep1State extends State<CreerOffreStep1> {
  static const Color topBarColor = Color(0xFFCCD5AE);
  static const Color backgroundColor = Color(0xFFFEFAE0);
  static const Color cardColor = Color(0xFFF5EED8);
  static const Color orangeColor = Color(0xFFE8824A);
  static const Color brownColor = Color(0xFF5D4E37);
  static const Color selectedFilterColor = Color(0xFFCCD5AE);

  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final NouvelleOffreData _data = NouvelleOffreData();

  final List<String> _availableFiltres = [
    'Sans gluten',
    'Sans lactose',
    'Sans sucre',
    'Végétarien',
    'Healthy',
  ];

  @override
  void initState() {
    super.initState();

    // Si mode édition, charger les données
    if (widget.isEditing && widget.offerData != null) {
      _data.loadFromOffer(widget.offerData!);
    }

    _nomController.text = _data.nom;
    _descController.text = _data.description;
    _data.filtres.forEach((f) {
      if (!_availableFiltres.contains(f)) {
        _data.filtres.remove(f);
      }
    });
  }

  @override
  void dispose() {
    _nomController.dispose();
    _descController.dispose();
    super.dispose();
  }

  bool get _isValid =>
      _nomController.text.trim().isNotEmpty &&
      _descController.text.trim().isNotEmpty;

  void _handleNext() {
    if (!_isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez remplir le nom et la description'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    _data.nom = _nomController.text.trim();
    _data.description = _descController.text.trim();

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CreerOffreStep2()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Container(height: 8, color: topBarColor),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => widget.isEditing
                        ? Navigator.pop(context)
                        : Navigator.popUntil(context, (route) => route.isFirst),
                    child: const Icon(
                      Icons.arrow_back,
                      color: Color(0xFF3E2723),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    widget.isEditing ? 'Modifier l\'offre' : 'Nouvelle offre',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF3E2723),
                    ),
                  ),
                ],
              ),
            ),
            _buildProgressTabs(0),
            const SizedBox(height: 24),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Nom de l'offre",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF3E2723),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        controller: _nomController,
                        onChanged: (_) => setState(() {}),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF424242),
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Panier boulangerie surprise ...',
                          hintStyle: TextStyle(
                            fontSize: 14,
                            color: Color(0xFFBDB5A0),
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Description courte',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF3E2723),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        controller: _descController,
                        onChanged: (_) => setState(() {}),
                        maxLines: 5,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF424242),
                        ),
                        decoration: const InputDecoration(
                          hintText:
                              'Décrivez le contenu du panier ( pain, viennoiseries ...)',
                          hintStyle: TextStyle(
                            fontSize: 14,
                            color: Color(0xFFBDB5A0),
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Filtres alimentaires',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF3E2723),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: _availableFiltres.map((filtre) {
                        final isSelected = _data.filtres.contains(filtre);
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              if (isSelected) {
                                _data.filtres.remove(filtre);
                              } else {
                                _data.filtres.add(filtre);
                              }
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? selectedFilterColor
                                  : cardColor,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFFB8C49E)
                                    : Colors.transparent,
                              ),
                            ),
                            child: Text(
                              filtre,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: isSelected
                                    ? brownColor
                                    : const Color(0xFF424242),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
            _buildButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressTabs(int currentStep) {
    final steps = ['Informations', 'Prix & stock', 'Créneau', 'Photo & aperçu'];
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE0D8C8), width: 1)),
      ),
      child: Row(
        children: List.generate(steps.length, (i) {
          final isActive = i == currentStep;
          return Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isActive ? topBarColor : Colors.transparent,
                    width: 2,
                  ),
                ),
              ),
              child: Text(
                steps[i],
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  color: isActive
                      ? const Color(0xFF3E2723)
                      : const Color(0xFF9E9E9E),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildButtons() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      child: Column(
        children: [
          GestureDetector(
            onTap: _handleNext,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: _isValid ? topBarColor : topBarColor.withOpacity(0.5),
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Center(
                child: Text(
                  'Suivant',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF3E2723),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () => widget.isEditing
                ? Navigator.pop(context)
                : Navigator.popUntil(context, (route) => route.isFirst),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: orangeColor,
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Center(
                child: Text(
                  'Retour',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
  */