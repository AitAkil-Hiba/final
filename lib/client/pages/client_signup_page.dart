import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:peeco/core/core.dart';
import 'package:peeco/core/pages/verification_code_page.dart';
import 'package:peeco/client/client.dart';
import 'package:peeco/models/auth_models.dart';
import 'package:peeco/services/auth_service.dart';
import 'package:peeco/client/pages/home_client_screen.dart';

class ClientSignupPage extends StatefulWidget {
  const ClientSignupPage({super.key});

  @override
  State<ClientSignupPage> createState() => _ClientSignupPageState();
}

class _ClientSignupPageState extends State<ClientSignupPage> {
  static const _errorPadding = EdgeInsets.only(left: 14, top: 5, bottom: 2);

  final _prenomController = TextEditingController();
  final _nomController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _prenomFocus = FocusNode();
  final _nomFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmFocus = FocusNode();

  final AuthService _authService = AuthService();

  String? _prenomError;
  String? _nomError;
  String? _emailError;
  String? _passwordError;
  String? _confirmError;

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _acceptedTerms = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    _prenomFocus.addListener(() {
      if (!_prenomFocus.hasFocus) {
        setState(
          () => _prenomError = InputValidator.prenom(_prenomController.text),
        );
      }
    });

    _nomFocus.addListener(() {
      if (!_nomFocus.hasFocus) {
        setState(() => _nomError = InputValidator.nom(_nomController.text));
      }
    });

    _emailFocus.addListener(() {
      if (!_emailFocus.hasFocus) {
        setState(
          () => _emailError = InputValidator.email(_emailController.text),
        );
      }
    });

    _passwordFocus.addListener(() {
      if (!_passwordFocus.hasFocus) {
        setState(
          () => _passwordError = InputValidator.newPassword(
            _passwordController.text,
          ),
        );
      }
    });

    _confirmFocus.addListener(() {
      if (!_confirmFocus.hasFocus) {
        setState(
          () => _confirmError = InputValidator.confirmPassword(
            _confirmPasswordController.text,
            _passwordController.text,
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _prenomController.dispose();
    _nomController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _prenomFocus.dispose();
    _nomFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmFocus.dispose();
    super.dispose();
  }

  void _showSuccessBanner(String message, String subtitle) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (ctx) => _SuccessBanner(
        message: message,
        subtitle: subtitle,
        onDone: () => entry.remove(),
      ),
    );
    overlay.insert(entry);
  }

  void _showErrorBanner(String message, String subtitle) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (ctx) => _ErrorBanner(
        message: message,
        subtitle: subtitle,
        onDone: () => entry.remove(),
      ),
    );
    overlay.insert(entry);
  }

  void _handleSignup() {
    setState(() {
      _prenomError = InputValidator.prenom(_prenomController.text);
      _nomError = InputValidator.nom(_nomController.text);
      _emailError = InputValidator.email(_emailController.text);
      _passwordError = InputValidator.newPassword(_passwordController.text);
      _confirmError = InputValidator.confirmPassword(
        _confirmPasswordController.text,
        _passwordController.text,
      );
    });

    if (_prenomError != null ||
        _nomError != null ||
        _emailError != null ||
        _passwordError != null ||
        _confirmError != null ||
        !_acceptedTerms) {
      if (!_acceptedTerms) {
        _showErrorBanner(
          'Conditions requises',
          'Veuillez accepter les conditions d\'utilisation',
        );
      }
      return;
    }

    _showConfirmationSheet(_emailController.text.trim());
  }

  Future<void> _registerUser(String email) async {
    setState(() => _isLoading = true);

    final request = RegisterRequest(
      email: email,
      password: _passwordController.text,
      fullName: '${_prenomController.text.trim()} ${_nomController.text.trim()}',
      role: 'CLIENT',
    );

    print('  Tentative d\'inscription: ${request.email}');

    try {
      final result = await _authService.register(request);
      
      setState(() => _isLoading = false);

      if (mounted) {
        _navigateToVerification(email);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorBanner('Erreur d\'inscription', e.toString());
    }
  }

  void _showConfirmationSheet(String email) {
    final displayEmail = _maskEmail(email);

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFB5C99A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Icon(
              Icons.mark_email_unread_outlined,
              size: 48,
              color: Color.fromARGB(255, 248, 176, 104),
            ),
            const SizedBox(height: 16),
            const Text(
              'Le code sera envoyé à',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              displayEmail,
              style: const TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 45,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _registerUser(email);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 248, 176, 104),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Confirmer',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  String _maskEmail(String email) {
    if (!email.contains('@')) return email;
    final parts = email.split('@');
    final local = parts[0];
    final domain = parts[1];
    final maskedLocal = local.length > 2
        ? '${local.substring(0, 2)}${'*' * (local.length - 2)}'
        : '*' * local.length;
    return '$maskedLocal@$domain';
  }

  Future<void> _navigateToVerification(String email) async {
    final isVerified = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VerificationCodePage(
          identifier: email,
          mode: VerificationMode.emailVerification,
        ),
      ),
    );

