class DeviceLocationData {
  const DeviceLocationData({
    this.latitude,
    this.longitude,
    this.accuracy,
    this.address,
    this.deviceInfo,
  });

  final double? latitude;
  final double? longitude;
  final double? accuracy;
  final String? address;
  final String? deviceInfo;

  /// Formatted GPS coordinates string (e.g. "51.5074, -0.1278")
  String get gpsCoordinates {
    if (latitude == null || longitude == null) return '';
    return '${latitude!.toStringAsFixed(6)}, ${longitude!.toStringAsFixed(6)}';
  }

  /// Formatted address or empty string
  String get formattedAddress => address ?? '';

  /// Whether valid GPS coordinates are available
  bool get hasLocation => latitude != null && longitude != null;

  /// Serialize for API payloads
  Map<String, dynamic> toJson() => {
    'latitude': latitude,
    'longitude': longitude,
    'accuracy': accuracy,
    'address': address,
    'deviceInfo': deviceInfo,
  };
}
