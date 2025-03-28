class RegistrationModel {
  final int id;
  final int eventId;
  final int userId;
  final String status; // 'pending', 'confirmed', 'cancelled'
  final String? ticketNumber;
  final double? amount;
  final String? paymentStatus; // 'pending', 'completed', 'failed', 'refunded'
  final String? paymentMethod;
  final String? paymentId;
  final DateTime createdAt;
  final DateTime updatedAt;

  RegistrationModel({
    required this.id,
    required this.eventId,
    required this.userId,
    required this.status,
    this.ticketNumber,
    this.amount,
    this.paymentStatus,
    this.paymentMethod,
    this.paymentId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory RegistrationModel.fromJson(Map<String, dynamic> json) {
    return RegistrationModel(
      id: json['id'],
      eventId: json['event_id'],
      userId: json['user_id'],
      status: json['status'],
      ticketNumber: json['ticket_number'],
      amount:
          json['amount'] != null
              ? double.parse(json['amount'].toString())
              : null,
      paymentStatus: json['payment_status'],
      paymentMethod: json['payment_method'],
      paymentId: json['payment_id'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'event_id': eventId,
      'user_id': userId,
      'status': status,
      'ticket_number': ticketNumber,
      'amount': amount,
      'payment_status': paymentStatus,
      'payment_method': paymentMethod,
      'payment_id': paymentId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  RegistrationModel copyWith({
    int? id,
    int? eventId,
    int? userId,
    String? status,
    String? ticketNumber,
    double? amount,
    String? paymentStatus,
    String? paymentMethod,
    String? paymentId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RegistrationModel(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      userId: userId ?? this.userId,
      status: status ?? this.status,
      ticketNumber: ticketNumber ?? this.ticketNumber,
      amount: amount ?? this.amount,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentId: paymentId ?? this.paymentId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
