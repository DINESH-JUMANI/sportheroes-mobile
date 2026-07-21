class VenueModel {
  const VenueModel({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    this.address,
    this.city,
    this.state,
    this.country,
    this.createdBy,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  factory VenueModel.fromJson(Map<String, dynamic> json) {
    return VenueModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0,
      address: json['address'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      country: json['country'] as String?,
      createdBy: json['createdBy']?.toString(),
      isActive: json['isActive'] as bool? ?? true,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );
  }

  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final String? address;
  final String? city;
  final String? state;
  final String? country;
  final String? createdBy;
  final bool isActive;
  final String? createdAt;
  final String? updatedAt;

  String get locationLabel {
    final parts = [city, state, country]
        .where((e) => e != null && e.trim().isNotEmpty)
        .map((e) => e!.trim());
    if (parts.isNotEmpty) return parts.join(', ');
    if (address != null && address!.isNotEmpty) return address!;
    return '${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)}';
  }

  String get subtitle {
    if (address != null && address!.trim().isNotEmpty) return address!;
    return locationLabel;
  }
}

class CreateVenueRequest {
  const CreateVenueRequest({
    required this.name,
    required this.latitude,
    required this.longitude,
    this.address,
    this.city,
    this.state,
    this.country,
  });

  final String name;
  final double latitude;
  final double longitude;
  final String? address;
  final String? city;
  final String? state;
  final String? country;

  Map<String, dynamic> toJson() => {
        'name': name,
        'latitude': latitude,
        'longitude': longitude,
        if (address != null && address!.isNotEmpty) 'address': address,
        if (city != null && city!.isNotEmpty) 'city': city,
        if (state != null && state!.isNotEmpty) 'state': state,
        if (country != null && country!.isNotEmpty) 'country': country,
      };
}

class UpdateVenueRequest {
  const UpdateVenueRequest({
    this.name,
    this.latitude,
    this.longitude,
    this.address,
    this.city,
    this.state,
    this.country,
  });

  final String? name;
  final double? latitude;
  final double? longitude;
  final String? address;
  final String? city;
  final String? state;
  final String? country;

  Map<String, dynamic> toJson() => {
        if (name != null) 'name': name,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
        if (address != null) 'address': address,
        if (city != null) 'city': city,
        if (state != null) 'state': state,
        if (country != null) 'country': country,
      };
}
