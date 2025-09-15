import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as p;
import '../models/driver_profile.dart';
import '../models/trip.dart';
import '../models/refueling.dart';
import '../models/cost.dart';
import '../config/api_config.dart';
import 'retry_service.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  String? _token;

  void setToken(String token) {
    _token = token;
  }

  void clearToken() {
    _token = null;
  }

  Map<String, String> get _headers {
    final headers = {
      'Content-Type': 'application/json',
    };
    
    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    
    return headers;
  }

  Future<dynamic> _handleResponse(http.Response response) async {
    if (response.statusCode == 401) {
      clearToken();
      throw UnauthorizedException('Token inválido ou expirado');
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      String errorMessage;
      try {
        final errorData = jsonDecode(response.body);
        errorMessage = errorData['error'] ?? ApiConfig.getErrorMessage(response.statusCode);
      } catch (e) {
        errorMessage = ApiConfig.getErrorMessage(response.statusCode);
      }
      
      throw ApiException(errorMessage, response.statusCode);
    }
  }

  // Authentication
  Future<String> login(String username, String password) async {
    final url = Uri.parse(ApiConfig.buildUrl('driverLogin'));
    
    print('🔐 Tentando login para usuário: $username');
    print('🌐 URL: $url');
    
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      print('📡 Status da resposta: ${response.statusCode}');
      print('📄 Corpo da resposta: ${response.body}');

      final data = await _handleResponse(response);
      final token = data['token'];
      
      if (token == null) {
        throw ApiException('Token de autenticação não fornecido na resposta');
      }
      
      print('✅ Login bem-sucedido! Token recebido.');
      setToken(token);
      return token;
    } catch (e) {
      print('❌ Erro no login: $e');
      rethrow;
    }
  }

  // Driver Profile
  Future<DriverProfile> getDriverProfile() async {
    return RetryService.retryApiOperation(() async {
      final url = Uri.parse(ApiConfig.buildUrl('driverProfile'));
      
      final response = await http.get(url, headers: _headers);
      final data = await _handleResponse(response);
      
      return DriverProfile.fromJson(data);
    });
  }

  // Trips
  Future<List<Trip>> getOpenTrips() async {
    return RetryService.retryApiOperation(() async {
      final url = Uri.parse('${ApiConfig.buildUrl('trips')}?status=Em%20Andamento');
      
      final response = await http.get(url, headers: _headers);
      final data = await _handleResponse(response);
      
      if (data is List) {
        return data.map((trip) => Trip.fromJson(trip as Map<String, dynamic>)).toList();
      }
      
      return [];
    });
  }

  Future<void> finalizeTrip(int tripId, double distanciaTotal) async {
    final url = Uri.parse(ApiConfig.buildUrl('finalizeTrip', pathParams: {'id': tripId.toString()}));
    
    final response = await http.put(
      url,
      headers: _headers,
      body: jsonEncode({
        'distancia_total': distanciaTotal,
      }),
    );

    await _handleResponse(response);
  }

  // Refueling
  Future<void> addRefueling(Refueling refueling) async {
    final url = Uri.parse(ApiConfig.buildUrl('refuelings'));
    
    final response = await http.post(
      url,
      headers: _headers,
      body: jsonEncode(refueling.toJson()),
    );

    await _handleResponse(response);
  }

  // Costs
  Future<void> addCost(Cost cost) async {
    final url = Uri.parse(ApiConfig.buildUrl('costs'));
    
    final response = await http.post(
      url,
      headers: _headers,
      body: jsonEncode(cost.toJson()),
    );

    await _handleResponse(response);
  }

  // File Upload
  Future<String> uploadImage(File imageFile) async {
    final url = Uri.parse(ApiConfig.buildUrl('upload'));
    
    String extension = p.extension(imageFile.path).toLowerCase();
    MediaType mediaType = MediaType(
      'image',
      extension.isNotEmpty ? extension.substring(1) : 'jpeg',
    );

    var request = http.MultipartRequest('POST', url)
      ..headers['Authorization'] = 'Bearer $_token'
      ..files.add(await http.MultipartFile.fromPath(
        'file',
        imageFile.path,
        contentType: mediaType,
      ));

    var response = await request.send();

    if (response.statusCode == 401) {
      clearToken();
      throw UnauthorizedException('Token inválido ou expirado');
    }

    if (response.statusCode == 200) {
      final respStr = await response.stream.bytesToString();
      final data = jsonDecode(respStr);
      return data['filePath'];
    } else {
      throw ApiException('Erro no upload da imagem: ${response.statusCode}', response.statusCode);
    }
  }
}

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, [this.statusCode]);

  @override
  String toString() => 'ApiException: $message';
}

class UnauthorizedException implements Exception {
  final String message;

  UnauthorizedException(this.message);

  @override
  String toString() => 'UnauthorizedException: $message';
}
