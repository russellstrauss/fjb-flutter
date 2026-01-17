import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal() {
    // Initialization happens asynchronously in checkAuth()
  }

  static const String _storageKey = 'admin_auth';
  bool _isAuthenticated = false;
  String? _authToken;

  bool initAuth() {
    try {
      // In a real app, this would read from SharedPreferences
      // For now, we'll check on each call since we need async
      return _isAuthenticated;
    } catch (e) {
      return false;
    }
  }

  Future<bool> checkAuth() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getString(_storageKey);
      if (stored != null) {
        final authData = json.decode(stored) as Map<String, dynamic>;
        final token = authData['token'] as String?;
        final expiresStr = authData['expires'] as String?;
        
        if (token != null && expiresStr != null) {
          final expires = DateTime.parse(expiresStr);
          if (expires.isAfter(DateTime.now())) {
            _isAuthenticated = true;
            _authToken = token;
            return true;
          } else {
            // Token expired, clear it
            await prefs.remove(_storageKey);
            _isAuthenticated = false;
            _authToken = null;
          }
        }
      }
      return false;
    } catch (e) {
      print('Error checking auth: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>> login(String username, String password) async {
    // In production, this would make an API call
    // For demo, using hardcoded credentials (should use env vars in production)
    const adminUsername = 'admin'; // Should come from env: const.fromEnvironment('ADMIN_USERNAME', defaultValue: 'admin')
    const adminPassword = 'admin'; // Should come from env: const.fromEnvironment('ADMIN_PASSWORD', defaultValue: 'admin')

    if (username == adminUsername && password == adminPassword) {
      // Generate a simple token (in production, use proper JWT)
      final token = base64Encode('$username:${DateTime.now().millisecondsSinceEpoch}'.codeUnits);
      final expires = DateTime.now().add(const Duration(hours: 24));

      _authToken = token;
      _isAuthenticated = true;

      // Store in SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_storageKey, json.encode({
        'token': token,
        'expires': expires.toIso8601String(),
      }));

      return {'success': true};
    } else {
      return {'success': false, 'error': 'Invalid username or password'};
    }
  }

  Future<void> logout() async {
    _isAuthenticated = false;
    _authToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }

  bool get isAuthenticated => _isAuthenticated;
  String? get authToken => _authToken;
}





