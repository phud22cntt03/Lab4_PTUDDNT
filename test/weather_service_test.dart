import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:weather_app/services/weather_service.dart';
import 'package:weather_app/utils/app_exception.dart';
import 'dart:async';

void main() {
  group('WeatherService', () {
    test('parses weather response correctly', () async {
      final client = MockClient((request) async {
        return http.Response(
          '''
          {
            "name": "Ho Chi Minh City",
            "dt": 1735722000,
            "visibility": 10000,
            "coord": {"lat": 10.8231, "lon": 106.6297},
            "sys": {"country": "VN", "sunrise": 1735682400, "sunset": 1735725600},
            "main": {
              "temp": 25.0,
              "feels_like": 27.0,
              "humidity": 78,
              "pressure": 1009,
              "temp_min": 24.0,
              "temp_max": 30.0
            },
            "wind": {"speed": 3.2, "deg": 120},
            "clouds": {"all": 25},
            "weather": [{"description": "clear sky", "icon": "01d", "main": "Clear"}]
          }
          ''',
          200,
        );
      });

      final service = WeatherService(
        httpClient: client,
        apiKeyOverride: 'test-key',
      );

      final weather = await service.getCurrentWeatherByCity('Ho Chi Minh City');

      expect(weather.cityName, 'Ho Chi Minh City');
      expect(weather.temperature, 25.0);
      expect(weather.mainCondition, 'Clear');
    });

    test('throws friendly exception on invalid city', () async {
      final client = MockClient((request) async {
        return http.Response('{"message":"city not found"}', 404);
      });

      final service = WeatherService(
        httpClient: client,
        apiKeyOverride: 'test-key',
      );

      expect(
        () => service.getCurrentWeatherByCity('InvalidCity'),
        throwsA(isA<AppException>()),
      );
    });

    test('parses hourly forecast entries correctly', () async {
      final client = MockClient((request) async {
        return http.Response(
          '''
          {
            "list": [
              {
                "dt": 1735722000,
                "main": {
                  "temp": 25.0,
                  "temp_min": 24.0,
                  "temp_max": 26.0,
                  "humidity": 78
                },
                "wind": {"speed": 3.2},
                "weather": [{"description": "clear sky", "icon": "01d", "main": "Clear"}],
                "pop": 0.15
              }
            ]
          }
          ''',
          200,
        );
      });

      final service = WeatherService(
        httpClient: client,
        apiKeyOverride: 'test-key',
      );

      final forecast =
          await service.getHourlyForecastByCity('Ho Chi Minh City');

      expect(forecast, hasLength(1));
      expect(forecast.first.temperature, 25.0);
      expect(forecast.first.precipitationProbability, 15.0);
      expect(forecast.first.mainCondition, 'Clear');
    });

    test('maps unauthorized responses to a friendly API key error', () async {
      final client = MockClient((request) async {
        return http.Response('{"message":"Invalid API key"}', 401);
      });

      final service = WeatherService(
        httpClient: client,
        apiKeyOverride: 'test-key',
      );

      expect(
        () => service.getCurrentWeatherByCity('Ho Chi Minh City'),
        throwsA(
          isA<AppException>().having(
            (error) => error.message,
            'message',
            'Invalid API key. Check your OpenWeatherMap key.',
          ),
        ),
      );
    });

    test('maps timeout failures to a retryable error message', () async {
      final client = MockClient((request) async {
        throw TimeoutException('request timed out');
      });

      final service = WeatherService(
        httpClient: client,
        apiKeyOverride: 'test-key',
      );

      expect(
        () => service.getCurrentWeatherByCity('Ho Chi Minh City'),
        throwsA(
          isA<AppException>().having(
            (error) => error.message,
            'message',
            'Network timeout. Please try again.',
          ),
        ),
      );
    });

    test('builds icon URLs with the expected scale suffix', () {
      final service = WeatherService(apiKeyOverride: 'test-key');

      expect(
        service.getIconUrl('10d', scale: 2),
        'https://openweathermap.org/img/wn/10d@2x.png',
      );
    });
  });
}
