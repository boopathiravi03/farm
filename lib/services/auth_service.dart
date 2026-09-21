import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String loggedInKey = 'logged_in';
  static const String roleKey = 'user_role';
  static const String phoneKey = 'user_phone';
  static const String tokenKey = 'jwt_token';
  static const String userKey = 'user_data';

  // Base API URL with Android emulator / local fallback
  static String get baseUrl {
    try {
      if (Platform.isAndroid) {
        return 'http://10.0.2.2:5000/api';
      }
    } catch (_) {}
    return 'http://localhost:5000/api';
  }

  // Save local login information
  static Future<void> login({
    required String role,
    required String phone,
    String? token,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(loggedInKey, true);
    await prefs.setString(roleKey, role);
    await prefs.setString(phoneKey, phone);
    if (token != null) {
      await prefs.setString(tokenKey, token);
    }
  }

  // Real Backend Login with JWT
  static Future<Map<String, dynamic>> apiLogin({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/auth/login'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(const Duration(seconds: 4));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['token'] != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(loggedInKey, true);
        await prefs.setString(tokenKey, data['token']);
        if (data['user'] != null) {
          final role = data['user']['role'] ?? 'farmer';
          final capitalRole =
              role.toString().substring(0, 1).toUpperCase() +
              role.toString().substring(1);
          await prefs.setString(roleKey, capitalRole);
          await prefs.setString(userKey, jsonEncode(data['user']));
        }
        return {'success': true, 'data': data};
      }

      return {'success': false, 'message': data['message'] ?? 'Login failed'};
    } catch (e) {
      return {'success': false, 'message': 'Cannot connect to backend: $e'};
    }
  }

  // Real Backend Registration
  static Future<Map<String, dynamic>> apiRegister({
    required String name,
    required String email,
    required String password,
    required String role,
    String? phone,
    String? location,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/auth/register'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'name': name,
              'email': email,
              'password': password,
              'role': role.toLowerCase(),
              'phone': phone,
              'location': location,
            }),
          )
          .timeout(const Duration(seconds: 4));

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return {'success': true, 'data': data};
      }

      return {
        'success': false,
        'message': data['message'] ?? 'Registration failed',
      };
    } catch (e) {
      return {'success': false, 'message': 'Cannot connect to backend: $e'};
    }
  }

  // Check whether user is logged in
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getBool(loggedInKey) ?? false;
  }

  // Get saved role
  static Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString(roleKey);
  }

  // Get saved phone
  static Future<String?> getPhone() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString(phoneKey);
  }

  // Get saved JWT token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString(tokenKey);
  }

  // Logout
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.clear();
  }
}
