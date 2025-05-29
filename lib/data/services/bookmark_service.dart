import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/event_model.dart';
import 'auth_token_service.dart';
import '../../core/config/app_constants.dart';

class BookmarkService {
  final AuthTokenService _authTokenService = AuthTokenService();

  Future<List<EventModel>> getBookmarkedEvents() async {
    try {
      final token = await _authTokenService.getToken();
      if (token == null) {
        throw Exception('User not authenticated');
      }

      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/user/bookmarks'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData['status'] == 'success') {
          final List<dynamic> data = responseData['data'];
          return data.map((json) => EventModel.fromJson(json)).toList();
        } else {
          throw Exception(
              responseData['message'] ?? 'Failed to load bookmarked events');
        }
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ??
            'Failed to load bookmarked events: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<bool> toggleBookmark(int eventId) async {
    try {
      final token = await _authTokenService.getToken();
      if (token == null) {
        throw Exception('User not authenticated');
      }

      // First check if the event is already bookmarked
      final checkResponse = await http.get(
        Uri.parse(
            '${AppConstants.baseUrl}/user/bookmarks/events/$eventId/check'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (checkResponse.statusCode != 200) {
        final errorData = jsonDecode(checkResponse.body);
        throw Exception(
            errorData['message'] ?? 'Failed to check bookmark status');
      }

      final checkData = jsonDecode(checkResponse.body);
      if (checkData['status'] != 'success') {
        throw Exception(
            checkData['message'] ?? 'Failed to check bookmark status');
      }

      final bool isBookmarked = checkData['data']['is_bookmarked'];

      // If already bookmarked, remove it
      if (isBookmarked) {
        final response = await http.delete(
          Uri.parse('${AppConstants.baseUrl}/user/bookmarks/events/$eventId'),
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        );

        if (response.statusCode == 200) {
          final responseData = jsonDecode(response.body);
          if (responseData['status'] == 'success') {
            return false; // Bookmark removed
          } else {
            throw Exception(
                responseData['message'] ?? 'Failed to remove bookmark');
          }
        } else {
          final errorData = jsonDecode(response.body);
          throw Exception(errorData['message'] ?? 'Failed to remove bookmark');
        }
      }
      // If not bookmarked, add it
      else {
        final response = await http.post(
          Uri.parse('${AppConstants.baseUrl}/user/bookmarks/events/$eventId'),
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        );

        if (response.statusCode == 200) {
          final responseData = jsonDecode(response.body);
          if (responseData['status'] == 'success') {
            return true; // Bookmark added
          } else {
            throw Exception(
                responseData['message'] ?? 'Failed to add bookmark');
          }
        } else {
          final errorData = jsonDecode(response.body);
          throw Exception(errorData['message'] ?? 'Failed to add bookmark');
        }
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<bool> isEventBookmarked(int eventId) async {
    try {
      final token = await _authTokenService.getToken();
      if (token == null) {
        return false;
      }

      final response = await http.get(
        Uri.parse(
            '${AppConstants.baseUrl}/user/bookmarks/events/$eventId/check'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          return data['data']['is_bookmarked'];
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
