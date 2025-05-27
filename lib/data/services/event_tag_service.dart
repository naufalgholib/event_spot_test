import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/event_tag_model.dart';
import 'auth_token_service.dart';

class EventTagService {
  static const String baseUrl = 'http://127.0.0.1:8000/api';
  final _tokenService = AuthTokenService();

  // Helper method to get auth headers
  Future<Map<String, String>> _getAuthHeaders() async {
    final authHeader = await _tokenService.getAuthHeader();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': authHeader,
    };
  }

  Future<List<EventTagModel>> getEventTags() async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/admin/event-tags'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> tagsList = data['data'];
        return tagsList.map((json) => EventTagModel.fromJson(json)).toList();
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(
            'Failed to load event tags: ${errorData['message'] ?? response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching event tags: $e');
    }
  }

  Future<EventTagModel> getEventTagById(int id) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/admin/event-tags/$id'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return EventTagModel.fromJson(data['data']);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(
            'Failed to load event tag: ${errorData['message'] ?? response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching event tag: $e');
    }
  }

  Future<EventTagModel> createEventTag(EventTagModel tag) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/admin/event-tags'),
        headers: headers,
        body: jsonEncode({
          'name': tag.name,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        if (responseData == null) {
          throw Exception('Server returned null response');
        }

        final data = responseData['data'];
        if (data == null) {
          throw Exception('Event tag data not found in response');
        }

        return EventTagModel.fromJson(data);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(
            'Failed to create event tag: ${errorData['message'] ?? response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating event tag: $e');
    }
  }

  Future<EventTagModel> updateEventTag(int id, EventTagModel tag) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/admin/event-tags/$id'),
        headers: headers,
        body: jsonEncode({
          'name': tag.name,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData == null) {
          throw Exception('Server returned null response');
        }

        final data = responseData['data'];
        if (data == null) {
          throw Exception('Event tag data not found in response');
        }

        return EventTagModel.fromJson(data);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(
            'Failed to update event tag: ${errorData['message'] ?? response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating event tag: $e');
    }
  }

  Future<void> deleteEventTag(int id) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/admin/event-tags/$id'),
        headers: headers,
      );

      if (response.statusCode != 200) {
        final errorData = jsonDecode(response.body);
        throw Exception(
            'Failed to delete event tag: ${errorData['message'] ?? response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting event tag: $e');
    }
  }
}
