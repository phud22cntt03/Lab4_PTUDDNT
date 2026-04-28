import 'dart:async';

import 'package:flutter/material.dart';
import 'package:weather_app/models/forecast_model.dart';
import 'package:weather_app/models/hourly_weather_model.dart';
import 'package:weather_app/models/weather_model.dart';
import 'package:weather_app/services/connectivity_service.dart';
import 'package:weather_app/services/location_service.dart';
import 'package:weather_app/services/storage_service.dart';
import 'package:weather_app/services/weather_service.dart';
import 'package:weather_app/utils/app_exception.dart';

enum WeatherState { initial, loading, loaded, error }

class WeatherProvider extends ChangeNotifier {
  WeatherProvider(
    this._weatherService,
    this._locationService,
    this._storageService,
    this._connectivityService,
  ) {
    _connectivitySubscription = _connectivityService.onConnectivityChanged.listen(
      (connected) {
        _hasConnection = connected;
        if (connected && _isShowingCachedData) {
          refreshWeather(silent: true);
        }
        notifyListeners();
      },
    );
  }

  final WeatherService _weatherService;
  final LocationService _locationService;
  final StorageService _storageService;
  final ConnectivityService _connectivityService;

  late final StreamSubscription<bool> _connectivitySubscription;

  WeatherModel? _currentWeather;
  List<HourlyWeatherModel> _hourlyForecast = <HourlyWeatherModel>[];
  List<ForecastModel> _dailyForecast = <ForecastModel>[];
  List<String> _favoriteCities = <String>[];
  List<String> _recentSearches = <String>[];
  WeatherState _state = WeatherState.initial;
  String _errorMessage = '';
  bool _isShowingCachedData = false;
  bool _hasConnection = true;
  bool _initialized = false;
  bool _lastFetchUsedLocation = true;
  String? _lastCityQuery;
  DateTime? _lastUpdated;

  WeatherModel? get currentWeather => _currentWeather;
  List<HourlyWeatherModel> get hourlyForecast => _hourlyForecast.take(8).toList();
  List<ForecastModel> get dailyForecast => _dailyForecast;
  List<String> get favoriteCities => _favoriteCities;
  List<String> get recentSearches => _recentSearches;
  WeatherState get state => _state;
  String get errorMessage => _errorMessage;
  bool get isShowingCachedData => _isShowingCachedData;
  bool get hasConnection => _hasConnection;
  DateTime? get lastUpdated => _lastUpdated;

  Future<void> initializeWeather() async {
    if (_initialized) {
      return;
    }
    _initialized = true;

    _favoriteCities = await _storageService.getFavoriteCities();
    _recentSearches = await _storageService.getRecentSearches();
    _hasConnection = await _connectivityService.hasConnection();

    await loadCachedWeather(notify: false);

    if (_currentWeather == null || !(await _storageService.isCacheValid())) {
      await fetchWeatherByLocation();
    } else {
      notifyListeners();
      if (_hasConnection) {
        refreshWeather(silent: true);
      }
    }
  }

  Future<void> fetchWeatherByCity(
    String cityName, {
    bool saveToHistory = true,
    bool showLoading = true,
  }) async {
    final query = cityName.trim();
    if (query.isEmpty) {
      _state = WeatherState.error;
      _errorMessage = 'Please enter a city name.';
      notifyListeners();
      return;
    }

    if (showLoading) {
      _state = WeatherState.loading;
      notifyListeners();
    }

    _hasConnection = await _connectivityService.hasConnection();
    if (!_hasConnection) {
      await _loadFallback('No internet connection. Showing cached data if available.');
      return;
    }

    try {
      final weather = await _weatherService.getCurrentWeatherByCity(query);
      final hourly = await _weatherService.getHourlyForecastByCity(query);
      await _applyLoadedWeather(weather, hourly);
      _lastFetchUsedLocation = false;
      _lastCityQuery = weather.cityName;

      if (saveToHistory) {
        await _saveRecentSearch(weather.cityName);
      }
    } on AppException catch (error) {
      await _loadFallback(error.message);
    } catch (_) {
      await _loadFallback('Unexpected error while loading weather.');
    }
  }

