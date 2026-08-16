import 'package:flutter/material.dart';
import '../../data/verification_repository.dart';
import '../../state/app_session.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_images.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/trust_badge.dart';
import '../shell/app_shell.dart';

/// Multi-step identity verification flow: Method -> Consent -> Aadhaar+OTP
/// -> Success. Matches the "Nearood | Identity Verification" mockup.
///
/// Not part of onboarding — this is only ever pushed at the moment someone
/// needs it, e.g. tapping "Request to Join" on an event while unverified.
/// [purpose] is shown as context for why verification is being asked for
/// right now. On success this pops `true` back to the caller (which is
/// expected to have pushed this screen and be waiting on the result);
/// if there's nothing to pop back to it falls back to the app shell.
class IdentityVerificationScreen extends StatefulWidget {
  const IdentityVerificationScreen({super.key, this.purpose});

  final String? purpose;

  @override
  State<IdentityVerificationScreen> createState() =>
      _IdentityVerificationScreenState();
}

enum _Step { method, consent, verify, success }

class _IdentityVerificationScreenState
    extends State<IdentityVerificationScreen> {
  _Step _step = _Step.method;
  bool _consentChecked = false;
  bool _otpSent = false;
  bool _sending = false;

  int get _stepNumber => switch (_step) {
        _Step.method => 1,
        _Step.consent => 2,
        _Step.verify => 3,
        _Step.success => 3,
      };

  Future<void> _skipVerification() async {
    final skip = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceContainerLowest,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        title: const Text('Skip for now?'),
        content: Text(
          widget.purpose == null
              ? "You can explore Nearood first. We'll ask again the "
                  'next time you need it, like requesting to join an event.'
              : "You won't be able to complete this until you verify. "
                  'You can come back to it anytime from your profile.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Keep verifying'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Skip for now'),
          ),
        ],
      ),
    );
    if (skip == true && mounted) {
      _leave(submitted: false);
    }
  }

  void _leave({required bool submitted}) {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop(submitted);
    } else {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const AppShell()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final showStepper = _step != _Step.success;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: _step == _Step.method
            ? null
            : const Text('Identity Verification'),
        actions: [
          if (_step != _Step.success)
            TextButton(
              onPressed: _skipVerification,
              child: const Text('Skip for now'),
            ),
          IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (showStepper) ...[
                _Stepper(current: _stepNumber),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Identity Verification',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.displayLgMobile,
                ),
                const SizedBox(height: 6),
                Text(
                  'Verified neighbors keep our community safe and reliable.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyLg,
                ),
                if (widget.purpose != null) ...[
                  const SizedBox(height: AppSpacing.base),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.base,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.warningContainer,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.lock_clock_rounded, size: 18, color: AppColors.warning),
                        const SizedBox(width: AppSpacing.base),
                        Expanded(
                          child: Text(
                            widget.purpose!,
                            style: AppTextStyles.labelMd.copyWith(color: AppColors.warning),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.md),
              ],
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: switch (_step) {
                  _Step.method => _MethodStep(
                      key: const ValueKey('method'),
                      onSelectAadhaar: () => setState(() => _step = _Step.consent),
                    ),
                  _Step.consent => _ConsentStep(
                      key: const ValueKey('consent'),
                      checked: _consentChecked,
                      onChanged: (v) => setState(() => _consentChecked = v),
                      onBack: () => setState(() => _step = _Step.method),
                      onContinue: _consentChecked
                          ? () => setState(() => _step = _Step.verify)
                          : null,
                    ),
                  _Step.verify => _VerifyStep(
                      key: const ValueKey('verify'),
                      otpSent: _otpSent,
                      sending: _sending,
                      onSendOtp: () async {
                        setState(() => _sending = true);
                        await Future.delayed(const Duration(milliseconds: 900));
                        if (!context.mounted) return;
                        setState(() {
                          _sending = false;
                          _otpSent = true;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('OTP sent successfully!')),
                        );
                      },
                      onVerify: (aadhaarNumber) async {
                        setState(() => _sending = true);
                        final digits = aadhaarNumber.replaceAll(RegExp('[^0-9]'), '');
                        final last4 = digits.length >= 4
                            ? digits.substring(digits.length - 4)
                            : digits;
                        try {
                          await VerificationRepository.instance
                              .submitAadhaarVerification(last4: last4);
                          await AppSession.instance.refresh();
                          if (!mounted) return;
                          setState(() {
                            _sending = false;
                            _step = _Step.success;
                          });
                        } catch (_) {
                          if (!context.mounted) return;
                          setState(() => _sending = false);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Couldn't submit — check your connection and try again."),
                            ),
                          );
                        }
                      },
                    ),
                  _Step.success => _SuccessStep(
                      key: const ValueKey('success'),
                      returningToCaller: widget.purpose != null,
                      onDone: () => _leave(submitted: true),
                    ),
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Stepper extends StatelessWidget {
  const _Stepper({required this.current});

  final int current;

  @override
  Widget build(BuildContext context) {
    Widget circle(int step, String label) {
      final active = current >= step;
      return Column(
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: active ? AppColors.primary : Colors.transparent,
              border: Border.all(
                color: active ? AppColors.primary : AppColors.outline,
                width: 2,
              ),
            ),
            child: Text(
              '$step',
              style: AppTextStyles.labelMd.copyWith(
                color: active ? AppColors.onPrimary : AppColors.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.labelMd.copyWith(
              color: active ? AppColors.primary : AppColors.onSurfaceVariant,
            ),
          ),
        ],
      );
    }

    Widget line(int afterStep) {
      final active = current >= afterStep + 1;
      return Expanded(
        child: Container(
          height: 2,
          margin: const EdgeInsets.symmetric(horizontal: 8),
          color: active ? AppColors.primary : AppColors.outlineVariant,
        ),
      );
    }

    return Row(
      children: [
        circle(1, 'Method'),
        line(1),
        circle(2, 'Consent'),
        line(2),
        circle(3, 'Verify'),
      ],
    );
  }
}

