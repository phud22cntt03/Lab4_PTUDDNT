import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:weather_app/providers/location_provider.dart';
import 'package:weather_app/services/location_service.dart';

class _FakeLocationService extends LocationService {
  bool serviceEnabled = true;
  LocationPermission permission = LocationPermission.denied;
  LocationPermission requestResult = LocationPermission.denied;
  var openedAppSettings = false;
  var openedLocationSettings = false;

  @override
  Future<bool> isLocationServiceEnabled() async => serviceEnabled;

  @override
  Future<LocationPermission> getPermissionStatus() async => permission;

  @override
  Future<LocationPermission> requestPermission() async => requestResult;

  @override
  Future<bool> openAppSettings() async {
    openedAppSettings = true;
    return true;
  }

  @override
  Future<bool> openLocationSettings() async {
    openedLocationSettings = true;
    return true;
  }
}

void main() {
  group('LocationProvider', () {
    test('reports service disabled when location service is off', () async {
      final service = _FakeLocationService()..serviceEnabled = false;
      final provider = LocationProvider(service);

      await provider.refreshStatus();

      expect(provider.status, LocationStatus.serviceDisabled);
      expect(provider.message, 'Location service is disabled.');
    });

    test('maps denied forever permission to provider state', () async {
      final service = _FakeLocationService()
        ..permission = LocationPermission.deniedForever;
      final provider = LocationProvider(service);

      await provider.refreshStatus();

      expect(provider.status, LocationStatus.deniedForever);
      expect(provider.message, 'Location permission denied forever.');
    });

    test('requestAccess sets granted state after permission approval',
        () async {
      final service = _FakeLocationService()
        ..requestResult = LocationPermission.whileInUse;
      final provider = LocationProvider(service);

      await provider.requestAccess();

      expect(provider.status, LocationStatus.granted);
      expect(provider.message, isEmpty);
    });

    test('delegates settings actions to the service', () async {
      final service = _FakeLocationService();
      final provider = LocationProvider(service);

      await provider.openAppSettings();
      await provider.openLocationSettings();

      expect(service.openedAppSettings, isTrue);
      expect(service.openedLocationSettings, isTrue);
    });
  });
}
