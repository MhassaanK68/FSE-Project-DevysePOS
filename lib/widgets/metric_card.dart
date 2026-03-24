import 'package:flutter/material.dart';

import '../utils/design_constants.dart';

class MetricCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color? iconColor;

  const MetricCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(
        minHeight: AppTouchTarget.cardMinHeight,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: AppShadows.soft,
      ),
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: (iconColor ?? AppColors.primary).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(
              icon,
              color: iconColor ?? AppColors.primary,
              size: 28,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            value,
            style: AppTextStyles.heading2.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            title,
            style: AppTextStyles.labelMedium.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
