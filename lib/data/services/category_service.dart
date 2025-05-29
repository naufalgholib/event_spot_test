import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/category_model.dart';
import 'auth_token_service.dart';
import '../../core/config/app_constants.dart';

class CategoryService {
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

  Future<List<CategoryModel>> getCategories() async {
    try {
      final response =
          await http.get(Uri.parse('${AppConstants.baseUrl}/categories'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> categoriesList = data['list'];
        return categoriesList
            .map((json) => CategoryModel.fromJson(json))
            .toList();
      } else {
        throw Exception('Failed to load categories');
      }
    } catch (e) {
      throw Exception('Error fetching categories: $e');
    }
  }

  Future<CategoryModel> getCategoryById(int id) async {
    try {
      final response =
          await http.get(Uri.parse('${AppConstants.baseUrl}/categories/$id'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return CategoryModel.fromJson(data);
      } else {
        throw Exception('Failed to load category');
      }
    } catch (e) {
      throw Exception('Error fetching category: $e');
    }
  }

  Future<CategoryModel> createCategory(CategoryModel category) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}/admin/categories'),
        headers: headers,
        body: jsonEncode(category.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        if (responseData == null) {
          throw Exception('Server returned null response');
        }

        final data = responseData['data'];
        if (data == null) {
          throw Exception('Category data not found in response');
        }

        return CategoryModel.fromJson(data);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(
            'Failed to create category: ${errorData['message'] ?? response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating category: $e');
    }
  }

  Future<CategoryModel> updateCategory(int id, CategoryModel category) async {
    try {
      final headers = await _getAuthHeaders();
      final Map<String, dynamic> requestBody = {
        'name': category.name,
        'description': category.description,
        'icon': category.icon,
      };

      final response = await http.put(
        Uri.parse('${AppConstants.baseUrl}/admin/categories/$id'),
        headers: headers,
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData == null) {
          throw Exception('Server returned null response');
        }

        final data = responseData['data'];
        if (data == null) {
          throw Exception('Category data not found in response');
        }

        return CategoryModel.fromJson(data);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(
            'Failed to update category: ${errorData['message'] ?? response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating category: $e');
    }
  }

  Future<void> deleteCategory(int id) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.delete(
        Uri.parse('${AppConstants.baseUrl}/admin/categories/$id'),
        headers: headers,
      );

      if (response.statusCode != 200) {
        final errorData = jsonDecode(response.body);
        throw Exception(
            'Failed to delete category: ${errorData['message'] ?? response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting category: $e');
    }
  }
}
