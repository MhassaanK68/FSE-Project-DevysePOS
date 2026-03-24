import 'package:flutter/material.dart';

import '../utils/design_constants.dart';

/// Shell screen for future POS flows; keeps navigation structure consistent.
class FlowPlaceholderScreen extends StatelessWidget {
  const FlowPlaceholderScreen({
    super.key,
    required this.title,
    required this.description,
    this.icon = Icons.construction_outlined,
  });

  final String title;
  final String description;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.xxl),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                child: Icon(icon, size: 56, color: AppColors.primary),
              ),
              const SizedBox(height: AppSpacing.xxl),
              Text(
                title,
                textAlign: TextAlign.center,
                style: AppTextStyles.heading2.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                description,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
