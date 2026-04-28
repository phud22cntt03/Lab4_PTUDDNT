import 'package:flutter/material.dart';
import 'package:weather_app/utils/constants.dart';

class WeatherVisuals {
  WeatherVisuals._();

  static LinearGradient gradientForCondition(
    String condition, {
    required bool isNight,
  }) {
    final normalized = condition.toLowerCase();

    if (isNight) {
      return const LinearGradient(
        colors: [AppConstants.nightPrimary, AppConstants.nightBackground],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }

    switch (normalized) {
      case 'clear':
        return const LinearGradient(
          colors: [AppConstants.sunnyPrimary, AppConstants.sunnyBackground],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'rain':
      case 'drizzle':
      case 'thunderstorm':
        return const LinearGradient(
          colors: [AppConstants.rainyPrimary, AppConstants.rainyBackground],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'clouds':
      case 'mist':
      case 'fog':
      case 'haze':
      case 'smoke':
        return const LinearGradient(
          colors: [AppConstants.cloudyPrimary, AppConstants.cloudyBackground],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      default:
        return const LinearGradient(
          colors: [Color(0xFF3A7BD5), Color(0xFF6DD5FA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }
  }

  static IconData iconForCondition(String condition) {
    switch (condition.toLowerCase()) {
      case 'clear':
        return Icons.wb_sunny_rounded;
      case 'rain':
      case 'drizzle':
        return Icons.grain_rounded;
      case 'thunderstorm':
        return Icons.thunderstorm_rounded;
      case 'snow':
        return Icons.ac_unit_rounded;
      case 'clouds':
        return Icons.cloud_rounded;
      default:
        return Icons.wb_cloudy_rounded;
    }
  }
}
