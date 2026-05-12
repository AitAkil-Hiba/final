import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:peeco/core/core.dart';
import 'package:peeco/client/client.dart';
import 'package:peeco/commerce/commerce.dart';
import 'package:peeco/services/auth_service.dart';

class CompleteProfilePage extends StatefulWidget {
  final String prenom;
  final String nom;

  const CompleteProfilePage({
    super.key,
    required this.prenom,
    required this.nom,
  });

  @override
  State<CompleteProfilePage> createState() => _CompleteProfilePageState();
}

class _CompleteProfilePageState extends State<CompleteProfilePage> {
  final AuthService _authService = AuthService();
  
  File? _pickedImage;
  bool _useInitials = false;
  bool _isLoading = false;

  String get _initials {
    final p = widget.prenom.isNotEmpty ? widget.prenom[0].toUpperCase() : '';
    final n = widget.nom.isNotEmpty ? widget.nom[0].toUpperCase() : '';
    return '$p$n';
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

  Future<void> _pickFromGallery() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _pickedImage = File(picked.path);
        _useInitials = false;
      });
    }
  }

  Future<void> _pickFromCamera() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.camera);
    if (picked != null) {
      setState(() {
        _pickedImage = File(picked.path);
        _useInitials = false;
      });
    }
  }

  void _selectInitials() {
    setState(() {
      _pickedImage = null;
      _useInitials = true;
    });
  }

  Future<void> _goToHome() async {
    setState(() => _isLoading = true);

    if (_pickedImage != null) {
      final success = await _authService.uploadProfileImage(_pickedImage!.path);
      if (success) {
        print('  Profile image uploaded');
      } else {
        print('  Failed to upload profile image');
      }
    }

    final role = await _authService.getUserRole();
    
    setState(() => _isLoading = false);

    if (mounted) {
      _showSuccessBanner(
        'Profil complété !',
        'Bienvenue sur Peeco',
      );
      
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          if (role == 'CLIENT') {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const ClientHome()),
              (route) => false,
            );
          } else if (role == 'MERCHANT') {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const AccueilCommercantPage()),
              (route) => false,
            );
          } else {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const ClientHome()),
              (route) => false,
            );
          }
        }
      });
    }
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
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: sh),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: sh * 0.09),

                    SizedBox(
                      width: double.infinity,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'Completez votre profil',
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

                    Text(
                      'Ajoutez une photo pour que\nles commerçants vous reconnaissent.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'NotoLoopedThai',
                        fontSize: (sw * 0.038).clamp(12.0, 15.0),
                        color: const Color.fromARGB(187, 0, 0, 0),
                        height: 1.5,
                      ),
                    ),

                    SizedBox(height: sh * 0.07),

                    _Avatar(
                      image: _pickedImage,
                      useInitials: _useInitials,
                      initials: _initials,
                      size: sw * 0.38,
                      backgroundColor: const Color.fromARGB(255, 210, 213, 178),
                    ),

                    SizedBox(height: sh * 0.08),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _SourceButton(
                          icon: Icons.image_outlined,
                          label: 'Galerie',
                          onTap: _pickFromGallery,
                          size: sw * 0.21,
                        ),
                        SizedBox(width: sw * 0.05),
                        _SourceButton(
                          icon: Icons.camera_alt_outlined,
                          label: 'Caméra',
                          onTap: _pickFromCamera,
                          size: sw * 0.21,
                        ),
                        SizedBox(width: sw * 0.05),
                        _SourceButton(
                          customLabel: 'Aa',
                          label: 'Initiales',
                          onTap: _selectInitials,
                          size: sw * 0.21,
                        ),
                      ],
                    ),

                    SizedBox(height: sh * 0.1),

                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: sw * 0.048),
                      child: SizedBox(
                        width: double.infinity,
                        height: (sh * 0.055).clamp(44.0, 54.0),
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _goToHome,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(255, 248, 176, 104),
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
                                  'Continuer',
                                  style: TextStyle(
                                    fontFamily: 'PlusJakartaSans',
                                    fontWeight: FontWeight.bold,
                                    fontSize: (sw * 0.048).clamp(15.0, 21.0),
                                  ),
                                ),
                        ),
                      ),
                    ),

                    SizedBox(height: sh * 0.015),

                    GestureDetector(
                      onTap: _isLoading ? null : _goToHome,
                      child: Text(
                        'Passer cette étape',
                        style: TextStyle(
                          fontFamily: 'NotoLoopedThai',
                          fontSize: (sw * 0.04).clamp(14.0, 18.0),
                          color: const Color.fromARGB(199, 0, 0, 0),
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),

                    SizedBox(height: sh * 0.05),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final File? image;
  final bool useInitials;
  final String initials;
  final double size;
  final Color backgroundColor;

  const _Avatar({
    required this.image,
    required this.useInitials,
    required this.initials,
    this.size = 120,
    this.backgroundColor = const Color.fromARGB(255, 232, 228, 210),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: backgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(2, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: _content(),
    );
  }

  Widget _content() {
    if (image != null) {
      return Image.file(image!, fit: BoxFit.cover);
    }
    if (useInitials) {
      return Center(
        child: Text(
          initials,
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontWeight: FontWeight.normal,
            fontSize: size * 0.4,
            color: const Color.fromARGB(255, 0, 0, 0),
          ),
        ),
      );
    }
    return Center(
      child: Image.asset(
        'assets/icon_person.png',
        width: size * 0.9,
        height: size * 0.9,
        fit: BoxFit.contain,
        color: const Color.fromARGB(255, 0, 0, 0),
      ),
    );
  }
}

class _SourceButton extends StatelessWidget {
  final IconData? icon;
  final String? customLabel;
  final String label;
  final VoidCallback onTap;
  final double size;

  const _SourceButton({
    this.icon,
    this.customLabel,
    required this.label,
    required this.onTap,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 210, 213, 178),
          borderRadius: BorderRadius.circular(size * 0.29),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 10,
              spreadRadius: 2,
              offset: const Offset(2, 4),
            ),
          ],
        ),
        child: Center(
          child: customLabel != null
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      customLabel!,
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontWeight: FontWeight.bold,
                        fontSize: size * 0.27,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: size * 0.03),
                    Text(
                      label,
                      style: TextStyle(
                        fontFamily: 'NotoLoopedThai',
                        fontSize: size * 0.14,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, size: size * 0.29, color: Colors.black87),
                    SizedBox(height: size * 0.05),
                    Text(
                      label,
                      style: TextStyle(
                        fontFamily: 'NotoLoopedThai',
                        fontSize: size * 0.14,
                        color: Colors.black87,
                      ),
                    ),
                  ],
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