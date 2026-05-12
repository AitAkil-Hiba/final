
import 'package:flutter/material.dart';
import 'package:peeco/client/pages/app_constants.dart';
import 'package:peeco/client/pages/widgets/standard_header.dart';
import 'package:peeco/client/pages/widgets/standard_card.dart';

enum TypeAdresse { maison, universite, famille, travail, autre }

extension TypeAdresseExt on TypeAdresse {
  String get label {
    switch (this) {
      case TypeAdresse.maison:     return 'Maison';
      case TypeAdresse.universite: return 'Université';
      case TypeAdresse.famille:    return 'Chez la famille';
      case TypeAdresse.travail:    return 'Travail';
      case TypeAdresse.autre:      return 'Autre';
    }
  }

  IconData get icon {
    switch (this) {
      case TypeAdresse.maison:     return Icons.home_outlined;
      case TypeAdresse.universite: return Icons.school_outlined;
      case TypeAdresse.famille:    return Icons.people_outline;
      case TypeAdresse.travail:    return Icons.work_outline;
      case TypeAdresse.autre:      return Icons.place_outlined;
    }
  }

  Color get iconColor {
    switch (this) {
      case TypeAdresse.maison:     return Color(0xFFE07B39);
      case TypeAdresse.universite: return Color(0xFF5A9E8B);
      case TypeAdresse.famille:    return Color(0xFF6B7C4E);
      case TypeAdresse.travail:    return Color(0xFF2C2814);
      case TypeAdresse.autre:      return Color(0xFF8A8070);
    }
  }
}

class AdresseFavorite {
  final String id;
  String nom;
  String adresse;
  TypeAdresse type;

  AdresseFavorite({
    required this.id,
    required this.nom,
    required this.adresse,
    required this.type,
  });
}


final List<AdresseFavorite> _adresses = [
  AdresseFavorite(
    id: 'a1',
    nom: 'Maison',
    adresse: 'Rue des Orangers, Oued Smar, Alger',
    type: TypeAdresse.maison,
  ),
  AdresseFavorite(
    id: 'a2',
    nom: 'Université',
    adresse: 'USTHB, Bab Ezzouar, Alger',
    type: TypeAdresse.universite,
  ),
  AdresseFavorite(
    id: 'a3',
    nom: 'Chez la famille',
    adresse: 'Cité Sidi Yacine, Kouba, Alger',
    type: TypeAdresse.famille,
  ),
  AdresseFavorite(
    id: 'a4',
    nom: 'Bureau',
    adresse: 'Centre d\'Affaires, Hydra, Alger',
    type: TypeAdresse.travail,
  ),
  AdresseFavorite(
    id: 'a5',
    nom: 'Centre Commercial',
    adresse: 'Ardis, Bab Ezzouar, Alger',
    type: TypeAdresse.autre,
  ),
];


class AccesRapideScreen extends StatefulWidget {
  const AccesRapideScreen({super.key});

  @override
  State<AccesRapideScreen> createState() => _AccesRapideScreenState();
}

class _AccesRapideScreenState extends State<AccesRapideScreen> {
  bool _modeEdition = false;
  final _rechercheCtrl = TextEditingController();

