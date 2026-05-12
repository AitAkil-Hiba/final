import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Widget buildFieldError(String message, {EdgeInsets? padding}) {
  return Padding(
    padding: padding ?? const EdgeInsets.only(left: 14, top: 5),
    child: Row(
      children: [
        const Icon(Icons.error_outline, color: Colors.red, size: 14),
        const SizedBox(width: 5),
        Flexible(
          child: Text(
            message,
            style: const TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 12,
              color: Colors.red,
            ),
          ),
        ),
      ],
    ),
  );
}

class CustomInputField extends StatelessWidget {
  final String label;
  final IconData icon;
  final TextEditingController controller;
  final FocusNode? focusNode;
  final TextInputType keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;
  final int? maxLength;
  final int? maxLines;
  final String? hintText;
  final List<TextInputFormatter>? inputFormatters;
  final void Function(String)? onChanged;

  const CustomInputField({
    super.key,
    required this.label,
    required this.icon,
    required this.controller,
    this.focusNode,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.suffixIcon,
    this.maxLength,
    this.maxLines = 1,
    this.hintText,
    this.inputFormatters,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;

    final isMultiline = maxLines != null && maxLines! > 1;
    final fieldHeight = isMultiline ? null : (sh * 0.045).clamp(36.0, 44.0);
    final fontSize    = (sw * 0.036).clamp(13.0, 16.0);
    final labelSize   =  (sw * 0.035).clamp(12.0, 15.0);
    final iconSize    = (sw * 0.058).clamp(20.0, 26.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 14),
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: labelSize,            
                color: Colors.black,
              ),
            ),
          ),
        if (label.isNotEmpty) SizedBox(height: sh * 0.008),  

        Container(
          height: fieldHeight,                    
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 210, 213, 178),
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: const Color.fromARGB(130, 255, 255, 255)
                    .withValues(alpha: 0.6),
                blurRadius: 0,
                spreadRadius: 1,
                offset: const Offset(1, 1),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            keyboardType: keyboardType,
            obscureText: obscureText,
            maxLength: maxLength,
            maxLines: obscureText ? 1 : maxLines,
            textAlignVertical: TextAlignVertical.center,
            inputFormatters: inputFormatters,
            onChanged: onChanged,
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: fontSize,                 
              color: Colors.black,
            ),
            decoration: InputDecoration(
              isDense: true,
              border: InputBorder.none,
              counterText: '',
              contentPadding: const EdgeInsets.symmetric(
                vertical: 11,
                horizontal: 16,
              ),
              hintText: hintText,
              hintStyle: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: fontSize,                
                color: const Color.fromARGB(120, 0, 0, 0),
              ),
              prefixIcon: Icon(
                icon,
                color: const Color.fromARGB(208, 0, 0, 0),
                size: iconSize,                    
              ),
              suffixIcon: suffixIcon,
            ),
          ),
        ),
      ],
    );
  }
}