
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:peeco/client/pages/navigation_bar.dart';
import 'package:peeco/client/pages/app_constants.dart';
import 'package:peeco/client/pages/widgets/standard_header.dart';
import 'package:peeco/client/pages/widgets/standard_card.dart';
import 'package:peeco/core/pages/role_selection_page.dart';

// ─────────────────────────────────────────────
// COULEURS — Using AppConstants now
// ─────────────────────────────────────────────

// ─────────────────────────────────────────────
// ÉCRAN
// ─────────────────────────────────────────────
class ProfilClientScreen extends StatefulWidget {
  const ProfilClientScreen({super.key});

  @override
  State<ProfilClientScreen> createState() => _ProfilClientScreenState();
}

class _ProfilClientScreenState extends State<ProfilClientScreen> {

  // ── Données fictives ──
  String _nom            = 'Sofiane kadi';
  String _email          = 'sofiane.kadi8@gmail.com';
  String _adresse        = 'Oued Smar, Alger';
  final int    _nbReservations = 12;
  final int    _nbFavoris      = 8;
  final String _economise      = '2 140 DA';
  final String _membreDepuis   = 'Janvier 2024';
  
  bool _notifActives = true;

  // ─────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      body: CustomScrollView(
        slivers: [
          // Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: StandardHeader(
                title: 'Profil',
                showLogo: false,
                showSearchBar: false,
                showBackButton: false,
                trailing: GestureDetector(
                  onTap: _ouvrirEdition,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withOpacity(0.13),
                      borderRadius: BorderRadius.circular(AppBorderRadius.medium),
                      border: Border.all(color: AppColors.accent.withOpacity(0.35)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.edit_outlined, size: 12, color: AppColors.accent),
                        SizedBox(width: 4),
                        Text('Modifier',
                            style: TextStyle(
                                fontSize: AppTextSizes.caption,
                                fontWeight: AppFontWeights.bold,
                                color: AppColors.accent)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          // Hero - Avatar + Nom + Email + Badge
          SliverToBoxAdapter(child: _hero()),
          
          // Stats - Réservations / Favoris
          SliverToBoxAdapter(child: _carteStats()),
          
          // Économies
          SliverToBoxAdapter(child: _carteEconomies()),
          
          // Section Compte
          SliverToBoxAdapter(child: _sectionCompte()),
          
          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),
          
          // Section Aide
          SliverToBoxAdapter(child: _sectionAide()),
          
          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),
          
          // Documents Juridiques
          SliverToBoxAdapter(child: _sectionDocuments()),
          
          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),
          