  @override
  void dispose() {
    _rechercheCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StandardHeader(
              title: 'Accès rapide',
              showLogo: false,
              showSearchBar: true,
              showBackButton: true,
              trailing: GestureDetector(
                onTap: () => setState(() => _modeEdition = !_modeEdition),
                child: Text(
                  _modeEdition ? 'Terminer' : 'Modifier',
                  style: const TextStyle(
                    fontSize: AppTextSizes.bodySmall,
                    fontWeight: AppFontWeights.bold,
                    color: AppColors.textDark,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Accès rapide',
                      style: TextStyle(
                        fontSize: AppTextSizes.titleLarge,
                        fontWeight: AppFontWeights.extraBold,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    ..._adresses.map((a) => _adresseItem(a)),
                    const SizedBox(height: AppSpacing.sm),
                    if (!_modeEdition) _boutonAjouter(),
                    const SizedBox(height: AppSpacing.xxl),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _adresseItem(AdresseFavorite a) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(AppBorderRadius.large),
        border: Border.all(color: AppColors.divider.withOpacity(0.6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: a.type.iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                a.type.icon,
                size: 28,
                color: a.type.iconColor,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    a.nom,
                    style: const TextStyle(
                      fontSize: AppTextSizes.titleSmall,
                      fontWeight: AppFontWeights.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    a.adresse,
                    style: const TextStyle(
                      fontSize: AppTextSizes.bodySmall,
                      color: AppColors.textMuted,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (_modeEdition) ...[
              _editButton(a),
              const SizedBox(width: AppSpacing.sm),
              _deleteButton(a),
            ],
          ],
        ),
      ),
    );
  }

  Widget _editButton(AdresseFavorite a) {
    return GestureDetector(
      onTap: () => _ouvrirModifier(a),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.iconBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.textDark.withOpacity(0.2)),
        ),
        child: const Icon(
          Icons.edit_outlined,
          size: 18,
          color: AppColors.textDark,
        ),
      ),
    );
  }

  Widget _deleteButton(AdresseFavorite a) {
    return GestureDetector(
      onTap: () => _confirmerSuppression(a),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.danger.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.danger.withOpacity(0.3)),
        ),
        child: const Icon(
          Icons.delete_outline,
          size: 18,
          color: AppColors.danger,
        ),
      ),
    );
  }

  Widget _boutonAjouter() {
    return GestureDetector(
      onTap: () => _ouvrirAjouter(),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(AppBorderRadius.large),
          border: Border.all(color: AppColors.divider.withOpacity(0.6)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.add_location_alt_outlined,
                size: 28,
                color: AppColors.accent,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ajouter une adresse',
                    style: TextStyle(
                      fontSize: AppTextSizes.titleSmall,
                      fontWeight: AppFontWeights.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Maison, travail ou lieu personnalisé',
                    style: TextStyle(
                      fontSize: AppTextSizes.bodySmall,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.accent,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add,
                size: 20,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

 
  void _confirmerSuppression(AdresseFavorite a) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: EdgeInsets.fromLTRB(
          20, 24, 20,
          MediaQuery.of(context).padding.bottom + 24,
        ),
        decoration: const BoxDecoration(
          color: Color(0xFFFAEDCD),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.accentBg,
                shape: BoxShape.circle,
              ),
              child: Icon(
                a.type.icon,
                size: 40,
                color: a.type.iconColor,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Supprimer ce lieu ?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Voulez-vous supprimer "${a.nom}" de vos adresses ?',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textMuted,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () {
                setState(() => _adresses.remove(a));
                Navigator.pop(context);
              },
              child: Container(
                width: double.infinity,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.danger,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Center(
                  child: Text(
                    'Oui, Supprimer',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: double.infinity,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.input,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Center(
                  child: Text(
                    'Annuler',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

 
  void _ouvrirModifier(AdresseFavorite a) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _FormulaireAdresse(
        adresse: a,
        onSave: (nom, adresseText, type) {
          setState(() {
            a.nom = nom;
            a.adresse = adresseText;
            a.type = type;
          });
        },
      ),
    );
  }

  
  void _ouvrirAjouter() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _FormulaireAdresse(
        adresse: null,
        onSave: (nom, adresseText, type) {
          setState(() {
            _adresses.add(AdresseFavorite(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              nom: nom,
              adresse: adresseText,
              type: type,
            ));
          });
        },
      ),
    );
  }
}


class _FormulaireAdresse extends StatefulWidget {
  final AdresseFavorite? adresse;
  final void Function(String nom, String adresse, TypeAdresse type) onSave;

  const _FormulaireAdresse({
    required this.adresse,
    required this.onSave,
  });

  @override
  State<_FormulaireAdresse> createState() => _FormulaireAdresseState();
}

class _FormulaireAdresseState extends State<_FormulaireAdresse> {
  late final TextEditingController _nomCtrl;
  late final TextEditingController _adresseCtrl;
  late TypeAdresse _typeSelectionne;

  bool get _estModif => widget.adresse != null;

  @override
  void initState() {
    super.initState();
    _nomCtrl = TextEditingController(text: widget.adresse?.nom ?? '');
    _adresseCtrl = TextEditingController(text: widget.adresse?.adresse ?? '');
    _typeSelectionne = widget.adresse?.type ?? TypeAdresse.maison;
  }

  @override
  void dispose() {
    _nomCtrl.dispose();
    _adresseCtrl.dispose();
    super.dispose();
  }

  void _enregistrer() {
    if (_nomCtrl.text.trim().isEmpty || _adresseCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Remplissez le nom et l\'adresse.'),
          backgroundColor: Color(0xFFD64545),
        ),
      );
      return;
    }
    widget.onSave(
      _nomCtrl.text.trim(),
      _adresseCtrl.text.trim(),
      _typeSelectionne,
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFF5F0E3),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            20, 16, 20,
            MediaQuery.of(context).padding.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD9D0BF),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Center(
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: _estModif ? AppColors.accent : AppColors.accent.withOpacity(0.9),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _estModif
                        ? Icons.edit_outlined
                        : Icons.add_location_alt_outlined,
                    size: 30,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              if (!_estModif) ...[
                const Text(
                  'Ajouter une adresse',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 14),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: TypeAdresse.values.map((t) {
                      final isSelected = _typeSelectionne == t;
                      return GestureDetector(
                        onTap: () => setState(() => _typeSelectionne = t),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? t.iconColor.withOpacity(0.15)
                                : AppColors.input,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: isSelected ? t.iconColor : AppColors.divider,
                              width: 1.5,
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                t.icon,
                                size: 28,
                                color: isSelected ? t.iconColor : AppColors.textMuted,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                t.label,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected ? t.iconColor : AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 20),
              ],

              const Text(
                'Nom du lieu',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 8),
              _champ(_nomCtrl, 'Ex: Maison, Travail...'),

              const SizedBox(height: 16),

              const Text(
                'Adresse complète',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 8),
              _champ(_adresseCtrl, 'Rue, commune, Wilaya…'),

              const SizedBox(height: 12),

              GestureDetector(
                onTap: () {},
                child: Container(
                  width: double.infinity,
                  height: 46,
                  decoration: BoxDecoration(
                    color: AppColors.input,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.map_outlined,
                          size: 20, color: AppColors.textMuted),
                      SizedBox(width: 8),
                      Text(
                        'Pointer sur la carte',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              GestureDetector(
                onTap: _enregistrer,
                child: Container(
                  width: double.infinity,
                  height: 56,
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
                    child: Text(
                      'Enregistrer',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _champ(TextEditingController ctrl, String hint) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.input,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: TextField(
        controller: ctrl,
        style: const TextStyle(
          fontSize: AppTextSizes.bodyLarge,
          color: AppColors.textDark,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: AppColors.textMut.withOpacity(0.7),
            fontSize: AppTextSizes.bodySmall,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}