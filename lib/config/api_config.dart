import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:weather_app/utils/app_exception.dart';

class ApiConfig {
  ApiConfig._();

  static const String baseUrl = 'https://api.openweathermap.org/data/2.5';
  static const String currentWeather = '/weather';
  static const String forecast = '/forecast';
  static const Duration requestTimeout = Duration(seconds: 15);

  static String get apiKey {
    const keyFromDefine = String.fromEnvironment('OPENWEATHER_API_KEY');
    if (keyFromDefine.isNotEmpty) {
      return keyFromDefine;
    }

    final keyFromEnv = dotenv.env['OPENWEATHER_API_KEY'] ?? '';
    return keyFromEnv;
  }

  static Uri buildUri(String endpoint, Map<String, dynamic> params) {
    if (apiKey.isEmpty) {
      throw const AppException(
        'Missing API key. Add OPENWEATHER_API_KEY to .env or pass --dart-define=OPENWEATHER_API_KEY=your_key.',
      );
    }

    final queryParameters = <String, String>{
      for (final entry in params.entries) entry.key: '${entry.value}',
      'appid': apiKey,
      'units': 'metric',
    };

    return Uri.parse('$baseUrl$endpoint').replace(
      queryParameters: queryParameters,
    );
  }
}
