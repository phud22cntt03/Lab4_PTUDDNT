import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:weather_app/models/hourly_weather_model.dart';
import 'package:weather_app/models/weather_model.dart';

class StorageService {
  static const String _weatherKey = 'cached_weather';
  static const String _hourlyForecastKey = 'cached_hourly_forecast';
  static const String _lastUpdateKey = 'last_update';
  static const String _favoriteCitiesKey = 'favorite_cities';
  static const String _recentSearchesKey = 'recent_searches';
  static const String _temperatureUnitKey = 'temperature_unit';
  static const String _windSpeedUnitKey = 'wind_speed_unit';
  static const String _timeFormatKey = 'time_format';

  Future<void> saveWeatherData(
    WeatherModel weather,
    List<HourlyWeatherModel> hourlyForecast,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(_weatherKey, jsonEncode(weather.toJson()));
    await prefs.setString(
      _hourlyForecastKey,
      jsonEncode(hourlyForecast.map((item) => item.toJson()).toList()),
    );
    await prefs.setInt(_lastUpdateKey, DateTime.now().millisecondsSinceEpoch);
  }

  Future<WeatherModel?> getCachedWeather() async {
    final prefs = await SharedPreferences.getInstance();
    final weatherJson = prefs.getString(_weatherKey);
    if (weatherJson == null || weatherJson.isEmpty) {
      return null;
    }

    return WeatherModel.fromJson(jsonDecode(weatherJson) as Map<String, dynamic>);
  }

  Future<List<HourlyWeatherModel>> getCachedHourlyForecast() async {
    final prefs = await SharedPreferences.getInstance();
    final rawJson = prefs.getString(_hourlyForecastKey);
    if (rawJson == null || rawJson.isEmpty) {
      return [];
    }

    final list = jsonDecode(rawJson) as List<dynamic>;
    return list
        .cast<Map<String, dynamic>>()
        .map(HourlyWeatherModel.fromJson)
        .toList();
  }

  Future<bool> isCacheValid() async {
    final lastUpdate = await getLastUpdate();
    if (lastUpdate == null) {
      return false;
    }

    return DateTime.now().difference(lastUpdate) < const Duration(minutes: 30);
  }

  Future<DateTime?> getLastUpdate() async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getInt(_lastUpdateKey);
    if (timestamp == null) {
      return null;
    }
    return DateTime.fromMillisecondsSinceEpoch(timestamp);
  }

  Future<List<String>> getFavoriteCities() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_favoriteCitiesKey) ?? <String>[];
  }

  Future<void> saveFavoriteCities(List<String> cities) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_favoriteCitiesKey, cities);
  }

  Future<List<String>> getRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_recentSearchesKey) ?? <String>[];
  }

  Future<void> saveRecentSearches(List<String> searches) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_recentSearchesKey, searches);
  }

  Future<void> saveTemperatureUnit(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_temperatureUnitKey, value);
  }

  Future<String?> getTemperatureUnit() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_temperatureUnitKey);
  }

  Future<void> saveWindSpeedUnit(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_windSpeedUnitKey, value);
  }

  Future<String?> getWindSpeedUnit() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_windSpeedUnitKey);
  }

  Future<void> saveTimeFormat(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_timeFormatKey, value);
  }

  Future<String?> getTimeFormat() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_timeFormatKey);
  }
}
