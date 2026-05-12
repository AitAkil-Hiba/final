import 'package:flutter/material.dart';
import '../../../services/api_service.dart';

class InfoCommercePage extends StatefulWidget {
  const InfoCommercePage({super.key});

  @override
  State<InfoCommercePage> createState() => _InfoCommercePageState();
}

class _InfoCommercePageState extends State<InfoCommercePage> {
  static const Color topBarColor = Color(0xFFCCD5AE);
  static const Color backgroundColor = Color(0xFFFEFAE0);
  static const Color cardColor = Color(0xFFF5EED8);
  static const Color brownColor = Color(0xFF5D4E37);
  static const Color orangeColor = Color(0xFFE8824A);

  bool _isEditing = false;
  bool _showSuccess = false;
  bool _isLoading = false;

  // Types de commerce
  final List<String> _typesCommerce = [
    'Café',
    'Superette',
    'Pâtisserie',
    'Boucherie',
    'Epicerie',
    'Boulangerie',
    'Restaurant',
  ];

  // 58 Wilayas algériennes
  final List<String> _wilayas = [
    '01 - Adrar',
    '02 - Chlef',
    '03 - Laghouat',
    '04 - Oum El Bouaghi',
    '05 - Batna',
    '06 - Béjaïa',
    '07 - Biskra',
    '08 - Béchar',
    '09 - Blida',
    '10 - Bouira',
    '11 - Tamanrasset',
    '12 - Tébessa',
    '13 - Tlemcen',
    '14 - Tiaret',
    '15 - Tizi Ouzou',
    '16 - Alger',
    '17 - Djelfa',
    '18 - Jijel',
    '19 - Sétif',
    '20 - Saïda',
    '21 - Skikda',
    '22 - Sidi Bel Abbès',
    '23 - Annaba',
    '24 - Guelma',
    '25 - Constantine',
    '26 - Médéa',
    '27 - Mostaganem',
    '28 - M\'Sila',
    '29 - Mascara',
    '30 - Ouargla',
    '31 - Oran',
    '32 - El Bayadh',
    '33 - Illizi',
    '34 - Bordj Bou Arréridj',
    '35 - Boumerdès',
    '36 - El Tarf',
    '37 - Tindouf',
    '38 - Tissemsilt',
    '39 - El Oued',
    '40 - Khenchela',
    '41 - Souk Ahras',
    '42 - Tipaza',
    '43 - Mila',
    '44 - Aïn Defla',
    '45 - Naâma',
    '46 - Aïn Témouchent',
    '47 - Ghardaïa',
    '48 - Relizane',
    '49 - Timimoun',
    '50 - Bordj Badji Mokhtar',
    '51 - Ouled Djellal',
    '52 - Béni Abbès',
    '53 - In Salah',
    '54 - In Guezzam',
    '55 - Touggourt',
    '56 - Djanet',
    '57 - El M\'Ghair',
    '58 - El Menia',
  ];

  // Controllers pour les champs
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _adresseController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _numeroRcController = TextEditingController();
  final TextEditingController _siretController = TextEditingController();

