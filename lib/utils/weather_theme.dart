import 'package:flutter/material.dart';
import 'package:weather_app/models/weather_model.dart';
import 'package:weather_app/utils/constants.dart';

class WeatherPalette {
  const WeatherPalette({
    required this.backgroundGradient,
    required this.primaryAccent,
    required this.secondaryAccent,
    required this.surface,
    required this.surfaceStrong,
    required this.outline,
    required this.textPrimary,
    required this.textMuted,
  });

  final LinearGradient backgroundGradient;
  final Color primaryAccent;
  final Color secondaryAccent;
  final Color surface;
  final Color surfaceStrong;
  final Color outline;
  final Color textPrimary;
  final Color textMuted;

  factory WeatherPalette.fromWeather(WeatherModel? weather) {
    return WeatherPalette.fromCondition(
      weather?.mainCondition,
      isNight: weather?.isNightTime ?? false,
    );
  }

  factory WeatherPalette.fromCondition(
    String? condition, {
    required bool isNight,
  }) {
    final normalized = condition?.toLowerCase() ?? '';

    if (isNight) {
      return const WeatherPalette(
        backgroundGradient: LinearGradient(
          colors: [Color(0xFF10203D), Color(0xFF060B16), Color(0xFF02040A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        primaryAccent: Color(0xFF8EA7FF),
        secondaryAccent: Color(0xFF42C6FF),
        surface: Color(0xCC12203A),
        surfaceStrong: Color(0xE61A2A46),
        outline: Color(0x4DA3B7E4),
        textPrimary: Colors.white,
        textMuted: Color(0xFFD0DBF5),
      );
    }

    switch (normalized) {
      case 'clear':
        return const WeatherPalette(
          backgroundGradient: LinearGradient(
            colors: [Color(0xFFFFC75F), Color(0xFFFF8C42), Color(0xFF3478F6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          primaryAccent: Color(0xFFFF9F1C),
          secondaryAccent: Color(0xFF4FB4FF),
          surface: Color(0xB3192B49),
          surfaceStrong: Color(0xD924365B),
          outline: Color(0x66FFE3A1),
          textPrimary: Colors.white,
          textMuted: Color(0xFFFCEBD1),
        );
      case 'rain':
      case 'drizzle':
        return const WeatherPalette(
          backgroundGradient: LinearGradient(
            colors: [Color(0xFF406882), Color(0xFF223A5E), Color(0xFF10182A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          primaryAccent: Color(0xFF7BDFF2),
          secondaryAccent: Color(0xFF4D96FF),
          surface: Color(0xCC122338),
          surfaceStrong: Color(0xE61A2E49),
          outline: Color(0x668DD9FF),
          textPrimary: Colors.white,
          textMuted: Color(0xFFD7E6F5),
        );
      case 'thunderstorm':
        return const WeatherPalette(
          backgroundGradient: LinearGradient(
            colors: [Color(0xFF34225C), Color(0xFF15162F), Color(0xFF090B18)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          primaryAccent: Color(0xFFF5B700),
          secondaryAccent: Color(0xFF8B9DFF),
          surface: Color(0xCC181C35),
          surfaceStrong: Color(0xE6232948),
          outline: Color(0x66E2C675),
          textPrimary: Colors.white,
          textMuted: Color(0xFFE2E1F8),
        );
      case 'snow':
        return const WeatherPalette(
          backgroundGradient: LinearGradient(
            colors: [Color(0xFFEAF6FF), Color(0xFFA0D8EF), Color(0xFF5C7AEA)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          primaryAccent: Color(0xFF4E78FF),
          secondaryAccent: Color(0xFF9EE7FF),
          surface: Color(0xB3172A4D),
          surfaceStrong: Color(0xD9213A66),
          outline: Color(0x66DBF2FF),
          textPrimary: Colors.white,
          textMuted: Color(0xFFE8F6FF),
        );
      case 'clouds':
      case 'mist':
      case 'fog':
      case 'haze':
      case 'smoke':
        return const WeatherPalette(
          backgroundGradient: LinearGradient(
            colors: [Color(0xFF91A4B7), Color(0xFF4D648D), Color(0xFF1E2A44)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          primaryAccent: Color(0xFFC1D4E8),
          secondaryAccent: Color(0xFF7BB4FF),
          surface: Color(0xCC152238),
          surfaceStrong: Color(0xE61E304D),
          outline: Color(0x66D8E5F4),
          textPrimary: Colors.white,
          textMuted: Color(0xFFDDE7F3),
        );
      default:
        return const WeatherPalette(
          backgroundGradient: LinearGradient(
            colors: [Color(0xFF3A7BD5), Color(0xFF00B4D8), Color(0xFF01497C)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          primaryAccent: Color(0xFF5BE7FF),
          secondaryAccent: Color(0xFF78A6FF),
          surface: Color(0xCC11213A),
          surfaceStrong: Color(0xE61A2D4F),
          outline: Color(0x665BC0FF),
          textPrimary: Colors.white,
          textMuted: Color(0xFFD6E9F8),
        );
    }
  }

  ThemeData toThemeData() {
    final scheme = ColorScheme.fromSeed(
      seedColor: primaryAccent,
      brightness: Brightness.dark,
    ).copyWith(
      primary: primaryAccent,
      secondary: secondaryAccent,
      surface: surfaceStrong,
      onSurface: textPrimary,
      outline: outline,
      surfaceTint: Colors.transparent,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: Colors.transparent,
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.cardRadius),
          side: BorderSide(color: outline),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: textPrimary,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 22,
          fontWeight: FontWeight.w700,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        hintStyle: TextStyle(color: textMuted.withValues(alpha: 0.82)),
        prefixIconColor: textMuted,
        suffixIconColor: textPrimary,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: primaryAccent, width: 1.4),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: surfaceStrong,
        contentTextStyle: TextStyle(color: textPrimary),
        behavior: SnackBarBehavior.floating,
      ),
      listTileTheme: ListTileThemeData(
        iconColor: textPrimary,
        textColor: textPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
      dividerColor: outline.withValues(alpha: 0.42),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: primaryAccent),
      chipTheme: ChipThemeData(
        backgroundColor: surface,
        disabledColor: surface,
        selectedColor: primaryAccent.withValues(alpha: 0.26),
        secondarySelectedColor: primaryAccent.withValues(alpha: 0.26),
        labelStyle: TextStyle(color: textPrimary),
        secondaryLabelStyle: TextStyle(color: textPrimary),
        deleteIconColor: textPrimary,
        side: BorderSide(color: outline),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        brightness: Brightness.dark,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primaryAccent,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textPrimary,
          side: BorderSide(color: outline),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.all(textPrimary),
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return primaryAccent.withValues(alpha: 0.28);
            }
            return surface;
          }),
          side: WidgetStateProperty.all(BorderSide(color: outline)),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          ),
        ),
      ),
      textTheme: Typography.whiteMountainView.apply(
        bodyColor: textPrimary,
        displayColor: textPrimary,
      ),
    );
  }
}
