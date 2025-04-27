class Event {
  final String id;
  final String title;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final String location;
  final String? imageUrl;
  final String organizerId;
  final double ticketPrice;
  final String category;
  final String status;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.location,
    this.imageUrl,
    required this.organizerId,
    required this.ticketPrice,
    required this.category,
    required this.status,
  });
}
