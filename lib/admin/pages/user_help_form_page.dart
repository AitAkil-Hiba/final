import 'package:flutter/material.dart';
import 'core/core.dart';

class UserHelpFormPage extends StatefulWidget {
  const UserHelpFormPage({super.key});

  @override
  State<UserHelpFormPage> createState() => _UserHelpFormPageState();
}

class _UserHelpFormPageState extends State<UserHelpFormPage> {
  final List<String> _helpTypes = [
    'Bug technique',
    'Problème de paiement',
    'Problème de notifications',
    'Application lente ou instable',
    'Autre',
  ];

  String? _selectedType;
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  void _submitHelpRequest() {
    if (_selectedType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Veuillez sélectionner un type de problème'),
          backgroundColor: const Color(0xFFE07B39),
        ),
      );
      return;
    }


    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Votre demande d\'aide a été envoyée avec succès'),
        backgroundColor: const Color(0xFFA8C88A),
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final r = _Responsive(context);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: appGradient,
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(r.hp(20), r.vp(20), r.hp(20), r.vp(4)),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: r.scale(20),
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Demande d\'aide',
                      style: AppTextStyles.pageTitle.copyWith(fontSize: r.fontSize(24)),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: r.hp(20)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: r.vp(30)),
                      
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(r.scale(20)),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(r.scale(24)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Rencontrez-vous un problème avec l\'application ? Dites-nous ce qui ne va pas.',
                              style: TextStyle(
                                fontFamily: AppFonts.plusJakarta,
                                fontSize: r.fontSize(16),
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF1A1A1A),
                              ),
                            ),
                            SizedBox(height: r.vp(24)),
                            
                            Text(
                              'Type de problème',
                              style: TextStyle(
                                fontFamily: AppFonts.plusJakarta,
                                fontSize: r.fontSize(14),
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF1A1A1A),
                              ),
                            ),
                            SizedBox(height: r.vp(12)),
                            
                            ..._helpTypes.map((type) => _RadioOption(
                              value: type,
                              groupValue: _selectedType,
                              onChanged: (value) {
                                setState(() {
                                  _selectedType = value;
                                });
                              },
                            )),
                            
                            SizedBox(height: r.vp(24)),
                            
                            Text(
                              'Description (optionnel)',
                              style: TextStyle(
                                fontFamily: AppFonts.plusJakarta,
                                fontSize: r.fontSize(14),
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF1A1A1A),
                              ),
                            ),
                            SizedBox(height: r.vp(12)),
                            
                            TextField(
                              controller: _descriptionController,
                              maxLines: 5,
                              decoration: InputDecoration(
                                hintText: 'Expliquez le problème en quelques détails...',
                                hintStyle: TextStyle(
                                  fontFamily: AppFonts.plusJakarta,
                                  fontSize: r.fontSize(14),
                                  color: const Color(0xFFAAAAAA),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(r.scale(16)),
                                  borderSide: BorderSide(
                                    color: const Color(0xFFE8DEC8),
                                    width: 1,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(r.scale(16)),
                                  borderSide: BorderSide(
                                    color: const Color(0xFFA8C88A),
                                    width: 2,
                                  ),
                                ),
                                filled: true,
                                fillColor: const Color(0xFFF9F9F9),
                              ),
                              style: TextStyle(
                                fontFamily: AppFonts.plusJakarta,
                                fontSize: r.fontSize(14),
                                color: const Color(0xFF1A1A1A),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      SizedBox(height: r.vp(40)),
                      
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _submitHelpRequest,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFA8C88A),
                            padding: EdgeInsets.symmetric(vertical: r.vp(16)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(r.scale(30)),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            'Envoyer la demande',
                            style: TextStyle(
                              fontFamily: AppFonts.plusJakarta,
                              fontSize: r.fontSize(16),
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      
                      SizedBox(height: r.vp(30)),
                    ],
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

class _RadioOption extends StatelessWidget {
  const _RadioOption({
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  final String value;
  final String? groupValue;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final r = _Responsive(context);
    final isSelected = value == groupValue;

    return GestureDetector(
      onTap: () => onChanged(value),
      child: Container(
        margin: EdgeInsets.only(bottom: r.vp(8)),
        padding: EdgeInsets.all(r.scale(16)),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEDF5E5) : const Color(0xFFF9F9F9),
          borderRadius: BorderRadius.circular(r.scale(16)),
          border: Border.all(
            color: isSelected ? const Color(0xFFA8C88A) : const Color(0xFFE8DEC8),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: r.scale(20),
              height: r.scale(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? const Color(0xFFA8C88A) : const Color(0xFFAAAAAA),
                  width: 2,
                ),
                color: isSelected ? const Color(0xFFA8C88A) : Colors.transparent,
              ),
              child: isSelected
                  ? Center(
                      child: Icon(
                        Icons.check,
                        size: r.scale(12),
                        color: Colors.white,
                      ),
                    )
                  : null,
            ),
            SizedBox(width: r.hp(12)),
            Expanded(
              child: Text(
                value,
                style: TextStyle(
                  fontFamily: AppFonts.plusJakarta,
                  fontSize: r.fontSize(14),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: const Color(0xFF1A1A1A),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Responsive {
  _Responsive(BuildContext context)
      : _size = MediaQuery.of(context).size,
        _textScale = MediaQuery.of(context).textScaler;

  final Size _size;
  final TextScaler _textScale;

  static const double _baseWidth = 390.0;
  static const double _baseHeight = 844.0;

  double get _widthRatio => (_size.width / _baseWidth).clamp(0.5, 1.4);
  double get _heightRatio => (_size.height / _baseHeight).clamp(0.5, 1.4);

  double scale(double value) =>
      value * ((_widthRatio + _heightRatio) / 2);

  double hp(double value) => value * _widthRatio;

  double vp(double value) => value * _heightRatio;

  double fontSize(double value) =>
      _textScale.scale(value * _widthRatio);
}
