import 'package:flutter/material.dart';
import 'package:peeco/core/core.dart';

class ConditionsPage extends StatelessWidget {
  const ConditionsPage({super.key});
  @override
  Widget build(BuildContext context) => _LegalPage(
    title: "Conditions d'utilisation",
    version: 'Version 1.0 — 26 mars 2026',
    sections: const [
      _Section(
        title: '1. Objet',
        body:
            'PEECO est une application qui met en relation des commerçants souhaitant vendre leurs produits alimentaires invendus à prix réduit, et des clients souhaitant les acheter. PEECO agit uniquement comme intermédiaire technique — la vente se fait directement entre le commerçant et le client.',
      ),
      _Section(
        title: '2. Inscription',
        body:
            "L'utilisation de PEECO requiert la création d'un compte avec des informations exactes. Les commerçants doivent fournir un numéro de registre de commerce valide. Vous êtes responsable de la confidentialité de vos identifiants.",
      ),
      _Section(
        title: '3. Obligations des Commerçants',
        bullets: [
          'Proposer uniquement des produits propres à la consommation et conformes aux normes sanitaires.',
          'Indiquer correctement la nature, la quantité et les dates de péremption des produits.',
          "Honorer toute commande confirmée et informer PEECO en cas d'impossibilité.",
          'Ne jamais proposer de produits avariés ou dangereux.',
        ],
      ),
      _Section(
        title: '4. Obligations des Clients',
        bullets: [
          'Se présenter au retrait dans le créneau horaire convenu.',
          'Consommer les produits dans les délais indiqués.',
          'Ne pas revendre à titre commercial les produits achetés via PEECO.',
        ],
      ),
      _Section(
        title: '5. Paiements & Remboursements',
        body:
            "Le paiement s'effectue en ligne au moment de la réservation. Si un commerçant annule une commande, le client est remboursé intégralement sous 3 à 5 jours ouvrés. Aucun remboursement n'est accordé pour une commande déjà confirmée, sauf non-conformité avérée du produit.",
      ),
      _Section(
        title: '6. Responsabilités',
        body:
            "Les commerçants sont seuls responsables de la qualité et de la conformité de leurs produits. PEECO ne peut être tenu responsable des actes des commerçants ni de la qualité des produits vendus. Les clients reconnaissent acheter des produits proches de leur date de péremption.",
      ),
      _Section(
        title: '7. Résiliation',
        body:
            "PEECO peut suspendre ou supprimer tout compte en cas de violation des présentes conditions. Les utilisateurs peuvent supprimer leur compte à tout moment depuis les paramètres de l'application.",
      ),
      _Section(
        title: '8. Loi applicable',
        body:
            "Les présentes conditions sont soumises au droit algérien. Tout litige fera l'objet d'une tentative de résolution amiable avant tout recours judiciaire.",
      ),
    ],
  );
}

class PolitiqueConfidentialitePage extends StatelessWidget {
  const PolitiqueConfidentialitePage({super.key});
  @override
  Widget build(BuildContext context) => _LegalPage(
    title: 'Politique de confidentialité',
    version: 'Version 1.0 — 26 mars 2026',
    sections: const [
      _Section(
        title: '1. Données collectées',
        body:
            'Clients : nom, e-mail, téléphone, localisation (avec consentement), historique de commandes.\n\nCommerçants : raison sociale, registre de commerce, coordonnées bancaires (via prestataire sécurisé), données d\'activité.',
      ),
      _Section(
        title: '2. Utilisation des données',
        bullets: [
          'Gestion des comptes et traitement des commandes.',
          "Amélioration de l'application et prévention des fraudes.",
          'Envoi de notifications et offres promotionnelles (avec votre consentement).',
          'Respect des obligations légales et comptables.',
        ],
      ),
      _Section(
        title: '3. Conservation',
        body:
            'Données de compte : 3 ans après suppression.\nDonnées de transactions : 10 ans (obligation légale).\nDonnées de localisation : 90 jours maximum.',
      ),
      _Section(
        title: '4. Partage des données',
        body:
            "PEECO ne vend jamais vos données. Elles peuvent être partagées uniquement avec nos prestataires de paiement et d'hébergement, ou sur demande des autorités compétentes. Entre commerçants et clients, seules les informations nécessaires au retrait sont partagées.",
      ),
      _Section(
        title: '5. Vos droits',
        body:
            "Vous pouvez à tout moment accéder, rectifier, supprimer ou exporter vos données personnelles, ou retirer votre consentement.\n\nPour exercer ces droits : privacy@peeco.app",
      ),
      _Section(
        title: '6. Sécurité',
        body:
            'Vos données sont chiffrées en transit et au repos. Nous réalisons des audits de sécurité réguliers pour garantir leur protection.',
      ),
    ],
  );
}

