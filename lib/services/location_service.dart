import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:weather_app/models/location_model.dart';
import 'package:weather_app/utils/app_exception.dart';

class LocationService {
  Future<bool> isLocationServiceEnabled() {
    return Geolocator.isLocationServiceEnabled();
  }

  Future<LocationPermission> getPermissionStatus() {
    return Geolocator.checkPermission();
  }

  Future<LocationPermission> requestPermission() {
    return Geolocator.requestPermission();
  }

  Future<bool> openAppSettings() {
    return Geolocator.openAppSettings();
  }

  Future<bool> openLocationSettings() {
    return Geolocator.openLocationSettings();
  }

  Future<Position> getCurrentLocation() async {
    final serviceEnabled = await isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw const AppException('Location service is disabled.');
    }

    var permission = await getPermissionStatus();
    if (permission == LocationPermission.denied) {
      permission = await requestPermission();
    }

    if (permission == LocationPermission.denied) {
      throw const AppException('Location permission denied.');
    }

    if (permission == LocationPermission.deniedForever) {
      throw const AppException(
        'Location permission denied forever. Open settings to enable it.',
      );
    }

    return Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  Future<LocationModel> reverseGeocode(double latitude, double longitude) async {
    try {
      final placemarks = await placemarkFromCoordinates(latitude, longitude);
      final placemark = placemarks.isNotEmpty ? placemarks.first : null;

      return LocationModel(
        latitude: latitude,
        longitude: longitude,
        city: placemark?.locality ??
            placemark?.subAdministrativeArea ??
            placemark?.administrativeArea ??
            'Unknown',
        country: placemark?.country ?? '',
      );
    } catch (_) {
      return LocationModel(
        latitude: latitude,
        longitude: longitude,
        city: 'Unknown',
        country: '',
      );
    }
  }
}
