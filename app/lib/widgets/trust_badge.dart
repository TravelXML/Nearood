import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// Small pill badge used to surface trust/verification signals, e.g.
/// "Identity Verified Community" or "Aadhaar Verified".
class TrustBadge extends StatelessWidget {
  const TrustBadge({
    super.key,
    required this.label,
    this.icon = Icons.verified_rounded,
    this.background = AppColors.primaryFixed,
    this.foreground = AppColors.primary,
    this.dense = false,
  });

  final String label;
  final IconData icon;
  final Color background;
  final Color foreground;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: dense ? 12 : 16,
        vertical: dense ? 6 : 10,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: dense ? 14 : 18, color: foreground),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.labelSm.copyWith(
                color: foreground,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