    if (mounted && isVerified == true) {
      _showSuccessBanner(
        'Compte vérifié !',
        'Vous pouvez maintenant vous connecter.',
      );

      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const LoginPage()),
            (route) => false,
          );
        }
      });
    }
  }

  void _go(Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  Widget _fieldError(String message) {
    return buildFieldError(message, padding: _errorPadding);
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: appGradient,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: sw * 0.062),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: sh * 0.05),

                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                ),

                SizedBox(height: sh * 0.015),

                SizedBox(
                  width: double.infinity,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'S\'inscrire',
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontWeight: FontWeight.bold,
                        fontSize: (sw * 0.095).clamp(28.0, 42.0),
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: sh * 0.01),

                SizedBox(
                  width: double.infinity,
                  child: Text(
                    'Créez votre compte Peeco',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'NotoLoopedThai',
                      fontSize: (sw * 0.038).clamp(13.0, 17.0),
                      color: const Color.fromARGB(255, 0, 0, 0),
                    ),
                  ),
                ),

                SizedBox(height: sh * 0.055),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: sw * 0.055),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CustomInputField(
                                  label: 'Prénom',
                                  icon: Icons.person_outline,
                                  controller: _prenomController,
                                  focusNode: _prenomFocus,
                                  onChanged: (_) {
                                    if (_prenomError != null)
                                      setState(() => _prenomError = null);
                                  },
                                ),
                                if (_prenomError != null)
                                  _fieldError(_prenomError!),
                              ],
                            ),
                          ),
                          SizedBox(width: sw * 0.025),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CustomInputField(
                                  label: 'Nom',
                                  icon: Icons.person_outline,
                                  controller: _nomController,
                                  focusNode: _nomFocus,
                                  onChanged: (_) {
                                    if (_nomError != null)
                                      setState(() => _nomError = null);
                                  },
                                ),
                                if (_nomError != null) _fieldError(_nomError!),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: sh * 0.012),

                      CustomInputField(
                        label: 'Adresse e-mail',
                        icon: Icons.mail_outline,
                        controller: _emailController,
                        focusNode: _emailFocus,
                        keyboardType: TextInputType.emailAddress,
                        onChanged: (_) {
                          if (_emailError != null)
                            setState(() => _emailError = null);
                        },
                      ),
                      if (_emailError != null) _fieldError(_emailError!),
                      SizedBox(height: sh * 0.012),

                      CustomInputField(
                        label: 'Mot de passe',
                        icon: Icons.lock_outline,
                        controller: _passwordController,
                        focusNode: _passwordFocus,
                        obscureText: _obscurePassword,
                        onChanged: (_) {
                          if (_passwordError != null)
                            setState(() => _passwordError = null);
                          if (_confirmError != null) {
                            setState(
                              () => _confirmError =
                                  InputValidator.confirmPassword(
                                    _confirmPasswordController.text,
                                    _passwordController.text,
                                  ),
                            );
                          }
                        },
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: Colors.black54,
                            size: 20,
                          ),
                          onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                        ),
                      ),
                      if (_passwordError != null) _fieldError(_passwordError!),
                      SizedBox(height: sh * 0.012),

                      CustomInputField(
                        label: 'Confirmer le mot de passe',
                        icon: Icons.lock_outline,
                        controller: _confirmPasswordController,
                        focusNode: _confirmFocus,
                        obscureText: _obscureConfirm,
                        onChanged: (_) {
                          if (_confirmError != null)
                            setState(() => _confirmError = null);
                        },
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirm
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: Colors.black54,
                            size: 20,
                          ),
                          onPressed: () => setState(
                            () => _obscureConfirm = !_obscureConfirm,
                          ),
                        ),
                      ),
                      if (_confirmError != null) _fieldError(_confirmError!),
                      SizedBox(height: sh * 0.018),

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: Checkbox(
                              value: _acceptedTerms,
                              onChanged: (val) =>
                                  setState(() => _acceptedTerms = val ?? false),
                              activeColor: const Color.fromARGB(255, 248, 176, 104),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              side: const BorderSide(color: Colors.black54),
                            ),
                          ),
                          SizedBox(width: sw * 0.025),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                style: TextStyle(
                                  fontFamily: 'NotoLoopedThai',
                                  fontSize: (sw * 0.028).clamp(10.0, 13.0),
                                  color: Colors.black87,
                                ),
                                children: [
                                  const TextSpan(text: 'J\'accepte les '),
                                  TextSpan(
                                    text: 'conditions d\'utilisation',
                                    style: const TextStyle(
                                      color: Color.fromARGB(255, 230, 163, 97),
                                      decoration: TextDecoration.underline,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () =>
                                          _go(const ConditionsPage()),
                                  ),
                                  const TextSpan(text: ' de Peeco, la '),
                                  TextSpan(
                                    text: 'politique de confidentialité',
                                    style: const TextStyle(
                                      color: Color.fromARGB(255, 230, 163, 97),
                                      decoration: TextDecoration.underline,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () => _go(
                                        const PolitiqueConfidentialitePage(),
                                      ),
                                  ),
                                  const TextSpan(text: ' et le '),
                                  TextSpan(
                                    text: 'contrat de licence utilisateur',
                                    style: const TextStyle(
                                      color: Color.fromARGB(255, 230, 163, 97),
                                      decoration: TextDecoration.underline,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () =>
                                          _go(const ContratLicencePage()),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: sh * 0.028),

                      SizedBox(
                        width: double.infinity,
                        height: (sh * 0.055).clamp(44.0, 54.0),
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleSignup,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(255, 248, 176, 104),
                            disabledBackgroundColor: const Color.fromARGB(160, 248, 176, 104),
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 0,
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.black,
                                  strokeWidth: 2,
                                )
                              : Text(
                                  'Créer un compte',
                                  style: TextStyle(
                                    fontFamily: 'PlusJakartaSans',
                                    fontWeight: FontWeight.bold,
                                    fontSize: (sw * 0.045).clamp(14.0, 19.0),
                                  ),
                                ),
                        ),
                      ),
                      SizedBox(height: sh * 0.01),

                                          ],
                  ),
                ),

                SizedBox(height: sh * 0.022),

                Center(
                  child: RichText(
                    text: TextSpan(
                      text: 'Vous avez déjà un compte ? ',
                      style: TextStyle(
                        fontFamily: 'NotoLoopedThai',
                        fontSize: (sw * 0.035).clamp(12.0, 15.0),
                        color: Colors.black,
                      ),
                      children: [
                        TextSpan(
                          text: 'Se connecter',
                          style: const TextStyle(
                            fontFamily: 'NotoLoopedThai',
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const LoginPage(),
                                ),
                              );
                            },
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: sh * 0.05),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SuccessBanner extends StatefulWidget {
  final String message;
  final String subtitle;
  final VoidCallback onDone;
  
  const _SuccessBanner({
    required this.message,
    required this.subtitle,
    required this.onDone,
  });

  @override
  State<_SuccessBanner> createState() => _SuccessBannerState();
}

class _SuccessBannerState extends State<_SuccessBanner> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<Offset> _slide;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 380));
    _slide = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();
    Future.delayed(const Duration(milliseconds: 2400), () {
      if (mounted) _ctrl.reverse().then((_) => widget.onDone());
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final navbarHeight = kBottomNavigationBarHeight;
    final finalBottom = navbarHeight + 20;

    return Positioned(
      bottom: finalBottom,
      left: 20,
      right: 20,
      child: SlideTransition(
        position: _slide,
        child: FadeTransition(
          opacity: _fade,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFCCD5AE),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.10),
                    blurRadius: 18,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check_rounded, size: 18, color: Colors.black87),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.message,
                          style: const TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          widget.subtitle,
                          style: const TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 11,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatefulWidget {
  final String message;
  final String subtitle;
  final VoidCallback onDone;
  
  const _ErrorBanner({
    required this.message,
    required this.subtitle,
    required this.onDone,
  });

  @override
  State<_ErrorBanner> createState() => _ErrorBannerState();
}

class _ErrorBannerState extends State<_ErrorBanner> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<Offset> _slide;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 380));
    _slide = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();
    Future.delayed(const Duration(milliseconds: 2400), () {
      if (mounted) _ctrl.reverse().then((_) => widget.onDone());
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final navbarHeight = kBottomNavigationBarHeight;
    final finalBottom = navbarHeight + 20;

    return Positioned(
      bottom: finalBottom,
      left: 20,
      right: 20,
      child: SlideTransition(
        position: _slide,
        child: FadeTransition(
          opacity: _fade,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFF8B068).withOpacity(0.95),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.10),
                    blurRadius: 18,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close_rounded, size: 18, color: Colors.black87),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.message,
                          style: const TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          widget.subtitle,
                          style: const TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 11,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}