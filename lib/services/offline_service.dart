import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/refueling.dart';
import '../models/cost.dart';

class OfflineService {
  static final OfflineService _instance = OfflineService._internal();
  factory OfflineService() => _instance;
  OfflineService._internal();

  SharedPreferences? _prefs;

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Offline queue keys
  static const String _refuelingQueueKey = 'offline_refueling_queue';
  static const String _costQueueKey = 'offline_cost_queue';
  static const String _tripFinalizationQueueKey = 'offline_trip_finalization_queue';

  // Refueling Queue
  Future<void> queueRefueling(Refueling refueling) async {
    if (_prefs == null) return;
    
    try {
      final queue = await getQueuedRefuelings();
      queue.add(refueling);
      
      final json = jsonEncode(queue.map((r) => r.toJson()).toList());
      await _prefs!.setString(_refuelingQueueKey, json);
    } catch (e) {
      print('Error queueing refueling: $e');
    }
  }

  Future<List<Refueling>> getQueuedRefuelings() async {
    if (_prefs == null) return [];
    
    try {
      final json = _prefs!.getString(_refuelingQueueKey);
      if (json == null) return [];
      
      final data = jsonDecode(json) as List;
      return data.map((refuelingData) => Refueling.fromJson(refuelingData)).toList();
    } catch (e) {
      print('Error getting queued refuelings: $e');
      return [];
    }
  }

  Future<void> removeQueuedRefueling(Refueling refueling) async {
    if (_prefs == null) return;
    
    try {
      final queue = await getQueuedRefuelings();
      queue.removeWhere((r) => 
          r.vehicleId == refueling.vehicleId &&
          r.refuelDate == refueling.refuelDate &&
          r.odometer == refueling.odometer);
      
      final json = jsonEncode(queue.map((r) => r.toJson()).toList());
      await _prefs!.setString(_refuelingQueueKey, json);
    } catch (e) {
      print('Error removing queued refueling: $e');
    }
  }

  Future<void> clearRefuelingQueue() async {
    if (_prefs == null) return;
    await _prefs!.remove(_refuelingQueueKey);
  }

  // Cost Queue
  Future<void> queueCost(Cost cost) async {
    if (_prefs == null) return;
    
    try {
      final queue = await getQueuedCosts();
      queue.add(cost);
      
      final json = jsonEncode(queue.map((c) => c.toJson()).toList());
      await _prefs!.setString(_costQueueKey, json);
    } catch (e) {
      print('Error queueing cost: $e');
    }
  }

  Future<List<Cost>> getQueuedCosts() async {
    if (_prefs == null) return [];
    
    try {
      final json = _prefs!.getString(_costQueueKey);
      if (json == null) return [];
      
      final data = jsonDecode(json) as List;
      return data.map((costData) => Cost.fromJson(costData)).toList();
    } catch (e) {
      print('Error getting queued costs: $e');
      return [];
    }
  }

  Future<void> removeQueuedCost(Cost cost) async {
    if (_prefs == null) return;
    
    try {
      final queue = await getQueuedCosts();
      queue.removeWhere((c) => 
          c.tripId == cost.tripId &&
          c.tipoCusto == cost.tipoCusto &&
          c.descricao == cost.descricao &&
          c.valor == cost.valor);
      
      final json = jsonEncode(queue.map((c) => c.toJson()).toList());
      await _prefs!.setString(_costQueueKey, json);
    } catch (e) {
      print('Error removing queued cost: $e');
    }
  }

  Future<void> clearCostQueue() async {
    if (_prefs == null) return;
    await _prefs!.remove(_costQueueKey);
  }

  // Trip Finalization Queue
  Future<void> queueTripFinalization(int tripId, double distance) async {
    if (_prefs == null) return;
    
    try {
      final queue = await getQueuedTripFinalizations();
      queue.add({
        'tripId': tripId,
        'distance': distance,
        'timestamp': DateTime.now().toIso8601String(),
      });
      
      final json = jsonEncode(queue);
      await _prefs!.setString(_tripFinalizationQueueKey, json);
    } catch (e) {
      print('Error queueing trip finalization: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getQueuedTripFinalizations() async {
    if (_prefs == null) return [];
    
    try {
      final json = _prefs!.getString(_tripFinalizationQueueKey);
      if (json == null) return [];
      
      final data = jsonDecode(json) as List;
      return data.cast<Map<String, dynamic>>();
    } catch (e) {
      print('Error getting queued trip finalizations: $e');
      return [];
    }
  }

  Future<void> removeQueuedTripFinalization(Map<String, dynamic> finalization) async {
    if (_prefs == null) return;
    
    try {
      final queue = await getQueuedTripFinalizations();
      queue.removeWhere((f) => f['tripId'] == finalization['tripId']);
      
      final json = jsonEncode(queue);
      await _prefs!.setString(_tripFinalizationQueueKey, json);
    } catch (e) {
      print('Error removing queued trip finalization: $e');
    }
  }

  Future<void> clearTripFinalizationQueue() async {
    if (_prefs == null) return;
    await _prefs!.remove(_tripFinalizationQueueKey);
  }

  // Queue Management
  Future<void> clearAllQueues() async {
    if (_prefs == null) return;
    
    await Future.wait([
      clearRefuelingQueue(),
      clearCostQueue(),
      clearTripFinalizationQueue(),
    ]);
  }

  Future<int> getTotalQueuedItems() async {
    final refuelings = await getQueuedRefuelings();
    final costs = await getQueuedCosts();
    final finalizations = await getQueuedTripFinalizations();
    
    return refuelings.length + costs.length + finalizations.length;
  }

  Future<Map<String, dynamic>> getQueueStats() async {
    final refuelings = await getQueuedRefuelings();
    final costs = await getQueuedCosts();
    final finalizations = await getQueuedTripFinalizations();
    
    return {
      'refuelings': refuelings.length,
      'costs': costs.length,
      'finalizations': finalizations.length,
      'total': refuelings.length + costs.length + finalizations.length,
    };
  }
}
