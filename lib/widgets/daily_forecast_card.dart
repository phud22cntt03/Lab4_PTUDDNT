import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weather_app/models/forecast_model.dart';
import 'package:weather_app/providers/settings_provider.dart';
import 'package:weather_app/utils/date_formatter.dart';

class DailyForecastCard extends StatelessWidget {
  const DailyForecastCard({
    super.key,
    required this.forecast,
    this.backgroundColor,
    this.textColor,
  });

  final ForecastModel forecast;
  final Color? backgroundColor;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final surface = backgroundColor ?? Colors.white.withValues(alpha: 0.12);
    final onSurface = textColor ?? Colors.white;

    final min = settings.displayTemperature(forecast.minTemperature).round();
    final max = settings.displayTemperature(forecast.maxTemperature).round();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormatter.dayLabel(forecast.date),
                  style: TextStyle(
                    color: onSurface,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  forecast.description,
                  style: TextStyle(color: onSurface.withValues(alpha: 0.72)),
                ),
              ],
            ),
          ),
          CachedNetworkImage(
            imageUrl: 'https://openweathermap.org/img/wn/${forecast.icon}@2x.png',
            width: 50,
            height: 50,
            errorWidget: (context, url, error) =>
                Icon(Icons.cloud_rounded, color: onSurface),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$max${settings.temperatureUnitLabel()} / $min${settings.temperatureUnitLabel()}',
                style: TextStyle(
                  color: onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${forecast.precipitationProbability.round()}% rain',
                style: TextStyle(color: onSurface.withValues(alpha: 0.72)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