  Future<void> fetchWeatherByLocation({bool showLoading = true}) async {
    if (showLoading) {
      _state = WeatherState.loading;
      notifyListeners();
    }

    _hasConnection = await _connectivityService.hasConnection();
    if (!_hasConnection) {
      await _loadFallback('No internet connection. Showing cached data if available.');
      return;
    }

    try {
      final position = await _locationService.getCurrentLocation();
      final weather = await _weatherService.getCurrentWeatherByCoordinates(
        position.latitude,
        position.longitude,
      );
      final hourly = await _weatherService.getHourlyForecastByCoordinates(
        position.latitude,
        position.longitude,
      );

      await _applyLoadedWeather(weather, hourly);
      _lastFetchUsedLocation = true;
      _lastCityQuery = weather.cityName;
    } on AppException catch (error) {
      await _loadFallback(error.message);
    } catch (_) {
      await _loadFallback('Unable to load weather for your current location.');
    }
  }

  Future<void> refreshWeather({bool silent = false}) async {
    if (_lastFetchUsedLocation) {
      await fetchWeatherByLocation(showLoading: !silent);
    } else if (_lastCityQuery != null) {
      await fetchWeatherByCity(
        _lastCityQuery!,
        saveToHistory: false,
        showLoading: !silent,
      );
    } else {
      await fetchWeatherByLocation(showLoading: !silent);
    }
  }

  Future<void> loadCachedWeather({bool notify = true}) async {
    final cachedWeather = await _storageService.getCachedWeather();
    final cachedHourly = await _storageService.getCachedHourlyForecast();
    final lastUpdate = await _storageService.getLastUpdate();

    if (cachedWeather == null) {
      return;
    }

    _currentWeather = cachedWeather;
    _hourlyForecast = cachedHourly;
    _dailyForecast = ForecastModel.fromHourlyList(cachedHourly);
    _lastUpdated = lastUpdate;
    _isShowingCachedData = true;
    _state = WeatherState.loaded;
    _lastFetchUsedLocation = false;
    _lastCityQuery = cachedWeather.cityName;

    if (notify) {
      notifyListeners();
    }
  }

  Future<void> toggleFavoriteCity(String cityName) async {
    final normalized = cityName.trim();
    if (normalized.isEmpty) {
      return;
    }

    final index = _favoriteCities.indexWhere(
      (city) => city.toLowerCase() == normalized.toLowerCase(),
    );

    if (index >= 0) {
      _favoriteCities.removeAt(index);
    } else {
      if (_favoriteCities.length >= 5) {
        _favoriteCities.removeAt(0);
      }
      _favoriteCities.add(normalized);
    }

    await _storageService.saveFavoriteCities(_favoriteCities);
    notifyListeners();
  }

  bool isFavorite(String cityName) {
    return _favoriteCities.any(
      (city) => city.toLowerCase() == cityName.trim().toLowerCase(),
    );
  }

  Future<void> _applyLoadedWeather(
    WeatherModel weather,
    List<HourlyWeatherModel> hourly,
  ) async {
    _currentWeather = weather;
    _hourlyForecast = hourly;
    _dailyForecast = ForecastModel.fromHourlyList(hourly);
    _state = WeatherState.loaded;
    _errorMessage = '';
    _isShowingCachedData = false;
    _lastUpdated = DateTime.now();

    await _storageService.saveWeatherData(weather, hourly);
    notifyListeners();
  }

  Future<void> _loadFallback(String message) async {
    await loadCachedWeather(notify: false);

    if (_currentWeather != null) {
      _state = WeatherState.loaded;
      _errorMessage = message;
      _isShowingCachedData = true;
    } else {
      _state = WeatherState.error;
      _errorMessage = message;
    }

    notifyListeners();
  }

  Future<void> _saveRecentSearch(String cityName) async {
    final updated = <String>[
      cityName,
      ..._recentSearches.where(
        (item) => item.toLowerCase() != cityName.toLowerCase(),
      ),
    ].take(10).toList();

    _recentSearches = updated;
    await _storageService.saveRecentSearches(updated);
    notifyListeners();
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }
}
