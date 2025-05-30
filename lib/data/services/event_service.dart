import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/event_model.dart';
import '../../core/config/app_constants.dart';
import 'auth_token_service.dart';
import 'package:dio/dio.dart';

class EventService {
  final _tokenService = AuthTokenService();
  final _dio = Dio();

  Future<List<EventModel>> getEvents() async {
    try {
      final response =
          await http.get(Uri.parse('${AppConstants.baseUrl}/events'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        if (!responseData.containsKey('data')) {
          throw Exception('Response does not contain data field');
        }

        final List<dynamic> data = responseData['data'];

        if (data.isEmpty) {
          return [];
        }

        final events = data.map((json) {
          final event = EventModel.fromJson(json);
          return event;
        }).toList();

        return events;
      } else {
        throw Exception(
            'Failed to load events: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error loading events: $e');
    }
  }

  Future<List<EventModel>> getBookmarkedEvents() async {
    try {
      final response = await _dio.get(
        '${AppConstants.baseUrl}/user/bookmarks',
        options: Options(
          headers: {
            'Authorization': 'Bearer ${await _tokenService.getToken()}',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData['status'] == 'success') {
          final List<dynamic> eventsData = responseData['data'];
          return eventsData.map((data) => EventModel.fromJson(data)).toList();
        }
        throw Exception(
            responseData['message'] ?? 'Failed to load bookmarked events');
      }
      throw Exception('Failed to load bookmarked events');
    } catch (e) {
      throw Exception('Failed to load bookmarked events: ${e.toString()}');
    }
  }

  Future<void> addBookmark(int eventId) async {
    try {
      final response = await _dio.post(
        '${AppConstants.baseUrl}/user/bookmarks',
        data: {'event_id': eventId},
        options: Options(
          headers: {
            'Authorization': 'Bearer ${await _tokenService.getToken()}',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to add bookmark');
      }
    } catch (e) {
      throw Exception('Failed to add bookmark: ${e.toString()}');
    }
  }

  Future<void> removeBookmark(int eventId) async {
    try {
      final response = await _dio.delete(
        '${AppConstants.baseUrl}/user/bookmarks/$eventId',
        options: Options(
          headers: {
            'Authorization': 'Bearer ${await _tokenService.getToken()}',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to remove bookmark');
      }
    } catch (e) {
      throw Exception('Failed to remove bookmark: ${e.toString()}');
    }
  }

  Future<EventModel> getEventDetail(int id) async {
    try {
      final response =
          await http.get(Uri.parse('${AppConstants.baseUrl}/events/$id'));

      if (response.statusCode == 200) {
        final dynamic data = json.decode(response.body)['data'];
        return EventModel.fromJson(data);
      } else {
        throw Exception('Failed to load event detail');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<EventModel> getEventBySlug(String slug) async {
    try {
      final response = await http
          .get(Uri.parse('${AppConstants.baseUrl}/events/slug/$slug'));

      if (response.statusCode == 200) {
        final dynamic data = json.decode(response.body)['data'];
        return EventModel.fromJson(data);
      } else {
        throw Exception('Failed to load event detail');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<List<EventModel>> searchEvents({
    String? query,
    int? categoryId,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (query != null && query.isNotEmpty) {
        queryParams['q'] = query;
      }
      if (categoryId != null) {
        queryParams['category_id'] = categoryId.toString();
      }

      final uri = Uri.parse('${AppConstants.baseUrl}/events/search')
          .replace(queryParameters: queryParams);

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final List<dynamic> data = responseData['data'];
        return data.map((json) => EventModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to search events: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<List<EventModel>> getEventsByPromoter(int promoterId) async {
    try {
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/promoters/$promoterId/events'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final List<dynamic> data = responseData['data'];
        return data.map((json) => EventModel.fromJson(json)).toList();
      } else {
        throw Exception(
            'Failed to load promoter events: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
