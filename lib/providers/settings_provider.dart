import 'package:flutter/material.dart';
import 'package:weather_app/services/storage_service.dart';

enum TemperatureUnit { celsius, fahrenheit }
enum WindSpeedUnit { ms, kmh, mph }
enum ClockFormat { h12, h24 }

class SettingsProvider extends ChangeNotifier {
  SettingsProvider(this._storageService);

  final StorageService _storageService;

  TemperatureUnit _temperatureUnit = TemperatureUnit.celsius;
  WindSpeedUnit _windSpeedUnit = WindSpeedUnit.ms;
  ClockFormat _clockFormat = ClockFormat.h24;

  TemperatureUnit get temperatureUnit => _temperatureUnit;
  WindSpeedUnit get windSpeedUnit => _windSpeedUnit;
  ClockFormat get clockFormat => _clockFormat;

  bool get use24HourFormat => _clockFormat == ClockFormat.h24;

  Future<void> loadSettings() async {
    final temperatureUnit = await _storageService.getTemperatureUnit();
    final windSpeedUnit = await _storageService.getWindSpeedUnit();
    final timeFormat = await _storageService.getTimeFormat();

    _temperatureUnit = TemperatureUnit.values.firstWhere(
      (value) => value.name == temperatureUnit,
      orElse: () => TemperatureUnit.celsius,
    );
    _windSpeedUnit = WindSpeedUnit.values.firstWhere(
      (value) => value.name == windSpeedUnit,
      orElse: () => WindSpeedUnit.ms,
    );
    _clockFormat = ClockFormat.values.firstWhere(
      (value) => value.name == timeFormat,
      orElse: () => ClockFormat.h24,
    );
    notifyListeners();
  }

  Future<void> setTemperatureUnit(TemperatureUnit value) async {
    _temperatureUnit = value;
    notifyListeners();
    await _storageService.saveTemperatureUnit(value.name);
  }

  Future<void> setWindSpeedUnit(WindSpeedUnit value) async {
    _windSpeedUnit = value;
    notifyListeners();
    await _storageService.saveWindSpeedUnit(value.name);
  }

  Future<void> setClockFormat(ClockFormat value) async {
    _clockFormat = value;
    notifyListeners();
    await _storageService.saveTimeFormat(value.name);
  }

  double displayTemperature(double celsius) {
    if (_temperatureUnit == TemperatureUnit.fahrenheit) {
      return (celsius * 9 / 5) + 32;
    }
    return celsius;
  }

  String temperatureUnitLabel() {
    return _temperatureUnit == TemperatureUnit.fahrenheit ? '°F' : '°C';
  }

  double displayWindSpeed(double metersPerSecond) {
    switch (_windSpeedUnit) {
      case WindSpeedUnit.ms:
        return metersPerSecond;
      case WindSpeedUnit.kmh:
        return metersPerSecond * 3.6;
      case WindSpeedUnit.mph:
        return metersPerSecond * 2.23694;
    }
  }

  String windSpeedUnitLabel() {
    switch (_windSpeedUnit) {
      case WindSpeedUnit.ms:
        return 'm/s';
      case WindSpeedUnit.kmh:
        return 'km/h';
      case WindSpeedUnit.mph:
        return 'mph';
    }
  }
}
