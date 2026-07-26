import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// Shown instead of crashing when the app is launched without Supabase
/// credentials wired up (see scripts/run.sh + .env.local.example).
class SetupRequiredScreen extends StatelessWidget {
  const SetupRequiredScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.cloud_off_rounded, size: 48, color: AppColors.warning),
                const SizedBox(height: AppSpacing.base),
                Text('Supabase isn\'t connected yet', style: AppTextStyles.headlineMd),
                const SizedBox(height: AppSpacing.base),
                Text(
                  'Copy app/.env.local.example to app/.env.local, fill in your '
                  "project's URL and anon key, then run:",
                  style: AppTextStyles.bodyMd,
                ),
                const SizedBox(height: AppSpacing.base),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainer,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: const Text(
                    './scripts/run.sh',
                    style: TextStyle(fontFamily: 'monospace', fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
