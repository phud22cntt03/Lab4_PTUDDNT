import 'package:flutter/material.dart';
import 'package:weather_app/utils/constants.dart';
import 'package:weather_app/utils/weather_theme.dart';

class WeatherBackdrop extends StatelessWidget {
  const WeatherBackdrop({
    super.key,
    required this.palette,
    required this.child,
  });

  final WeatherPalette palette;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: AppConstants.shortAnimation,
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(gradient: palette.backgroundGradient),
      child: Stack(
        children: [
          Positioned(
            top: -120,
            left: -80,
            child: _GlowOrb(
              size: 280,
              color: palette.primaryAccent.withValues(alpha: 0.28),
            ),
          ),
          Positioned(
            top: 120,
            right: -90,
            child: _GlowOrb(
              size: 240,
              color: palette.secondaryAccent.withValues(alpha: 0.22),
            ),
          ),
          Positioned(
            bottom: -100,
            left: 40,
            child: _GlowOrb(
              size: 220,
              color: palette.textPrimary.withValues(alpha: 0.08),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color,
              blurRadius: 80,
              spreadRadius: 12,
            ),
          ],
        ),
      ),
    );
  }
}
