import 'package:flutter/material.dart';

import '../utils/design_constants.dart';

class PlaceholderImage extends StatelessWidget {
  final String? category;
  final double? width;
  final double? height;
  final double? iconSize;

  const PlaceholderImage({
    super.key,
    this.category,
    this.width,
    this.height,
    this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? double.infinity,
      height: height ?? double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.1),
            AppColors.primary.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Center(
        child: Icon(
          Icons.image_outlined,
          size: iconSize ?? 48,
          color: AppColors.primary.withValues(alpha: 0.5),
        ),
      ),
    );
  }
}
