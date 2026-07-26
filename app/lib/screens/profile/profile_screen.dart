import 'package:flutter/material.dart';
import '../../state/app_session.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/trust_badge.dart';
import '../verification/identity_verification_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: AppSession.instance,
          builder: (context, _) {
            final session = AppSession.instance;
            return ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                Center(
                  child: Column(
                    children: [
                      const CircleAvatar(
                        radius: 44,
                        backgroundColor: AppColors.surfaceContainerHigh,
                        child: Icon(Icons.person_rounded, size: 44, color: AppColors.primary),
                      ),
                      const SizedBox(height: AppSpacing.base),
                      Text(session.displayName ?? 'Your Name', style: AppTextStyles.headlineMd),
                      const SizedBox(height: 6),
                      Text(session.neighbourhood ?? 'No neighbourhood set', style: AppTextStyles.bodyMd),
                      const SizedBox(height: AppSpacing.base),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        alignment: WrapAlignment.center,
                        children: [
                          if (session.isVerified)
                            const TrustBadge(label: 'Identity Verified', dense: true)
                          else
                            const TrustBadge(
                              label: 'Not yet verified',
                              icon: Icons.error_outline_rounded,
                              background: AppColors.warningContainer,
                              foreground: AppColors.warning,
                              dense: true,
                            ),
                          const TrustBadge(
                            label: 'Mobile Verified',
                            icon: Icons.smartphone_rounded,
                            dense: true,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                if (!session.isVerified)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.base),
                    child: _SectionCard(
                      title: 'Verify your identity',
                      subtitle:
                          "You'll need this to request to join events or offer assistance. Takes about a minute with Aadhaar.",
                      icon: Icons.verified_user_outlined,
                      accent: AppColors.warning,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const IdentityVerificationScreen(
                              purpose: 'Verify your identity to unlock joining events and requesting help.',
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                _SectionCard(
                  title: 'Trust & reputation',
                  subtitle:
                      'Built from verification, profile completeness, ratings and participation history. Not a guarantee of safety — always use in-app safety tools.',
                  icon: Icons.workspace_premium_rounded,
                ),
                const SizedBox(height: AppSpacing.base),
                _SectionCard(
                  title: 'Safety Centre',
                  subtitle: 'SOS, trusted contacts, live check-in and reporting tools.',
                  icon: Icons.health_and_safety_rounded,
                ),
                const SizedBox(height: AppSpacing.base),
                _SectionCard(
                  title: 'Privacy settings',
                  subtitle: 'Control what neighbours can see before and after they connect with you.',
                  icon: Icons.privacy_tip_rounded,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.accent = AppColors.primary,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(AppRadius.xl),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.xl),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.06),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: accent),
              const SizedBox(width: AppSpacing.base),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyles.labelMd.copyWith(fontSize: 16)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: AppTextStyles.bodyMd),
                  ],
                ),
              ),
              if (onTap != null)
                const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.outline),
            ],
          ),
        ),
      ),
    );
  }
}
