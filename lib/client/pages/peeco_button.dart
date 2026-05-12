
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:peeco/client/pages/peeco_colors.dart';

class PeecoButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isOutlined;
  final bool isLoading;
  final IconData? icon;
 
  const PeecoButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isOutlined = false,
    this.isLoading = false,
    this.icon,
  });
 
  @override
  Widget build(BuildContext context) {
    final content = isLoading
        ? const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: PeecoColors.textPrimary,
            ),
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18),
                const SizedBox(width: 8),
              ],
              Text(label),
            ],
          );
 
    if (isOutlined) {
      return OutlinedButton(onPressed: onPressed, child: content);
    }
    return ElevatedButton(onPressed: onPressed, child: content);
  }
}
 
/// Champ texte stylé PEECO
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
 