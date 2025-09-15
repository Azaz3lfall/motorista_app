import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/driver_profile.dart';
import '../models/trip.dart';

class CacheService {
  static final CacheService _instance = CacheService._internal();
  factory CacheService() => _instance;
  CacheService._internal();

  SharedPreferences? _prefs;

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Cache keys
  static const String _driverProfileKey = 'cached_driver_profile';
  static const String _tripsKey = 'cached_trips';
  static const String _lastUpdateKey = 'last_cache_update';
  static const String _cacheExpiryKey = 'cache_expiry_hours';

  // Cache expiry time in hours
  static const int _defaultCacheExpiryHours = 1;

  // Driver Profile Cache
  Future<void> cacheDriverProfile(DriverProfile profile) async {
    if (_prefs == null) return;
    
    try {
      final json = jsonEncode(profile.toJson());
      await _prefs!.setString(_driverProfileKey, json);
      await _updateLastCacheTime();
    } catch (e) {
      print('Error caching driver profile: $e');
    }
  }

  Future<DriverProfile?> getCachedDriverProfile() async {
    if (_prefs == null) return null;
    
    try {
      final json = _prefs!.getString(_driverProfileKey);
      if (json == null) return null;
      
      if (await _isCacheExpired()) {
        await clearDriverProfileCache();
        return null;
      }
      
      final data = jsonDecode(json);
      return DriverProfile.fromJson(data);
    } catch (e) {
      print('Error getting cached driver profile: $e');
      return null;
    }
  }

  Future<void> clearDriverProfileCache() async {
    if (_prefs == null) return;
    await _prefs!.remove(_driverProfileKey);
  }

  // Trips Cache
  Future<void> cacheTrips(List<Trip> trips) async {
    if (_prefs == null) return;
    
    try {
      final json = jsonEncode(trips.map((trip) => trip.toJson()).toList());
      await _prefs!.setString(_tripsKey, json);
      await _updateLastCacheTime();
    } catch (e) {
      print('Error caching trips: $e');
    }
  }

  Future<List<Trip>?> getCachedTrips() async {
    if (_prefs == null) return null;
    
    try {
      final json = _prefs!.getString(_tripsKey);
      if (json == null) return null;
      
      if (await _isCacheExpired()) {
        await clearTripsCache();
        return null;
      }
      
      final data = jsonDecode(json) as List;
      return data.map((tripData) => Trip.fromJson(tripData)).toList();
    } catch (e) {
      print('Error getting cached trips: $e');
      return null;
    }
  }

  Future<void> clearTripsCache() async {
    if (_prefs == null) return;
    await _prefs!.remove(_tripsKey);
  }

  // Cache Management
  Future<void> clearAllCache() async {
    if (_prefs == null) return;
    
    await Future.wait([
      clearDriverProfileCache(),
      clearTripsCache(),
      _prefs!.remove(_lastUpdateKey),
    ]);
  }

  Future<void> setCacheExpiry(int hours) async {
    if (_prefs == null) return;
    await _prefs!.setInt(_cacheExpiryKey, hours);
  }

  Future<int> getCacheExpiry() async {
    if (_prefs == null) return _defaultCacheExpiryHours;
    return _prefs!.getInt(_cacheExpiryKey) ?? _defaultCacheExpiryHours;
  }

  // Private methods
  Future<void> _updateLastCacheTime() async {
    if (_prefs == null) return;
    await _prefs!.setString(_lastUpdateKey, DateTime.now().toIso8601String());
  }

  Future<bool> _isCacheExpired() async {
    if (_prefs == null) return true;
    
    try {
      final lastUpdateStr = _prefs!.getString(_lastUpdateKey);
      if (lastUpdateStr == null) return true;
      
      final lastUpdate = DateTime.parse(lastUpdateStr);
      final expiryHours = await getCacheExpiry();
      final expiryTime = lastUpdate.add(Duration(hours: expiryHours));
      
      return DateTime.now().isAfter(expiryTime);
    } catch (e) {
      print('Error checking cache expiry: $e');
      return true;
    }
  }

  // Cache statistics
  Future<Map<String, dynamic>> getCacheStats() async {
    if (_prefs == null) return {};
    
    try {
      final lastUpdateStr = _prefs!.getString(_lastUpdateKey);
      final hasDriverProfile = _prefs!.containsKey(_driverProfileKey);
      final hasTrips = _prefs!.containsKey(_tripsKey);
      final expiryHours = await getCacheExpiry();
      
      return {
        'lastUpdate': lastUpdateStr,
        'hasDriverProfile': hasDriverProfile,
        'hasTrips': hasTrips,
        'expiryHours': expiryHours,
        'isExpired': await _isCacheExpired(),
      };
    } catch (e) {
      print('Error getting cache stats: $e');
      return {};
    }
  }
}
