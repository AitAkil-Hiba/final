import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:peeco/core/core.dart';
import 'package:peeco/client/client.dart';
import 'package:peeco/commerce/commerce.dart';
import 'package:peeco/admin/admin.dart';
import 'package:peeco/models/auth_models.dart';
import 'package:peeco/services/auth_service.dart';
import 'package:peeco/client/pages/home_client_screen.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _obscurePassword = true;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

  final AuthService _authService = AuthService();

  String? _emailError;
  String? _passwordError;
  String? _generalError;
  bool _isLoading = false;
  bool _isForgotLoading = false;

  @override
  void initState() {
    super.initState();

    _emailFocus.addListener(() {
      if (!_emailFocus.hasFocus && _emailController.text.isNotEmpty) {
        setState(() {
          _emailError = InputValidator.emailOrPhone(_emailController.text);
        });
      }
    });

    _passwordFocus.addListener(() {
      if (!_passwordFocus.hasFocus && _passwordController.text.isNotEmpty) {
        setState(() {
          _passwordError = InputValidator.password(_passwordController.text);
        });
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  String _maskEmail(String email) {
    final parts = email.split('@');
    if (parts.length != 2) return email;
    final name = parts[0];
    final domain = parts[1];
    if (name.length <= 2) return '${'*' * name.length}@$domain';
    return '${name[0]}${'*' * (name.length - 2)}${name[name.length - 1]}@$domain';
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

  Future<void> _handleForgotPassword() async {
    if (_emailController.text.trim().isEmpty) {
      setState(() {
        _emailError = 'Veuillez entrer votre email d\'abord';
      });
      return;
    }

    final input = _emailController.text.trim();
    
    final phoneRegex = RegExp(r'^0[567][0-9]{8}$');
    if (phoneRegex.hasMatch(input)) {
      setState(() {
        _emailError = 'Veuillez saisir votre email pour recevoir le code de réinitialisation';
      });
      return;
    }
    
    final emailRegex = RegExp(r'^([\w\.\-]+)@([\w\-]+)((\.(\w){2,3})+)$');
    if (!emailRegex.hasMatch(input)) {
      setState(() => _emailError = 'Veuillez entrer une adresse email valide');
      return;
    }

    _showForgotPasswordConfirmationSheet(input);
  }

  void _showForgotPasswordConfirmationSheet(String email) {
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
                onPressed: () async {
                  Navigator.pop(context);
                  await _sendForgotPasswordCode(email);
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

  Future<void> _sendForgotPasswordCode(String email) async {
    setState(() => _isForgotLoading = true);

    try {
      final response = await _authService.forgotPassword(email);

      setState(() => _isForgotLoading = false);

      if (response != null && mounted) {
        _showSuccessBanner(
          'Code envoyé !',
          'Vérifiez votre email pour le code de réinitialisation',
        );
        
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => VerificationCodePage(
                  identifier: email,
                  mode: VerificationMode.forgotPassword,
                ),
              ),
            );
          }
        });
      } else {
        setState(() {
          _emailError = 'Erreur lors de l\'envoi. Veuillez réessayer.';
        });
      }
    } catch (e) {
      setState(() {
        _emailError = e.toString();
        _isForgotLoading = false;
      });
    }
  }

  Future<void> _handleLogin() async {
    setState(() {
      _emailError = InputValidator.emailOrPhone(_emailController.text);
      _passwordError = InputValidator.password(_passwordController.text);
      _generalError = null;
    });

    if (_emailError != null || _passwordError != null) return;

    setState(() => _isLoading = true);

    final request = LoginRequest(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    try {
      final loginResponse = await _authService.login(request);
      
      setState(() => _isLoading = false);

      if (mounted) {
        _showSuccessBanner(
          'Connexion réussie !',
          'Bienvenue sur Peeco',
        );
        
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            final role = loginResponse.role;
            print('  Login success - User role: $role');
            
            if (role == 'CLIENT') {
              print('  Navigating to HomeClientScreen');
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const HomeClientScreen()),
                (route) => false,
              );
            } else if (role == 'COMMERCANT' || role == 'MERCHANT') {
              print('  Navigating to AccueilCommercantPage');
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const AccueilCommercantPage()),
                (route) => false,
              );
            } else if (role == 'ADMIN') {
              print('  Navigating to AdminShell');
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const AdminShell()),
                (route) => false,
              );
            } else {
              print('⚠️ Unknown role: $role - defaulting to HomeClientScreen');
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const HomeClientScreen()),
                (route) => false,
              );
            }
          }
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorBanner(
        'Erreur de connexion',
        e.toString(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final sh = size.height;
    final sw = size.width;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: appGradient,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: sw * 0.062),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: sh * 0.05),

                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(
                    Icons.arrow_back,
                    color: Colors.black,
                    size: 24,
                  ),
                ),

                SizedBox(height: sh * 0.09),

                Center(
                  child: Text(
                    'Se connecter',
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontWeight: FontWeight.bold,
                      fontSize: (sw * 0.095).clamp(28.0, 42.0),
                      color: Colors.black,
                    ),
                  ),
                ),

                SizedBox(height: sh * 0.01),

                Center(
                  child: Text(
                    'Connectez-vous à votre compte Peeco',
                    style: TextStyle(
                      fontFamily: 'NotoLoopedThai',
                      fontSize: (sw * 0.038).clamp(13.0, 17.0),
                      color: const Color.fromARGB(217, 0, 0, 0),
                    ),
                  ),
                ),

                SizedBox(height: sh * 0.08),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: sw * 0.055),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomInputField(
                        label: 'Adresse email/Numéro de téléphone',
                        icon: Icons.mail_outline,
                        controller: _emailController,
                        focusNode: _emailFocus,
                        keyboardType: TextInputType.text,
                        onChanged: (_) {
                          if (_emailError != null || _generalError != null) {
                            setState(() {
                              _emailError = null;
                              _generalError = null;
                            });
                          }
                        },
                      ),

                      if (_emailError != null) buildFieldError(_emailError!),

                      SizedBox(height: sh * 0.012),

                      Padding(
                        padding: const EdgeInsets.only(
                          left: 14,
                          right: 4,
                          bottom: 8,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Mot de passe',
                              style: TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: (sw * 0.035).clamp(12.0, 15.0),
                                color: Colors.black,
                              ),
                            ),
                            GestureDetector(
                              onTap: _isForgotLoading
                                  ? null
                                  : _handleForgotPassword,
                              child: _isForgotLoading
                                  ? const SizedBox(
                                      width: 14,
                                      height: 14,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.black,
                                      ),
                                    )
                                  : Text(
                                      'Mot de passe oublié ?',
                                      style: TextStyle(
                                        fontFamily: 'NotoLoopedThai',
                                        fontSize:
                                            (sw * 0.033).clamp(11.0, 15.0),
                                        color: Colors.black,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                            ),
                          ],
                        ),
                      ),

                      Container(
                        height: (sh * 0.052).clamp(40.0, 50.0),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 210, 213, 178),
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: const Color.fromARGB(130, 255, 255, 255)
                                  .withValues(alpha: 0.6),
                              blurRadius: 0,
                              spreadRadius: 1,
                              offset: const Offset(1, 1),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _passwordController,
                          focusNode: _passwordFocus,
                          obscureText: _obscurePassword,
                          textAlignVertical: TextAlignVertical.center,
                          onChanged: (_) {
                            if (_passwordError != null ||
                                _generalError != null) {
                              setState(() {
                                _passwordError = null;
                                _generalError = null;
                              });
                            }
                          },
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: (sw * 0.036).clamp(13.0, 16.0),
                            color: Colors.black,
                          ),
                          decoration: InputDecoration(
                            isDense: true,
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 11,
                              horizontal: 16,
                            ),
                            prefixIcon: const Icon(
                              Icons.lock_outline,
                              color: Color.fromARGB(208, 0, 0, 0),
                              size: 24,
                            ),
                            suffixIcon: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                              child: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: const Color.fromARGB(180, 0, 0, 0),
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ),

                      if (_passwordError != null)
                        buildFieldError(_passwordError!),
                    ],
                  ),
                ),

                SizedBox(height: sh * 0.065),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: sw * 0.048),
                  child: SizedBox(
                    width: double.infinity,
                    height: (sh * 0.055).clamp(44.0, 54.0),
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color.fromARGB(255, 248, 176, 104),
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
                              'Se connecter',
                              style: TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontWeight: FontWeight.bold,
                                fontSize: (sw * 0.048).clamp(15.0, 21.0),
                              ),
                            ),
                    ),
                  ),
                ),

                SizedBox(height: sh * 0.013),

                
                SizedBox(height: sh * 0.028),

                Center(
                  child: RichText(
                    text: TextSpan(
                      text: 'Vous n\'avez pas de compte ? ',
                      style: TextStyle(
                        fontFamily: 'NotoLoopedThai',
                        fontSize: (sw * 0.035).clamp(12.0, 15.0),
                        color: Colors.black,
                      ),
                      children: [
                        TextSpan(
                          text: 'S\'inscrire',
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
                                  builder: (_) => const ChoicePage(),
                                ),
                              );
                            },
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: sh * 0.04),
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