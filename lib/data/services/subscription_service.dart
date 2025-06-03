import 'dart:convert';
import 'package:http/http.dart' as http;
// Removed SharedPreferences import as AuthTokenService will handle it
import '../../core/config/app_constants.dart';
import '../models/user_model.dart';
import '../models/category_model.dart';
import 'auth_token_service.dart'; // Added AuthTokenService import

class SubscriptionService {
  final String _baseUrl = AppConstants.baseUrl;
  final AuthTokenService _tokenService =
      AuthTokenService(); // Added AuthTokenService instance

  // _getToken is no longer needed here, will use _tokenService directly

  Future<List<UserModel>> getFollowedPromoters() async {
    final token = await _tokenService.getToken(); // Use AuthTokenService
    if (token == null) {
      throw Exception('Authentication token not found. Please log in.');
    }

    final response = await http.get(
      Uri.parse('$_baseUrl/user/subscriptions/promotors'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token', // Standard Bearer token usage
      },
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      final List<dynamic> dataList = responseData['data'];
      return dataList
          .map((item) => UserModel.fromJson(item[
              'promotor'])) // Assuming 'promotor' is always present based on your example
          .toList();
    } else if (response.statusCode == 401) {
      throw Exception('Unauthenticated. Please log in again.');
    } else {
      throw Exception('Failed to load followed promoters: ${response.body}');
    }
  }

  Future<void> unfollowPromoter(String promoterId) async {
    final token = await _tokenService.getToken(); // Use AuthTokenService
    if (token == null) {
      throw Exception('Authentication token not found. Please log in.');
    }

    final response = await http.delete(
      Uri.parse('$_baseUrl/user/subscriptions/promotors/$promoterId'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200 || response.statusCode == 204) {
      try {
        final body = jsonDecode(response.body);
        if (body['status'] == 'success') {
          return;
        }
        // If status is not success, or if other fields indicate error even with 200
        throw Exception(body['message'] ??
            'Failed to unfollow promoter (unexpected response)');
      } catch (e) {
        // This catch block handles cases where response.body is not valid JSON (e.g., for 204 No Content)
        // or if jsonDecode itself fails. For 204, this is expected success.
        if (response.statusCode == 204) return;
        // If it was 200 but body wasn't JSON or didn't have expected fields, it's an issue.
        throw Exception(
            'Failed to unfollow promoter: Invalid response format. ${e.toString()}');
      }
    } else if (response.statusCode == 401) {
      throw Exception('Unauthenticated. Please log in again.');
    } else {
      try {
        final body = jsonDecode(response.body);
        throw Exception(
            'Failed to unfollow promoter: ${body['message'] ?? response.body}');
      } catch (e) {
        throw Exception('Failed to unfollow promoter: ${response.body}');
      }
    }
  }

  Future<List<CategoryModel>> getSubscribedCategories() async {
    final token = await _tokenService.getToken(); // Use AuthTokenService
    if (token == null) {
      throw Exception('Authentication token not found. Please log in.');
    }

    final response = await http.get(
      Uri.parse('$_baseUrl/user/subscriptions/categories'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      final List<dynamic> dataList = responseData['data'];
      return dataList
          .map((item) => CategoryModel.fromJson(
              item['category'])) // Assuming 'category' is always present
          .toList();
    } else if (response.statusCode == 401) {
      throw Exception('Unauthenticated. Please log in again.');
    } else {
      throw Exception('Failed to load subscribed categories: ${response.body}');
    }
  }

  Future<void> unsubscribeFromCategory(String categoryId) async {
    final token = await _tokenService.getToken(); // Use AuthTokenService
    if (token == null) {
      throw Exception('Authentication token not found. Please log in.');
    }

    final response = await http.delete(
      Uri.parse('$_baseUrl/user/subscriptions/categories/$categoryId'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200 || response.statusCode == 204) {
      try {
        final body = jsonDecode(response.body);
        if (body['status'] == 'success') {
          return;
        }
        throw Exception(body['message'] ??
            'Failed to unsubscribe from category (unexpected response)');
      } catch (e) {
        if (response.statusCode == 204) return;
        throw Exception(
            'Failed to unsubscribe from category: Invalid response format. ${e.toString()}');
      }
    } else if (response.statusCode == 401) {
      throw Exception('Unauthenticated. Please log in again.');
    } else {
      try {
        final body = jsonDecode(response.body);
        throw Exception(
            'Failed to unsubscribe from category: ${body['message'] ?? response.body}');
      } catch (e) {
        throw Exception(
            'Failed to unsubscribe from category: ${response.body}');
      }
    }
  }
}
