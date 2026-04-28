import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weather_app/models/weather_model.dart';
import 'package:weather_app/providers/settings_provider.dart';
import 'package:weather_app/utils/date_formatter.dart';
import 'package:weather_app/utils/weather_icons.dart';

class CurrentWeatherCard extends StatelessWidget {
  const CurrentWeatherCard({super.key, required this.weather});

  final WeatherModel weather;

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final displayedTemp = settings.displayTemperature(weather.temperature).round();
    final displayedFeelsLike =
        settings.displayTemperature(weather.feelsLike).round();
    final displayedMin = settings.displayTemperature(weather.tempMin ?? weather.temperature).round();
    final displayedMax = settings.displayTemperature(weather.tempMax ?? weather.temperature).round();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: WeatherVisuals.gradientForCondition(
          weather.mainCondition,
          isNight: weather.isNightTime,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 30,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${weather.cityName}, ${weather.country}',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      DateFormatter.fullDate(weather.dateTime),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                WeatherVisuals.iconForCondition(weather.mainCondition),
                size: 28,
                color: Colors.white,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              CachedNetworkImage(
                imageUrl: 'https://openweathermap.org/img/wn/${weather.icon}@4x.png',
                width: 110,
                height: 110,
                placeholder: (context, url) => const SizedBox(
                  width: 110,
                  height: 110,
                  child: Center(child: CircularProgressIndicator(color: Colors.white)),
                ),
                errorWidget: (context, url, error) => const Icon(
                  Icons.cloud_queue_rounded,
                  size: 72,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$displayedTemp${settings.temperatureUnitLabel()}',
                      style: const TextStyle(
                        fontSize: 54,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      weather.description.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 16,
                        letterSpacing: 0.8,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Feels like $displayedFeelsLike${settings.temperatureUnitLabel()}',
                      style: const TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'H:$displayedMax  L:$displayedMin ${settings.temperatureUnitLabel()}',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _SmallInfo(
                  icon: Icons.wb_twilight_rounded,
                  label: 'Sunrise',
                  value: DateFormatter.timeLabel(
                    weather.sunrise,
                    use24HourFormat: settings.use24HourFormat,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SmallInfo(
                  icon: Icons.nights_stay_rounded,
                  label: 'Sunset',
                  value: DateFormatter.timeLabel(
                    weather.sunset,
                    use24HourFormat: settings.use24HourFormat,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SmallInfo extends StatelessWidget {
  const _SmallInfo({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.white70)),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
