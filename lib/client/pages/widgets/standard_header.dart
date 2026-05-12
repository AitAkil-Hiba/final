

import 'package:flutter/material.dart';
import 'package:peeco/client/pages/app_constants.dart';

class StandardHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final bool showSearchBar;
  final bool showLogo;
  final bool showLocation;
  final VoidCallback? onBackTap;
  final String? searchHint;
  final Widget? trailing;

  const StandardHeader({
    super.key,
    required this.title,
    this.showBackButton = true,
    this.showSearchBar = true,
    this.showLogo = true,
    this.showLocation = false,
    this.onBackTap,
    this.searchHint,
    this.trailing,
  });

  @override
  Size get preferredSize => Size.fromHeight(AppDimensions.headerHeight);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.headerBg,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        border: Border.all(color: AppColors.offerCardBg, width: 2),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            children: [
              Row(
                children: [
                  if (showBackButton && !showLogo)
                    GestureDetector(
                      onTap: onBackTap ?? () => Navigator.pop(context),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.accent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new,
                          size: 18,
                          color: AppColors.textDark,
                        ),
                      ),
                    )
                  else if (showBackButton && showLogo)
                    const SizedBox(width: 40),
                  
                  if (showLogo)
                    Image.asset(
                      'assets/images/laaisraf_logo.png',
                      height: AppDimensions.logoSize,
                      errorBuilder: (_, __, ___) => Container(
                        width: AppDimensions.logoSize,
                        height: AppDimensions.logoSize,
                        decoration: const BoxDecoration(
                          color: AppColors.accent,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.store,
                          size: 20,
                          color: AppColors.white,
                        ),
                      ),
                    )
                  else ...[
                    if (showBackButton) const SizedBox(width: 12),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: AppTextSizes.titleXLarge,
                        fontWeight: AppFontWeights.extraBold,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                  
                  const Spacer(),
                  
                  if (showLocation) ...[
                    const Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: AppColors.textDark,
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'Alger, Alger',
                      style: TextStyle(
                        fontSize: AppTextSizes.bodySmall,
                        color: AppColors.textDark,
                        fontWeight: AppFontWeights.medium,
                      ),
                    ),
                  ],
                  
                  if (trailing != null) ...[
                    const SizedBox(width: 12),
                    trailing!
                  ] else ...[
                    if (!showLocation) const SizedBox(width: 36),
                  ],
                ],
              ),
              
              if (showSearchBar) ...[
                const SizedBox(height: 12),
                Container(
                  height: 45,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCCD1AE),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: AppColors.textMuted, width: 0.5),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 30),
                      const Icon(
                        Icons.search,
                        color: AppColors.chipDark,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          searchHint ?? 'Rechercher...',
                          style: const TextStyle(
                            color: AppColors.chipDark,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
