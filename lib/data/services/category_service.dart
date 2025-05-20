import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/category_model.dart';

class CategoryService {
  static const String baseUrl = 'http://192.168.1.9:8000/api';

  Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/categories'));

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
      final response = await http.get(Uri.parse('$baseUrl/categories/$id'));

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
      final response = await http.post(
        Uri.parse('$baseUrl/categories'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(category.toJson()),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return CategoryModel.fromJson(data);
      } else {
        throw Exception('Failed to create category');
      }
    } catch (e) {
      throw Exception('Error creating category: $e');
    }
  }

  Future<CategoryModel> updateCategory(int id, CategoryModel category) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/categories/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(category.toJson()),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return CategoryModel.fromJson(data);
      } else {
        throw Exception('Failed to update category');
      }
    } catch (e) {
      throw Exception('Error updating category: $e');
    }
  }

  Future<void> deleteCategory(int id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/categories/$id'));

      if (response.statusCode != 200) {
        throw Exception('Failed to delete category');
      }
    } catch (e) {
      throw Exception('Error deleting category: $e');
    }
  }
}
