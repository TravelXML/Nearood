import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_images.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../widgets/ambient_blobs.dart';
import '../widgets/trust_badge.dart';
import 'auth/sign_in_screen.dart';
import 'onboarding/onboarding_screen.dart';

/// Bento-grid welcome/hero screen matching the first Stitch mockup:
/// "Trusted people. Meaningful moments. Nearby."
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          const AmbientBlobs(),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.md,
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.base + 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.06),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Image.asset(AppImages.logo, height: 40),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Trusted people. Meaningful moments. Nearby.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.displayLgMobile,
                  ),
                  const SizedBox(height: AppSpacing.base),
                  Text(
                    'Step onto the digital porch and connect with the neighbors who make your house a home.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyLg,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  // Hero illustration with verification badge overlay.
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.xxl),
                    child: Stack(
                      children: [
                        Image.asset(
                          AppImages.splashHero,
                          height: 260,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                        const Positioned(
                          top: 16,
                          left: 16,
                          child: TrustBadge(
                            label: 'Identity Verified Community',
                            background: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.base + 4),
                  Row(
                    children: [
                      Expanded(
                        child: _BentoTile(
                          image: AppImages.splashBento1,
                          label: 'Community Support',
                          labelColor: AppColors.tertiaryContainer,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.base + 4),
                      Expanded(
                        child: _BentoTile(
                          image: AppImages.splashBento2,
                          label: 'Meaningful Help',
                          labelColor: AppColors.secondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const OnboardingScreen(),
                          ),
                        );
                      },
                      child: const Text('Join the Neighborhood'),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.base),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const SignInScreen()),
                        );
                      },
                      child: const Text('Sign In'),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.base),
                  Row(
                    children: [
                      Expanded(
                        child: Divider(color: AppColors.outlineVariant),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          'Your local circle awaits',
                          style: AppTextStyles.labelSm,
                        ),
                      ),
                      Expanded(
                        child: Divider(color: AppColors.outlineVariant),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BentoTile extends StatelessWidget {
  const _BentoTile({
    required this.image,
    required this.label,
    required this.labelColor,
  });

  final String image;
  final String label;
  final Color labelColor;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.xl),
      child: Stack(
        children: [
          Image.asset(image, height: 140, width: double.infinity, fit: BoxFit.cover),
          Positioned(
            bottom: 10,
            left: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Text(
                label,
                style: AppTextStyles.labelSm.copyWith(color: labelColor),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
