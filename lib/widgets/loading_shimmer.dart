import 'package:flutter/material.dart';
import 'package:weather_app/utils/constants.dart';

class LoadingShimmer extends StatelessWidget {
  const LoadingShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.35, end: 0.9),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(AppConstants.screenPadding),
            children: [
              _block(height: 24, width: 180),
              const SizedBox(height: 24),
              _block(height: 280),
              const SizedBox(height: 20),
              _block(height: 180),
              const SizedBox(height: 20),
              _block(height: 300),
            ],
          ),
        );
      },
    );
  }

  Widget _block({required double height, double? width}) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}
