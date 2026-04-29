import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weather_app/models/hourly_weather_model.dart';
import 'package:weather_app/models/weather_model.dart';
import 'package:weather_app/services/storage_service.dart';

WeatherModel _weatherModel() {
  return WeatherModel(
    cityName: 'Ho Chi Minh City',
    country: 'VN',
    temperature: 31,
    feelsLike: 35,
    humidity: 72,
    windSpeed: 4.5,
    pressure: 1008,
    description: 'clear sky',
    icon: '01d',
    mainCondition: 'Clear',
    dateTime: DateTime(2026, 4, 28, 9),
    sunrise: DateTime(2026, 4, 28, 5, 42),
    sunset: DateTime(2026, 4, 28, 18, 2),
    latitude: 10.8231,
    longitude: 106.6297,
    tempMin: 29,
    tempMax: 33,
    visibility: 10000,
    cloudiness: 10,
    windDegree: 120,
  );
}

HourlyWeatherModel _hourlyModel(DateTime at, double temperature) {
  return HourlyWeatherModel(
    dateTime: at,
    temperature: temperature,
    tempMin: temperature - 1,
    tempMax: temperature + 1,
    description: 'few clouds',
    icon: '02d',
    mainCondition: 'Clouds',
    humidity: 70,
    windSpeed: 3.5,
    precipitationProbability: 25,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('StorageService', () {
    late StorageService storageService;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      storageService = StorageService();
    });

    test('saves and restores cached weather data', () async {
      final weather = _weatherModel();
      final hourly = <HourlyWeatherModel>[
        _hourlyModel(DateTime(2026, 4, 28, 9), 30),
        _hourlyModel(DateTime(2026, 4, 28, 12), 32),
      ];

      await storageService.saveWeatherData(weather, hourly);

      final cachedWeather = await storageService.getCachedWeather();
      final cachedHourly = await storageService.getCachedHourlyForecast();
      final lastUpdate = await storageService.getLastUpdate();

      expect(cachedWeather, isNotNull);
      expect(cachedWeather!.cityName, weather.cityName);
      expect(cachedWeather.temperature, weather.temperature);
      expect(cachedHourly, hasLength(2));
      expect(cachedHourly.first.temperature, 30);
      expect(lastUpdate, isNotNull);
    });

    test('returns false when cache is missing or expired', () async {
      expect(await storageService.isCacheValid(), isFalse);

      SharedPreferences.setMockInitialValues({
        'last_update': DateTime.now()
            .subtract(const Duration(minutes: 31))
            .millisecondsSinceEpoch,
      });
      storageService = StorageService();

      expect(await storageService.isCacheValid(), isFalse);
    });

    test('returns true when cache timestamp is still fresh', () async {
      SharedPreferences.setMockInitialValues({
        'last_update': DateTime.now()
            .subtract(const Duration(minutes: 10))
            .millisecondsSinceEpoch,
      });
      storageService = StorageService();

      expect(await storageService.isCacheValid(), isTrue);
    });
  });
}
