import 'package:flutter/material.dart';
import 'package:peeco/core/core.dart';
import 'package:peeco/commerce/commerce.dart';

class MerchantSignupStep1Page extends StatefulWidget {
  const MerchantSignupStep1Page({super.key});

  @override
  State<MerchantSignupStep1Page> createState() =>
      _MerchantSignupStep1PageState();
}

class _MerchantSignupStep1PageState extends State<MerchantSignupStep1Page> {
  static final _errorPadding = EdgeInsets.only(left: 14, top: 5, bottom: 2);

  final _prenomController = TextEditingController();
  final _nomController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _prenomFocus = FocusNode();
  final _nomFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _phoneFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmFocus = FocusNode();

  String? _prenomError;
  String? _nomError;
  String? _emailError;
  String? _phoneError;
  String? _passwordError;
  String? _confirmError;

  bool _obscurePassword = true;
  bool _obscureConfirm = true;

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
          () => _emailError = InputValidator.emailProfessionnel(
            _emailController.text,
          ),
        );
      }
    });

    _phoneFocus.addListener(() {
      if (!_phoneFocus.hasFocus) {
        setState(
          () =>
              _phoneError = InputValidator.phoneRequired(_phoneController.text),
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
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _prenomFocus.dispose();
    _nomFocus.dispose();
    _emailFocus.dispose();
    _phoneFocus.dispose();
    _passwordFocus.dispose();
    _confirmFocus.dispose();
    super.dispose();
  }

  void _handleNext() {
    setState(() {
      _prenomError = InputValidator.prenom(_prenomController.text);
      _nomError = InputValidator.nom(_nomController.text);
      _emailError = InputValidator.emailProfessionnel(_emailController.text);
      _phoneError = InputValidator.phoneRequired(_phoneController.text);
      _passwordError = InputValidator.newPassword(_passwordController.text);
      _confirmError = InputValidator.confirmPassword(
        _confirmPasswordController.text,
        _passwordController.text,
      );
    });

    if (_prenomError != null ||
        _nomError != null ||
        _emailError != null ||
        _phoneError != null ||
        _passwordError != null ||
        _confirmError != null)
      return;

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MerchantSignupStep2Page(
            prenom: _prenomController.text.trim(),
            nom: _nomController.text.trim(),
            email: _emailController.text.trim(),
            phone: _phoneController.text.trim(),
            password: _passwordController.text,
          ),
        ),
      );
    }
  }

  Widget _fieldError(String message) {
    return buildFieldError(message, padding: _errorPadding);
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;

    return commercePageScaffold(
      context: context,
      step: 1,
      isLoading: false,
      children: [
        sectionTitle('Informations du gérant', sw: sw, sh: sh),

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
                  if (_prenomError != null) _fieldError(_prenomError!),
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
                      if (_nomError != null) setState(() => _nomError = null);
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
          label: 'Adresse e-mail professionnel',
          icon: Icons.mail_outline,
          controller: _emailController,
          focusNode: _emailFocus,
          keyboardType: TextInputType.emailAddress,
          onChanged: (_) {
            if (_emailError != null) setState(() => _emailError = null);
          },
        ),
        if (_emailError != null) _fieldError(_emailError!),
        SizedBox(height: sh * 0.012),

        CustomInputField(
          label: 'Numéro de téléphone',
          icon: Icons.phone_outlined,
          controller: _phoneController,
          focusNode: _phoneFocus,
          keyboardType: TextInputType.phone,
          onChanged: (_) {
            if (_phoneError != null) setState(() => _phoneError = null);
          },
        ),
        if (_phoneError != null) _fieldError(_phoneError!),
        SizedBox(height: sh * 0.012),

        CustomInputField(
          label: 'Mot de passe',
          icon: Icons.lock_outline,
          controller: _passwordController,
          focusNode: _passwordFocus,
          obscureText: _obscurePassword,
          onChanged: (_) {
            if (_passwordError != null) setState(() => _passwordError = null);
            if (_confirmError != null) {
              setState(
                () => _confirmError = InputValidator.confirmPassword(
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
            onPressed: () =>
                setState(() => _obscurePassword = !_obscurePassword),
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
            if (_confirmError != null) setState(() => _confirmError = null);
          },
          suffixIcon: IconButton(
            icon: Icon(
              _obscureConfirm
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: Colors.black54,
              size: 20,
            ),
            onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
          ),
        ),
        if (_confirmError != null) _fieldError(_confirmError!),
        SizedBox(height: sh * 0.025),

        actionButton(
          label: 'Suivant',
          onPressed: _handleNext,
          sw: sw,
          sh: sh,
          isLoading: false,
        ),
      ],
    );
  }
}
