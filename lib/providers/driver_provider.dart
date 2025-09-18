import 'package:flutter/foundation.dart';
import '../models/driver_profile.dart';
import '../services/api_service.dart';

enum DriverState {
  initial,
  loading,
  loaded,
  error,
}

class DriverProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  DriverState _state = DriverState.initial;
  DriverProfile? _driverProfile;
  String? _errorMessage;

  // Getters
  DriverState get state => _state;
  DriverProfile? get driverProfile => _driverProfile;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _state == DriverState.loading;
  bool get hasError => _state == DriverState.error;
  bool get isLoaded => _state == DriverState.loaded && _driverProfile != null;

  // Load driver profile
  Future<void> loadDriverProfile() async {
    _setState(DriverState.loading);
    _clearError();
    
    try {
      _driverProfile = await _apiService.getDriverProfile();
      _setState(DriverState.loaded);
    } catch (e) {
      _setError('Erro ao carregar perfil do motorista: $e');
    }
  }

  // Refresh driver profile
  Future<void> refreshDriverProfile() async {
    await loadDriverProfile();
  }

  // Clear data
  void clearData() {
    _driverProfile = null;
    _setState(DriverState.initial);
    _clearError();
  }

  // Clear error
  void clearError() {
    _clearError();
  }

  // Private methods
  void _setState(DriverState newState) {
    _state = newState;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    _state = DriverState.error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

