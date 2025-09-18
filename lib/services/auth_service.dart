import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final ApiService _apiService = ApiService();
  String? _currentToken;

  String? get currentToken => _currentToken;
  bool get isLoggedIn => _currentToken != null && _currentToken!.isNotEmpty;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    
    if (token != null && token.isNotEmpty) {
      _currentToken = token;
      _apiService.setToken(token);
    }
  }

  Future<String> login(String username, String password) async {
    try {
      final token = await _apiService.login(username, password);
      await _saveToken(token);
      return token;
    } catch (e) {
      await logout();
      rethrow;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    
    _currentToken = null;
    _apiService.clearToken();
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt_token', token);
    
    _currentToken = token;
    _apiService.setToken(token);
  }

  Future<bool> validateToken() async {
    if (!isLoggedIn) return false;
    
    try {
      await _apiService.getDriverProfile();
      return true;
    } catch (e) {
      if (e is UnauthorizedException) {
        await logout();
      }
      return false;
    }
  }
}

