import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weather_app/providers/weather_provider.dart';
import 'package:weather_app/widgets/daily_forecast_card.dart';
import 'package:weather_app/widgets/hourly_forecast_list.dart';

class ForecastScreen extends StatelessWidget {
  const ForecastScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WeatherProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          provider.currentWeather == null
              ? 'Forecast'
              : 'Forecast - ${provider.currentWeather!.cityName}',
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Next 24 Hours',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          HourlyForecastList(
            forecasts: provider.hourlyForecast,
            backgroundColor:
                Theme.of(context).colorScheme.surfaceContainerHighest,
            textColor: Theme.of(context).colorScheme.onSurface,
          ),
          const SizedBox(height: 24),
          const Text(
            'Next 5 Days',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          ...provider.dailyForecast.map(
            (forecast) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: DailyForecastCard(
                forecast: forecast,
                backgroundColor:
                    Theme.of(context).colorScheme.surfaceContainerHighest,
                textColor: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
