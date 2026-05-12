
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:peeco/client/pages/peeco_colors.dart';

class PeecoGradientBackground extends StatelessWidget {
  final Widget child;
  final LinearGradient? gradient;
 
  const PeecoGradientBackground({
    super.key,
    required this.child,
    this.gradient,
  });
 
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient ?? PeecoColors.gradientBackground,
      ),
      child: child,
    );
  }
}
 
/// Carte avec bordure vert sauge
class PeecoCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? elevation;
 
  const PeecoCard({
    super.key,
    required this.child,
    this.padding,
    this.elevation,
  });
 
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: PeecoColors.backgroundCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PeecoColors.border, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: PeecoColors.accentGreen.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}
 