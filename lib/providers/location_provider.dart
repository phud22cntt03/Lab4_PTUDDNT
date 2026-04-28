import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:weather_app/services/location_service.dart';

enum LocationStatus {
  initial,
  checking,
  granted,
  denied,
  deniedForever,
  serviceDisabled,
}

class LocationProvider extends ChangeNotifier {
  LocationProvider(this._locationService);

  final LocationService _locationService;

  LocationStatus _status = LocationStatus.initial;
  String _message = '';

  LocationStatus get status => _status;
  String get message => _message;

  Future<void> refreshStatus() async {
    _status = LocationStatus.checking;
    notifyListeners();

    final serviceEnabled = await _locationService.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _status = LocationStatus.serviceDisabled;
      _message = 'Location service is disabled.';
      notifyListeners();
      return;
    }

    final permission = await _locationService.getPermissionStatus();
    _setFromPermission(permission);
  }

  Future<void> requestAccess() async {
    _status = LocationStatus.checking;
    notifyListeners();

    final permission = await _locationService.requestPermission();
    _setFromPermission(permission);
  }

  Future<void> openAppSettings() async {
    await _locationService.openAppSettings();
  }

  Future<void> openLocationSettings() async {
    await _locationService.openLocationSettings();
  }

  void _setFromPermission(LocationPermission permission) {
    if (permission == LocationPermission.denied) {
      _status = LocationStatus.denied;
      _message = 'Location permission denied.';
    } else if (permission == LocationPermission.deniedForever) {
      _status = LocationStatus.deniedForever;
      _message = 'Location permission denied forever.';
    } else {
      _status = LocationStatus.granted;
      _message = '';
    }
    notifyListeners();
  }
}
