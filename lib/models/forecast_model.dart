import 'package:weather_app/models/hourly_weather_model.dart';

class ForecastModel {
  const ForecastModel({
    required this.date,
    required this.minTemperature,
    required this.maxTemperature,
    required this.averageTemperature,
    required this.description,
    required this.icon,
    required this.mainCondition,
    required this.humidity,
    required this.windSpeed,
    required this.precipitationProbability,
  });

  final DateTime date;
  final double minTemperature;
  final double maxTemperature;
  final double averageTemperature;
  final String description;
  final String icon;
  final String mainCondition;
  final int humidity;
  final double windSpeed;
  final double precipitationProbability;

  static List<ForecastModel> fromHourlyList(List<HourlyWeatherModel> items) {
    final grouped = <DateTime, List<HourlyWeatherModel>>{};

    for (final item in items) {
      final key = DateTime(item.dateTime.year, item.dateTime.month, item.dateTime.day);
      grouped.putIfAbsent(key, () => []).add(item);
    }

    final sortedKeys = grouped.keys.toList()..sort();

    return sortedKeys.map((date) {
      final dayItems = grouped[date]!;
      final representative = _pickRepresentative(dayItems);
      final averageTemperature = dayItems
              .map((item) => item.temperature)
              .reduce((value, element) => value + element) /
          dayItems.length;
      final minTemperature = dayItems
          .map((item) => item.tempMin)
          .reduce((value, element) => value < element ? value : element);
      final maxTemperature = dayItems
          .map((item) => item.tempMax)
          .reduce((value, element) => value > element ? value : element);
      final humidity = (dayItems
                  .map((item) => item.humidity)
                  .reduce((value, element) => value + element) /
              dayItems.length)
          .round();
      final windSpeed = dayItems
              .map((item) => item.windSpeed)
              .reduce((value, element) => value + element) /
          dayItems.length;
      final precipitationProbability = dayItems
          .map((item) => item.precipitationProbability)
          .reduce((value, element) => value > element ? value : element);

      return ForecastModel(
        date: date,
        minTemperature: minTemperature,
        maxTemperature: maxTemperature,
        averageTemperature: averageTemperature,
        description: representative.description,
        icon: representative.icon,
        mainCondition: representative.mainCondition,
        humidity: humidity,
        windSpeed: windSpeed,
        precipitationProbability: precipitationProbability,
      );
    }).take(5).toList();
  }

  static HourlyWeatherModel _pickRepresentative(List<HourlyWeatherModel> items) {
    items.sort(
      (a, b) =>
          (a.dateTime.hour - 12).abs().compareTo((b.dateTime.hour - 12).abs()),
    );
    return items.first;
  }
}
