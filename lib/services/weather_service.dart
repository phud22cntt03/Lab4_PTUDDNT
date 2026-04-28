import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:weather_app/config/api_config.dart';
import 'package:weather_app/models/hourly_weather_model.dart';
import 'package:weather_app/models/weather_model.dart';
import 'package:weather_app/utils/app_exception.dart';

class WeatherService {
  WeatherService({
    http.Client? httpClient,
    this.apiKeyOverride,
  }) : _httpClient = httpClient ?? http.Client();

  final http.Client _httpClient;
  final String? apiKeyOverride;

  Future<WeatherModel> getCurrentWeatherByCity(String cityName) async {
    final uri = _buildUri(ApiConfig.currentWeather, {'q': cityName});
    final json = await _getJson(uri);
    return WeatherModel.fromJson(json);
  }

  Future<WeatherModel> getCurrentWeatherByCoordinates(
    double latitude,
    double longitude,
  ) async {
    final uri = _buildUri(
      ApiConfig.currentWeather,
      {'lat': latitude, 'lon': longitude},
    );
    final json = await _getJson(uri);
    return WeatherModel.fromJson(json);
  }

  Future<List<HourlyWeatherModel>> getHourlyForecastByCity(String cityName) async {
    final uri = _buildUri(ApiConfig.forecast, {'q': cityName});
    final json = await _getJson(uri);
    return _parseHourlyForecast(json);
  }

  Future<List<HourlyWeatherModel>> getHourlyForecastByCoordinates(
    double latitude,
    double longitude,
  ) async {
    final uri = _buildUri(
      ApiConfig.forecast,
      {'lat': latitude, 'lon': longitude},
    );
    final json = await _getJson(uri);
    return _parseHourlyForecast(json);
  }

  String getIconUrl(String iconCode, {int scale = 4}) {
    return 'https://openweathermap.org/img/wn/$iconCode@${scale}x.png';
  }

  List<HourlyWeatherModel> _parseHourlyForecast(Map<String, dynamic> json) {
    final list = json['list'] as List<dynamic>? ?? <dynamic>[];
    return list
        .cast<Map<String, dynamic>>()
        .map(HourlyWeatherModel.fromJson)
        .toList();
  }

  Uri _buildUri(String endpoint, Map<String, dynamic> params) {
    final apiKey = apiKeyOverride ?? ApiConfig.apiKey;
    if (apiKey.isEmpty) {
      throw const AppException(
        'Missing API key. Run the app with --dart-define=OPENWEATHER_API_KEY=your_key.',
      );
    }

    final queryParameters = <String, String>{
      for (final entry in params.entries) entry.key: '${entry.value}',
      'appid': apiKey,
      'units': 'metric',
    };

    return Uri.parse('${ApiConfig.baseUrl}$endpoint').replace(
      queryParameters: queryParameters,
    );
  }

  Future<Map<String, dynamic>> _getJson(Uri uri) async {
    http.Response response;
    try {
      response = await _httpClient.get(uri).timeout(ApiConfig.requestTimeout);
    } on TimeoutException {
      throw const AppException('Network timeout. Please try again.');
    } on Exception {
      throw const AppException('Unable to connect. Check your internet connection.');
    }

    final body = response.body.isEmpty ? '{}' : response.body;
    final decoded = jsonDecode(body) as Map<String, dynamic>;

    switch (response.statusCode) {
      case 200:
        return decoded;
      case 401:
        throw const AppException('Invalid API key. Check your OpenWeatherMap key.');
      case 404:
        throw const AppException('City not found. Please try another city.');
      case 429:
        throw const AppException(
          'API rate limit exceeded. Showing cached data if available.',
        );
      default:
        final message = decoded['message'] as String?;
        throw AppException(message ?? 'Failed to load weather data.');
    }
  }
}
