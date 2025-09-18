class Constants {
  // API Configuration
  static const String baseUrl = 'http://104.251.211.91:3666';
  
  // Storage Keys
  static const String jwtTokenKey = 'jwt_token';
  static const String userPreferencesKey = 'user_preferences';
  
  // App Configuration
  static const String appName = 'App Motorista';
  static const String appVersion = '1.0.0';
  
  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  
  // Image Configuration
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB
  static const List<String> allowedImageExtensions = ['jpg', 'jpeg', 'png', 'gif'];
  
  // Trip Status
  static const String tripStatusEmAndamento = 'Em Andamento';
  static const String tripStatusFinalizada = 'Finalizada';
  static const String tripStatusCancelada = 'Cancelada';
  
  // Cost Types
  static const String costTypePedagio = 'PEDAGIO';
  static const String costTypeAlimentacao = 'ALIMENTACAO';
  static const String costTypeManutencao = 'MANUTENCAO';
  static const String costTypeOutros = 'OUTROS';
  
  // Error Messages
  static const String errorNetworkConnection = 'Erro de conexão. Verifique sua internet.';
  static const String errorUnauthorized = 'Sessão expirada. Faça login novamente.';
  static const String errorGeneric = 'Ocorreu um erro inesperado.';
  static const String errorInvalidCredentials = 'Credenciais inválidas.';
  static const String errorNoVehicles = 'Nenhum veículo associado ao seu perfil.';
  static const String errorNoTrips = 'Nenhuma viagem em andamento.';
  
  // Success Messages
  static const String successLogin = 'Login realizado com sucesso!';
  static const String successRefueling = 'Abastecimento registrado com sucesso!';
  static const String successCostAdded = 'Custo adicionado com sucesso!';
  static const String successTripFinalized = 'Viagem finalizada com sucesso!';
  static const String successImageUpload = 'Imagem enviada com sucesso!';
}

