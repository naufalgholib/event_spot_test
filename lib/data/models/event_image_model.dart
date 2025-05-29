class EventImage {
  final int id;
  final int eventId;
  final String imagePath;
  final String imageType;
  final bool isPrimary;
  final int order;
  final DateTime createdAt;
  final DateTime updatedAt;

  EventImage({
    required this.id,
    required this.eventId,
    required this.imagePath,
    required this.imageType,
    this.isPrimary = false,
    this.order = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory EventImage.fromJson(Map<String, dynamic> json) {
    final now = DateTime.now();
    return EventImage(
      id: json['id'] ?? 0,
      eventId: json['event_id'] ?? 0,
      imagePath: json['image_path']?.toString() ?? '',
      imageType: json['image_type']?.toString() ?? 'poster',
      isPrimary: json['is_primary'] == 1,
      order: json['order'] ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : now,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'].toString())
          : now,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'event_id': eventId,
      'image_path': imagePath,
      'image_type': imageType,
      'is_primary': isPrimary ? 1 : 0,
      'order': order,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
