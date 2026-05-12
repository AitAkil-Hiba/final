import 'package:flutter/material.dart';
import 'package:peeco/core/core.dart';
import 'package:peeco/client/client.dart';
import 'package:flutter/gestures.dart';
import 'package:peeco/commerce/commerce.dart';

class ChoicePage extends StatefulWidget {
  const ChoicePage({super.key});

  @override
  State<ChoicePage> createState() => _ChoicePageState();
}

class _ChoicePageState extends State<ChoicePage> {
  static const _clientHighlights = [
    'Découvrez des plats locaux',
    'Commandez rapidement',
    'Profitez des meilleures offres',
  ];
  static const _merchantHighlights = [
    'Augmentez vos ventes',
    'Présentez votre menu en ligne',
    'Touchez plus de clients',
  ];

  String? selectedRole;
  bool showError = false;

  void _handleContinue() {
    if (selectedRole == null) {
      setState(() => showError = true);
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) setState(() => showError = false);
      });
      return;
    }
    if (selectedRole == 'client') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ClientSignupPage()),
      );
    } else if (selectedRole == 'commercant') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => MerchantSignupStep1Page()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size    = MediaQuery.of(context).size;
    final sh      = size.height;
    final sw      = size.width;
    final padding = MediaQuery.of(context).padding;

    final verticalPad = (sh * 0.07).clamp(30.0, 80.0);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: appGradient,
        child: SafeArea(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: sh - padding.top - padding.bottom,
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: sw * 0.062,
                  vertical: verticalPad,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'Bienvenue ! Qui êtes-vous ?',
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
                    SizedBox(height: sh * 0.016),

                    Text(
                      'Choisissez votre profil pour créer\nvotre compte adapté à vos besoins.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'NotoLoopedThai',
                        fontSize: (sw * 0.038).clamp(13.0, 17.0),
                        color: const Color(0xFF383838),
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: sh * 0.065),

                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: _ChoiceCard(
                              icon: Icons.person_outline,
                              title: 'Client',
                              description:
                                  'Explorez des repas près de vous et commandez en quelques clics.',
                              color: const Color(0xFFB5C99A),
                              isSelected: selectedRole == 'client',
                              onTap: () => setState(() {
                                selectedRole = 'client';
                                showError = false;
                              }),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _ChoiceCard(
                              icon: Icons.storefront_outlined,
                              title: 'Commerçant',
                              description:
                                  'Présentez vos plats et développez votre activité grâce à nos outils.',
                              color: const Color(0xFFF8B068),
                              isSelected: selectedRole == 'commercant',
                              onTap: () => setState(() {
                                selectedRole = 'commercant';
                                showError = false;
                              }),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: sh * 0.018),

                    if (showError)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.error_outline, color: Colors.red, size: 16),
                          SizedBox(width: 6),
                          Text(
                            'Veuillez choisir votre profil d\'abord',
                            style: TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 13,
                              color: Colors.red,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),

                    SizedBox(height: sh * 0.008),

                    if (selectedRole != null)
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: sw * 0.05),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          decoration: BoxDecoration(
                            color: (selectedRole == 'client'
                                    ? const Color(0xFFB5C99A)
                                    : const Color(0xFFF8B068))
                                .withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              for (final point in selectedRole == 'client'
                                  ? _clientHighlights
                                  : _merchantHighlights)
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 3),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.circle,
                                          size: 6, color: Color(0xFF7A6640)),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          point,
                                          style: const TextStyle(
                                            fontFamily: 'PlusJakartaSans',
                                            fontSize: 13,
                                            color: Color(0xFF5C4A1E),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),

                    SizedBox(
                        height: selectedRole != null ? sh * 0.035 : sh * 0.07),

                    SizedBox(
                      width: double.infinity,
                      height: (sh * 0.055).clamp(44.0, 54.0),
                      child: ElevatedButton(
                        onPressed: _handleContinue,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: selectedRole == 'client'
                              ? const Color(0xFFB5C99A)
                              : const Color(0xFFF8B068),
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          selectedRole == null
                              ? 'Créer mon Compte'
                              : selectedRole == 'client'
                                  ? 'Créer mon Compte Client'
                                  : 'Créer mon Compte Commerçant',
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontWeight: FontWeight.bold,
                            fontSize: (sw * 0.043).clamp(14.0, 18.0),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: sh * 0.013),

                    RichText(
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

                    SizedBox(height: sh * 0.01),
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


class _ChoiceCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;
  final Color color;
  final bool isSelected;

  const _ChoiceCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
    required this.color,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    final sw       = MediaQuery.of(context).size.width;
    final iconSize = (sw * 0.065).clamp(20.0, 28.0);   
    final iconPad  = (sw * 0.04).clamp(12.0, 17.0);    

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(sw * 0.035),             
        decoration: BoxDecoration(
          color: isSelected
              ? color
              : const Color.fromARGB(134, 183, 192, 157),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.15),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(iconPad),
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.black, size: iconSize),
            ),
            SizedBox(height: sw * 0.025),              

            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontWeight: FontWeight.bold,
                fontSize: (sw * 0.038).clamp(12.0, 16.0), 
                color: Colors.black,
              ),
            ),
            SizedBox(height: sw * 0.016),              

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                description,
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: (sw * 0.027).clamp(9.0, 12.0), 
                  color: const Color.fromARGB(164, 0, 0, 0),
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}