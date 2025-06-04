import 'dart:convert';

class AdminDashboardModel {
  final int totalUsers;
  final int totalEvents;
  final int totalTags;
  final int totalCategories;
  final List<Map<String, dynamic>> recentEvents;

  AdminDashboardModel({
    required this.totalUsers,
    required this.totalEvents,
    required this.totalTags,
    required this.totalCategories,
    required this.recentEvents,
  });

  factory AdminDashboardModel.fromJson(Map<String, dynamic> json) {
    // Handle both string and int types for counts
    int parseCount(dynamic value) {
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    // Parse recent events
    List<Map<String, dynamic>> parseRecentEvents(dynamic recentEventsData) {
      if (recentEventsData is List) {
        return recentEventsData
            .map((event) =>
                event is Map<String, dynamic> ? event : <String, dynamic>{})
            .toList();
      } else if (recentEventsData is String) {
        try {
          final decoded = jsonDecode(recentEventsData);
          if (decoded is List) {
            return decoded
                .map((event) =>
                    event is Map<String, dynamic> ? event : <String, dynamic>{})
                .toList();
          }
        } catch (_) {}
      }
      return [];
    }

    return AdminDashboardModel(
      totalUsers: parseCount(json['total_users']),
      totalEvents: parseCount(json['total_events']),
      totalTags: parseCount(json['total_tags']),
      totalCategories: parseCount(json['total_categories']),
      recentEvents: parseRecentEvents(json['recent_events']),
    );
  }
}
