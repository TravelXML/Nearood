import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_images.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/ambient_blobs.dart';
import '../../widgets/trust_badge.dart';
import '../auth/sign_in_screen.dart';

class _OnboardingSlide {
  const _OnboardingSlide({
    required this.image,
    required this.tint,
    required this.rotation,
    required this.title,
    required this.description,
  });

  final String image;
  final Color tint;
  final double rotation;
  final String title;
  final String description;
}

const _slides = [
  _OnboardingSlide(
    image: AppImages.onboardingDiscover,
    tint: AppColors.primaryFixed,
    rotation: 0.05,
    title: 'Discover trusted neighbours nearby.',
    description:
        'Connect with identity-verified people in your immediate area to build a safer, friendlier street.',
  ),
  _OnboardingSlide(
    image: AppImages.onboardingExperiences,
    tint: AppColors.secondaryFixed,
    rotation: -0.05,
    title: 'Join dinners, activities, and local experiences.',
    description:
        'From book clubs to shared garden dinners, find real-world ways to engage with your community.',
  ),
  _OnboardingSlide(
    image: AppImages.onboardingHelp,
    tint: AppColors.tertiaryFixed,
    rotation: 0.1,
    title: 'Get or offer help safely within your community.',
    description:
        "Lend a hand with grocery runs or borrow a tool. Verification ensures everyone's safety and peace of mind.",
  ),
];

/// Three-slide onboarding carousel matching the second Stitch mockup
/// ("Welcome to Neighbourly"). Spec item 2.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _signIn() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SignInScreen()),
    );
  }

  void _getStarted() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SignInScreen(isRegister: true)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          const AmbientBlobs(),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: AppSpacing.base),
                Image.asset(AppImages.logo, height: 40),
                const SizedBox(height: 4),
                Text(
                  'BUILDING COMMUNITY',
                  style: AppTextStyles.labelMd.copyWith(
                    color: AppColors.onSurfaceVariant,
                    letterSpacing: 2,
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _controller,
                    itemCount: _slides.length,
                    onPageChanged: (i) => setState(() => _index = i),
                    itemBuilder: (context, i) => _SlideView(slide: _slides[i]),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.base,
                    AppSpacing.md,
                    AppSpacing.md,
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(_slides.length, (i) {
                          final active = i == _index;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            height: 8,
                            width: active ? 32 : 8,
                            decoration: BoxDecoration(
                              color: active
                                  ? AppColors.primary
                                  : AppColors.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(AppRadius.full),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _getStarted,
                          icon: const Icon(Icons.arrow_forward_rounded, size: 20),
                          label: const Text('Get Started'),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.base),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _signIn,
                              child: const Text('Sign In'),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.base),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _signIn,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.secondaryContainer,
                                side: const BorderSide(
                                  color: AppColors.secondaryContainer,
                                  width: 2,
                                ),
                              ),
                              icon: const Icon(Icons.accessibility_new_rounded, size: 18),
                              label: const Text('Senior Cit.'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.base + 4),
                      const TrustBadge(
                        label: 'Identity Verified Community',
                        background: Color(0x1A2A14B4),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SlideView extends StatelessWidget {
  const _SlideView({required this.slide});

  final _OnboardingSlide slide;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.base),
          SizedBox(
            height: 300,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Transform.rotate(
                  angle: slide.rotation,
                  child: Container(
                    width: 260,
                    height: 260,
                    decoration: BoxDecoration(
                      color: slide.tint.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(48),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(40),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(32),
                    child: Image.asset(
                      slide.image,
                      width: 260,
                      height: 260,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            slide.title,
            textAlign: TextAlign.center,
            style: AppTextStyles.displayLgMobile,
          ),
          const SizedBox(height: AppSpacing.base),
          Text(
            slide.description,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMd,
          ),
        ],
      ),
    );
  }
}
