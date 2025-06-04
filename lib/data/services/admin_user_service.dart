import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_token_service.dart';
import '../../core/config/app_constants.dart';
import '../models/user_model.dart';

class AdminUserService {
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

  // Get all users with pagination
  Future<Map<String, dynamic>> getUsersPaginated(
      {int page = 1, int perPage = 50}) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse(
            '${AppConstants.baseUrl}/admin/users?page=$page&per_page=$perPage'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['data'] != null) {
          final List<dynamic> usersJson = responseData['data'];
          final users =
              usersJson.map((json) => UserModel.fromJson(json)).toList();

          // Extract pagination metadata if available
          final Map<String, dynamic> meta = responseData['meta'] ?? {};
          final int currentPage = meta['current_page'] ?? page;
          final int lastPage = meta['last_page'] ?? 1;
          final int total = meta['total'] ?? users.length;

          return {
            'users': users,
            'currentPage': currentPage,
            'lastPage': lastPage,
            'total': total,
            'hasMore': currentPage < lastPage,
          };
        } else {
          throw Exception('Invalid response format');
        }
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(
            'Failed to fetch users: ${errorData['message'] ?? response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching users: $e');
    }
  }

  // Get all users (legacy method, now fetches all pages)
  Future<List<UserModel>> getUsers() async {
    try {
      List<UserModel> allUsers = [];
      int currentPage = 1;
      bool hasMore = true;

      while (hasMore) {
        final result = await getUsersPaginated(page: currentPage, perPage: 100);
        final List<UserModel> users = result['users'];
        allUsers.addAll(users);

        hasMore = result['hasMore'];
        currentPage++;

        // Safety check to prevent infinite loops
        if (currentPage > 10) break;
      }

      return allUsers;
    } catch (e) {
      throw Exception('Error fetching all users: $e');
    }
  }

  // Get user by id
  Future<UserModel> getUserById(int userId) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/admin/users/$userId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['data'] != null) {
          return UserModel.fromJson(responseData['data']);
        } else {
          throw Exception('Invalid response format');
        }
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(
            'Failed to fetch user: ${errorData['message'] ?? response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching user: $e');
    }
  }

  // Create new user
  Future<UserModel> createUser({
    required String name,
    required String email,
    required String password,
    required String userType,
    String? phoneNumber,
    bool isActive = true,
  }) async {
    try {
      final headers = await _getAuthHeaders();
      final Map<String, dynamic> requestBody = {
        'name': name,
        'email': email,
        'password': password,
        'user_type': userType,
        'status': isActive ? 'active' : 'inactive',
      };

      if (phoneNumber != null) {
        requestBody['phone'] = phoneNumber;
      }

      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}/admin/users'),
        headers: headers,
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        if (responseData['data'] != null) {
          return UserModel.fromJson(responseData['data']);
        } else {
          throw Exception('Invalid response format');
        }
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(
            'Failed to create user: ${errorData['message'] ?? response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating user: $e');
    }
  }

  // Update user
  Future<UserModel> updateUser({
    required int userId,
    String? name,
    String? email,
    String? password,
    String? userType,
    String? phoneNumber,
    bool? isActive,
  }) async {
    try {
      final headers = await _getAuthHeaders();
      final Map<String, dynamic> requestBody = {};

      if (name != null) requestBody['name'] = name;
      if (email != null) requestBody['email'] = email;
      if (password != null) requestBody['password'] = password;
      if (userType != null) requestBody['user_type'] = userType;
      if (isActive != null)
        requestBody['status'] = isActive ? 'active' : 'inactive';
      if (phoneNumber != null) requestBody['phone'] = phoneNumber;

      final response = await http.put(
        Uri.parse('${AppConstants.baseUrl}/admin/users/$userId'),
        headers: headers,
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['data'] != null) {
          return UserModel.fromJson(responseData['data']);
        } else {
          throw Exception('Invalid response format');
        }
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(
            'Failed to update user: ${errorData['message'] ?? response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating user: $e');
    }
  }

  // Delete user
  Future<void> deleteUser(int userId) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.delete(
        Uri.parse('${AppConstants.baseUrl}/admin/users/$userId'),
        headers: headers,
      );

      if (response.statusCode != 200) {
        final errorData = jsonDecode(response.body);
        throw Exception(
            'Failed to delete user: ${errorData['message'] ?? response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting user: $e');
    }
  }

  // Update user active status
  Future<UserModel> updateUserActiveStatus(int userId, bool isActive) async {
    try {
      final headers = await _getAuthHeaders();
      final Map<String, dynamic> requestBody = {
        'is_active': isActive,
      };

      final response = await http.put(
        Uri.parse('${AppConstants.baseUrl}/admin/users/$userId/active'),
        headers: headers,
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['data'] != null) {
          return UserModel.fromJson(responseData['data']);
        } else {
          throw Exception('Invalid response format');
        }
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(
            'Failed to update user status: ${errorData['message'] ?? response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating user status: $e');
    }
  }

  // Update user role
  Future<UserModel> updateUserRole(int userId, String userType) async {
    try {
      final headers = await _getAuthHeaders();
      final Map<String, dynamic> requestBody = {
        'user_type': userType,
      };

      final response = await http.put(
        Uri.parse('${AppConstants.baseUrl}/admin/users/$userId/role'),
        headers: headers,
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['data'] != null) {
          return UserModel.fromJson(responseData['data']);
        } else {
          throw Exception('Invalid response format');
        }
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(
            'Failed to update user role: ${errorData['message'] ?? response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating user role: $e');
    }
  }
}
