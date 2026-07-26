import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// Consistent "coming soon" scaffold for bottom-nav destinations that
/// don't have a Stitch mockup yet, so the shell reads as one system
/// while those screens are designed and built out.
class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({
    super.key,
    required this.title,
    required this.icon,
    required this.description,
    this.upcoming = const [],
  });

  final String title;
  final IconData icon;
  final String description;
  final List<String> upcoming;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 88,
                  height: 88,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHigh,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 40, color: AppColors.primary),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  title,
                  style: AppTextStyles.headlineMd,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.base),
                Text(
                  description,
                  style: AppTextStyles.bodyMd,
                  textAlign: TextAlign.center,
                ),
                if (upcoming.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.md),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: AppSpacing.base,
                    runSpacing: AppSpacing.base,
                    children: upcoming
                        .map(
                          (label) => Chip(
                            label: Text(label),
                            labelStyle: AppTextStyles.labelSm.copyWith(
                              color: AppColors.primary,
                            ),
                            backgroundColor: AppColors.primaryFixed,
                            side: BorderSide.none,
                          ),
                        )
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
