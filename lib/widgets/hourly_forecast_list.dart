import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weather_app/models/hourly_weather_model.dart';
import 'package:weather_app/providers/settings_provider.dart';
import 'package:weather_app/utils/date_formatter.dart';

class HourlyForecastList extends StatelessWidget {
  const HourlyForecastList({
    super.key,
    required this.forecasts,
    this.backgroundColor,
    this.textColor,
  });

  final List<HourlyWeatherModel> forecasts;
  final Color? backgroundColor;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final onSurface = textColor ?? Colors.white;
    final surface = backgroundColor ?? Colors.white.withValues(alpha: 0.14);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hourly Forecast',
          style: TextStyle(
            color: onSurface,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 180,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: forecasts.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final forecast = forecasts[index];
              final displayedTemp =
                  settings.displayTemperature(forecast.temperature).round();

              return Container(
                width: 120,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: surface,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DateFormatter.hourLabel(
                        forecast.dateTime,
                        use24HourFormat: settings.use24HourFormat,
                      ),
                      style: TextStyle(
                        color: onSurface.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    CachedNetworkImage(
                      imageUrl:
                          'https://openweathermap.org/img/wn/${forecast.icon}@2x.png',
                      width: 52,
                      height: 52,
                      errorWidget: (context, url, error) =>
                          Icon(Icons.cloud_rounded, color: onSurface),
                    ),
                    Text(
                      '$displayedTemp${settings.temperatureUnitLabel()}',
                      style: TextStyle(
                        color: onSurface,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '${forecast.precipitationProbability.round()}% rain',
                      style: TextStyle(
                        color: onSurface.withValues(alpha: 0.75),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
