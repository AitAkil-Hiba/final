import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:peeco/core/core.dart';
import 'package:peeco/client/client.dart';


BoxDecoration inputBoxDecoration() => BoxDecoration(
  color: const Color.fromARGB(255, 210, 213, 178),
  borderRadius: BorderRadius.circular(25),
  boxShadow: [
    BoxShadow(
      color: Colors.white.withValues(alpha: 0.55),
      blurRadius: 0,
      spreadRadius: 1,
      offset: const Offset(1, 1),
    ),
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.08),
      blurRadius: 4,
      spreadRadius: 0,
      offset: const Offset(0, 2),
    ),
  ],
);

Widget sectionTitle(String text, {required double sw, required double sh}) => Padding(
  padding: EdgeInsets.only(left: 2, bottom: sh * 0.016),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        text,
        style: TextStyle(
          fontFamily: 'PlusJakartaSans',
          fontWeight: FontWeight.w600,
          fontSize: (sw * 0.035).clamp(12.0, 15.0),
          color: Colors.black87,
        ),
      ),
      SizedBox(height: sh * 0.006),
      Container(height: 1, width: double.infinity, color: Colors.black26),
    ],
  ),
);

Widget fieldLabel(String text, {required double sw, required double sh}) => Padding(
  padding: EdgeInsets.only(left: 14, bottom: sh * 0.01),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        text,
        style: TextStyle(
          fontFamily: 'PlusJakartaSans',
          fontSize: (sw * 0.038).clamp(13.0, 17.0),
          color: Colors.black,
        ),
      ),
      SizedBox(height: sh * 0.005),
      Container(height: 1, width: 80, color: Colors.black26),
    ],
  ),
);

Widget actionButton({
  required String label,
  required VoidCallback? onPressed,
  required double sw,
  required double sh,
  bool isLoading = false,
}) => Align(
  alignment: Alignment.centerRight,
  child: SizedBox(
    height: (sh * 0.055).clamp(44.0, 54.0),
    child: ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 248, 176, 104),
        disabledBackgroundColor: const Color.fromARGB(160, 248, 176, 104),
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        elevation: 0,
        padding: EdgeInsets.symmetric(horizontal: sw * 0.08),
      ),
      child: isLoading
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                color: Colors.black,
                strokeWidth: 2,
              ),
            )
          : Text(
              label,
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontWeight: FontWeight.bold,
                fontSize: (sw * 0.045).clamp(14.0, 19.0),
              ),
            ),
    ),
  ),
);

Widget alreadyHaveAccount(BuildContext context, {required double sw}) => Center(
  child: RichText(
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
          style: TextStyle(
            fontFamily: 'NotoLoopedThai',
            fontWeight: FontWeight.bold,
            fontSize: (sw * 0.035).clamp(12.0, 15.0),
            color: Colors.black,
          ),
          recognizer: TapGestureRecognizer()
            ..onTap = () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => LoginPage()),
            ),
        ),
      ],
    ),
  ),
);

Widget commercePageScaffold({
  required BuildContext context,
  required int step,
  required List<Widget> children,
  bool isLoading = false,
}) {
  final sw = MediaQuery.of(context).size.width;
  final sh = MediaQuery.of(context).size.height;

  return Scaffold(
    body: Container(
      width: double.infinity,
      height: double.infinity,
      decoration: appGradient,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: sw * 0.062, vertical: sh * 0.04),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.pop(context),
                padding: EdgeInsets.zero,
              ),
              SizedBox(height: sh * 0.015),
              SizedBox(
                width: double.infinity,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'S\'inscrire',
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
              SizedBox(height: sh * 0.008),
              SizedBox(
                width: double.infinity,
                child: Text(
                  'Créez votre compte Peeco',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'NotoLoopedThai',
                    fontSize: (sw * 0.038).clamp(13.0, 17.0),
                    color: Colors.black,
                  ),
                ),
              ),
              SizedBox(height: sh * 0.04),
              StepIndicator(currentStep: step),
              SizedBox(height: sh * 0.05),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: sw * 0.02),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: children,
                ),
              ),
              SizedBox(height: sh * 0.02),
              alreadyHaveAccount(context, sw: sw),
              SizedBox(height: sh * 0.05),
            ],
          ),
        ),
      ),
    ),
  );
}

