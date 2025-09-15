class Validators {
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'Campo $fieldName é obrigatório';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email é obrigatório';
    }
    
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Email inválido';
    }
    
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Senha é obrigatória';
    }
    
    if (value.length < 6) {
      return 'Senha deve ter pelo menos 6 caracteres';
    }
    
    return null;
  }

  static String? validateNumeric(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'Campo $fieldName é obrigatório';
    }
    
    final numericValue = double.tryParse(value.replaceAll(',', '.'));
    if (numericValue == null) {
      return 'Campo $fieldName deve ser um número válido';
    }
    
    if (numericValue < 0) {
      return 'Campo $fieldName deve ser um número positivo';
    }
    
    return null;
  }

  static String? validatePositiveNumber(String? value, String fieldName) {
    final error = validateNumeric(value, fieldName);
    if (error != null) return error;
    
    final numericValue = double.tryParse(value!.replaceAll(',', '.'));
    if (numericValue! <= 0) {
      return 'Campo $fieldName deve ser maior que zero';
    }
    
    return null;
  }

  static String? validateOdometer(String? value) {
    return validatePositiveNumber(value, 'Hodômetro');
  }

  static String? validateLiters(String? value) {
    return validatePositiveNumber(value, 'Litros');
  }

  static String? validateCost(String? value) {
    return validatePositiveNumber(value, 'Valor');
  }

  static String? validateDistance(String? value) {
    return validatePositiveNumber(value, 'Distância');
  }

  static String? validateVehicleSelection(int? value) {
    if (value == null) {
      return 'Selecione um veículo';
    }
    return null;
  }

  static String? validateCostType(String? value) {
    if (value == null || value.isEmpty) {
      return 'Selecione o tipo de custo';
    }
    return null;
  }

  static String? validateDescription(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Descrição é obrigatória';
    }
    
    if (value.trim().length < 3) {
      return 'Descrição deve ter pelo menos 3 caracteres';
    }
    
    return null;
  }

  static String? validatePostoName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nome do posto é obrigatório';
    }
    
    if (value.trim().length < 2) {
      return 'Nome do posto deve ter pelo menos 2 caracteres';
    }
    
    return null;
  }

  static String? validateCity(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Cidade é obrigatória';
    }
    
    if (value.trim().length < 2) {
      return 'Cidade deve ter pelo menos 2 caracteres';
    }
    
    return null;
  }
}
