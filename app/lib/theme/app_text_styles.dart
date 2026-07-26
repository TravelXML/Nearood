import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Typography scale from DESIGN.md: Comfortaa for headings, Plus Jakarta
/// Sans for body copy and UI labels.
class AppTextStyles {
  AppTextStyles._();

  static const _headingFamily = 'Comfortaa';
  static const _bodyFamily = 'Plus Jakarta Sans';

  static const displayLg = TextStyle(
    fontFamily: _headingFamily,
    fontSize: 48,
    fontWeight: FontWeight.w700,
    height: 56 / 48,
    letterSpacing: -0.02 * 48,
    color: AppColors.onSurface,
  );

  static const displayLgMobile = TextStyle(
    fontFamily: _headingFamily,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 40 / 32,
    letterSpacing: -0.02 * 32,
    color: AppColors.onSurface,
  );

  static const headlineMd = TextStyle(
    fontFamily: _headingFamily,
    fontSize: 32,
    fontWeight: FontWeight.w600,
    height: 40 / 32,
    letterSpacing: -0.01 * 32,
    color: AppColors.onSurface,
  );

  static const headlineSm = TextStyle(
    fontFamily: _headingFamily,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 32 / 24,
    color: AppColors.onSurface,
  );

  static const bodyLg = TextStyle(
    fontFamily: _bodyFamily,
    fontSize: 18,
    fontWeight: FontWeight.w400,
    height: 28 / 18,
    color: AppColors.onSurfaceVariant,
  );

  static const bodyMd = TextStyle(
    fontFamily: _bodyFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 24 / 16,
    color: AppColors.onSurfaceVariant,
  );

  static const labelMd = TextStyle(
    fontFamily: _bodyFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 20 / 14,
    letterSpacing: 0.02 * 14,
    color: AppColors.onSurface,
  );

  static const labelSm = TextStyle(
    fontFamily: _bodyFamily,
    fontSize: 12,
    fontWeight: FontWeight.w700,
    height: 16 / 12,
    letterSpacing: 0.05 * 12,
    color: AppColors.onSurfaceVariant,
  );
}
