import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_images.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../widgets/ambient_blobs.dart';
import 'welcome_screen.dart';

/// App-launch splash: brand logo + tagline, auto-advances to the Welcome
/// screen. Mirrors spec item 1 ("Splash Screen").
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1600), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const WelcomeScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          const AmbientBlobs(),
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(AppRadius.xl),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.08),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Image.asset(AppImages.logo, height: 56),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Trusted people.\nMeaningful moments. Nearby.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.displayLgMobile,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Step onto the digital porch and connect with the\nneighbours who make your house a home.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyLg,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    const SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
