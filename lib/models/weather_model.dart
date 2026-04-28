class WeatherModel {
  const WeatherModel({
    required this.cityName,
    required this.country,
    required this.temperature,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.pressure,
    required this.description,
    required this.icon,
    required this.mainCondition,
    required this.dateTime,
    required this.sunrise,
    required this.sunset,
    required this.latitude,
    required this.longitude,
    this.tempMin,
    this.tempMax,
    this.visibility,
    this.cloudiness,
    this.windDegree,
  });

  final String cityName;
  final String country;
  final double temperature;
  final double feelsLike;
  final int humidity;
  final double windSpeed;
  final int pressure;
  final String description;
  final String icon;
  final String mainCondition;
  final DateTime dateTime;
  final DateTime sunrise;
  final DateTime sunset;
  final double latitude;
  final double longitude;
  final double? tempMin;
  final double? tempMax;
  final int? visibility;
  final int? cloudiness;
  final int? windDegree;

  bool get isNightTime {
    return dateTime.isBefore(sunrise) || dateTime.isAfter(sunset);
  }

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    final main = json['main'] as Map<String, dynamic>? ?? {};
    final weather = (json['weather'] as List<dynamic>? ?? [])
        .cast<Map<String, dynamic>>();
    final wind = json['wind'] as Map<String, dynamic>? ?? {};
    final sys = json['sys'] as Map<String, dynamic>? ?? {};
    final coord = json['coord'] as Map<String, dynamic>? ?? {};
    final clouds = json['clouds'] as Map<String, dynamic>? ?? {};

    return WeatherModel(
      cityName: json['name'] as String? ?? 'Unknown',
      country: sys['country'] as String? ?? '',
      temperature: (main['temp'] as num?)?.toDouble() ?? 0,
      feelsLike: (main['feels_like'] as num?)?.toDouble() ?? 0,
      humidity: (main['humidity'] as num?)?.toInt() ?? 0,
      windSpeed: (wind['speed'] as num?)?.toDouble() ?? 0,
      pressure: (main['pressure'] as num?)?.toInt() ?? 0,
      description: weather.isNotEmpty
          ? weather.first['description'] as String? ?? ''
          : '',
      icon: weather.isNotEmpty ? weather.first['icon'] as String? ?? '' : '',
      mainCondition: weather.isNotEmpty
          ? weather.first['main'] as String? ?? 'Clear'
          : 'Clear',
      dateTime: DateTime.fromMillisecondsSinceEpoch(
        ((json['dt'] as num?)?.toInt() ?? 0) * 1000,
      ),
      sunrise: DateTime.fromMillisecondsSinceEpoch(
        ((sys['sunrise'] as num?)?.toInt() ?? 0) * 1000,
      ),
      sunset: DateTime.fromMillisecondsSinceEpoch(
        ((sys['sunset'] as num?)?.toInt() ?? 0) * 1000,
      ),
      latitude: (coord['lat'] as num?)?.toDouble() ?? 0,
      longitude: (coord['lon'] as num?)?.toDouble() ?? 0,
      tempMin: (main['temp_min'] as num?)?.toDouble(),
      tempMax: (main['temp_max'] as num?)?.toDouble(),
      visibility: (json['visibility'] as num?)?.toInt(),
      cloudiness: (clouds['all'] as num?)?.toInt(),
      windDegree: (wind['deg'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': cityName,
      'sys': {
        'country': country,
        'sunrise': sunrise.millisecondsSinceEpoch ~/ 1000,
        'sunset': sunset.millisecondsSinceEpoch ~/ 1000,
      },
      'coord': {
        'lat': latitude,
        'lon': longitude,
      },
      'main': {
        'temp': temperature,
        'feels_like': feelsLike,
        'humidity': humidity,
        'pressure': pressure,
        'temp_min': tempMin,
        'temp_max': tempMax,
      },
      'wind': {
        'speed': windSpeed,
        'deg': windDegree,
      },
      'weather': [
        {
          'description': description,
          'icon': icon,
          'main': mainCondition,
        }
      ],
      'dt': dateTime.millisecondsSinceEpoch ~/ 1000,
      'visibility': visibility,
      'clouds': {'all': cloudiness},
    };
  }
}
