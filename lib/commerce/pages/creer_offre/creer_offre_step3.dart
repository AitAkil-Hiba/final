import 'package:flutter/material.dart';
import 'creer_offre_step1.dart';
import 'creer_offre_step4.dart';

class CreerOffreStep3 extends StatefulWidget {
  const CreerOffreStep3({super.key});

  @override
  State<CreerOffreStep3> createState() => _CreerOffreStep3State();
}

class _CreerOffreStep3State extends State<CreerOffreStep3> {
  static const Color topBarColor = Color(0xFFCCD5AE);
  static const Color backgroundColor = Color(0xFFFEFAE0);
  static const Color cardColor = Color(0xFFF5EED8);
  static const Color orangeColor = Color(0xFFE8824A);
  static const Color brownColor = Color(0xFF5D4E37);
  static const Color selectedColor = Color(0xFFCCD5AE);

  final NouvelleOffreData _data = NouvelleOffreData();

  final List<String> _creneaux = [
    '07h–09h',
    '09h–11h',
    '11h–13h',
    '13h–15h',
    '17h–19h',
    '19h–21h',
    'Personnalisé',
  ];

  bool get _isValid =>
      _data.dateFin != null &&
      _data.creneau.isNotEmpty &&
      (_data.creneau != 'Personnalisé' ||
          (_data.retraitDebut != null && _data.retraitFin != null));

