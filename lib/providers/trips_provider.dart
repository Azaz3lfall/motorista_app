import 'package:flutter/foundation.dart';
import '../models/trip.dart';
import '../models/refueling.dart';
import '../models/cost.dart';
import '../services/api_service.dart';

enum TripsState {
  initial,
  loading,
  loaded,
  error,
}

class TripsProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  TripsState _state = TripsState.initial;
  List<Trip> _trips = [];
  String? _errorMessage;

  // Getters
  TripsState get state => _state;
  List<Trip> get trips => _trips;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _state == TripsState.loading;
  bool get hasError => _state == TripsState.error;
  bool get isLoaded => _state == TripsState.loaded;
  bool get isEmpty => _trips.isEmpty && isLoaded;

  // Load open trips
  Future<void> loadOpenTrips() async {
    _setState(TripsState.loading);
    _clearError();
    
    try {
      _trips = await _apiService.getOpenTrips();
      _setState(TripsState.loaded);
    } catch (e) {
      _setError('Erro ao carregar viagens: $e');
    }
  }

  // Refresh trips
  Future<void> refreshTrips() async {
    await loadOpenTrips();
  }

  // Finalize trip
  Future<bool> finalizeTrip(int tripId, double distance) async {
    try {
      await _apiService.finalizeTrip(tripId, distance);
      // Remove the finalized trip from the list
      _trips.removeWhere((trip) => trip.id == tripId);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Erro ao finalizar viagem: $e');
      return false;
    }
  }

  // Add refueling
  Future<bool> addRefueling(Refueling refueling) async {
    try {
      await _apiService.addRefueling(refueling);
      // Refresh trips to get updated data
      await refreshTrips();
      return true;
    } catch (e) {
      _setError('Erro ao adicionar abastecimento: $e');
      return false;
    }
  }

  // Add cost (for trip-related costs)
  Future<bool> addCost(Cost cost) async {
    try {
      await _apiService.addCost(cost);
      // Refresh trips to get updated data
      await refreshTrips();
      return true;
    } catch (e) {
      _setError('Erro ao adicionar custo: $e');
      return false;
    }
  }

  // Add standalone cost (custos avulsos)
  Future<bool> addStandaloneCost(Cost cost) async {
    try {
      await _apiService.addStandaloneCost(cost);
      // For standalone costs, we don't need to refresh trips
      // but we could refresh if needed in the future
      return true;
    } catch (e) {
      _setError('Erro ao adicionar custo avulso: $e');
      return false;
    }
  }

  // Clear data
  void clearData() {
    _trips = [];
    _setState(TripsState.initial);
    _clearError();
  }

  // Clear error
  void clearError() {
    _clearError();
  }

  // Private methods
  void _setState(TripsState newState) {
    _state = newState;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    _state = TripsState.error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
