class LocationModel {
  const LocationModel({
    required this.latitude,
    required this.longitude,
    required this.city,
    required this.country,
  });

  final double latitude;
  final double longitude;
  final String city;
  final String country;

  String get displayName {
    if (country.isEmpty) {
      return city;
    }
    return '$city, $country';
  }

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0,
      city: json['city'] as String? ?? 'Unknown',
      country: json['country'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'city': city,
      'country': country,
    };
  }
}
