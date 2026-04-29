import 'package:flutter_test/flutter_test.dart';
import 'package:weather_app/models/forecast_model.dart';
import 'package:weather_app/models/hourly_weather_model.dart';

HourlyWeatherModel _hourly({
  required DateTime at,
  required double temp,
  required double min,
  required double max,
  required String description,
  required String icon,
  required String main,
  required int humidity,
  required double windSpeed,
  required double pop,
}) {
  return HourlyWeatherModel(
    dateTime: at,
    temperature: temp,
    tempMin: min,
    tempMax: max,
    description: description,
    icon: icon,
    mainCondition: main,
    humidity: humidity,
    windSpeed: windSpeed,
    precipitationProbability: pop,
  );
}

void main() {
  group('ForecastModel', () {
    test('aggregates hourly entries by day and picks a noon representative',
        () {
      final items = <HourlyWeatherModel>[
        _hourly(
          at: DateTime(2026, 4, 28, 8),
          temp: 26,
          min: 24,
          max: 29,
          description: 'few clouds',
          icon: '02d',
          main: 'Clouds',
          humidity: 80,
          windSpeed: 3,
          pop: 10,
        ),
        _hourly(
          at: DateTime(2026, 4, 28, 12),
          temp: 30,
          min: 25,
          max: 33,
          description: 'light rain',
          icon: '10d',
          main: 'Rain',
          humidity: 70,
          windSpeed: 5,
          pop: 60,
        ),
        _hourly(
          at: DateTime(2026, 4, 28, 18),
          temp: 28,
          min: 26,
          max: 31,
          description: 'overcast clouds',
          icon: '04d',
          main: 'Clouds',
          humidity: 75,
          windSpeed: 4,
          pop: 40,
        ),
        _hourly(
          at: DateTime(2026, 4, 29, 9),
          temp: 27,
          min: 23,
          max: 30,
          description: 'clear sky',
          icon: '01d',
          main: 'Clear',
          humidity: 65,
          windSpeed: 2,
          pop: 5,
        ),
      ];

      final forecast = ForecastModel.fromHourlyList(items);

      expect(forecast, hasLength(2));

      final firstDay = forecast.first;
      expect(firstDay.date, DateTime(2026, 4, 28));
      expect(firstDay.minTemperature, 24);
      expect(firstDay.maxTemperature, 33);
      expect(firstDay.averageTemperature, closeTo(28, 0.001));
      expect(firstDay.humidity, 75);
      expect(firstDay.windSpeed, closeTo(4, 0.001));
      expect(firstDay.precipitationProbability, 60);
      expect(firstDay.mainCondition, 'Rain');
      expect(firstDay.description, 'light rain');
      expect(firstDay.icon, '10d');
    });

    test('limits daily forecast output to five days', () {
      final items = List<HourlyWeatherModel>.generate(
        6,
        (index) => _hourly(
          at: DateTime(2026, 5, 1 + index, 12),
          temp: 25.0 + index,
          min: 20.0 + index,
          max: 30.0 + index,
          description: 'clear sky',
          icon: '01d',
          main: 'Clear',
          humidity: 60,
          windSpeed: 3,
          pop: 0,
        ),
      );

      final forecast = ForecastModel.fromHourlyList(items);

      expect(forecast, hasLength(5));
      expect(forecast.last.date, DateTime(2026, 5, 5));
    });
  });
}
