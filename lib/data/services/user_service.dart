import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import 'auth_token_service.dart';
import '../../core/config/app_constants.dart';

class UserService {
  final _tokenService = AuthTokenService();

  // GET HEADERS - Non-static method
  Future<Map<String, String>> _getHeaders() async {
    final token = await _tokenService.getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<UserModel?> getCurrentUser() async {
    try {
      final token = await _tokenService.getToken();
      if (token == null) return null;

      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/auth/me'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['data'];
        return UserModel.fromJson(data);
      } else {
        throw Exception('Failed to get current user: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // ADD METHOD getUserProfile yang hilang
  Future<UserModel?> getUserProfile() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/user/profile/details'),
        headers: headers,
      );

      print('Profile response: ${response.statusCode}');
      print('Profile body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return UserModel.fromJson(data['data']);
        }
      } else if (response.statusCode == 401) {
        throw Exception('Authentication failed. Please login again.');
      }
      return null;
    } catch (e) {
      print('Error getting profile: $e');
      rethrow;
    }
  }

  Future<bool> isLoggedIn() async {
    final token = await _tokenService.getToken();
    return token != null;
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    required String phoneNumber,
    required String userType,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}/auth/register'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
          'phone_number': phoneNumber,
          'user_type': userType,
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Save token
        await _tokenService.saveToken(
          responseData['data']['token'],
          responseData['data']['token_type'],
        );

        return {
          'user': UserModel.fromJson(responseData['data']['user']),
          'token': responseData['data']['token'],
          'tokenType': responseData['data']['token_type'],
        };
      } else {
        throw Exception(responseData['message'] ?? 'Registration failed');
      }
    } catch (e) {
      throw Exception('Failed to register: $e');
    }
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}/auth/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (responseData['data'] != null &&
            responseData['data']['user'] != null &&
            responseData['data']['token'] != null) {
          // Save token
          await _tokenService.saveToken(
            responseData['data']['token'],
            responseData['data']['token_type'],
          );

          return {
            'user': UserModel.fromJson(responseData['data']['user']),
            'token': responseData['data']['token'],
            'tokenType': responseData['data']['token_type'],
          };
        } else {
          throw Exception('Invalid response format from server');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Invalid email or password');
      } else if (response.statusCode == 422) {
        // Handle validation errors
        final errors = responseData['errors'];
        if (errors != null) {
          final errorMessages =
              errors.values.expand((messages) => messages).join(', ');
          throw Exception(errorMessages);
        }
        throw Exception(responseData['message'] ?? 'Validation failed');
      } else {
        throw Exception(responseData['message'] ?? 'Login failed');
      }
    } catch (e) {
      if (e is FormatException) {
        throw Exception('Invalid response from server');
      }
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      final token = await _tokenService.getToken();
      if (token != null) {
        final response = await http.post(
          Uri.parse('${AppConstants.baseUrl}/auth/logout'),
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        );

        if (response.statusCode != 200) {
          throw Exception('Failed to logout: ${response.statusCode}');
        }
      }
    } finally {
      await _tokenService.clearToken();
    }
  }

  // UPDATE PROFILE - Non-static method
  Future<bool> updateProfile(UserModel user) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('${AppConstants.baseUrl}/user/profile/edit'),
        headers: headers,
        body: jsonEncode(user.toJson()),
      );

      print('Update response: ${response.statusCode}');
      print('Update body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] ?? false;
      }
      return false;
    } catch (e) {
      print('Error updating profile: $e');
      return false;
    }
  }

  // UPDATE PROFILE PICTURE - Non-static method
  Future<String?> updateProfilePicture(File imageFile) async {
    try {
      final token = await _tokenService.getToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${AppConstants.baseUrl}/user/profile/profile-picture'),
      );
      
      request.headers.addAll({
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });

      request.files.add(
        await http.MultipartFile.fromPath(
          'profile_picture',
          imageFile.path,
        ),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('Image upload response: ${response.statusCode}');
      print('Image upload body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          return data['data']['profile_picture'];
        }
      }
      return null;
    } catch (e) {
      print('Error updating profile picture: $e');
      return null;
    }
  }

  // DELETE PROFILE PICTURE - Non-static method
  Future<bool> deleteProfilePicture() async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('${AppConstants.baseUrl}/user/profile/profile-picture'),
        headers: headers,
      );

      print('Delete image response: ${response.statusCode}');
      print('Delete image body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] ?? false;
      }
      return false;
    } catch (e) {
      print('Error deleting profile picture: $e');
      return false;
    }
  }
}