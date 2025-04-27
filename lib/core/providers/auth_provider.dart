import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/mock_user_repository.dart';
import '../constants/app_constants.dart';

class AuthProvider extends ChangeNotifier {
  final MockUserRepository _userRepository = MockUserRepository();
  UserModel? _currentUser;
  bool _isLoading = false;

  AuthProvider() {
    _loadSavedUser();
  }

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _currentUser != null;

  Future<void> _loadSavedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(AppConstants.userDataKey);
    if (userJson != null) {
      try {
        final user = await _userRepository.getCurrentUser();
        if (user != null) {
          _currentUser = user;
          notifyListeners();
        }
      } catch (e) {
        // Handle error loading saved user
        print('Error loading saved user: $e');
      }
    }
  }

  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = await _userRepository.login(email, password);
      if (user != null) {
        _currentUser = user;
        // Save user data
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(
          AppConstants.userDataKey,
          user.toJson().toString(),
        );
      }
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _userRepository.logout();
      _currentUser = null;
      // Clear saved user data
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(AppConstants.userDataKey);
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Check if user has required role
  bool hasRole(String role) {
    return _currentUser?.userType == role;
  }

  // Check if user has access to a specific feature
  bool canAccess(String feature) {
    if (!isLoggedIn) return false;

    switch (feature) {
      case 'create_event':
        return hasRole('admin') || hasRole('promotor');
      case 'manage_users':
        return hasRole('admin');
      case 'view_analytics':
        return hasRole('admin') || hasRole('promotor');
      default:
        return true;
    }
  }

  // Update user profile
  Future<void> updateUser(UserModel updatedUser) async {
    _isLoading = true;
    notifyListeners();

    try {
      // TODO: Call API to update user profile
      // For now, just update the local state
      _currentUser = updatedUser;

      // Save updated user data
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        AppConstants.userDataKey,
        updatedUser.toJson().toString(),
      );
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
