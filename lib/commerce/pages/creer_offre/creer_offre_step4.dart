import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'creer_offre_step1.dart';
import '../../../services/api_service.dart';

class CreerOffreStep4 extends StatefulWidget {
  const CreerOffreStep4({super.key});

  @override
  State<CreerOffreStep4> createState() => _CreerOffreStep4State();
}

class _CreerOffreStep4State extends State<CreerOffreStep4> {
  static const Color topBarColor = Color(0xFFCCD5AE);
  static const Color backgroundColor = Color(0xFFFEFAE0);
  static const Color cardColor = Color(0xFFF5EED8);
  static const Color orangeColor = Color(0xFFE8824A);
  static const Color brownColor = Color(0xFF5D4E37);

  final NouvelleOffreData _data = NouvelleOffreData();
  final ImagePicker _picker = ImagePicker();
  bool _showSuccess = false;
  bool _isPublishing = false;

  bool _isSupportedImagePath(String path) {
    final lower = path.toLowerCase();
    return lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.png');
  }

  Future<void> _pickImages() async {
    if (_data.photos.length >= 5) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Maximum 5 photos'),
            duration: Duration(seconds: 2),
          ),
        );
      }
      return;
    }

    final List<XFile> images = await _picker.pickMultiImage(
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 90,
    );

    if (images.isEmpty || !mounted) return;

    final remaining = 5 - _data.photos.length;
    final selected = images.take(remaining).toList();

    final List<File> accepted = [];
    for (final x in selected) {
      if (!_isSupportedImagePath(x.path)) continue;
      final file = File(x.path);
      final bytes = await file.length();
      if (bytes <= 5 * 1024 * 1024) {
        accepted.add(file);
      }
    }

    if (accepted.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez choisir des images JPG/PNG (≤ 5 Mo)'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() => _data.photos.addAll(accepted));

    if (images.length > remaining) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Limite atteinte : 5 photos maximum'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'jan',
      'fév',
      'mar',
      'avr',
      'mai',
      'juin',
      'juil',
      'août',
      'sep',
      'oct',
      'nov',
      'déc',
    ];
    final h = date.hour.toString().padLeft(2, '0');
    final m = date.minute.toString().padLeft(2, '0');
    return '${date.day} ${months[date.month - 1]} ${date.year} · $h:$m';
  }

  Future<void> _handlePublier() async {
    if (_isPublishing) return;

    if (_data.nom.isEmpty ||
        _data.prixOriginal.isEmpty ||
        _data.prixReduit.isEmpty ||
        _data.dateFin == null ||
        _data.creneau.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez remplir toutes les informations requises'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isPublishing = true);

    try {
      // ✅ Préparer les heures de retrait
      String heureDebutRetrait = '';
      String heureFinRetrait = '';

      if (_data.creneau == 'Personnalisé') {
        if (_data.retraitDebut != null && _data.retraitFin != null) {
          heureDebutRetrait =
              '${_data.retraitDebut!.hour.toString().padLeft(2, '0')}:${_data.retraitDebut!.minute.toString().padLeft(2, '0')}';
          heureFinRetrait =
              '${_data.retraitFin!.hour.toString().padLeft(2, '0')}:${_data.retraitFin!.minute.toString().padLeft(2, '0')}';
        }
      } else {
        // ✅ CORRIGÉ : "07h–09h" → "07:00" et "09:00"
        final parts = _data.creneau.split('–');
        if (parts.length == 2) {
          heureDebutRetrait = parts[0].trim().replaceAll('h', ':00');
          heureFinRetrait = parts[1].trim().replaceAll('h', ':00');

          // Debug logs pour vérifier les heures
          print('🕐 Créneau sélectionné: ${_data.creneau}');
          print('⏰ Heure début: $heureDebutRetrait');
          print('⏰ Heure fin: $heureFinRetrait');
        }
      }

      // ✅ Validation des heures
      if (heureDebutRetrait.isEmpty || heureFinRetrait.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Veuillez sélectionner un créneau horaire'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // ✅ Créer l'offre via l'API
      final result = await ApiService.createOffer(
        titre: _data.nom,
        description: _data.description.isNotEmpty ? _data.description : null,
        prixOriginal: double.tryParse(_data.prixOriginal) ?? 0.0,
        prixReduit: double.tryParse(_data.prixReduit) ?? 0.0,
        quantiteDisponible: _data.stock,
        heureDebutRetrait: heureDebutRetrait,
        heureFinRetrait: heureFinRetrait,
        dateExpiration: _data.dateFin != null
            ? DateTime(
                _data.dateFin!.year,
                _data.dateFin!.month,
                _data.dateFin!.day,
                23,
                59,
              ).toIso8601String()
            : null,
        preferencesAlim: _data.filtres.isNotEmpty
            ? _data.filtres.join(',')
            : null,
      );

      // ✅ Upload des photos si présentes
      final offerId =
          result['id']?.toString() ??
          result['offerId']?.toString() ??
          result['data']?['id']?.toString();

      if (offerId != null && _data.photos.isNotEmpty) {
        await ApiService.uploadOfferImages(
          offerId: offerId,
          photos: _data.photos,
        );
      }

      if (mounted) {
        setState(() => _showSuccess = true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur : ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isPublishing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Container(height: 8, color: topBarColor),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.popUntil(
                          context,
                          (route) => route.isFirst,
                        ),
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
                _buildProgressTabs(3),
                const SizedBox(height: 24),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Photos du panier',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF3E2723),
                          ),
                        ),
                        const SizedBox(height: 10),
                        GestureDetector(
                          onTap: _pickImages,
                          child: Container(
                            height: _data.photos.isNotEmpty ? 170 : 130,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: const Color(0xFFD7CFC0),
                                width: 1,
                              ),
                            ),
                            child: _data.photos.isNotEmpty
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(13),
                                    child: GridView.builder(
                                      padding: const EdgeInsets.all(10),
                                      gridDelegate:
                                          const SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 3,
                                            mainAxisSpacing: 8,
                                            crossAxisSpacing: 8,
                                          ),
                                      itemCount: _data.photos.length,
                                      itemBuilder: (context, index) {
                                        final file = _data.photos[index];
                                        return Stack(
                                          children: [
                                            Positioned.fill(
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                child: Image.file(
                                                  file,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                            Positioned(
                                              right: 4,
                                              top: 4,
                                              child: GestureDetector(
                                                onTap: () => setState(
                                                  () => _data.photos.removeAt(
                                                    index,
                                                  ),
                                                ),
                                                child: Container(
                                                  padding: const EdgeInsets.all(
                                                    4,
                                                  ),
                                                  decoration:
                                                      const BoxDecoration(
                                                        color: Colors.black54,
                                                        shape: BoxShape.circle,
                                                      ),
                                                  child: const Icon(
                                                    Icons.close,
                                                    size: 14,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                  )
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Icon(
                                        Icons.image_outlined,
                                        size: 32,
                                        color: Color(0xFFBDB5A0),
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        'Ajouter des photos',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF9E9E9E),
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        'JPG, PNG · max 5 photos · 5 Mo chacune',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Color(0xFFBDB5A0),
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                        if (_data.photos.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Text(
                                '${_data.photos.length}/5',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF9E9E9E),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const Spacer(),
                              GestureDetector(
                                onTap: _pickImages,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE8DCC0),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Text(
                                    'Ajouter',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: brownColor,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 24),
                        const Text(
                          "Aperçu de l'offre",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF3E2723),
                          ),
                        ),
                        const SizedBox(height: 10),
                        _buildApercu(),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
                _buildButtons(),
              ],
            ),

            // ── Success overlay ──
            if (_showSuccess)
              Positioned.fill(
                child: Stack(
                  children: [
                    Container(color: Colors.black.withOpacity(0.3)),
                    Center(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 32),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 28,
                          vertical: 40,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE9EDC9),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: orangeColor,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check,
                                color: Colors.black,
                                size: 44,
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'Offre publiée !',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF3E2723),
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Votre offre est maintenant visible par les clients autour de vous.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF757575),
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 28),
                            GestureDetector(
                              onTap: () {
                                _data.reset();
                                Navigator.popUntil(
                                  context,
                                  (route) => route.isFirst,
                                );
                              },
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE8DCC0),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: const Center(
                                  child: Text(
                                    'Retour',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: brownColor,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildApercu() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _data.nom.isEmpty ? 'Nom de l\'offre' : _data.nom,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF3E2723),
            ),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFE0D8C8)),
          const SizedBox(height: 12),
          _buildApercuRow(
            'Prix',
            Row(
              children: [
                Text(
                  _data.prixReduit.isEmpty ? '—' : '${_data.prixReduit} DA',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF3E2723),
                  ),
                ),
                if (_data.prixOriginal.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Text(
                    '${_data.prixOriginal} DA',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF9E9E9E),
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 10),
          _buildApercuRow(
            'Stock',
            Text(
              '${_data.stock} disponibles',
              style: const TextStyle(fontSize: 14, color: Color(0xFF3E2723)),
            ),
          ),
          const SizedBox(height: 10),
          _buildApercuRow(
            'Retrait',
            Text(
              _data.creneau.isEmpty
                  ? '—'
                  : (_data.creneau == 'Personnalisé'
                        ? (_data.creneauPersonnalise ?? '—')
                        : _data.creneau),
              style: const TextStyle(fontSize: 14, color: Color(0xFF3E2723)),
            ),
          ),
          if (_data.filtres.isNotEmpty) ...[
            const SizedBox(height: 10),
            _buildApercuRow(
              'Filtres',
              Wrap(
                spacing: 6,
                children: _data.filtres
                    .map(
                      (f) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: orangeColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          f,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
          if (_data.dateFin != null) ...[
            const SizedBox(height: 10),
            _buildApercuRow(
              'Date fin',
              Text(
                _formatDate(_data.dateFin!),
                style: const TextStyle(fontSize: 14, color: Color(0xFF3E2723)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildApercuRow(String label, Widget value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: const TextStyle(fontSize: 13, color: Color(0xFF9E9E9E)),
          ),
        ),
        Expanded(child: value),
      ],
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
            onTap: _isPublishing ? null : _handlePublier,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: _isPublishing
                    ? topBarColor.withOpacity(0.6)
                    : topBarColor,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Center(
                child: _isPublishing
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFF3E2723),
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Publication...',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF3E2723),
                            ),
                          ),
                        ],
                      )
                    : const Text(
                        "Publier l'offre",
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
            onTap: () => Navigator.pop(context),
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


//========================================================================================
//=======================================================================================
/*
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'creer_offre_step1.dart';
import '../../../services/api_service.dart';

class CreerOffreStep4 extends StatefulWidget {
  const CreerOffreStep4({super.key});

  @override
  State<CreerOffreStep4> createState() => _CreerOffreStep4State();
}

class _CreerOffreStep4State extends State<CreerOffreStep4> {
  static const Color topBarColor = Color(0xFFCCD5AE);
  static const Color backgroundColor = Color(0xFFFEFAE0);
  static const Color cardColor = Color(0xFFF5EED8);
  static const Color orangeColor = Color(0xFFE8824A);
  static const Color brownColor = Color(0xFF5D4E37);

  final NouvelleOffreData _data = NouvelleOffreData();
  final ImagePicker _picker = ImagePicker();
  bool _showSuccess = false;
  bool _isPublishing = false;

  bool _isSupportedImagePath(String path) {
    final lower = path.toLowerCase();
    return lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.png');
  }

  Future<void> _pickImages() async {
    if (_data.photos.length >= 5) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Maximum 5 photos'),
            duration: Duration(seconds: 2),
          ),
        );
      }
      return;
    }

    final List<XFile> images = await _picker.pickMultiImage(
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 90,
    );

    if (images.isEmpty || !mounted) return;

    final remaining = 5 - _data.photos.length;
    final selected = images.take(remaining).toList();

    final List<File> accepted = [];
    for (final x in selected) {
      if (!_isSupportedImagePath(x.path)) continue;
      final file = File(x.path);
      final bytes = await file.length();
      if (bytes <= 5 * 1024 * 1024) {
        accepted.add(file);
      }
    }

    if (accepted.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez choisir des images JPG/PNG (≤ 5 Mo)'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() => _data.photos.addAll(accepted));

    if (images.length > remaining) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Limite atteinte : 5 photos maximum'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'jan',
      'fév',
      'mar',
      'avr',
      'mai',
      'juin',
      'juil',
      'août',
      'sep',
      'oct',
      'nov',
      'déc',
    ];
    final h = date.hour.toString().padLeft(2, '0');
    final m = date.minute.toString().padLeft(2, '0');
    return '${date.day} ${months[date.month - 1]} ${date.year} · $h:$m';
  }

  Future<void> _handlePublier() async {
    if (_isPublishing) return;

    if (_data.nom.isEmpty ||
        _data.prixOriginal.isEmpty ||
        _data.prixReduit.isEmpty ||
        _data.dateFin == null ||
        _data.creneau.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez remplir toutes les informations requises'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isPublishing = true);

    try {
      String heureDebutRetrait = '';
      String heureFinRetrait = '';

      if (_data.creneau == 'Personnalisé') {
        if (_data.retraitDebut != null && _data.retraitFin != null) {
          heureDebutRetrait =
              '${_data.retraitDebut!.hour.toString().padLeft(2, '0')}:${_data.retraitDebut!.minute.toString().padLeft(2, '0')}';
          heureFinRetrait =
              '${_data.retraitFin!.hour.toString().padLeft(2, '0')}:${_data.retraitFin!.minute.toString().padLeft(2, '0')}';
        }
      } else {
        final parts = _data.creneau.split('–');
        if (parts.length == 2) {
          heureDebutRetrait = parts[0].trim().replaceAll('h', ':00');
          heureFinRetrait = parts[1].trim().replaceAll('h', ':00');
        }
      }

      if (_data.isEditing && _data.editingOfferId != null) {
        // ✅ MODE MISE À JOUR - Correction des types nullable
        await ApiService.updateOffer(
          _data.editingOfferId!,
          titre: _data.nom,
          description: _data.description.isNotEmpty ? _data.description : null,
          prixOriginal: double.tryParse(_data.prixOriginal) ?? 0.0,
          prixReduit: double.tryParse(_data.prixReduit) ?? 0.0,
          quantiteDisponible: _data.stock,
          heureDebutRetrait: heureDebutRetrait,
          heureFinRetrait: heureFinRetrait,
          dateExpiration: _data.dateFin != null
              ? DateTime(
                  _data.dateFin!.year,
                  _data.dateFin!.month,
                  _data.dateFin!.day,
                  23,
                  59,
                ).toIso8601String()
              : '', // ← Ajoute une valeur par défaut non-nullable
          preferencesAlim: _data.filtres.isNotEmpty
              ? _data.filtres.join(',')
              : null,
          typeNourriture: '', // ← Valeur par défaut
          allergenes: '', // ← Valeur par défaut
        );

        // Upload des nouvelles photos
        if (_data.photos.isNotEmpty) {
          await ApiService.uploadOfferImages(
            offerId: _data.editingOfferId!,
            photos: _data.photos,
          );
        }
      } else {
        // ✅ MODE CRÉATION
        final result = await ApiService.createOffer(
          titre: _data.nom,
          description: _data.description.isNotEmpty ? _data.description : null,
          prixOriginal: double.tryParse(_data.prixOriginal) ?? 0.0,
          prixReduit: double.tryParse(_data.prixReduit) ?? 0.0,
          quantiteDisponible: _data.stock,
          heureDebutRetrait: heureDebutRetrait,
          heureFinRetrait: heureFinRetrait,
          dateExpiration: _data.dateFin != null
              ? DateTime(
                  _data.dateFin!.year,
                  _data.dateFin!.month,
                  _data.dateFin!.day,
                  23,
                  59,
                ).toIso8601String()
              : null,
          preferencesAlim: _data.filtres.isNotEmpty
              ? _data.filtres.join(',')
              : null,
        );

        final offerId =
            result['id']?.toString() ??
            result['offerId']?.toString() ??
            result['data']?['id']?.toString();

        if (offerId != null && _data.photos.isNotEmpty) {
          await ApiService.uploadOfferImages(
            offerId: offerId,
            photos: _data.photos,
          );
        }
      }

      if (mounted) {
        setState(() => _showSuccess = true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur : ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isPublishing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = _data.isEditing;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Container(height: 8, color: topBarColor),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(
                          Icons.arrow_back,
                          color: Color(0xFF3E2723),
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        isEditing ? 'Modifier l\'offre' : 'Nouvelle offre',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF3E2723),
                        ),
                      ),
                    ],
                  ),
                ),
                _buildProgressTabs(3),
                const SizedBox(height: 24),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Photos du panier',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF3E2723),
                          ),
                        ),
                        const SizedBox(height: 10),
                        GestureDetector(
                          onTap: _pickImages,
                          child: Container(
                            height:
                                _data.photos.isNotEmpty ||
                                    _data.existingImages.isNotEmpty
                                ? 170
                                : 130,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: const Color(0xFFD7CFC0),
                                width: 1,
                              ),
                            ),
                            child:
                                (_data.photos.isNotEmpty ||
                                    _data.existingImages.isNotEmpty)
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(13),
                                    child: GridView.builder(
                                      padding: const EdgeInsets.all(10),
                                      gridDelegate:
                                          const SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 3,
                                            mainAxisSpacing: 8,
                                            crossAxisSpacing: 8,
                                          ),
                                      itemCount:
                                          _data.photos.length +
                                          _data.existingImages.length,
                                      itemBuilder: (context, index) {
                                        final isExisting =
                                            index < _data.existingImages.length;
                                        final imageUrl = isExisting
                                            ? _data.existingImages[index]
                                            : null;
                                        final imageFile = !isExisting
                                            ? _data.photos[index -
                                                  _data.existingImages.length]
                                            : null;

                                        return Stack(
                                          children: [
                                            Positioned.fill(
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                child: imageFile != null
                                                    ? Image.file(
                                                        imageFile,
                                                        fit: BoxFit.cover,
                                                      )
                                                    : Image.network(
                                                        imageUrl!,
                                                        fit: BoxFit.cover,
                                                        errorBuilder:
                                                            (
                                                              context,
                                                              error,
                                                              stackTrace,
                                                            ) {
                                                              return Container(
                                                                color: Colors
                                                                    .grey[300],
                                                                child: const Icon(
                                                                  Icons
                                                                      .broken_image,
                                                                ),
                                                              );
                                                            },
                                                      ),
                                              ),
                                            ),
                                            Positioned(
                                              right: 4,
                                              top: 4,
                                              child: GestureDetector(
                                                onTap: () => setState(() {
                                                  if (isExisting) {
                                                    _data.existingImages
                                                        .removeAt(index);
                                                  } else {
                                                    _data.photos.removeAt(
                                                      index -
                                                          _data
                                                              .existingImages
                                                              .length,
                                                    );
                                                  }
                                                }),
                                                child: Container(
                                                  padding: const EdgeInsets.all(
                                                    4,
                                                  ),
                                                  decoration:
                                                      const BoxDecoration(
                                                        color: Colors.black54,
                                                        shape: BoxShape.circle,
                                                      ),
                                                  child: const Icon(
                                                    Icons.close,
                                                    size: 14,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                  )
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Icon(
                                        Icons.image_outlined,
                                        size: 32,
                                        color: Color(0xFFBDB5A0),
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        'Ajouter des photos',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF9E9E9E),
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        'JPG, PNG · max 5 photos · 5 Mo chacune',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Color(0xFFBDB5A0),
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                        if (_data.photos.isNotEmpty ||
                            _data.existingImages.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Text(
                                '${_data.photos.length + _data.existingImages.length}/5',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF9E9E9E),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const Spacer(),
                              GestureDetector(
                                onTap: _pickImages,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE8DCC0),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Text(
                                    'Ajouter',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: brownColor,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 24),
                        const Text(
                          "Aperçu de l'offre",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF3E2723),
                          ),
                        ),
                        const SizedBox(height: 10),
                        _buildApercu(),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
                _buildButtons(),
              ],
            ),

            // Success overlay
            if (_showSuccess)
              Positioned.fill(
                child: Stack(
                  children: [
                    Container(color: Colors.black.withOpacity(0.3)),
                    Center(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 32),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 28,
                          vertical: 40,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE9EDC9),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: orangeColor,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check,
                                color: Colors.black,
                                size: 44,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              isEditing
                                  ? 'Offre modifiée !'
                                  : 'Offre publiée !',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF3E2723),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              isEditing
                                  ? 'Votre offre a été mise à jour avec succès.'
                                  : 'Votre offre est maintenant visible par les clients autour de vous.',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF757575),
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 28),
                            GestureDetector(
                              onTap: () {
                                _data.reset();
                                Navigator.popUntil(
                                  context,
                                  (route) => route.isFirst,
                                );
                              },
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE8DCC0),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: const Center(
                                  child: Text(
                                    'Retour',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: brownColor,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildApercu() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _data.nom.isEmpty ? 'Nom de l\'offre' : _data.nom,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF3E2723),
            ),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFE0D8C8)),
          const SizedBox(height: 12),
          _buildApercuRow(
            'Prix',
            Row(
              children: [
                Text(
                  _data.prixReduit.isEmpty ? '—' : '${_data.prixReduit} DA',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF3E2723),
                  ),
                ),
                if (_data.prixOriginal.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Text(
                    '${_data.prixOriginal} DA',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF9E9E9E),
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 10),
          _buildApercuRow(
            'Stock',
            Text(
              '${_data.stock} disponibles',
              style: const TextStyle(fontSize: 14, color: Color(0xFF3E2723)),
            ),
          ),
          const SizedBox(height: 10),
          _buildApercuRow(
            'Retrait',
            Text(
              _data.creneau.isEmpty
                  ? '—'
                  : (_data.creneau == 'Personnalisé'
                        ? (_data.creneauPersonnalise ?? '—')
                        : _data.creneau),
              style: const TextStyle(fontSize: 14, color: Color(0xFF3E2723)),
            ),
          ),
          if (_data.filtres.isNotEmpty) ...[
            const SizedBox(height: 10),
            _buildApercuRow(
              'Filtres',
              Wrap(
                spacing: 6,
                children: _data.filtres
                    .map(
                      (f) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: orangeColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          f,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
          if (_data.dateFin != null) ...[
            const SizedBox(height: 10),
            _buildApercuRow(
              'Date fin',
              Text(
                _formatDate(_data.dateFin!),
                style: const TextStyle(fontSize: 14, color: Color(0xFF3E2723)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildApercuRow(String label, Widget value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: const TextStyle(fontSize: 13, color: Color(0xFF9E9E9E)),
          ),
        ),
        Expanded(child: value),
      ],
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
            onTap: _isPublishing ? null : _handlePublier,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: _isPublishing
                    ? topBarColor.withOpacity(0.6)
                    : topBarColor,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Center(
                child: _isPublishing
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFF3E2723),
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Publication...',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF3E2723),
                            ),
                          ),
                        ],
                      )
                    : Text(
                        _data.isEditing ? "Mettre à jour" : "Publier l'offre",
                        style: const TextStyle(
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
            onTap: () => Navigator.pop(context),
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