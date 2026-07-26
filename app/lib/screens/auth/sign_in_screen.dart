import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../state/app_session.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../location/select_location_screen.dart';
import '../shell/app_shell.dart';

/// Real Supabase email-OTP sign-in/sign-up (one flow handles both — Supabase
/// creates the account on first verification), plus Google OAuth. Identity
/// (Aadhaar/Govt ID) verification is deliberately not part of this flow;
/// it's asked for later, only when someone tries to request to join an
/// event or offer assistance.
class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key, this.isRegister = false});

  final bool isRegister;

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _emailController = TextEditingController();
  final List<TextEditingController> _otpControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _otpNodes = List.generate(6, (_) => FocusNode());

  bool _codeSent = false;
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    for (final c in _otpControllers) {
      c.dispose();
    }
    for (final n in _otpNodes) {
      n.dispose();
    }
    super.dispose();
  }

  bool get _isValidEmail => RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(_emailController.text.trim());

  Future<void> _sendCode() async {
    if (!_isValidEmail) {
      setState(() => _error = 'Enter a valid email address.');
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await Supabase.instance.client.auth.signInWithOtp(
        email: _emailController.text.trim(),
      );
      if (!mounted) return;
      setState(() {
        _codeSent = true;
        _submitting = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Code sent — check your email.')),
      );
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _error = e.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _error = "Couldn't send the code. Check your connection and try again.";
      });
    }
  }

  Future<void> _verifyCode() async {
    final token = _otpControllers.map((c) => c.text).join();
    if (token.length != 6) {
      setState(() => _error = 'Enter the 6-digit code.');
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await Supabase.instance.client.auth.verifyOTP(
        type: OtpType.email,
        email: _emailController.text.trim(),
        token: token,
      );
      await AppSession.instance.refresh();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => AppSession.instance.hasLocation
              ? const AppShell()
              : const SelectLocationScreen(),
        ),
        (route) => false,
      );
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _error = e.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _error = "That code didn't work. Check it and try again.";
      });
    }
  }

  Future<void> _continueWithGoogle() async {
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      // Web: full-page redirect to Google, then back to this same origin —
      // Supabase's client auto-detects the session from the redirect URL
      // on reload (detectSessionInUri), so there's nothing to await here.
      await Supabase.instance.client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: Uri.base.origin,
      );
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _error = e.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _error = "Couldn't start Google sign-in. Try again.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            if (_codeSent) {
              setState(() => _codeSent = false);
            } else {
              Navigator.of(context).maybePop();
            }
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.base),
              Text(
                _codeSent
                    ? 'Enter your code'
                    : (widget.isRegister ? 'Create your account' : 'Welcome back'),
                style: AppTextStyles.displayLgMobile,
              ),
              const SizedBox(height: AppSpacing.base),
              Text(
                _codeSent
                    ? 'We sent a 6-digit code to ${_emailController.text.trim()}.'
                    : (widget.isRegister
                        ? "We'll only ask for your Aadhaar or government ID later, when you request to join an event or offer help."
                        : 'Sign in with your email to pick up where you left off.'),
                style: AppTextStyles.bodyMd,
              ),
              const SizedBox(height: AppSpacing.md),
              if (!_codeSent) ...[
                Text('Email', style: AppTextStyles.labelMd),
                const SizedBox(height: 6),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                  decoration: const InputDecoration(hintText: 'you@example.com'),
                  onSubmitted: (_) => _sendCode(),
                ),
              ] else ...[
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
              if (_error != null) ...[
                const SizedBox(height: AppSpacing.base),
                Text(_error!, style: AppTextStyles.labelMd.copyWith(color: AppColors.error)),
              ],
              const SizedBox(height: AppSpacing.base + 4),
              ElevatedButton(
                onPressed: _submitting ? null : (_codeSent ? _verifyCode : _sendCode),
                child: _submitting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text(_codeSent ? 'Verify & continue' : 'Send code'),
              ),
              if (_codeSent) ...[
                const SizedBox(height: AppSpacing.base),
                TextButton(
                  onPressed: _submitting ? null : _sendCode,
                  child: const Text('Resend code'),
                ),
              ],
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  const Expanded(child: Divider(color: AppColors.outlineVariant)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text('or', style: AppTextStyles.labelSm),
                  ),
                  const Expanded(child: Divider(color: AppColors.outlineVariant)),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              OutlinedButton.icon(
                onPressed: _submitting ? null : _continueWithGoogle,
                icon: const _GoogleGlyph(),
                label: const Text('Continue with Google'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.onSurface,
                  side: const BorderSide(color: AppColors.outlineVariant, width: 2),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded, size: 18, color: AppColors.onSurfaceVariant),
                    const SizedBox(width: AppSpacing.base),
                    Expanded(
                      child: Text(
                        "No ID needed to sign up or browse. We'll ask for Aadhaar or a government ID only when you request to join an event or offer assistance.",
                        style: AppTextStyles.labelSm,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Lightweight "G" glyph so we don't need to bundle a brand asset for a
/// disabled placeholder button.
class _GoogleGlyph extends StatelessWidget {
  const _GoogleGlyph();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      alignment: Alignment.center,
      decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
      child: const Text(
        'G',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: Color(0xFF4285F4),
          height: 1,
        ),
      ),
    );
  }
}
