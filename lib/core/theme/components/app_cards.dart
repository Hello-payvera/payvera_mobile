import 'package:flutter/material.dart';

import '../../design/app_elevation.dart';
import '../../design/app_radius.dart';
import '../../design/app_spacing.dart';
import '../colors/app_colors.dart';

class PayveraCard extends StatelessWidget {
  const PayveraCard({
    super.key,
    required this.child,
    this.padding = AppSpacing.card,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      elevation: AppElevation.low,
      borderRadius: AppRadius.extraLarge,
      child: InkWell(
        borderRadius: AppRadius.extraLarge,
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: AppRadius.extraLarge,
            border: Border.all(
              color: AppColors.border,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}