  Future<void> _pickDateFin() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _data.dateFin ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 1),
      locale: const Locale('fr', 'FR'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFCCD5AE),
              onPrimary: Color(0xFF3E2723),
              surface: Color(0xFFFEFAE0),
              onSurface: Color(0xFF3E2723),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _data.dateFin = DateTime(picked.year, picked.month, picked.day);
      });
    }
  }

  String _formatDateTime(DateTime date) {
    final months = [
      'janvier',
      'février',
      'mars',
      'avril',
      'mai',
      'juin',
      'juillet',
      'août',
      'septembre',
      'octobre',
      'novembre',
      'décembre',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _formatTimeOfDay(TimeOfDay t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  Future<void> _pickCustomRetraitTimes() async {
    final now = TimeOfDay.now();
    final start = await showTimePicker(
      context: context,
      initialTime: _data.retraitDebut ?? now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFCCD5AE),
              onPrimary: Color(0xFF3E2723),
              surface: Color(0xFFFEFAE0),
              onSurface: Color(0xFF3E2723),
            ),
          ),
          child: child!,
        );
      },
    );
    if (start == null || !mounted) return;

    final end = await showTimePicker(
      context: context,
      initialTime: _data.retraitFin ?? start,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFCCD5AE),
              onPrimary: Color(0xFF3E2723),
              surface: Color(0xFFFEFAE0),
              onSurface: Color(0xFF3E2723),
            ),
          ),
          child: child!,
        );
      },
    );
    if (end == null || !mounted) return;

    setState(() {
      _data.retraitDebut = start;
      _data.retraitFin = end;
      _data.creneauPersonnalise =
          '${_formatTimeOfDay(start)}–${_formatTimeOfDay(end)}';
    });
  }

  void _handleNext() {
    if (!_isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez remplir la date de fin et le créneau'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CreerOffreStep4()),
    );
  }

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
                    onTap: () =>
                        Navigator.popUntil(context, (route) => route.isFirst),
                    child: const Icon(
                      Icons.arrow_back,
                      color: Color(0xFF3E2723),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Nouvelle offre',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF3E2723),
                    ),
                  ),
                ],
              ),
            ),
            _buildProgressTabs(2),
            const SizedBox(height: 24),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Date
                    const Text(
                      "Date de fin de l'offre",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF3E2723),
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _pickDateFin,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                _data.dateFin != null
                                    ? _formatDateTime(_data.dateFin!)
                                    : '',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: _data.dateFin != null
                                      ? const Color(0xFF424242)
                                      : const Color(0xFFBDB5A0),
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.keyboard_arrow_down,
                              color: Color(0xFF5D4E37),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Créneau de retrait
                    const Text(
                      'Créneau de retrait',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF3E2723),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: _creneaux.map((c) {
                        final isSelected = _data.creneau == c;
                        return GestureDetector(
                          onTap: () async {
                            if (c == 'Personnalisé') {
                              setState(() {
                                _data.creneau = c;
                                _data.creneauPersonnalise = null;
                                _data.retraitDebut = null;
                                _data.retraitFin = null;
                              });
                              await _pickCustomRetraitTimes();
                              return;
                            }
                            setState(() {
                              _data.creneau = c;
                              _data.creneauPersonnalise = null;
                              _data.retraitDebut = null;
                              _data.retraitFin = null;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected ? selectedColor : cardColor,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFFB8C49E)
                                    : Colors.transparent,
                              ),
                            ),
                            child: Text(
                              c,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: isSelected
                                    ? brownColor
                                    : const Color(0xFF424242),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    if (_data.creneau == 'Personnalisé') ...[
                      const SizedBox(height: 6),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                (_data.retraitDebut != null &&
                                        _data.retraitFin != null)
                                    ? '${_formatTimeOfDay(_data.retraitDebut!)} – ${_formatTimeOfDay(_data.retraitFin!)}'
                                    : 'Choisir les heures',
                                style: TextStyle(
                                  fontSize: 14,
                                  color:
                                      (_data.retraitDebut != null &&
                                          _data.retraitFin != null)
                                      ? const Color(0xFF424242)
                                      : const Color(0xFFBDB5A0),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: _pickCustomRetraitTimes,
                              child: const Icon(
                                Icons.schedule,
                                size: 18,
                                color: Color(0xFF5D4E37),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
            _buildButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressTabs(int currentStep) {
    final steps = ['Informations', 'Prix & stock', 'Créneau', 'Photo & aperçu'];
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE0D8C8), width: 1)),
      ),
      child: Row(
        children: List.generate(steps.length, (i) {
          final isActive = i == currentStep;
          return Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isActive ? topBarColor : Colors.transparent,
                    width: 2,
                  ),
                ),
              ),
              child: Text(
                steps[i],
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  color: isActive
                      ? const Color(0xFF3E2723)
                      : const Color(0xFF9E9E9E),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildButtons() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      child: Column(
        children: [
          GestureDetector(
            onTap: _handleNext,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: _isValid ? topBarColor : topBarColor.withOpacity(0.5),
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Center(
                child: Text(
                  'Suivant',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF3E2723),
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
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: orangeColor,
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Center(
                child: Text(
                  'Retour',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
} 

//==========================================================================================
//======================================================================================
/*
import 'package:flutter/material.dart';
import 'creer_offre_step1.dart';
import 'creer_offre_step4.dart';

class CreerOffreStep3 extends StatefulWidget {
  const CreerOffreStep3({super.key});

  @override
  State<CreerOffreStep3> createState() => _CreerOffreStep3State();
}

class _CreerOffreStep3State extends State<CreerOffreStep3> {
  static const Color topBarColor = Color(0xFFCCD5AE);
  static const Color backgroundColor = Color(0xFFFEFAE0);
  static const Color cardColor = Color(0xFFF5EED8);
  static const Color orangeColor = Color(0xFFE8824A);
  static const Color brownColor = Color(0xFF5D4E37);
  static const Color selectedColor = Color(0xFFCCD5AE);

  final NouvelleOffreData _data = NouvelleOffreData();

  final List<String> _creneaux = [
    '07h–09h',
    '09h–11h',
    '11h–13h',
    '13h–15h',
    '17h–19h',
    '19h–21h',
    'Personnalisé',
  ];

  bool get _isValid =>
      _data.dateFin != null &&
      _data.creneau.isNotEmpty &&
      (_data.creneau != 'Personnalisé' ||
          (_data.retraitDebut != null && _data.retraitFin != null));

  Future<void> _pickDateFin() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _data.dateFin ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 1),
      locale: const Locale('fr', 'FR'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFCCD5AE),
              onPrimary: Color(0xFF3E2723),
              surface: Color(0xFFFEFAE0),
              onSurface: Color(0xFF3E2723),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _data.dateFin = DateTime(picked.year, picked.month, picked.day);
      });
    }
  }

  String _formatDateTime(DateTime date) {
    final months = [
      'janvier',
      'février',
      'mars',
      'avril',
      'mai',
      'juin',
      'juillet',
      'août',
      'septembre',
      'octobre',
      'novembre',
      'décembre',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _formatTimeOfDay(TimeOfDay t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  Future<void> _pickCustomRetraitTimes() async {
    final now = TimeOfDay.now();
    final start = await showTimePicker(
      context: context,
      initialTime: _data.retraitDebut ?? now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFCCD5AE),
              onPrimary: Color(0xFF3E2723),
              surface: Color(0xFFFEFAE0),
              onSurface: Color(0xFF3E2723),
            ),
          ),
          child: child!,
        );
      },
    );
    if (start == null || !mounted) return;

    final end = await showTimePicker(
      context: context,
      initialTime: _data.retraitFin ?? start,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFCCD5AE),
              onPrimary: Color(0xFF3E2723),
              surface: Color(0xFFFEFAE0),
              onSurface: Color(0xFF3E2723),
            ),
          ),
          child: child!,
        );
      },
    );
    if (end == null || !mounted) return;

    setState(() {
      _data.retraitDebut = start;
      _data.retraitFin = end;
      _data.creneauPersonnalise =
          '${_formatTimeOfDay(start)}–${_formatTimeOfDay(end)}';
    });
  }

  void _handleNext() {
    if (!_isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez remplir la date de fin et le créneau'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CreerOffreStep4()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = _data.isEditing;

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
                  Text(
                    isEditing ? 'Modifier l\'offre' : 'Nouvelle offre',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF3E2723),
                    ),
                  ),
                ],
              ),
            ),
            _buildProgressTabs(2),
            const SizedBox(height: 24),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Date de fin de l'offre",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF3E2723),
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _pickDateFin,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                _data.dateFin != null
                                    ? _formatDateTime(_data.dateFin!)
                                    : 'Sélectionner une date',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: _data.dateFin != null
                                      ? const Color(0xFF424242)
                                      : const Color(0xFFBDB5A0),
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.keyboard_arrow_down,
                              color: Color(0xFF5D4E37),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Créneau de retrait',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF3E2723),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: _creneaux.map((c) {
                        final isSelected = _data.creneau == c;
                        return GestureDetector(
                          onTap: () async {
                            if (c == 'Personnalisé') {
                              setState(() {
                                _data.creneau = c;
                                _data.creneauPersonnalise = null;
                                _data.retraitDebut = null;
                                _data.retraitFin = null;
                              });
                              await _pickCustomRetraitTimes();
                              return;
                            }
                            setState(() {
                              _data.creneau = c;
                              _data.creneauPersonnalise = null;
                              _data.retraitDebut = null;
                              _data.retraitFin = null;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected ? selectedColor : cardColor,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFFB8C49E)
                                    : Colors.transparent,
                              ),
                            ),
                            child: Text(
                              c,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: isSelected
                                    ? brownColor
                                    : const Color(0xFF424242),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    if (_data.creneau == 'Personnalisé') ...[
                      const SizedBox(height: 6),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                (_data.retraitDebut != null &&
                                        _data.retraitFin != null)
                                    ? '${_formatTimeOfDay(_data.retraitDebut!)} – ${_formatTimeOfDay(_data.retraitFin!)}'
                                    : 'Choisir les heures',
                                style: TextStyle(
                                  fontSize: 14,
                                  color:
                                      (_data.retraitDebut != null &&
                                          _data.retraitFin != null)
                                      ? const Color(0xFF424242)
                                      : const Color(0xFFBDB5A0),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: _pickCustomRetraitTimes,
                              child: const Icon(
                                Icons.schedule,
                                size: 18,
                                color: Color(0xFF5D4E37),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
            _buildButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressTabs(int currentStep) {
    final steps = ['Informations', 'Prix & stock', 'Créneau', 'Photo & aperçu'];
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE0D8C8), width: 1)),
      ),
      child: Row(
        children: List.generate(steps.length, (i) {
          final isActive = i == currentStep;
          return Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isActive ? topBarColor : Colors.transparent,
                    width: 2,
                  ),
                ),
              ),
              child: Text(
                steps[i],
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  color: isActive
                      ? const Color(0xFF3E2723)
                      : const Color(0xFF9E9E9E),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildButtons() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      child: Column(
        children: [
          GestureDetector(
            onTap: _handleNext,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: _isValid ? topBarColor : topBarColor.withOpacity(0.5),
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Center(
                child: Text(
                  'Suivant',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF3E2723),
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
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: orangeColor,
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Center(
                child: Text(
                  'Retour',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
*/