import 'package:flutter_test/flutter_test.dart';
import 'package:weather_app/providers/settings_provider.dart';
import 'package:weather_app/services/storage_service.dart';

class _FakeStorageService extends StorageService {
  String? storedTemperatureUnit;
  String? storedWindSpeedUnit;
  String? storedTimeFormat;

  String? savedTemperatureUnit;
  String? savedWindSpeedUnit;
  String? savedTimeFormat;

  @override
  Future<String?> getTemperatureUnit() async => storedTemperatureUnit;

  @override
  Future<String?> getWindSpeedUnit() async => storedWindSpeedUnit;

  @override
  Future<String?> getTimeFormat() async => storedTimeFormat;

  @override
  Future<void> saveTemperatureUnit(String value) async {
    savedTemperatureUnit = value;
  }

  @override
  Future<void> saveWindSpeedUnit(String value) async {
    savedWindSpeedUnit = value;
  }

  @override
  Future<void> saveTimeFormat(String value) async {
    savedTimeFormat = value;
  }
}

void main() {
  group('SettingsProvider', () {
    test('loads persisted settings and falls back for invalid values',
        () async {
      final storage = _FakeStorageService()
        ..storedTemperatureUnit = 'fahrenheit'
        ..storedWindSpeedUnit = 'invalid'
        ..storedTimeFormat = 'h12';
      final provider = SettingsProvider(storage);
      var notifyCount = 0;
      provider.addListener(() => notifyCount++);

      await provider.loadSettings();

      expect(provider.temperatureUnit, TemperatureUnit.fahrenheit);
      expect(provider.windSpeedUnit, WindSpeedUnit.ms);
      expect(provider.clockFormat, ClockFormat.h12);
      expect(provider.use24HourFormat, isFalse);
      expect(notifyCount, 1);
    });

    test('converts and persists temperature unit changes', () async {
      final storage = _FakeStorageService();
      final provider = SettingsProvider(storage);

      await provider.setTemperatureUnit(TemperatureUnit.fahrenheit);

      expect(provider.displayTemperature(25), closeTo(77, 0.001));
      expect(provider.temperatureUnitLabel(), '°F');
      expect(storage.savedTemperatureUnit, 'fahrenheit');
    });

    test('converts and labels wind speed for each configured unit', () async {
      final storage = _FakeStorageService();
      final provider = SettingsProvider(storage);

      expect(provider.displayWindSpeed(5), 5);
      expect(provider.windSpeedUnitLabel(), 'm/s');

      await provider.setWindSpeedUnit(WindSpeedUnit.kmh);
      expect(provider.displayWindSpeed(5), closeTo(18, 0.001));
      expect(provider.windSpeedUnitLabel(), 'km/h');
      expect(storage.savedWindSpeedUnit, 'kmh');

      await provider.setWindSpeedUnit(WindSpeedUnit.mph);
      expect(provider.displayWindSpeed(5), closeTo(11.1847, 0.0001));
      expect(provider.windSpeedUnitLabel(), 'mph');
      expect(storage.savedWindSpeedUnit, 'mph');
    });
  });
}
