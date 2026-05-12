class InputValidator {
  static String? emailOrPhone(String value) {
    if (value.trim().isEmpty)
      return 'Veuillez entrer votre adresse e-mail ou numéro de téléphone';

    final emailRegex = RegExp(r'^[\w.-]+@[\w.-]+\.[a-zA-Z]{2,}$');
    final phoneRegex = RegExp(r'^0[567][0-9]{8}$');

    if (!emailRegex.hasMatch(value.trim()) &&
        !phoneRegex.hasMatch(value.trim())) {
      return 'Adresse e-mail ou numéro invalide (ex: 0612345678 ou nom@email.com)';
    }

    if (emailRegex.hasMatch(value.trim()) && value.trim().length > 190) {
      return 'L\'adresse e-mail ne doit pas dépasser 190 caractères';
    }

    return null;
  }

  static String? password(String value) {
    if (value.isEmpty) return 'Veuillez entrer votre mot de passe';
    if (value.length < 8)
      return 'Le mot de passe doit contenir au moins 8 caractères';
    if (value.length > 100)
      return 'Le mot de passe ne doit pas dépasser 100 caractères';
    return null;
  }

  static String? email(String value) {
    if (value.trim().isEmpty) return 'Veuillez entrer votre adresse e-mail';
    final emailRegex = RegExp(r'^[\w.-]+@[\w.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value.trim()))
      return 'Adresse e-mail invalide (ex: nom@email.com)';
    if (value.trim().length > 190)
      return 'L\'adresse e-mail ne doit pas dépasser 190 caractères';
    return null;
  }

  static String? confirmPassword(String value, String original) {
    if (value.isEmpty) return 'Veuillez confirmer votre mot de passe';
    if (value != original) return 'Les mots de passe ne correspondent pas';
    return null;
  }

  static String? fullName(String value) {
    if (value.trim().isEmpty) return 'Veuillez entrer votre nom complet';
    if (value.trim().length < 1 || value.trim().length > 150)
      return 'Le nom doit contenir entre 1 et 150 caractères';
    final nameRegex = RegExp(r"^[a-zA-ZÀ-ÿ\s\-']+$");
    if (!nameRegex.hasMatch(value.trim()))
      return 'Le nom ne doit contenir que des lettres';
    return null;
  }

  /// Optional phone — returns null if empty (field not required)
  static String? phone(String value) {
    if (value.trim().isEmpty) return null;
    final phoneRegex = RegExp(r'^0[567][0-9]{8}$');
    if (!phoneRegex.hasMatch(value.trim())) {
      return 'Numéro invalide (doit commencer par 05, 06 ou 07 et contenir 10 chiffres)';
    }
    return null;
  }

  static String? nomCommerce(String value) {
    if (value.trim().isEmpty) return 'Veuillez entrer le nom de votre commerce';
    if (value.trim().length > 180)
      return 'Le nom du commerce ne doit pas dépasser 180 caractères';
    return null;
  }

  static String? verificationCode(String value) {
    if (value.trim().isEmpty) return 'Veuillez entrer le code de vérification';
    if (value.trim().length != 6)
      return 'Le code doit contenir exactement 6 caractères';
    return null;
  }

  /// Validates a full street address (rue, bâtiment, etc.)
  /// Requires at least 5 characters and no more than 250.
  static String? adresseComplete(String value) {
    if (value.trim().isEmpty)
      return 'Veuillez entrer l\'adresse complète de votre commerce';
    if (value.trim().length < 5)
      return 'L\'adresse est trop courte (minimum 5 caractères)';
    if (value.trim().length > 250)
      return 'L\'adresse ne doit pas dépasser 250 caractères';
    return null;
  }

  /// Validates first name (Prénom) — required, letters only, 1–50 chars
  static String? prenom(String value) {
    if (value.trim().isEmpty) return 'Veuillez entrer votre prénom';
    if (value.trim().length > 50)
      return 'Le prénom ne doit pas dépasser 50 caractères';
    final nameRegex = RegExp(r"^[a-zA-ZÀ-ÿ\s\-']+$");
    if (!nameRegex.hasMatch(value.trim()))
      return 'Le prénom ne doit contenir que des lettres';
    return null;
  }

  /// Validates last name (Nom) — required, letters only, 1–50 chars
  static String? nom(String value) {
    if (value.trim().isEmpty) return 'Veuillez entrer votre nom';
    if (value.trim().length > 50)
      return 'Le nom ne doit pas dépasser 50 caractères';
    final nameRegex = RegExp(r"^[a-zA-ZÀ-ÿ\s\-']+$");
    if (!nameRegex.hasMatch(value.trim()))
      return 'Le nom ne doit contenir que des lettres';
    return null;
  }

  /// Validates a professional email — same rules as email() but required context is signup
  static String? emailProfessionnel(String value) {
    if (value.trim().isEmpty)
      return 'Veuillez entrer votre adresse e-mail professionnelle';
    final emailRegex = RegExp(r'^[\w.-]+@[\w.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value.trim()))
      return 'Adresse e-mail invalide (ex: nom@entreprise.com)';
    if (value.trim().length > 190)
      return 'L\'adresse e-mail ne doit pas dépasser 190 caractères';
    return null;
  }

  /// Validates phone when it is REQUIRED (signup forms)
  static String? phoneRequired(String value) {
    if (value.trim().isEmpty)
      return 'Veuillez entrer votre numéro de téléphone';
    final phoneRegex = RegExp(r'^0[567][0-9]{8}$');
    if (!phoneRegex.hasMatch(value.trim())) {
      return 'Numéro invalide (doit commencer par 05, 06 ou 07 et contenir 10 chiffres)';
    }
    return null;
  }

  /// Validates a new password (signup) — stricter than login:
  /// requires at least one letter and one digit
  static String? newPassword(String value) {
    if (value.isEmpty) return 'Veuillez entrer un mot de passe';
    if (value.length < 8)
      return 'Le mot de passe doit contenir au moins 8 caractères';
    if (value.length > 100)
      return 'Le mot de passe ne doit pas dépasser 100 caractères';
    if (!RegExp(r'[a-zA-Z]').hasMatch(value))
      return 'Le mot de passe doit contenir au moins une lettre';
    if (!RegExp(r'[0-9]').hasMatch(value))
      return 'Le mot de passe doit contenir au moins un chiffre';
    return null;
  }

  /// Validates Algerian RC numbers.
  static String? numeroRC(String value) {
    final v = value.trim();
    if (v.isEmpty) return 'Veuillez entrer le numéro du Registre du Commerce';

    final withSlash = RegExp(r'^(0[1-9]|[1-5][0-9]|6[0-9])/[0-9]{5,8}$');

    final digitsOnly = RegExp(r'^[0-9]{7,10}$');

    if (!withSlash.hasMatch(v) && !digitsOnly.hasMatch(v)) {
      return 'Numéro RC invalide (ex: 16/0012345 ou 160012345) — code wilaya entre 01 et 69';
    }
    return null;
  }

  /// Validates that a required document file has been selected.
  /// Pass the label so the error message names the document.
  static String? documentRequired(dynamic file, String documentLabel) {
    if (file == null) return 'Veuillez joindre $documentLabel';
    return null;
  }
}
