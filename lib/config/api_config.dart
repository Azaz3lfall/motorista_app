class ApiConfig {
  // Base URL do backend
  static const String baseUrl = 'http://104.251.211.91:3666';
  
  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);
  
  // Retry configuration
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 2);
  
  // File upload configuration
  static const int maxFileSize = 10 * 1024 * 1024; // 10MB
  static const List<String> allowedImageTypes = ['image/jpeg', 'image/png', 'image/jpg'];
  
  // JWT configuration
  static const Duration tokenRefreshThreshold = Duration(minutes: 5);
  
  // API Endpoints
  static const Map<String, String> endpoints = {
    // Authentication
    'driverLogin': '/auth/driver-login',
    'driverLogout': '/auth/driver-logout',
    
    // Driver Profile
    'driverProfile': '/app/motorista/profile',
    
    // Trips
    'trips': '/app/motorista/trips',
    'finalizeTrip': '/app/motorista/trips/{id}/finalizar',
    
    // Refueling
    'refuelings': '/app/motorista/refuelings',
    'upload': '/app/motorista/upload',
    
    // Costs
    'costs': '/app/motorista/custos',
    'standaloneCosts': '/app/motorista/custos-avulsos',
  };
  
  // Error codes mapping
  static const Map<int, String> errorMessages = {
    400: 'Dados inválidos fornecidos',
    401: 'Credenciais inválidas ou token expirado',
    403: 'Acesso negado. Você não tem permissão para esta ação',
    404: 'Recurso não encontrado',
    409: 'Conflito. O recurso já existe',
    413: 'Arquivo muito grande. Máximo permitido: 10MB',
    422: 'Dados de entrada inválidos',
    429: 'Muitas tentativas. Tente novamente em alguns minutos',
    500: 'Erro interno do servidor. Tente novamente mais tarde',
    502: 'Servidor temporariamente indisponível',
    503: 'Serviço temporariamente indisponível',
  };
  
  // Get error message for status code
  static String getErrorMessage(int statusCode) {
    return errorMessages[statusCode] ?? 'Erro desconhecido (código: $statusCode)';
  }
  
  // Build endpoint URL
  static String buildUrl(String endpoint, {Map<String, String>? pathParams}) {
    String url = endpoints[endpoint] ?? endpoint;
    
    if (pathParams != null) {
      pathParams.forEach((key, value) {
        url = url.replaceAll('{$key}', value);
      });
    }
    
    return '$baseUrl$url';
  }
  
  // Validate file for upload
  static bool isValidFile(String fileName, int fileSize) {
    if (fileSize > maxFileSize) return false;
    
    final extension = fileName.toLowerCase().split('.').last;
    return ['jpg', 'jpeg', 'png'].contains(extension);
  }
}

