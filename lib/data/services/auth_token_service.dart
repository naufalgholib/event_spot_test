import 'package:shared_preferences/shared_preferences.dart';

class AuthTokenService {
  static const String _tokenKey = 'auth_token';
  static const String _tokenTypeKey = 'token_type';

  Future<void> saveToken(String token, String tokenType) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_tokenTypeKey, tokenType);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<String?> getTokenType() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenTypeKey);
  }

  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_tokenTypeKey);
  }

  Future<String> getAuthHeader() async {
    final token = await getToken();
    final tokenType = await getTokenType() ?? 'Bearer';
    return '$tokenType $token';
  }
}