          // Boutons actions
          SliverToBoxAdapter(child: _boutonsActions()),
          
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
        ],
      ),
      bottomNavigationBar: AppNavigationBar(
        selectedIndex: 4,
        onTap: (index) {
          AppNavigationBar.handleNavigation(context, index);
        },
      ),
    );
  }

  // ─────────────────────────────────────────────
  // HERO — En-tête avec avatar, nom, email, badge
  // ─────────────────────────────────────────────
  Widget _hero() {
    return Container(
      margin: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.sm),
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(AppBorderRadius.xlarge),
        border: Border.all(color: AppColors.divider.withOpacity(0.6)),
      ),
      child: Column(
        children: [
          // Avatar
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              color: AppColors.accent,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.white, width: 2),
            ),
            child: const Center(
              child: Text('S',
                  style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w600,
                      color: Colors.white)),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Nom
          Text(_nom,
              style: const TextStyle(
                  fontSize: AppTextSizes.titleLarge,
                  fontWeight: AppFontWeights.black,
                  color: AppColors.textDark)),
          const SizedBox(height: AppSpacing.xs),

          // Email
          Text(_email,
              style: const TextStyle(
                  fontSize: AppTextSizes.bodySmall, color: AppColors.textMuted)),
          const SizedBox(height: AppSpacing.sm),

          // Badge "Profil client"
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.accent.withOpacity(0.3)),
            ),
            child: const Text('Profil client',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.accent)),
          ),
          const SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // CARTE STATS — Réservations / Favoris
  // ─────────────────────────────────────────────
  Widget _carteStats() {
    return Container(
      margin: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.sm),
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(AppBorderRadius.xlarge),
        border: Border.all(color: AppColors.divider.withOpacity(0.6)),
      ),
      child: Row(
        children: [
          _statItem('$_nbReservations', 'Réservations'),
          Container(width: 1, height: 50, color: AppColors.divider),
          _statItem('$_nbFavoris', 'Favoris'),
        ],
      ),
    );
  }

  Widget _statItem(String val, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(val,
              style: const TextStyle(
                  fontSize: 24,
                  fontWeight: AppFontWeights.bold,
                  color: AppColors.textDark)),
          const SizedBox(height: AppSpacing.xs),
          Text(label,
              style: const TextStyle(
                  fontSize: AppTextSizes.caption, color: AppColors.textMuted)),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // CARTE ÉCONOMIES
  // ─────────────────────────────────────────────
  Widget _carteEconomies() {
    return Container(
      margin: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.md),
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(AppBorderRadius.xlarge),
        border: Border.all(color: AppColors.divider.withOpacity(0.6)),
      ),
      child: Column(
        children: [
          Text(_economise,
              style: const TextStyle(
                  fontSize: 24,
                  fontWeight: AppFontWeights.bold,
                  color: AppColors.accent)),
          const SizedBox(height: AppSpacing.xs),
          const Text('Économisés',
              style: TextStyle(fontSize: AppTextSizes.caption, color: AppColors.textMuted)),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // SECTION COMPTE
  // ─────────────────────────────────────────────
  Widget _sectionCompte() {
    return _carte(
      titre: 'Compte',
      enfants: [
        _ligneParam(
          Icons.location_on_outlined,
          'Mon adresse',
          subtitle: _adresse,
          onTap: () => Navigator.pushNamed(context, '/acces_rapide'),
        ),
        _ligneParam(
          Icons.notifications_outlined,
          'Notifications',
          onTap: () => Navigator.pushNamed(context, '/notifications_client'),
          trailing: const Icon(Icons.chevron_right, size: 20, color: AppColors.textMuted),
        ),
        _ligneParam(
          Icons.lock_outline,
          'Sécurité',
          onTap: () => _ouvrirPageSecurite(),
          isLast: true,
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // PAGE SÉCURITÉ
  // ─────────────────────────────────────────────
  void _ouvrirPageSecurite() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SecuritePage(),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // SECTION AIDE
  // ─────────────────────────────────────────────
  Widget _sectionAide() {
    return _carte(
      titre: 'Aide',
      enfants: [
        _ligneParam(
          Icons.help_outline_rounded,
          'Aide & support',
          onTap: () => _ouvrirPageAide(),
          isLast: true,
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // PAGE AIDE & SUPPORT
  // ─────────────────────────────────────────────
  void _ouvrirPageAide() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AideSupportPage(),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // SECTION DOCUMENTS JURIDIQUES
  // ─────────────────────────────────────────────
  Widget _sectionDocuments() {
    return _carte(
      titre: 'Documents Juridiques',
      enfants: [
        _ligneParam(
          Icons.description_outlined,
          "Conditions générales d'utilisation",
          onTap: () => _ouvrirDocumentJuridique('Conditions générales d\'utilisation'),
        ),
        _ligneParam(
          Icons.security_outlined,
          'Politique de confidentialité',
          onTap: () => _ouvrirDocumentJuridique('Politique de confidentialité'),
        ),
        _ligneParam(
          Icons.assignment_outlined,
          'Contrat de licence utilisateur',
          onTap: () => _ouvrirDocumentJuridique('Contrat de licence utilisateur'),
          isLast: true,
        ),
      ],
    );
  }

  void _ouvrirDocumentJuridique(String titre) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DocumentJuridiquePage(titre: titre),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // BOUTONS ACTIONS (avec thème cohérent)
  // ─────────────────────────────────────────────
  Widget _boutonsActions() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 0),
      child: Column(
        children: [
          // Se déconnecter
          GestureDetector(
            onTap: _confirmerDeconnexion,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.cardBg,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: AppColors.divider),
              ),
              child: const Center(
                child: Text('Se déconnecter',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark)),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Supprimer mon compte
          GestureDetector(
            onTap: _confirmerSuppression,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.dangerBg,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: AppColors.danger.withOpacity(0.5)),
              ),
              child: const Center(
                child: Text('Supprimer mon compte',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.danger)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // HELPERS WIDGETS
  // ─────────────────────────────────────────────
  Widget _carte({
    required String titre,
    required List<Widget> enfants,
  }) {
    return Container(
      margin: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, 0),
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.xs),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(AppBorderRadius.xlarge),
        border: Border.all(color: AppColors.divider.withOpacity(0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titre,
              style: const TextStyle(
                  fontSize: AppTextSizes.titleSmall,
                  fontWeight: AppFontWeights.bold,
                  color: AppColors.textDark)),
          const SizedBox(height: AppSpacing.md),
          ...enfants,
        ],
      ),
    );
  }

  Widget _ligneParam(
    IconData icon,
    String label, {
    String? subtitle,
    VoidCallback? onTap,
    Widget? trailing,
    bool isLast = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.only(bottom: isLast ? 0 : AppSpacing.md),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.scaffold,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.divider),
              ),
              child: Icon(icon, size: 20, color: AppColors.textDark),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: const TextStyle(
                          fontSize: AppTextSizes.bodyLarge,
                          fontWeight: AppFontWeights.medium,
                          color: AppColors.textDark)),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style: const TextStyle(
                            fontSize: AppTextSizes.bodySmall, color: AppColors.textMuted)),
                  ],
                ],
              ),
            ),
            trailing ??
                const Icon(Icons.chevron_right,
                    size: 20, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // MODIFICATION PROFIL
  // ─────────────────────────────────────────────
  void _ouvrirEdition() {
    final nomCtrl = TextEditingController(text: _nom);
    final emailCtrl = TextEditingController(text: _email);
    final adresseCtrl = TextEditingController(text: _adresse);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          decoration: const BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const Text('Modifier le profil',
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark)),
              const SizedBox(height: 20),
              _champTexte(nomCtrl, 'Nom complet', Icons.person_outline_rounded),
              const SizedBox(height: 12),
              _champTexte(emailCtrl, 'Email', Icons.email_outlined,
                  keyboard: TextInputType.emailAddress),
              const SizedBox(height: 12),
              _champTexte(adresseCtrl, 'Adresse', Icons.location_on_outlined),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _nom = nomCtrl.text.trim();
                    _email = emailCtrl.text.trim();
                    _adresse = adresseCtrl.text.trim();
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Profil mis à jour ✓'),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: Color(0xFF6B7C4E),
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(26),
                  ),
                  child: const Center(
                    child: Text('Enregistrer',
                        style: TextStyle(
                            color: AppColors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w800)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _champTexte(
    TextEditingController ctrl,
    String hint,
    IconData icon, {
    TextInputType keyboard = TextInputType.text,
  }) {
    return TextField(
      controller: ctrl,
      keyboardType: keyboard,
      style: const TextStyle(fontSize: AppTextSizes.bodySmall, color: AppColors.textDark),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: AppTextSizes.bodySmall),
        prefixIcon: Icon(icon, size: 18, color: AppColors.textMuted),
        filled: true,
        fillColor: AppColors.scaffold,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // POPUPS DE CONFIRMATION
  // ─────────────────────────────────────────────
  void _confirmerDeconnexion() {
    _showConfirmSheet(
      icon: Icons.logout_outlined,
      iconColor: AppColors.accent,
      iconBg: AppColors.accentBg,
      titre: 'Se déconnecter ?',
      corps: 'Vous devrez vous reconnecter pour accéder à votre espace.',
      labelConfirm: 'Déconnecter',
      couleurConfirm: AppColors.accent,
      onConfirm: () {
        Navigator.pop(context);
        Navigator.pushAndRemoveUntil(
            context, MaterialPageRoute(builder: (_) => const ChoicePage()), (route) => false);
      },
    );
  }

  void _confirmerSuppression() {
    _showConfirmSheet(
      icon: Icons.delete_outline_rounded,
      iconColor: AppColors.danger,
      iconBg: AppColors.dangerBg,
      titre: 'Supprimer le compte ?',
      corps: 'Cette action est irréversible. Toutes vos données seront effacées définitivement.',
      labelConfirm: 'Supprimer',
      couleurConfirm: AppColors.danger,
      onConfirm: () {
        Navigator.pop(context);
        Navigator.pushNamedAndRemoveUntil(
            context, '/choix_compte', (_) => false);
      },
    );
  }

  void _showConfirmSheet({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String titre,
    required String corps,
    required String labelConfirm,
    required Color couleurConfirm,
    required VoidCallback onConfirm,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: EdgeInsets.fromLTRB(
            20, 20, 20,
            MediaQuery.of(context).padding.bottom + 20),
        decoration: const BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2)),
            ),
            Container(
              width: 60, height: 60,
              decoration: BoxDecoration(
                  color: iconBg, shape: BoxShape.circle),
              child: Icon(icon, size: 26, color: iconColor),
            ),
            const SizedBox(height: 14),
            Text(titre,
                style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark)),
            const SizedBox(height: 8),
            Text(corps,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: AppTextSizes.bodySmall, color: AppColors.textMuted, height: 1.5)),
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppColors.scaffold,
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: const Center(
                        child: Text('Annuler',
                            style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                color: AppColors.textDark)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: onConfirm,
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: couleurConfirm,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Center(
                        child: Text(labelConfirm,
                            style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                                color: AppColors.white)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// PAGE SÉCURITÉ (avec thème cohérent)
// ═══════════════════════════════════════════════════════════════════════════
class SecuritePage extends StatefulWidget {
  const SecuritePage({super.key});

  @override
  State<SecuritePage> createState() => _SecuritePageState();
}

class _SecuritePageState extends State<SecuritePage> {
  final _ancienMdpCtrl = TextEditingController();
  final _nouveauMdpCtrl = TextEditingController();
  final _confirmerMdpCtrl = TextEditingController();

  @override
  void dispose() {
    _ancienMdpCtrl.dispose();
    _nouveauMdpCtrl.dispose();
    _confirmerMdpCtrl.dispose();
    super.dispose();
  }

  void _enregistrer() {
    if (_nouveauMdpCtrl.text != _confirmerMdpCtrl.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Les mots de passe ne correspondent pas'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Mot de passe modifié avec succès ✓'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.accentGreen,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: AppBar(
        backgroundColor: AppColors.headerBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Sécurité',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.cardBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.divider.withOpacity(0.6)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Modifier le mot de passe',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark)),
                  const SizedBox(height: AppSpacing.md),
                  const Text('Ancien mot de passe',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark)),
                  const SizedBox(height: 8),
                  _passwordField(_ancienMdpCtrl, 'Entrez votre ancien mot de passe'),
                  const SizedBox(height: AppSpacing.md),
                  const Text('Nouveau mot de passe',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark)),
                  const SizedBox(height: 8),
                  _passwordField(_nouveauMdpCtrl, 'Nouveau mot de passe'),
                  const SizedBox(height: AppSpacing.md),
                  const Text('Confirmer le mot de passe',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark)),
                  const SizedBox(height: 8),
                  _passwordField(_confirmerMdpCtrl, 'Confirmez votre nouveau mot de passe'),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            GestureDetector(
              onTap: _enregistrer,
              child: Container(
                width: double.infinity,
                height: 54,
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accent.withOpacity(0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text('Enregistrer',
                      style: TextStyle(
                          color: AppColors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w800)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _passwordField(TextEditingController ctrl, String hint) {
    return TextField(
      controller: ctrl,
      obscureText: true,
      style: const TextStyle(fontSize: AppTextSizes.bodySmall, color: AppColors.textDark),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: AppTextSizes.bodySmall),
        filled: true,
        fillColor: AppColors.inputBg,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// PAGE AIDE & SUPPORT (Placeholder)
// ═══════════════════════════════════════════════════════════════════════════
class AideSupportPage extends StatelessWidget {
  const AideSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: AppBar(
        backgroundColor: AppColors.headerBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Aide & Support',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark)),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.divider.withOpacity(0.6)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.accent.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.support_agent,
                      size: 40, color: AppColors.accent),
                ),
                const SizedBox(height: AppSpacing.lg),
                const Text('Page en construction',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark)),
                const SizedBox(height: AppSpacing.sm),
                const Text('Contenu à venir...',
                    style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textMuted)),
                const SizedBox(height: AppSpacing.lg),
                const Divider(color: AppColors.divider),
                const SizedBox(height: AppSpacing.lg),
                const Text('📧 Email: support@laaisraf.dz',
                    style: TextStyle(fontSize: 14, color: AppColors.textDark)),
                const SizedBox(height: AppSpacing.sm),
                const Text('📞 Téléphone: 021 123 456',
                    style: TextStyle(fontSize: 14, color: AppColors.textDark)),
                const SizedBox(height: AppSpacing.sm),
                const Text('💬 Chat: Disponible 9h-18h',
                    style: TextStyle(fontSize: 14, color: AppColors.textDark)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// PAGE DOCUMENT JURIDIQUE (Placeholder)
// ═══════════════════════════════════════════════════════════════════════════
class DocumentJuridiquePage extends StatelessWidget {
  final String titre;
  const DocumentJuridiquePage({super.key, required this.titre});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: AppBar(
        backgroundColor: AppColors.headerBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(titre,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark)),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.divider.withOpacity(0.6)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.accent.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.description_outlined,
                      size: 40, color: AppColors.accent),
                ),
                const SizedBox(height: AppSpacing.lg),
                const Text('Page en construction',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark)),
                const SizedBox(height: AppSpacing.sm),
                const Text('Ce document sera disponible prochainement.',
                    style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textMuted,
                        height: 1.5),
                    textAlign: TextAlign.center),
                const SizedBox(height: AppSpacing.lg),
                const Icon(Icons.arrow_downward, color: AppColors.textMuted),
                const SizedBox(height: AppSpacing.sm),
                const Text('Revenez bientôt !',
                    style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}