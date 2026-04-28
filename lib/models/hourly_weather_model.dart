class HourlyWeatherModel {
  const HourlyWeatherModel({
    required this.dateTime,
    required this.temperature,
    required this.tempMin,
    required this.tempMax,
    required this.description,
    required this.icon,
    required this.mainCondition,
    required this.humidity,
    required this.windSpeed,
    required this.precipitationProbability,
  });

  final DateTime dateTime;
  final double temperature;
  final double tempMin;
  final double tempMax;
  final String description;
  final String icon;
  final String mainCondition;
  final int humidity;
  final double windSpeed;
  final double precipitationProbability;

  factory HourlyWeatherModel.fromJson(Map<String, dynamic> json) {
    final main = json['main'] as Map<String, dynamic>? ?? {};
    final weather = (json['weather'] as List<dynamic>? ?? [])
        .cast<Map<String, dynamic>>();
    final wind = json['wind'] as Map<String, dynamic>? ?? {};

    return HourlyWeatherModel(
      dateTime: DateTime.fromMillisecondsSinceEpoch(
        ((json['dt'] as num?)?.toInt() ?? 0) * 1000,
      ),
      temperature: (main['temp'] as num?)?.toDouble() ?? 0,
      tempMin: (main['temp_min'] as num?)?.toDouble() ?? 0,
      tempMax: (main['temp_max'] as num?)?.toDouble() ?? 0,
      description: weather.isNotEmpty
          ? weather.first['description'] as String? ?? ''
          : '',
      icon: weather.isNotEmpty ? weather.first['icon'] as String? ?? '' : '',
      mainCondition: weather.isNotEmpty
          ? weather.first['main'] as String? ?? 'Clear'
          : 'Clear',
      humidity: (main['humidity'] as num?)?.toInt() ?? 0,
      windSpeed: (wind['speed'] as num?)?.toDouble() ?? 0,
      precipitationProbability: ((json['pop'] as num?)?.toDouble() ?? 0) * 100,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dt': dateTime.millisecondsSinceEpoch ~/ 1000,
      'main': {
        'temp': temperature,
        'temp_min': tempMin,
        'temp_max': tempMax,
        'humidity': humidity,
      },
      'weather': [
        {
          'description': description,
          'icon': icon,
          'main': mainCondition,
        }
      ],
      'wind': {'speed': windSpeed},
      'pop': precipitationProbability / 100,
    };
  }
}
