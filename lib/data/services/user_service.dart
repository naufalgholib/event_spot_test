import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import 'auth_token_service.dart';
import '../../core/config/app_constants.dart';

class UserService {
  final _tokenService = AuthTokenService();

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
}
