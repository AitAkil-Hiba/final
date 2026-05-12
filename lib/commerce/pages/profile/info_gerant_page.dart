import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../../services/api_service.dart';

class InfoGerantPage extends StatefulWidget {
  const InfoGerantPage({super.key});

  @override
  State<InfoGerantPage> createState() => _InfoGerantPageState();
}

class _InfoGerantPageState extends State<InfoGerantPage> {
  static const Color topBarColor = Color(0xFFCCD5AE);
  static const Color backgroundColor = Color(0xFFFEFAE0);
  static const Color cardColor = Color(0xFFF5EED8);
  static const Color brownColor = Color(0xFF5D4E37);
  static const Color orangeColor = Color(0xFFE8824A);

  bool _isEditing = false;
  bool _showSuccess = false;
  bool _isLoading = false;

  // Pour la photo de profil
  String? _selectedImagePath;
  final ImagePicker _picker = ImagePicker();

  // Pour la validation du téléphone
  String? _telephoneError;

  // Controllers pour les champs
  final TextEditingController _prenomController = TextEditingController();
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _telephoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadMerchantProfile();
  }

  @override
  void dispose() {
    _prenomController.dispose();
    _nomController.dispose();
    _emailController.dispose();
    _telephoneController.dispose();
    super.dispose();
  }

  // Charger les données du profil depuis l'API
  Future<void> _loadMerchantProfile() async {
    setState(() => _isLoading = true);

    try {
      print('🔍 Chargement du profil gérant...');
      final response = await ApiService.getCurrentProfile();
      print('📥 Réponse API: $response');

      final data = response['data'] ?? response;
      print('📋 Données extraites: $data');

      setState(() {
        // Extraire le nom complet et le diviser
        String fullName = data['fullName'] ?? data['nom'] ?? '';
        List<String> nameParts = fullName.split(' ');
        _prenomController.text = nameParts.isNotEmpty ? nameParts.first : '';
        _nomController.text = nameParts.length > 1
            ? nameParts.sublist(1).join(' ')
            : '';

        _emailController.text = data['email'] ?? '';
        _telephoneController.text = data['telephone'] ?? data['phone'] ?? '';
        _selectedImagePath =
            data['photoUrl'] ??
            data['photoPath'] ??
            data['profileImage'] ??
            data['photo'];
        _isLoading = false;
      });

      print('✅ Profil chargé avec succès');
    } catch (e) {
      print('❌ ERREUR chargement profil: $e');
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du chargement: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Fonction pour choisir une image depuis la galerie
  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _selectedImagePath = image.path;
        });

        // Backend: Uploader l'image vers votre API
        try {
          await ApiService.uploadProfilePhoto(File(image.path));
          print('✅ Photo uploadée avec succès');
        } catch (e) {
          print('❌ Erreur upload: $e');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // Validation du numéro de téléphone algérien
  String? _validateTelephone(String value) {
    if (value.isEmpty) {
      return 'Le numéro est requis';
    }

    // Supprimer les espaces et les tirets
    String cleaned = value.replaceAll(RegExp(r'[\s\-]'), '');

    // Vérifier que c'est 10 chiffres
    if (cleaned.length != 10) {
      return 'Le numéro doit contenir 10 chiffres';
    }

    // Vérifier que ça commence par 05, 06 ou 07
    if (!cleaned.startsWith(RegExp(r'05|06|07'))) {
      return 'Numéro invalide (doit commencer par 05, 06 ou 07)';
    }

    // Vérifier que ce sont bien des chiffres
    if (!RegExp(r'^\d+$').hasMatch(cleaned)) {
      return 'Le numéro ne doit contenir que des chiffres';
    }

    return null;
  }

  void _onTelephoneChanged(String value) {
    setState(() {
      _telephoneError = _validateTelephone(value);
    });
  }

  Future<void> _handleConfirmer() async {
    // Valider le téléphone avant sauvegarde
    String phone = _telephoneController.text;
    String? error = _validateTelephone(phone);

    if (error != null) {
      setState(() {
        _telephoneError = error;
      });
      return;
    }

    setState(() => _isLoading = true);

    try {
      print('💾 Sauvegarde du profil gérant...');
      print('📤 Données à envoyer:');
      print('  - fullName: ${_prenomController.text} ${_nomController.text}');
      print('  - email: ${_emailController.text}');
      print('  - telephone: ${_telephoneController.text}');

      // Sauvegarder via l'API - envoyer seulement les champs modifiés
      final result = await ApiService.updateProfile(
        fullName: '${_prenomController.text} ${_nomController.text}'.trim(),
        email: _emailController.text,
        telephone: _telephoneController.text,
      );

      print('✅ Sauvegarde réussie: $result');

      setState(() {
        _isEditing = false;
        _showSuccess = true;
        _isLoading = false;
      });

      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) setState(() => _showSuccess = false);
      });
    } catch (e) {
      print('❌ ERREUR sauvegarde: $e');
      setState(() => _isLoading = false);
      if (mounted) {
        // Vérifier si c'est une erreur d'autorisation (token expiré)
        String errorMsg = e.toString();
        bool isUnauthorized =
            errorMsg.toLowerCase().contains('unauthorized') ||
            errorMsg.toLowerCase().contains('401');

        if (isUnauthorized) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                'Session expirée. Veuillez vous reconnecter.',
              ),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
              action: SnackBarAction(
                label: 'Reconnecter',
                textColor: Colors.white,
                onPressed: () {
                  // Redirection vers la page de connexion
                  Navigator.of(
                    context,
                  ).pushNamedAndRemoveUntil('/login', (route) => false);
                },
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur lors de la sauvegarde: $errorMsg'),
              backgroundColor: Colors.red,
            ),
          );
        }
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
                        onTap: () => Navigator.pop(context),
                        child: const Icon(
                          Icons.arrow_back,
                          color: Color(0xFF3E2723),
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Informations du gérant',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF3E2723),
                          ),
                        ),
                      ),
                      // Bouton Modifier
                      if (!_isEditing)
                        GestureDetector(
                          onTap: () => setState(() => _isEditing = true),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'Modifier',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: brownColor,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        const SizedBox(height: 24),
                        // Photo de profil
                        GestureDetector(
                          onTap: _isEditing ? _pickImage : null,
                          child: Stack(
                            children: [
                              Container(
                                width: 90,
                                height: 90,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFD7CFC0),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: topBarColor,
                                    width: 2,
                                  ),
                                  image: _selectedImagePath != null
                                      ? DecorationImage(
                                          image: FileImage(
                                            File(_selectedImagePath!),
                                          ),
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                                ),
                                child: _selectedImagePath == null
                                    ? const Center(
                                        child: Text(
                                          'ML',
                                          style: TextStyle(
                                            fontSize: 28,
                                            fontWeight: FontWeight.w700,
                                            color: brownColor,
                                          ),
                                        ),
                                      )
                                    : null,
                              ),
                              if (_isEditing)
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: GestureDetector(
                                    onTap: _pickImage,
                                    child: Container(
                                      width: 28,
                                      height: 28,
                                      decoration: BoxDecoration(
                                        color: orangeColor,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.camera_alt,
                                        size: 14,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),
                        // Champs
                        Row(
                          children: [
                            Expanded(
                              child: _buildField(
                                label: 'Prénom',
                                controller: _prenomController,
                                icon: Icons.person_outline,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildField(
                                label: 'Nom',
                                controller: _nomController,
                                icon: Icons.person_outline,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildField(
                          label: 'Adresse e-mail professionnel',
                          controller: _emailController,
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 16),
                        _buildField(
                          label: 'Numéro de téléphone',
                          controller: _telephoneController,
                          icon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                          onChanged: _onTelephoneChanged,
                          errorText: _telephoneError,
                        ),
                        const SizedBox(height: 32),
                        // Bouton Confirmer
                        if (_isEditing)
                          GestureDetector(
                            onTap: _handleConfirmer,
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                color: topBarColor,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: const Center(
                                child: Text(
                                  'Confirmer',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: brownColor,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // ── Toast succès ──
            if (_showSuccess)
              Positioned(
                bottom: 30,
                left: 20,
                right: 20,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3E2723),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        color: Colors.white,
                        size: 20,
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Vos modifications sont enregistrées',
                        style: TextStyle(color: Colors.white, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    void Function(String)? onChanged,
    String? errorText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Color(0xFF757575),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: controller,
            enabled: _isEditing,
            keyboardType: keyboardType,
            style: const TextStyle(fontSize: 14, color: Color(0xFF3E2723)),
            onChanged: onChanged,
            decoration: InputDecoration(
              prefixIcon: Icon(icon, size: 18, color: const Color(0xFF9E9E9E)),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 14,
              ),
              errorText: errorText,
              errorStyle: const TextStyle(fontSize: 11),
            ),
          ),
        ),
      ],
    );
  }
}
