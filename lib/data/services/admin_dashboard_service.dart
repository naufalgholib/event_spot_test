import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_token_service.dart';
import '../../core/config/app_constants.dart';
import '../models/admin_dashboard_model.dart';

class AdminDashboardService {
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

  Future<AdminDashboardModel> getDashboardData() async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/admin/dashboard'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['status'] == 'success' &&
            responseData['data'] != null) {
          return AdminDashboardModel.fromJson(responseData['data']);
        } else {
          throw Exception('Invalid response format');
        }
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(
            'Failed to fetch dashboard data: ${errorData['message'] ?? response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching dashboard data: $e');
    }
  }
}
