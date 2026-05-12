import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:peeco/core/core.dart';
import 'package:peeco/client/client.dart';
import 'package:peeco/services/auth_service.dart';

enum VerificationMode { forgotPassword, emailVerification }

class VerificationCodePage extends StatefulWidget {
  final String identifier;
  final VerificationMode mode;

  const VerificationCodePage({
    super.key,
    required this.identifier,
    required this.mode,
  });

  @override
  State<VerificationCodePage> createState() => _VerificationCodePageState();
}

class _VerificationCodePageState extends State<VerificationCodePage> {
  final AuthService _authService = AuthService();
  
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  bool _hasError = false;
  bool _isVerifying = false;
  String? _errorMessage;

  int _secondsRemaining = 60;
  bool _canResend = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _secondsRemaining = 60;
    _canResend = false;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining == 0) {
        timer.cancel();
        setState(() => _canResend = true);
      } else {
        setState(() => _secondsRemaining--);
      }
    });
  }

  @override
  void dispose() {
    for (final c in _controllers) c.dispose();
    for (final f in _focusNodes) f.dispose();
    _timer?.cancel();
    super.dispose();
  }

  String get _fullCode => _controllers.map((c) => c.text).join();

  void _resetCodeInputs({required bool setError, String? errorMsg}) {
    for (final c in _controllers) {
      c.clear();
    }
    setState(() {
      _hasError = setError;
      _errorMessage = errorMsg;
    });
    FocusScope.of(context).requestFocus(_focusNodes[0]);
  }

  void _onDigitEntered(int index, String value) {
    if (_hasError) setState(() => _hasError = false);

    if (value.length == 1 && index < 5) {
      FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
    }

    if (_fullCode.length == 6) {
      _handleVerify();
    }
  }

  void _onBackspace(int index) {
    if (_controllers[index].text.isEmpty && index > 0) {
      _controllers[index - 1].clear();
      FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
    }
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

  Future<void> _sendVerificationCode() async {
    try {
      await _authService.resendVerificationCode(widget.identifier);
      print('  Email de vérification envoyé');
    } catch (e) {
      print('  Erreur envoi code: $e');
    }
  }

  Future<void> _handleVerify() async {
    final code = _fullCode;
    if (code.length < 6) return;

    setState(() {
      _isVerifying = true;
      _hasError = false;
      _errorMessage = null;
    });

    try {
      if (widget.mode == VerificationMode.forgotPassword) {
        setState(() => _isVerifying = false);

        _showSuccessBanner(
          'Code saisi !',
          'Vous pouvez maintenant créer un nouveau mot de passe',
        );

        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => NewPasswordPage(identifier: widget.identifier, code: code),
              ),
            );
          }
        });
      } else {
        await _authService.verifyEmail(widget.identifier, code);

        setState(() => _isVerifying = false);

        if (mounted) {
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      setState(() {
        _isVerifying = false;
        _hasError = true;
        _errorMessage = e.toString();
      });
      _resetCodeInputs(setError: true, errorMsg: e.toString());
    }
  }

  Future<void> _handleResend() async {
    if (!_canResend) return;
    
    setState(() => _canResend = false);
    
    try {
      await _authService.resendVerificationCode(widget.identifier);
      _startTimer();
      _resetCodeInputs(setError: false);
      
      _showSuccessBanner(
        'Code renvoyé !',
        'Vérifiez votre boîte de réception',
      );
    } catch (e) {
      _showErrorBanner('Erreur', e.toString());
      setState(() => _canResend = true);
    }
  }

  String get _timerDisplay {
    final minutes = (_secondsRemaining ~/ 60).toString().padLeft(2, '0');
    final seconds = (_secondsRemaining % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  Widget _buildCodeBox(int index, double sw, double sh) {
    return SizedBox(
      width: sw * 0.118,
      height: sh * 0.068,
      child: RawKeyboardListener(
        focusNode: FocusNode(),
        onKey: (event) {
          if (event is RawKeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.backspace) {
            _onBackspace(index);
          }
        },
        child: TextField(
          controller: _controllers[index],
          focusNode: _focusNodes[index],
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          maxLength: 1,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontWeight: FontWeight.bold,
            fontSize: (sw * 0.055).clamp(18.0, 24.0),
            color: Colors.black,
          ),
          decoration: InputDecoration(
            counterText: '',
            filled: true,
            fillColor: const Color.fromARGB(255, 210, 213, 178),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: _hasError ? Colors.red : Colors.transparent,
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: _hasError
                    ? Colors.red
                    : const Color.fromARGB(255, 248, 176, 104),
                width: 2,
              ),
            ),
          ),
          onChanged: (value) => _onDigitEntered(index, value),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;

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

                SizedBox(
                  width: double.infinity,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'Code de vérification',
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontWeight: FontWeight.bold,
                        fontSize: (sw * 0.078).clamp(24.0, 34.0),
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: sh * 0.01),

                SizedBox(
                  width: double.infinity,
                  child: Text(
                    'Entrez le code envoyé à\n${widget.identifier}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'NotoLoopedThai',
                      fontSize: (sw * 0.038).clamp(13.0, 17.0),
                      color: const Color.fromARGB(217, 0, 0, 0),
                    ),
                  ),
                ),

                SizedBox(height: sh * 0.08),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(6, (i) {
                    return Padding(
                      padding: EdgeInsets.only(right: i < 5 ? sw * 0.025 : 0),
                      child: _buildCodeBox(i, sw, sh),
                    );
                  }),
                ),

                SizedBox(height: sh * 0.015),

                if (_hasError && _errorMessage != null)
                  SizedBox(
                    width: double.infinity,
                    child: Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'NotoLoopedThai',
                        fontSize: (sw * 0.032).clamp(11.0, 14.0),
                        color: Colors.red,
                      ),
                    ),
                  )
                else if (!_canResend)
                  Padding(
                    padding: EdgeInsets.only(left: sw * 0.01),
                    child: Text(
                      _timerDisplay,
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: (sw * 0.035).clamp(12.0, 15.0),
                        color: const Color.fromARGB(180, 0, 0, 0),
                      ),
                    ),
                  ),

                SizedBox(height: sh * 0.18),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: sw * 0.048),
                  child: SizedBox(
                    width: double.infinity,
                    height: (sh * 0.055).clamp(44.0, 54.0),
                    child: ElevatedButton(
                      onPressed: _isVerifying ? null : (_hasError ? () => _resetCodeInputs(setError: false) : _handleVerify),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 248, 176, 104),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 0,
                      ),
                      child: _isVerifying
                          ? const CircularProgressIndicator(
                              color: Colors.black,
                              strokeWidth: 2,
                            )
                          : Text(
                              _hasError ? 'Réessayer' : 'Vérifier',
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

                Center(
                  child: GestureDetector(
                    onTap: _canResend && !_isVerifying ? _handleResend : null,
                    child: RichText(
                      text: TextSpan(
                        text: 'Vous n\'avez pas reçu le code ? ',
                        style: TextStyle(
                          fontFamily: 'NotoLoopedThai',
                          fontSize: (sw * 0.035).clamp(12.0, 15.0),
                          color: _canResend && !_isVerifying
                              ? Colors.black
                              : const Color.fromARGB(120, 0, 0, 0),
                        ),
                        children: [
                          TextSpan(
                            text: 'Renvoyer le code',
                            style: TextStyle(
                              fontFamily: 'NotoLoopedThai',
                              fontWeight: FontWeight.bold,
                              color: _canResend && !_isVerifying
                                  ? Colors.black
                                  : const Color.fromARGB(120, 0, 0, 0),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                SizedBox(height: sh * 0.03),
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