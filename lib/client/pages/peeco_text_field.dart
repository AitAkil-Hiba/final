
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:peeco/client/pages/peeco_colors.dart';

class PeecoTextField extends StatelessWidget {
  final String hint;
  final IconData? prefixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
 
  const PeecoTextField({
    super.key,
    required this.hint,
    this.prefixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.controller,
    this.validator,
  });
 
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: PeecoColors.accentGreen, size: 20)
            : null,
      ),
    );
  }
}
 
/// Badge de statut coloré


class PeecoStatusBadge extends StatelessWidget {
  final String label;
  final Color color;
 
  const PeecoStatusBadge({super.key, required this.label, required this.color});
 
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}