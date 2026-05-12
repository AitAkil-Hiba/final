import 'package:flutter/material.dart';

class SecuritePage extends StatefulWidget {
  const SecuritePage({super.key});

  @override
  State<SecuritePage> createState() => _SecuritePageState();
}

class _SecuritePageState extends State<SecuritePage> {
  static const Color topBarColor = Color(0xFFCCD5AE);
  static const Color backgroundColor = Color(0xFFFEFAE0);
  static const Color cardColor = Color(0xFFF5EED8);
  static const Color brownColor = Color(0xFF5D4E37);
  static const Color orangeColor = Color(0xFFE8824A);
  static const Color errorColor = Color(0xFFE53935);
  static const Color successColor = Color(0xFF4CAF50);

  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _showCurrent = false;
  bool _showNew = false;
  bool _showConfirm = false;

  String? _errorCurrent;
  String? _errorNew;
  String? _errorConfirm;
  bool _showSuccess = false;
  bool _isLoading = false;

  // Règles de validation
  bool get _hasMinLength => _newPasswordController.text.length >= 8;
  bool get _hasUppercase =>
      _newPasswordController.text.contains(RegExp(r'[A-Z]'));
  bool get _hasNumber => _newPasswordController.text.contains(RegExp(r'[0-9]'));
  bool get _passwordsMatch =>
      _newPasswordController.text == _confirmPasswordController.text;

  bool get _isButtonEnabled =>
      _currentPasswordController.text.isNotEmpty &&
      _newPasswordController.text.isNotEmpty &&
      _confirmPasswordController.text.isNotEmpty;

  void _validate() {
    setState(() {
      _errorCurrent = null;
      _errorNew = null;
      _errorConfirm = null;
      _showSuccess = false;
    });

    bool hasError = false;

    // Champ actuel vide
    if (_currentPasswordController.text.isEmpty) {
      setState(
        () => _errorCurrent = 'Veuillez saisir votre mot de passe actuel',
      );
      hasError = true;
    }

    // Règles nouveau mot de passe
    if (!_hasMinLength || !_hasUppercase || !_hasNumber) {
      setState(
        () => _errorNew = 'Le mot de passe ne respecte pas les règles requises',
      );
      hasError = true;
    }

    // Confirmation
    if (!_passwordsMatch) {
      setState(() => _errorConfirm = 'Les mots de passe ne correspondent pas');
      hasError = true;
    }

    if (hasError) return;

    _submitChange();
  }

  Future<void> _submitChange() async {
    setState(() => _isLoading = true);

    // TODO Backend: POST /api/commercant/{id}/change-password
    // body: { currentPassword, newPassword }
    // Si mot de passe actuel incorrect → afficher erreur
    // Simuler appel API
    await Future.delayed(const Duration(seconds: 1));

    // Simulation : si le mot de passe actuel est "wrong" → erreur
    if (_currentPasswordController.text == 'wrong') {
      setState(() {
        _errorCurrent = 'Mot de passe actuel incorrect';
        _isLoading = false;
      });
      return;
    }

    // Succès
    setState(() {
      _isLoading = false;
      _showSuccess = true;
      _currentPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();
    });

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _showSuccess = false);
    });
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
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
                      const Text(
                        'Sécurité',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF3E2723),
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

                        // Titre section
                        const Text(
                          'Modifier le mot de passe',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF3E2723),
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Pour votre sécurité, ne partagez jamais votre mot de passe.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF9E9E9E),
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 28),

                        // Mot de passe actuel
                        _buildPasswordField(
                          label: 'Mot de passe actuel',
                          controller: _currentPasswordController,
                          isVisible: _showCurrent,
                          onToggle: () =>
                              setState(() => _showCurrent = !_showCurrent),
                          error: _errorCurrent,
                        ),
                        const SizedBox(height: 20),

                        // Nouveau mot de passe
                        _buildPasswordField(
                          label: 'Nouveau mot de passe',
                          controller: _newPasswordController,
                          isVisible: _showNew,
                          onToggle: () => setState(() => _showNew = !_showNew),
                          error: _errorNew,
                          onChanged: (_) => setState(() {}),
                        ),

                        // Règles de validation
                        const SizedBox(height: 10),
                        _buildPasswordRules(),
                        const SizedBox(height: 20),

                        // Confirmer mot de passe
                        _buildPasswordField(
                          label: 'Confirmer le nouveau mot de passe',
                          controller: _confirmPasswordController,
                          isVisible: _showConfirm,
                          onToggle: () =>
                              setState(() => _showConfirm = !_showConfirm),
                          error: _errorConfirm,
                          onChanged: (_) => setState(() {}),
                        ),
                        const SizedBox(height: 12),

                        // Mot de passe oublié
                        Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: () {
                              // TODO Backend: POST /api/auth/forgot-password
                            },
                            child: Text(
                              'Mot de passe oublié ?',
                              style: TextStyle(
                                fontSize: 13,
                                color: orangeColor,
                                fontWeight: FontWeight.w500,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Bouton mettre à jour
                        GestureDetector(
                          onTap: _isButtonEnabled && !_isLoading
                              ? _validate
                              : null,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              color: _isButtonEnabled
                                  ? topBarColor
                                  : topBarColor.withOpacity(0.4),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Center(
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: brownColor,
                                      ),
                                    )
                                  : const Text(
                                      'Mettre à jour le mot de passe',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: brownColor,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
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
                      Expanded(
                        child: Text(
                          'Mot de passe mis à jour avec succès',
                          style: TextStyle(color: Colors.white, fontSize: 13),
                        ),
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

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required bool isVisible,
    required VoidCallback onToggle,
    String? error,
    void Function(String)? onChanged,
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
            border: error != null
                ? Border.all(color: errorColor, width: 1.5)
                : null,
          ),
          child: TextField(
            controller: controller,
            obscureText: !isVisible,
            onChanged: onChanged,
            style: const TextStyle(fontSize: 14, color: Color(0xFF3E2723)),
            decoration: InputDecoration(
              prefixIcon: const Icon(
                Icons.lock_outline,
                size: 18,
                color: Color(0xFF9E9E9E),
              ),
              suffixIcon: GestureDetector(
                onTap: onToggle,
                child: Icon(
                  isVisible
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  size: 18,
                  color: const Color(0xFF9E9E9E),
                ),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 14,
              ),
            ),
          ),
        ),
        if (error != null) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.error_outline, size: 13, color: errorColor),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  error,
                  style: const TextStyle(fontSize: 12, color: errorColor),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildPasswordRules() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Le mot de passe doit contenir :',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF5D4E37),
            ),
          ),
          const SizedBox(height: 8),
          _buildRule('Au moins 8 caractères', _hasMinLength),
          const SizedBox(height: 4),
          _buildRule('Au moins 1 lettre majuscule', _hasUppercase),
          const SizedBox(height: 4),
          _buildRule('Au moins 1 chiffre', _hasNumber),
        ],
      ),
    );
  }

  Widget _buildRule(String text, bool isValid) {
    final bool hasInput = _newPasswordController.text.isNotEmpty;
    final Color color = !hasInput
        ? const Color(0xFF9E9E9E)
        : isValid
        ? successColor
        : errorColor;

    return Row(
      children: [
        Icon(
          !hasInput
              ? Icons.radio_button_unchecked
              : isValid
              ? Icons.check_circle_outline
              : Icons.cancel_outlined,
          size: 14,
          color: color,
        ),
        const SizedBox(width: 6),
        Text(text, style: TextStyle(fontSize: 12, color: color)),
      ],
    );
  }
}