class ContratLicencePage extends StatelessWidget {
  const ContratLicencePage({super.key});
  @override
  Widget build(BuildContext context) => _LegalPage(
    title: 'Contrat de licence utilisateur',
    version: 'Version 1.0 — 26 mars 2026',
    sections: const [
      _Section(
        title: '1. Licence accordée',
        body:
            "PEECO vous accorde une licence personnelle, non exclusive et non transférable pour installer et utiliser l'application PEECO sur vos appareils. Cette licence est gratuite pour les clients. Pour les commerçants, certaines fonctionnalités avancées peuvent être soumises à abonnement.",
      ),
      _Section(
        title: '2. Ce que vous ne pouvez pas faire',
        bullets: [
          "Copier, modifier ou décompiler l'application.",
          "Revendre ou sublicencier l'accès à l'application.",
          'Utiliser des robots ou scripts automatisés sans autorisation.',
          'Contourner les mesures de sécurité de la plateforme.',
          'Publier des informations fausses ou frauduleuses.',
        ],
      ),
      _Section(
        title: '3. Propriété',
        body:
            "L'application PEECO, son code, son interface et ses marques sont la propriété exclusive de PEECO SAS. Ce contrat ne vous transfère aucun droit de propriété, uniquement un droit d'usage limité.",
      ),
      _Section(
        title: '4. Conditions spécifiques — Commerçants',
        body:
            "Les commerçants s'engagent à ce que tout contenu publié (photos, descriptions, prix) soit exact et légal. PEECO perçoit une commission sur chaque vente, dont le taux est communiqué à l'inscription. Toute modification du taux sera notifiée 30 jours à l'avance.",
      ),
      _Section(
        title: '5. Conditions spécifiques — Clients',
        body:
            "L'accès Client est réservé à un usage personnel et non commercial. Les avis laissés doivent être sincères et respectueux. PEECO se réserve le droit de supprimer tout avis diffamatoire ou faux.",
      ),
      _Section(
        title: '6. Résiliation',
        body:
            "Ce contrat prend fin si vous supprimez votre compte ou si PEECO résilie votre accès en cas de violation des présentes conditions. À la résiliation, votre droit d'utiliser l'application cesse immédiatement.",
      ),
      _Section(
        title: '7. Limitation de responsabilité',
        body:
            'L\'application est fournie « en l\'état ». PEECO ne peut être tenu responsable des dommages indirects liés à son utilisation. La responsabilité totale de PEECO est limitée aux sommes versées par l\'utilisateur au cours des 12 derniers mois.',
      ),
      _Section(
        title: '8. Contact',
        body: 'Pour toute question : legal@peeco.app',
      ),
    ],
  );
}

class _Section {
  final String title;
  final String? body;
  final List<String>? bullets;
  const _Section({required this.title, this.body, this.bullets});
}

class _LegalPage extends StatelessWidget {
  final String title;
  final String version;
  final List<_Section> sections;

  const _LegalPage({
    required this.title,
    required this.version,
    required this.sections,
  });

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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(sw * 0.04, sh * 0.02, sw * 0.04, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                    ),
                    SizedBox(height: sh * 0.016),
                    Text(
                      title,
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontWeight: FontWeight.bold,
                        fontSize: (sw * 0.062).clamp(20.0, 28.0),
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: sh * 0.005),
                    Text(
                      version,
                      style: TextStyle(
                        fontFamily: 'NotoLoopedThai',
                        fontSize: (sw * 0.030).clamp(10.0, 13.0),
                        color: Colors.black54,
                      ),
                    ),
                    SizedBox(height: sh * 0.016),
                    const Divider(color: Colors.black12, thickness: 1),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    sw * 0.07,
                    sh * 0.015,
                    sw * 0.07,
                    sh * 0.05,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: sections
                        .map((s) => _SectionWidget(section: s))
                        .toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionWidget extends StatelessWidget {
  final _Section section;
  const _SectionWidget({required this.section});

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;

    return Padding(
      padding: EdgeInsets.only(bottom: sh * 0.025),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            section.title,
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontWeight: FontWeight.bold,
              fontSize: (sw * 0.038).clamp(13.0, 16.0),
              color: Colors.black,
            ),
          ),
          SizedBox(height: sh * 0.007),

          if (section.body != null)
            Text(
              section.body!,
              style: TextStyle(
                fontFamily: 'NotoLoopedThai',
                fontSize: (sw * 0.032).clamp(11.0, 14.0),
                color: Colors.black87,
                height: 1.6,
              ),
            ),

          if (section.bullets != null)
            ...section.bullets!.map(
              (b) => Padding(
                padding: EdgeInsets.only(top: sh * 0.006),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: sh * 0.006, right: sw * 0.02),
                      child: const CircleAvatar(
                        radius: 2.5,
                        backgroundColor: Colors.black54,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        b,
                        style: TextStyle(
                          fontFamily: 'NotoLoopedThai',
                          fontSize: (sw * 0.032).clamp(11.0, 14.0),
                          color: Colors.black87,
                          height: 1.6,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}