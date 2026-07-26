import 'dart:ui';
import 'package:flutter/material.dart';

/// Recreates the soft "ambient glow" blurred circles used behind content
/// on the splash, onboarding and verification screens in the mockups.
class AmbientBlobs extends StatelessWidget {
  const AmbientBlobs({
    super.key,
    this.topColor = const Color(0xFF5148D7),
    this.bottomColor = const Color(0xFFFD761A),
  });

  final Color topColor;
  final Color bottomColor;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            top: -100,
            left: -100,
            child: _blob(topColor),
          ),
          Positioned(
            bottom: -100,
            right: -100,
            child: _blob(bottomColor),
          ),
        ],
      ),
    );
  }

  Widget _blob(Color color) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
      child: Container(
        width: 320,
        height: 320,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: 0.15),
        ),
      ),
    );
  }
}
