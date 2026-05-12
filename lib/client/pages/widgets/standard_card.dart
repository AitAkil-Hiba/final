import 'package:flutter/material.dart';
import 'package:peeco/client/pages/app_constants.dart';

class StandardCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? description;
  final String? imagePath;
  final String? price;
  final String? distance;
  final String? category;
  final Widget? trailing;
  final VoidCallback? onTap;
  final double? imageWidth;
  final double? imageHeight;
  final bool showShadow;

  const StandardCard({
    super.key,
    required this.title,
    this.subtitle,
    this.description,
    this.imagePath,
    this.price,
    this.distance,
    this.category,
    this.trailing,
    this.onTap,
    this.imageWidth = 60,
    this.imageHeight = 60,
    this.showShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(AppBorderRadius.large),
          border: Border.all(color: AppColors.divider.withOpacity(0.3)),
          boxShadow: showShadow ? [AppShadows.card] : null,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imagePath != null) ...[
              Container(
                width: imageWidth,
                height: imageHeight,
                decoration: BoxDecoration(
                  color: AppColors.inputBg,
                  borderRadius: BorderRadius.circular(AppBorderRadius.medium),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppBorderRadius.medium),
                  child: Image.asset(
                    imagePath!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: AppColors.inputBg,
                      child: Icon(
                        Icons.store,
                        color: AppColors.accent,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
            ],
            
            
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
            
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: AppTextSizes.titleSmall,
                      fontWeight: AppFontWeights.bold,
                      color: AppColors.textDark,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  if (category != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      category!,
                      style: const TextStyle(
                        fontSize: AppTextSizes.bodySmall,
                        color: AppColors.textMuted,
                        fontWeight: AppFontWeights.medium,
                      ),
                    ),
                  ],
                  
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle!,
                      style: const TextStyle(
                        fontSize: AppTextSizes.bodySmall,
                        color: AppColors.textMuted,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  
                  if (distance != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 12,
                          color: AppColors.textMuted,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          distance!,
                          style: const TextStyle(
                            fontSize: AppTextSizes.caption,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ],
                  
                  if (price != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      price!,
                      style: const TextStyle(
                        fontSize: AppTextSizes.bodyLarge,
                        fontWeight: AppFontWeights.bold,
                        color: AppColors.accent,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            
            if (trailing != null) ...[
              const SizedBox(width: AppSpacing.md),
              trailing!,
            ],
          ],
        ),
      ),
    );
  }
}

class StandardChip extends StatelessWidget {
  final String label;
  final Color? backgroundColor;
  final Color? textColor;
  final VoidCallback? onTap;

  const StandardChip({
    super.key,
    required this.label,
    this.backgroundColor,
    this.textColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: 4,
        ),
        decoration: BoxDecoration(
          color: backgroundColor ?? AppColors.accent.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppBorderRadius.medium),
          border: Border.all(
            color: backgroundColor != null
                ? backgroundColor!.withOpacity(0.3)
                : AppColors.accent.withOpacity(0.3),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: AppTextSizes.caption,
            fontWeight: AppFontWeights.bold,
            color: textColor ?? AppColors.accent,
          ),
        ),
      ),
    );
  }
}

class StandardButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color? textColor;
  final bool isOutlined;
  final IconData? icon;

  const StandardButton({
    super.key,
    required this.label,
    this.onTap,
    this.backgroundColor,
    this.textColor,
    this.isOutlined = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: AppDimensions.buttonHeight,
        decoration: BoxDecoration(
          color: isOutlined
              ? Colors.transparent
              : backgroundColor ?? AppColors.accent,
          border: isOutlined
              ? Border.all(color: backgroundColor ?? AppColors.accent)
              : null,
          borderRadius: BorderRadius.circular(AppBorderRadius.round),
          boxShadow: !isOutlined ? [AppShadows.button] : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: isOutlined
                    ? (backgroundColor ?? AppColors.accent)
                    : (textColor ?? AppColors.white),
              ),
              const SizedBox(width: AppSpacing.sm),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: AppTextSizes.bodyMedium,
                fontWeight: AppFontWeights.bold,
                color: isOutlined
                    ? (backgroundColor ?? AppColors.accent)
                    : (textColor ?? AppColors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
