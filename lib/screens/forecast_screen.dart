import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weather_app/providers/weather_provider.dart';
import 'package:weather_app/utils/constants.dart';
import 'package:weather_app/utils/weather_theme.dart';
import 'package:weather_app/widgets/daily_forecast_card.dart';
import 'package:weather_app/widgets/hourly_forecast_list.dart';
import 'package:weather_app/widgets/weather_backdrop.dart';

class ForecastScreen extends StatelessWidget {
  const ForecastScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WeatherProvider>();
    final palette = WeatherPalette.fromWeather(provider.currentWeather);
    final colors = Theme.of(context).colorScheme;

    return WeatherBackdrop(
      palette: palette,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            provider.currentWeather == null
                ? 'Forecast'
                : 'Forecast - ${provider.currentWeather!.cityName}',
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(AppConstants.screenPadding),
          children: [
            Text(
              'Next 24 Hours',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: colors.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            HourlyForecastList(
              forecasts: provider.hourlyForecast,
              backgroundColor: colors.surface.withValues(alpha: 0.72),
              textColor: colors.onSurface,
            ),
            const SizedBox(height: 24),
            Text(
              'Next 5 Days',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: colors.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            ...provider.dailyForecast.map(
              (forecast) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: DailyForecastCard(
                  forecast: forecast,
                  backgroundColor: colors.surface.withValues(alpha: 0.72),
                  textColor: colors.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