class _MethodStep extends StatelessWidget {
  const _MethodStep({super.key, required this.onSelectAadhaar});

  final VoidCallback onSelectAadhaar;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _MethodCard(
          icon: Icons.fingerprint_rounded,
          title: 'Aadhaar (Government ID)',
          subtitle: 'Verify using your UIDAI number via OTP. Quickest method.',
          enabled: true,
          onTap: onSelectAadhaar,
        ),
        const SizedBox(height: AppSpacing.base),
        _MethodCard(
          icon: Icons.badge_outlined,
          title: "Driver's License / PAN",
          subtitle: 'Requires manual photo upload. Takes 24-48 hours.',
          enabled: false,
          onTap: null,
        ),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: AppSpacing.base,
          runSpacing: AppSpacing.base,
          children: const [
            TrustBadge(
              label: 'Identity Verified',
              background: AppColors.primaryFixed,
              foreground: AppColors.primary,
            ),
            TrustBadge(
              label: 'Aadhaar Verified',
              icon: Icons.check_circle_rounded,
              background: Color(0x1AFD761A),
              foreground: AppColors.secondaryContainer,
            ),
          ],
        ),
      ],
    );
  }
}

class _MethodCard extends StatelessWidget {
  const _MethodCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool enabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.7,
      child: Material(
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
                  color: AppColors.primary.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                  child: Icon(icon, color: AppColors.primary, size: 32),
                ),
                const SizedBox(width: AppSpacing.base + 4),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: AppTextStyles.headlineSm),
                      const SizedBox(height: 4),
                      Text(subtitle, style: AppTextStyles.bodyMd),
                    ],
                  ),
                ),
                Icon(
                  enabled ? Icons.arrow_forward_ios_rounded : Icons.lock_outline_rounded,
                  color: AppColors.outline,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ConsentStep extends StatelessWidget {
  const _ConsentStep({
    super.key,
    required this.checked,
    required this.onChanged,
    required this.onBack,
    required this.onContinue,
  });

  final bool checked;
  final ValueChanged<bool> onChanged;
  final VoidCallback onBack;
  final VoidCallback? onContinue;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(Icons.shield_rounded, color: AppColors.primary, size: 56),
          const SizedBox(height: AppSpacing.base),
          Text('Your Privacy Matters', style: AppTextStyles.headlineMd, textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.base),
          Container(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.base),
            decoration: const BoxDecoration(
              border: Border.symmetric(
                horizontal: BorderSide(color: AppColors.outlineVariant),
              ),
            ),
            child: Column(
              children: const [
                _PrivacyPoint(
                  icon: Icons.shield_outlined,
                  title: 'Strict Privacy: ',
                  body:
                      'We never share your full ID number or document photos with other neighbors.',
                ),
                SizedBox(height: AppSpacing.base),
                _PrivacyPoint(
                  icon: Icons.verified_user_rounded,
                  title: 'Verified Badging: ',
                  body:
                      'Only the "Verified" badge will appear on your profile to build trust.',
                ),
                SizedBox(height: AppSpacing.base),
                _PrivacyPoint(
                  icon: Icons.gavel_rounded,
                  title: 'Regulatory Compliance: ',
                  body:
                      'We adhere to all local data protection laws regarding PII (Personally Identifiable Information).',
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.base),
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer,
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: Row(
              children: [
                Checkbox(
                  value: checked,
                  onChanged: (v) => onChanged(v ?? false),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => onChanged(!checked),
                    child: Text(
                      'I consent to Nearood verifying my identity using the provided documents.',
                      style: AppTextStyles.labelMd,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.base),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(onPressed: onBack, child: const Text('Back')),
              ),
              const SizedBox(width: AppSpacing.base),
              Expanded(
                child: ElevatedButton(
                  onPressed: onContinue,
                  child: const Text('Agree & Continue'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PrivacyPoint extends StatelessWidget {
  const _PrivacyPoint({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: AppSpacing.base),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: AppTextStyles.bodyMd,
              children: [
                TextSpan(
                  text: title,
                  style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.onSurface),
                ),
                TextSpan(text: body),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _VerifyStep extends StatefulWidget {
  const _VerifyStep({
    super.key,
    required this.otpSent,
    required this.sending,
    required this.onSendOtp,
    required this.onVerify,
  });

  final bool otpSent;
  final bool sending;
  final VoidCallback onSendOtp;
  final ValueChanged<String> onVerify;

  @override
  State<_VerifyStep> createState() => _VerifyStepState();
}

class _VerifyStepState extends State<_VerifyStep> {
  final _aadhaarController = TextEditingController();
  final List<TextEditingController> _otpControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _otpNodes = List.generate(6, (_) => FocusNode());

  @override
  void dispose() {
    _aadhaarController.dispose();
    for (final c in _otpControllers) {
      c.dispose();
    }
    for (final n in _otpNodes) {
      n.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.xl),
            child: Image.asset(
              AppImages.verificationScan,
              height: 160,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: AppSpacing.base),
          Text(
            'Please provide your 12-digit Aadhaar number',
            textAlign: TextAlign.center,
            style: AppTextStyles.labelMd.copyWith(color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(height: AppSpacing.md),
          Align(
            alignment: Alignment.centerLeft,
            child: Text('Aadhaar Number', style: AppTextStyles.labelMd),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _aadhaarController,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            maxLength: 14,
            style: AppTextStyles.headlineSm,
            decoration: const InputDecoration(
              counterText: '',
              hintText: 'XXXX-XXXX-XXXX',
            ),
          ),
          if (widget.otpSent) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              'Enter 6-digit OTP sent to your registered mobile',
              textAlign: TextAlign.center,
              style: AppTextStyles.labelMd,
            ),
            const SizedBox(height: AppSpacing.base),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(6, (i) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: SizedBox(
                    width: 40,
                    height: 56,
                    child: TextField(
                      controller: _otpControllers[i],
                      focusNode: _otpNodes[i],
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      style: AppTextStyles.headlineSm,
                      decoration: const InputDecoration(
                        counterText: '',
                        contentPadding: EdgeInsets.zero,
                      ),
                      onChanged: (v) {
                        if (v.isNotEmpty && i < 5) {
                          _otpNodes[i + 1].requestFocus();
                        } else if (v.isEmpty && i > 0) {
                          _otpNodes[i - 1].requestFocus();
                        }
                      },
                    ),
                  ),
                );
              }),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: widget.sending
                  ? null
                  : (widget.otpSent
                      ? () => widget.onVerify(_aadhaarController.text)
                      : widget.onSendOtp),
              child: widget.sending
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Text(widget.otpSent ? 'Verify & Complete' : 'Send OTP'),
            ),
          ),
          const SizedBox(height: AppSpacing.base),
          Container(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.base, horizontal: AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.lock_outline_rounded, size: 16, color: AppColors.onSurfaceVariant),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    'We never share your full ID number with others.',
                    style: AppTextStyles.labelSm,
                    textAlign: TextAlign.center,
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

class _SuccessStep extends StatelessWidget {
  const _SuccessStep({
    super.key,
    required this.onDone,
    this.returningToCaller = false,
  });

  final VoidCallback onDone;
  final bool returningToCaller;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: AppSpacing.lg),
        Container(
          width: 96,
          height: 96,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.surfaceContainer,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.15),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(Icons.hourglass_top_rounded, color: AppColors.primary, size: 48),
        ),
        const SizedBox(height: AppSpacing.md),
        Text('Verification submitted', style: AppTextStyles.displayLgMobile, textAlign: TextAlign.center),
        const SizedBox(height: AppSpacing.base),
        Text(
          "We'll review it and notify you once it's confirmed. You can keep using Nearood in the meantime.",
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyLg,
        ),
        const SizedBox(height: AppSpacing.md),
        const TrustBadge(
          label: 'Verification pending',
          icon: Icons.hourglass_top_rounded,
          background: AppColors.warningContainer,
          foreground: AppColors.warning,
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onDone,
            child: Text(returningToCaller ? 'Continue' : 'Back to Profile'),
          ),
        ),
      ],
    );
  }
}
