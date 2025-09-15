import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';
import '../utils/constants.dart';

enum AuthState {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  AuthState _state = AuthState.initial;
  String? _errorMessage;
  String? _currentToken;

  // Getters
  AuthState get state => _state;
  String? get errorMessage => _errorMessage;
  String? get currentToken => _currentToken;
  bool get isAuthenticated => _state == AuthState.authenticated && _currentToken != null;
  bool get isLoading => _state == AuthState.loading;

  // Initialize auth state
  Future<void> initialize() async {
    _setState(AuthState.loading);
    
    try {
      await _authService.initialize();
      
      if (_authService.isLoggedIn) {
        _currentToken = _authService.currentToken;
        _setState(AuthState.authenticated);
      } else {
        _setState(AuthState.unauthenticated);
      }
    } catch (e) {
      _setError('Erro ao inicializar autenticação: $e');
    }
  }

  // Login
  Future<bool> login(String username, String password) async {
    _setState(AuthState.loading);
    _clearError();
    
    try {
      final token = await _authService.login(username, password);
      _currentToken = token;
      _setState(AuthState.authenticated);
      return true;
    } catch (e) {
      _setError(_getErrorMessage(e));
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    _setState(AuthState.loading);
    
    try {
      await _authService.logout();
      _currentToken = null;
      _setState(AuthState.unauthenticated);
    } catch (e) {
      _setError('Erro ao fazer logout: $e');
    }
  }

  // Validate token
  Future<bool> validateToken() async {
    if (!isAuthenticated) return false;
    
    try {
      final isValid = await _authService.validateToken();
      if (!isValid) {
        await logout();
      }
      return isValid;
    } catch (e) {
      await logout();
      return false;
    }
  }

  // Clear error
  void clearError() {
    _clearError();
  }

  // Private methods
  void _setState(AuthState newState) {
    _state = newState;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    _state = AuthState.error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  String _getErrorMessage(dynamic error) {
    if (error.toString().contains('401') || error.toString().contains('Token')) {
      return Constants.errorInvalidCredentials;
    } else if (error.toString().contains('connection') || error.toString().contains('network')) {
      return Constants.errorNetworkConnection;
    } else {
      return error.toString();
    }
  }
}