  String? _selectedTypeCommerce;
  String? _selectedWilaya;
  final TextEditingController _communeController = TextEditingController();
  final TextEditingController _codePostalController = TextEditingController();
  final TextEditingController _gpsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCommerceInfo();
  }

  // Charger les données du commerce depuis l'API
  Future<void> _loadCommerceInfo() async {
    setState(() => _isLoading = true);

    try {
      final response = await ApiService.getCurrentProfile();
      final data = response['data'] ?? response;

      setState(() {
        _nomController.text = data['nomCommerce'] ?? '';
        _adresseController.text = data['adresse'] ?? '';
        _descriptionController.text = data['description'] ?? '';
        _numeroRcController.text = data['numeroRc'] ?? '';
        _siretController.text = data['siret'] ?? '';
        _communeController.text = data['commune'] ?? '';
        _codePostalController.text = data['codePostal'] ?? '';
        _gpsController.text = data['gps'] ?? '';
        _selectedTypeCommerce = data['typeCommerce'];
        _selectedWilaya = data['wilaya'];
        _isLoading = false;

        if (data['heureOuverture'] != null &&
            data['heureOuverture'].toString().contains(':')) {
          final parts = data['heureOuverture'].toString().split(':');
          _heureOuverture = TimeOfDay(
            hour: int.parse(parts[0]),
            minute: int.parse(parts[1]),
          );
        }
        if (data['heureFermeture'] != null &&
            data['heureFermeture'].toString().contains(':')) {
          final parts = data['heureFermeture'].toString().split(':');
          _heureFermeture = TimeOfDay(
            hour: int.parse(parts[0]),
            minute: int.parse(parts[1]),
          );
        }

        _isLoading = false;
      });
    } catch (e) {
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

  TimeOfDay _heureOuverture = const TimeOfDay(hour: 7, minute: 0);
  TimeOfDay _heureFermeture = const TimeOfDay(hour: 20, minute: 0);

  @override
  void dispose() {
    _nomController.dispose();
    _adresseController.dispose();
    _descriptionController.dispose();
    _numeroRcController.dispose();
    _siretController.dispose();
    _communeController.dispose();
    _codePostalController.dispose();
    _gpsController.dispose();
    super.dispose();
  }

  String _formatTime(TimeOfDay t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  Future<void> _pickTime(bool isOuverture) async {
    if (!_isEditing) return;
    final time = await showTimePicker(
      context: context,
      initialTime: isOuverture ? _heureOuverture : _heureFermeture,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFCCD5AE),
              onPrimary: Color(0xFF3E2723),
              surface: Color(0xFFFEFAE0),
              onSurface: Color(0xFF3E2723),
            ),
          ),
          child: child!,
        );
      },
    );
    if (time != null) {
      setState(() {
        if (isOuverture) {
          _heureOuverture = time;
        } else {
          _heureFermeture = time;
        }
      });
    }
  }

  Future<void> _handleConfirmer() async {
    setState(() => _isLoading = true);

    try {
      // Sauvegarder via l'API
      await ApiService.updateProfile(
        fullName: '', // Sera rempli depuis les données existantes
        email: '', // Sera rempli depuis les données existantes
        nomCommerce: _nomController.text,
        typeCommerce: _selectedTypeCommerce,
        adresse: _adresseController.text,
        description: _descriptionController.text,
        numeroRc: _numeroRcController.text,
        siret: _siretController.text,
        wilaya: _selectedWilaya,
        commune: _communeController.text,
      );

      setState(() {
        _isEditing = false;
        _showSuccess = true;
        _isLoading = false;
      });

      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) setState(() => _showSuccess = false);
      });
    } catch (e) {
      print('❌ ERREUR sauvegarde commerce: $e');
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
                          'Informations du commerce',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF3E2723),
                          ),
                        ),
                      ),
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),

                        // ── Informations du commerce ──
                        _buildSectionTitle('Informations du commerce'),
                        const SizedBox(height: 12),
                        _buildField(
                          label: 'Nom / enseigne commerciale',
                          controller: _nomController,
                          icon: Icons.store_outlined,
                        ),
                        const SizedBox(height: 16),

                        // Type de commerce
                        _buildLabel('Type de commerce'),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedTypeCommerce,
                              isExpanded: true,
                              icon: const Icon(
                                Icons.keyboard_arrow_down,
                                color: brownColor,
                              ),
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF3E2723),
                              ),
                              dropdownColor: cardColor,
                              onChanged: _isEditing
                                  ? (val) => setState(
                                      () => _selectedTypeCommerce = val,
                                    )
                                  : null,
                              items: _typesCommerce
                                  .map(
                                    (t) => DropdownMenuItem(
                                      value: t,
                                      child: Text(t),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Horaires
                        _buildLabel('Horaires d\'ouverture'),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Ouverture',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF9E9E9E),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  GestureDetector(
                                    onTap: () => _pickTime(true),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 14,
                                      ),
                                      decoration: BoxDecoration(
                                        color: cardColor,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.access_time,
                                            size: 16,
                                            color: Color(0xFF9E9E9E),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            _formatTime(_heureOuverture),
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Color(0xFF3E2723),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Fermeture',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF9E9E9E),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  GestureDetector(
                                    onTap: () => _pickTime(false),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 14,
                                      ),
                                      decoration: BoxDecoration(
                                        color: cardColor,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.access_time,
                                            size: 16,
                                            color: Color(0xFF9E9E9E),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            _formatTime(_heureFermeture),
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Color(0xFF3E2723),
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
                        const SizedBox(height: 24),

                        // ── Adresse ──
                        _buildSectionTitle('Adresse du commerce'),
                        const SizedBox(height: 12),
                        _buildField(
                          label: 'Adresse complète',
                          controller: _adresseController,
                          icon: Icons.location_on_outlined,
                        ),
                        const SizedBox(height: 16),

                        // Wilaya
                        _buildLabel('Wilaya'),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedWilaya,
                              isExpanded: true,
                              icon: const Icon(
                                Icons.keyboard_arrow_down,
                                color: brownColor,
                              ),
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF3E2723),
                              ),
                              dropdownColor: cardColor,
                              onChanged: _isEditing
                                  ? (val) =>
                                        setState(() => _selectedWilaya = val!)
                                  : null,
                              items: _wilayas
                                  .map(
                                    (w) => DropdownMenuItem(
                                      value: w,
                                      child: Text(
                                        w,
                                        style: const TextStyle(fontSize: 13),
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Commune + Code postal
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: _buildField(
                                label: 'Commune',
                                controller: _communeController,
                                icon: Icons.location_city_outlined,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildField(
                                label: 'Code postal',
                                controller: _codePostalController,
                                icon: Icons.markunread_mailbox_outlined,
                                keyboardType: TextInputType.number,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // GPS
                        _buildField(
                          label: 'Localisation GPS',
                          controller: _gpsController,
                          icon: Icons.my_location_outlined,
                          keyboardType: TextInputType.text,
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

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: Color(0xFF3E2723),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: Color(0xFF757575),
      ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
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
            decoration: InputDecoration(
              prefixIcon: Icon(icon, size: 18, color: const Color(0xFF9E9E9E)),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
