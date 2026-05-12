import 'package:flutter/material.dart';

class DocumentsJuridiquesPage extends StatelessWidget {
  const DocumentsJuridiquesPage({super.key});

  static const Color topBarColor = Color(0xFFCCD5AE);
  static const Color backgroundColor = Color(0xFFFEFAE0);
  static const Color cardColor = Color(0xFFFFF8E8);
  static const Color brownColor = Color(0xFF5D4E37);
  static const Color lightBrown = Color(0xFF8B7355);

  @override
  Widget build(BuildContext context) {
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
                  const Expanded(
                    child: Text(
                      'Documents Juridiques — PEECO',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF3E2723),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),

                    // ── CONDITIONS D'UTILISATION ──
                    _buildDocCard(
                      children: [
                        _buildDocTitle("CONDITIONS D'UTILISATION"),
                        _buildVersion("Version 1.0 — 26 mars 2026"),
                        _buildArticleTitle("1. Objet"),
                        _buildParagraph(
                          "PEECO est une application qui met en relation des commerçants souhaitant vendre leurs produits alimentaires invendus à prix réduit, et des clients souhaitant les acheter. PEECO agit uniquement comme intermédiaire technique — la vente se fait directement entre le commerçant et le client.",
                        ),
                        _buildArticleTitle("2. Inscription"),
                        _buildParagraph(
                          "L'utilisation de PEECO requiert la création d'un compte avec des informations exactes. Les commerçants doivent fournir un numéro de registre de commerce valide. Vous êtes responsable de la confidentialité de vos identifiants.",
                        ),
                        _buildArticleTitle("3. Obligations des Commerçants"),
                        _buildBullet(
                          "Proposer uniquement des produits propres à la consommation et conformes aux normes sanitaires.",
                        ),
                        _buildBullet(
                          "Indiquer correctement la nature, la quantité et les dates de péremption des produits.",
                        ),
                        _buildBullet(
                          "Honorer toute commande confirmée et informer PEECO en cas d'impossibilité.",
                        ),
                        _buildBullet(
                          "Ne jamais proposer de produits avariés ou dangereux.",
                        ),
                        _buildArticleTitle("4. Obligations des Clients"),
                        _buildBullet(
                          "Se présenter au retrait dans le créneau horaire convenu.",
                        ),
                        _buildBullet(
                          "Consommer les produits dans les délais indiqués.",
                        ),
                        _buildBullet(
                          "Ne pas revendre à titre commercial les produits achetés via PEECO.",
                        ),
                        _buildArticleTitle("5. Paiements & Remboursements"),
                        _buildParagraph(
                          "Le paiement s'effectue en ligne au moment de la réservation. Si un commerçant annule une commande, le client est remboursé intégralement sous 3 à 5 jours ouvrés. Aucun remboursement n'est accordé pour une commande déjà confirmée, sauf non-conformité avérée du produit.",
                        ),
                        _buildArticleTitle("6. Responsabilités"),
                        _buildParagraph(
                          "Les commerçants sont seuls responsables de la qualité et de la conformité de leurs produits. PEECO ne peut être tenu responsable des actes des commerçants ni de la qualité des produits vendus. Les clients reconnaissent acheter des produits proches de leur date de péremption.",
                        ),
                        _buildArticleTitle("7. Résiliation"),
                        _buildParagraph(
                          "PEECO peut suspendre ou supprimer tout compte en cas de violation des présentes conditions. Les utilisateurs peuvent supprimer leur compte à tout moment depuis les paramètres de l'application.",
                        ),
                        _buildArticleTitle("8. Loi applicable"),
                        _buildParagraph(
                          "Les présentes conditions sont soumises au droit algérien. Tout litige fera l'objet d'une tentative de résolution amiable avant tout recours judiciaire.",
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // ── POLITIQUE DE CONFIDENTIALITÉ ──
                    _buildDocCard(
                      children: [
                        _buildDocTitle("POLITIQUE DE CONFIDENTIALITÉ"),
                        _buildVersion("Version 1.0 — 26 mars 2026"),
                        _buildArticleTitle("1. Données collectées"),
                        _buildParagraph(
                          "Clients : nom, e-mail, téléphone, localisation (avec consentement), historique de commandes.\nCommerçants : raison sociale, registre de commerce, coordonnées bancaires (via prestataire sécurisé), données d'activité.",
                        ),
                        _buildArticleTitle("2. Utilisation des données"),
                        _buildBullet(
                          "Gestion des comptes et traitement des commandes.",
                        ),
                        _buildBullet(
                          "Amélioration de l'application et prévention des fraudes.",
                        ),
                        _buildBullet(
                          "Envoi de notifications et offres promotionnelles (avec votre consentement).",
                        ),
                        _buildBullet(
                          "Respect des obligations légales et comptables.",
                        ),
                        _buildArticleTitle("3. Conservation"),
                        _buildParagraph(
                          "Données de compte : 3 ans après suppression. Données de transactions : 10 ans (obligation légale). Données de localisation : 90 jours maximum.",
                        ),
                        _buildArticleTitle("4. Partage des données"),
                        _buildParagraph(
                          "PEECO ne vend jamais vos données. Elles peuvent être partagées uniquement avec nos prestataires de paiement et d'hébergement, ou sur demande des autorités compétentes. Entre commerçants et clients, seules les informations nécessaires au retrait sont partagées.",
                        ),
                        _buildArticleTitle("5. Vos droits"),
                        _buildParagraph(
                          "Vous pouvez à tout moment accéder, rectifier, supprimer ou exporter vos données personnelles, ou retirer votre consentement. Pour exercer ces droits : privacy@peeco.app",
                        ),
                        _buildArticleTitle("6. Sécurité"),
                        _buildParagraph(
                          "Vos données sont chiffrées en transit et au repos. Nous réalisons des audits de sécurité réguliers pour garantir leur protection.",
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // ── CONTRAT DE LICENCE UTILISATEUR ──
                    _buildDocCard(
                      children: [
                        _buildDocTitle("CONTRAT DE LICENCE UTILISATEUR (CLUF)"),
                        _buildVersion("Version 1.0 — 26 mars 2026"),
                        _buildArticleTitle("1. Licence accordée"),
                        _buildParagraph(
                          "PEECO vous accorde une licence personnelle, non exclusive et non transférable pour installer et utiliser l'application PEECO sur vos appareils. Cette licence est gratuite pour les clients. Pour les commerçants, certaines fonctionnalités avancées peuvent être soumises à abonnement.",
                        ),
                        _buildArticleTitle(
                          "2. Ce que vous ne pouvez pas faire",
                        ),
                        _buildBullet(
                          "Copier, modifier ou décompiler l'application.",
                        ),
                        _buildBullet(
                          "Revendre ou sublicencier l'accès à l'application.",
                        ),
                        _buildBullet(
                          "Utiliser des robots ou scripts automatisés sans autorisation.",
                        ),
                        _buildBullet(
                          "Contourner les mesures de sécurité de la plateforme.",
                        ),
                        _buildBullet(
                          "Publier des informations fausses ou frauduleuses.",
                        ),
                        _buildArticleTitle("3. Propriété"),
                        _buildParagraph(
                          "L'application PEECO, son code, son interface et ses marques sont la propriété exclusive de PEECO SAS. Ce contrat ne vous transfère aucun droit de propriété, uniquement un droit d'usage limité.",
                        ),
                        _buildArticleTitle(
                          "4. Conditions spécifiques — Commerçants",
                        ),
                        _buildParagraph(
                          "Les commerçants s'engagent à ce que tout contenu publié (photos, descriptions, prix) soit exact et légal. PEECO perçoit une commission sur chaque vente, dont le taux est communiqué à l'inscription. Toute modification du taux sera notifiée 30 jours à l'avance.",
                        ),
                        _buildArticleTitle(
                          "5. Conditions spécifiques — Clients",
                        ),
                        _buildParagraph(
                          "L'accès Client est réservé à un usage personnel et non commercial. Les avis laissés doivent être sincères et respectueux. PEECO se réserve le droit de supprimer tout avis diffamatoire ou faux.",
                        ),
                        _buildArticleTitle("6. Résiliation"),
                        _buildParagraph(
                          "Ce contrat prend fin si vous supprimez votre compte ou si PEECO résilie votre accès en cas de violation des présentes conditions. À la résiliation, votre droit d'utiliser l'application cesse immédiatement.",
                        ),
                        _buildArticleTitle("7. Limitation de responsabilité"),
                        _buildParagraph(
                          "L'application est fournie « en l'état ». PEECO ne peut être tenu responsable des dommages indirects liés à son utilisation. La responsabilité totale de PEECO est limitée aux sommes versées par l'utilisateur au cours des 12 derniers mois.",
                        ),
                        _buildArticleTitle("8. Contact"),
                        _buildParagraph(
                          "Pour toute question : legal@peeco.app",
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocCard({required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8DCC8), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildDocTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w800,
          color: Color(0xFF3E2723),
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _buildVersion(String version) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        version,
        style: const TextStyle(
          fontSize: 11,
          color: Color(0xFF9E9E9E),
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }

  Widget _buildArticleTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: Color(0xFF5D4E37),
        ),
      ),
    );
  }

  Widget _buildParagraph(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          color: Color(0xFF424242),
          height: 1.55,
        ),
      ),
    );
  }

  Widget _buildBullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3, left: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 5),
            child: Text(
              '– ',
              style: TextStyle(fontSize: 12, color: Color(0xFF5D4E37)),
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF424242),
                height: 1.55,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
