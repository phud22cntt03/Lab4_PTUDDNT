import 'package:flutter_test/flutter_test.dart';
import 'package:weather_app/models/weather_model.dart';

void main() {
  group('WeatherModel', () {
    test('parses current weather JSON correctly', () {
      final json = <String, dynamic>{
        'name': 'Ho Chi Minh City',
        'dt': 1735722000,
        'visibility': 10000,
        'coord': {'lat': 10.8231, 'lon': 106.6297},
        'sys': {
          'country': 'VN',
          'sunrise': 1735682400,
          'sunset': 1735725600,
        },
        'main': {
          'temp': 25.0,
          'feels_like': 27.0,
          'humidity': 78,
          'pressure': 1009,
          'temp_min': 24.0,
          'temp_max': 30.0,
        },
        'wind': {'speed': 3.2, 'deg': 120},
        'clouds': {'all': 25},
        'weather': [
          {
            'description': 'clear sky',
            'icon': '01d',
            'main': 'Clear',
          }
        ],
      };

      final weather = WeatherModel.fromJson(json);

      expect(weather.cityName, 'Ho Chi Minh City');
      expect(weather.country, 'VN');
      expect(weather.temperature, 25.0);
      expect(weather.feelsLike, 27.0);
      expect(weather.humidity, 78);
      expect(weather.windSpeed, 3.2);
      expect(weather.mainCondition, 'Clear');
      expect(weather.visibility, 10000);
      expect(weather.cloudiness, 25);
    });
  });
}
