class SupportConcern {
  const SupportConcern({
    required this.id,
    required this.code,
    required this.label,
    this.description,
    this.sortOrder = 0,
    this.isOther = false,
    this.isActive = true,
  });

  factory SupportConcern.fromJson(Map<String, dynamic> json) {
    return SupportConcern(
      id: json['id']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      description: json['description'] as String?,
      sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
      isOther: json['isOther'] as bool? ?? false,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  final String id;
  final String code;
  final String label;
  final String? description;
  final int sortOrder;
  final bool isOther;
  final bool isActive;
}

class SupportTicketImage {
  const SupportTicketImage({
    required this.id,
    this.mimeType,
    this.sortOrder = 0,
  });

  factory SupportTicketImage.fromJson(Map<String, dynamic> json) {
    return SupportTicketImage(
      id: json['id']?.toString() ?? '',
      mimeType: json['mimeType'] as String?,
      sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
    );
  }

  final String id;
  final String? mimeType;
  final int sortOrder;
}

class SupportTicket {
  const SupportTicket({
    required this.id,
    required this.ticketNumber,
    required this.status,
    required this.description,
    this.otherConcernText,
    this.concern,
    this.images = const [],
    this.createdAt,
    this.updatedAt,
  });

  factory SupportTicket.fromJson(Map<String, dynamic> json) {
    return SupportTicket(
      id: json['id']?.toString() ?? '',
      ticketNumber: json['ticketNumber']?.toString() ?? '',
      status: json['status']?.toString() ?? 'open',
      description: json['description']?.toString() ?? '',
      otherConcernText: json['otherConcernText'] as String?,
      concern: json['concern'] is Map
          ? SupportConcern.fromJson(
              Map<String, dynamic>.from(json['concern'] as Map),
            )
          : null,
      images: json['images'] is List
          ? (json['images'] as List)
              .whereType<Map>()
              .map(
                (e) => SupportTicketImage.fromJson(
                  Map<String, dynamic>.from(e),
                ),
              )
              .toList()
          : const [],
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );
  }

  final String id;
  final String ticketNumber;
  final String status;
  final String description;
  final String? otherConcernText;
  final SupportConcern? concern;
  final List<SupportTicketImage> images;
  final String? createdAt;
  final String? updatedAt;

  String get statusLabel {
    switch (status) {
      case 'in_progress':
        return 'In progress';
      case 'resolved':
        return 'Resolved';
      case 'closed':
        return 'Closed';
      default:
        return 'Open';
    }
  }
}

class CreateSupportTicketRequest {
  const CreateSupportTicketRequest({
    required this.concernId,
    required this.description,
    this.otherConcernText,
    this.images = const [],
  });

  final String concernId;
  final String description;
  final String? otherConcernText;
  final List<({String imageBase64, String mimeType})> images;

  Map<String, dynamic> toJson() => {
        'concernId': concernId,
        'description': description,
        if (otherConcernText != null && otherConcernText!.trim().isNotEmpty)
          'otherConcernText': otherConcernText,
        if (images.isNotEmpty)
          'images': images
              .map(
                (i) => {
                  'imageBase64': i.imageBase64,
                  'mimeType': i.mimeType,
                },
              )
              .toList(),
      };
}
