import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'creer_offre_step1.dart';
import 'creer_offre_step3.dart';

class CreerOffreStep2 extends StatefulWidget {
  const CreerOffreStep2({super.key});

  @override
  State<CreerOffreStep2> createState() => _CreerOffreStep2State();
}

class _CreerOffreStep2State extends State<CreerOffreStep2> {
  static const Color topBarColor = Color(0xFFCCD5AE);
  static const Color backgroundColor = Color(0xFFFEFAE0);
  static const Color cardColor = Color(0xFFF5EED8);
  static const Color orangeColor = Color(0xFFE8824A);

  final TextEditingController _prixOriginalController = TextEditingController();
  final TextEditingController _prixReduitController = TextEditingController();
  final NouvelleOffreData _data = NouvelleOffreData();

  @override
  void initState() {
    super.initState();
    _prixOriginalController.text = _data.prixOriginal;
    _prixReduitController.text = _data.prixReduit;
  }

  @override
  void dispose() {
    _prixOriginalController.dispose();
    _prixReduitController.dispose();
    super.dispose();
  }

  bool get _isValid =>
      _prixOriginalController.text.trim().isNotEmpty &&
      _prixReduitController.text.trim().isNotEmpty &&
      _data.stock >= 1;

  void _handleNext() {
    if (!_isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez remplir tous les champs'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Vérification prix réduit < prix original
    final original = int.tryParse(_prixOriginalController.text.trim()) ?? 0;
    final reduit = int.tryParse(_prixReduitController.text.trim()) ?? 0;

    if (reduit >= original) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Le prix réduit doit être inférieur au prix original'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    _data.prixOriginal = _prixOriginalController.text.trim();
    _data.prixReduit = _prixReduitController.text.trim();

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CreerOffreStep3()),
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
            _buildProgressTabs(1),
            const SizedBox(height: 24),
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Prix original
                    const Text(
                      'Prix original (valeur réelle)',
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
                        controller: _prixOriginalController,
                        onChanged: (_) => setState(() {}),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF424242),
                        ),
                        decoration: const InputDecoration(
                          hintText: '450 da',
                          hintStyle: TextStyle(
                            fontSize: 14,
                            color: Color(0xFFBDB5A0),
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          suffixText: 'DA',
                          suffixStyle: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF9E9E9E),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Prix réduit
                    const Text(
                      'Prix réduit',
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
                        controller: _prixReduitController,
                        onChanged: (_) => setState(() {}),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF424242),
                        ),
                        decoration: const InputDecoration(
                          hintText: '240 da',
                          hintStyle: TextStyle(
                            fontSize: 14,
                            color: Color(0xFFBDB5A0),
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          suffixText: 'DA',
                          suffixStyle: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF9E9E9E),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Stock disponible
                    const Text(
                      'Stock disponible',
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
                      child: Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 4,
                              ),
                              child: Text(
                                '${_data.stock}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF424242),
                                ),
                              ),
                            ),
                          ),
                          Column(
                            children: [
                              // Augmenter
                              GestureDetector(
                                onTap: () => setState(() => _data.stock++),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  child: const Icon(
                                    Icons.keyboard_arrow_up,
                                    size: 20,
                                    color: Color(0xFF5D4E37),
                                  ),
                                ),
                              ),
                              // Diminuer
                              GestureDetector(
                                onTap: () {
                                  if (_data.stock > 1) {
                                    setState(() => _data.stock--);
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  child: Icon(
                                    Icons.keyboard_arrow_down,
                                    size: 20,
                                    color: _data.stock > 1
                                        ? const Color(0xFF5D4E37)
                                        : const Color(0xFFBDB5A0),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
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


//=============================================================================================
//============================================================================================
/*
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'creer_offre_step1.dart';
import 'creer_offre_step3.dart';

class CreerOffreStep2 extends StatefulWidget {
  const CreerOffreStep2({super.key});

  @override
  State<CreerOffreStep2> createState() => _CreerOffreStep2State();
}

class _CreerOffreStep2State extends State<CreerOffreStep2> {
  static const Color topBarColor = Color(0xFFCCD5AE);
  static const Color backgroundColor = Color(0xFFFEFAE0);
  static const Color cardColor = Color(0xFFF5EED8);
  static const Color orangeColor = Color(0xFFE8824A);

  final TextEditingController _prixOriginalController = TextEditingController();
  final TextEditingController _prixReduitController = TextEditingController();
  final NouvelleOffreData _data = NouvelleOffreData();

  @override
  void initState() {
    super.initState();
    _prixOriginalController.text = _data.prixOriginal;
    _prixReduitController.text = _data.prixReduit;
  }

  @override
  void dispose() {
    _prixOriginalController.dispose();
    _prixReduitController.dispose();
    super.dispose();
  }

  bool get _isValid =>
      _prixOriginalController.text.trim().isNotEmpty &&
      _prixReduitController.text.trim().isNotEmpty &&
      _data.stock >= 1;

  void _handleNext() {
    if (!_isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez remplir tous les champs'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final original = int.tryParse(_prixOriginalController.text.trim()) ?? 0;
    final reduit = int.tryParse(_prixReduitController.text.trim()) ?? 0;

    if (reduit >= original) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Le prix réduit doit être inférieur au prix original'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    _data.prixOriginal = _prixOriginalController.text.trim();
    _data.prixReduit = _prixReduitController.text.trim();

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CreerOffreStep3()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = _data.isEditing;

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
            _buildProgressTabs(1),
            const SizedBox(height: 24),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Prix original (valeur réelle)',
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
                        controller: _prixOriginalController,
                        onChanged: (_) => setState(() {}),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF424242),
                        ),
                        decoration: const InputDecoration(
                          hintText: '450 da',
                          hintStyle: TextStyle(
                            fontSize: 14,
                            color: Color(0xFFBDB5A0),
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          suffixText: 'DA',
                          suffixStyle: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF9E9E9E),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Prix réduit',
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
                        controller: _prixReduitController,
                        onChanged: (_) => setState(() {}),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF424242),
                        ),
                        decoration: const InputDecoration(
                          hintText: '240 da',
                          hintStyle: TextStyle(
                            fontSize: 14,
                            color: Color(0xFFBDB5A0),
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          suffixText: 'DA',
                          suffixStyle: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF9E9E9E),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Stock disponible',
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
                      child: Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 4,
                              ),
                              child: Text(
                                '${_data.stock}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF424242),
                                ),
                              ),
                            ),
                          ),
                          Column(
                            children: [
                              GestureDetector(
                                onTap: () => setState(() => _data.stock++),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  child: const Icon(
                                    Icons.keyboard_arrow_up,
                                    size: 20,
                                    color: Color(0xFF5D4E37),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  if (_data.stock > 1) {
                                    setState(() => _data.stock--);
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  child: Icon(
                                    Icons.keyboard_arrow_down,
                                    size: 20,
                                    color: _data.stock > 1
                                        ? const Color(0xFF5D4E37)
                                        : const Color(0xFFBDB5A0),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
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
    final bool isValid = _isValid;

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
                color: isValid ? topBarColor : topBarColor.withOpacity(0.5),
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