class StepIndicator extends StatelessWidget {
  final int currentStep;
  const StepIndicator({super.key, required this.currentStep});
  static const _labels = ['Compte', 'Commerce', 'Localisation', 'Documents'];

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final circleSize = (sw * 0.11).clamp(38.0, 50.0);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (i) {
        final step = i + 1;
        final isActive = step == currentStep;
        final isDone = step < currentStep;
        return Row(
          children: [
            Column(
              children: [
                Container(
                  width: circleSize,
                  height: circleSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isActive || isDone
                        ? const Color(0xFFB5C99A)
                        : const Color.fromARGB(215, 210, 213, 178),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 6,
                        spreadRadius: 1,
                        offset: const Offset(2, 3),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      '$step',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontWeight: FontWeight.bold,
                        fontSize: (sw * 0.033).clamp(12.0, 15.0),
                        color: isActive || isDone
                            ? const Color.fromARGB(255, 0, 0, 0)
                            : Colors.black38,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: sw * 0.018),
                Text(
                  _labels[i],
                  style: TextStyle(
                    fontFamily: 'NotoLoopedThai',
                    fontSize: (sw * 0.028).clamp(10.0, 13.0),
                    color: isActive || isDone ? Colors.black87 : Colors.black38,
                  ),
                ),
              ],
            ),
            if (step < 4)
              Container(
                width: sw * 0.07,
                height: 1,
                margin: EdgeInsets.only(bottom: sw * 0.055),
                color: isDone
                    ? Colors.black38
                    : const Color.fromARGB(80, 0, 0, 0),
              ),
          ],
        );
      }),
    );
  }
}

class AppDropdown<T> extends StatelessWidget {
  final T? value;
  final String hint;
  final List<T> items;
  final String Function(T) itemLabel;
  final ValueChanged<T?> onChanged;

  const AppDropdown({
    super.key,
    required this.value,
    required this.hint,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;

    return Container(
      height: (sh * 0.052).clamp(40.0, 50.0),
      decoration: inputBoxDecoration(),
      padding: EdgeInsets.symmetric(horizontal: sw * 0.04),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          hint: Text(
            hint,
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: (sw * 0.033).clamp(11.0, 14.0),
              color: const Color.fromARGB(120, 0, 0, 0),
            ),
          ),
          isExpanded: true,
          menuMaxHeight: 300,
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black54),
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: (sw * 0.035).clamp(12.0, 15.0),
            color: Colors.black,
          ),
          dropdownColor: const Color.fromARGB(255, 225, 228, 192),
          borderRadius: BorderRadius.circular(16),
          items: items
              .map(
                (item) => DropdownMenuItem<T>(
                  value: item,
                  child: Text(itemLabel(item)),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class UploadBox extends StatelessWidget {
  final File? file;
  final VoidCallback onTap;

  const UploadBox({super.key, required this.file, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: sh * 0.11,
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 210, 213, 178),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.55),
              blurRadius: 0,
              spreadRadius: 1,
              offset: const Offset(1, 1),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 4,
              spreadRadius: 0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: file != null
              ? Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.file(file!, fit: BoxFit.cover),
                    Positioned(
                      bottom: 6,
                      right: 8,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: sw * 0.02,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.45),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.edit_outlined,
                              color: Colors.white,
                              size: 12,
                            ),
                            SizedBox(width: sw * 0.01),
                            Text(
                              'Changer',
                              style: TextStyle(
                                fontFamily: 'NotoLoopedThai',
                                fontSize: (sw * 0.025).clamp(9.0, 11.0),
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.upload_file_outlined,
                      color: Colors.black45,
                      size: sw * 0.07,
                    ),
                    SizedBox(height: sh * 0.008),
                    Text(
                      'Glisser & déposer ou parcourir\nJPG, PNG ou PDF — max 5 Mo',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'NotoLoopedThai',
                        fontSize: (sw * 0.026).clamp(10.0, 12.0),
                        color: Colors.black45,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}