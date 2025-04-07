class FollowerModel {
  final int id;
  final int userId;
  final int promoterId;
  final DateTime createdAt;

  FollowerModel({
    required this.id,
    required this.userId,
    required this.promoterId,
    required this.createdAt,
  });

  factory FollowerModel.fromJson(Map<String, dynamic> json) {
    return FollowerModel(
      id: json['id'],
      userId: json['user_id'],
      promoterId: json['promotor_id'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'promotor_id': promoterId,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
