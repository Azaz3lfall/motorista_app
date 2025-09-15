import 'package:flutter_test/flutter_test.dart';
import 'package:motorista_app/utils/validators.dart';

void main() {
  group('Validators Tests', () {
    group('validateRequired', () {
      test('should return null for valid value', () {
        expect(Validators.validateRequired('test', 'campo'), isNull);
      });

      test('should return error for null value', () {
        expect(Validators.validateRequired(null, 'campo'), 'Campo campo é obrigatório');
      });

      test('should return error for empty value', () {
        expect(Validators.validateRequired('', 'campo'), 'Campo campo é obrigatório');
      });

      test('should return error for whitespace only value', () {
        expect(Validators.validateRequired('   ', 'campo'), 'Campo campo é obrigatório');
      });
    });

    group('validateEmail', () {
      test('should return null for valid email', () {
        expect(Validators.validateEmail('test@example.com'), isNull);
      });

      test('should return error for null email', () {
        expect(Validators.validateEmail(null), 'Email é obrigatório');
      });

      test('should return error for empty email', () {
        expect(Validators.validateEmail(''), 'Email é obrigatório');
      });

      test('should return error for invalid email format', () {
        expect(Validators.validateEmail('invalid-email'), 'Email inválido');
        expect(Validators.validateEmail('test@'), 'Email inválido');
        expect(Validators.validateEmail('@example.com'), 'Email inválido');
      });
    });

    group('validatePassword', () {
      test('should return null for valid password', () {
        expect(Validators.validatePassword('password123'), isNull);
      });

      test('should return error for null password', () {
        expect(Validators.validatePassword(null), 'Senha é obrigatória');
      });

      test('should return error for empty password', () {
        expect(Validators.validatePassword(''), 'Senha é obrigatória');
      });

      test('should return error for short password', () {
        expect(Validators.validatePassword('12345'), 'Senha deve ter pelo menos 6 caracteres');
      });
    });

    group('validateNumeric', () {
      test('should return null for valid number', () {
        expect(Validators.validateNumeric('123.45', 'campo'), isNull);
        expect(Validators.validateNumeric('123,45', 'campo'), isNull);
      });

      test('should return error for null value', () {
        expect(Validators.validateNumeric(null, 'campo'), 'Campo campo é obrigatório');
      });

      test('should return error for empty value', () {
        expect(Validators.validateNumeric('', 'campo'), 'Campo campo é obrigatório');
      });

      test('should return error for non-numeric value', () {
        expect(Validators.validateNumeric('abc', 'campo'), 'Campo campo deve ser um número válido');
      });

      test('should return error for negative number', () {
        expect(Validators.validateNumeric('-10', 'campo'), 'Campo campo deve ser um número positivo');
      });
    });

    group('validatePositiveNumber', () {
      test('should return null for positive number', () {
        expect(Validators.validatePositiveNumber('10.5', 'campo'), isNull);
      });

      test('should return error for zero', () {
        expect(Validators.validatePositiveNumber('0', 'campo'), 'Campo campo deve ser maior que zero');
      });

      test('should return error for negative number', () {
        expect(Validators.validatePositiveNumber('-5', 'campo'), 'Campo campo deve ser um número positivo');
      });
    });

    group('validateOdometer', () {
      test('should return null for valid odometer', () {
        expect(Validators.validateOdometer('1000'), isNull);
      });

      test('should return error for invalid odometer', () {
        expect(Validators.validateOdometer('0'), 'Campo Hodômetro deve ser maior que zero');
        expect(Validators.validateOdometer('-100'), 'Campo Hodômetro deve ser um número positivo');
      });
    });

    group('validateLiters', () {
      test('should return null for valid liters', () {
        expect(Validators.validateLiters('50'), isNull);
      });

      test('should return error for invalid liters', () {
        expect(Validators.validateLiters('0'), 'Campo Litros deve ser maior que zero');
      });
    });

    group('validateCost', () {
      test('should return null for valid cost', () {
        expect(Validators.validateCost('25.50'), isNull);
      });

      test('should return error for invalid cost', () {
        expect(Validators.validateCost('0'), 'Campo Valor deve ser maior que zero');
      });
    });

    group('validateDistance', () {
      test('should return null for valid distance', () {
        expect(Validators.validateDistance('100'), isNull);
      });

      test('should return error for invalid distance', () {
        expect(Validators.validateDistance('0'), 'Campo Distância deve ser maior que zero');
      });
    });

    group('validateVehicleSelection', () {
      test('should return null for valid selection', () {
        expect(Validators.validateVehicleSelection(1), isNull);
      });

      test('should return error for null selection', () {
        expect(Validators.validateVehicleSelection(null), 'Selecione um veículo');
      });
    });

    group('validateCostType', () {
      test('should return null for valid cost type', () {
        expect(Validators.validateCostType('PEDAGIO'), isNull);
      });

      test('should return error for null cost type', () {
        expect(Validators.validateCostType(null), 'Selecione o tipo de custo');
      });

      test('should return error for empty cost type', () {
        expect(Validators.validateCostType(''), 'Selecione o tipo de custo');
      });
    });

    group('validateDescription', () {
      test('should return null for valid description', () {
        expect(Validators.validateDescription('Valid description'), isNull);
      });

      test('should return error for null description', () {
        expect(Validators.validateDescription(null), 'Descrição é obrigatória');
      });

      test('should return error for empty description', () {
        expect(Validators.validateDescription(''), 'Descrição é obrigatória');
      });

      test('should return error for short description', () {
        expect(Validators.validateDescription('ab'), 'Descrição deve ter pelo menos 3 caracteres');
      });
    });

    group('validatePostoName', () {
      test('should return null for valid posto name', () {
        expect(Validators.validatePostoName('Posto Shell'), isNull);
      });

      test('should return error for null posto name', () {
        expect(Validators.validatePostoName(null), 'Nome do posto é obrigatório');
      });

      test('should return error for short posto name', () {
        expect(Validators.validatePostoName('A'), 'Nome do posto deve ter pelo menos 2 caracteres');
      });
    });

    group('validateCity', () {
      test('should return null for valid city', () {
        expect(Validators.validateCity('São Paulo'), isNull);
      });

      test('should return error for null city', () {
        expect(Validators.validateCity(null), 'Cidade é obrigatória');
      });

      test('should return error for short city', () {
        expect(Validators.validateCity('A'), 'Cidade deve ter pelo menos 2 caracteres');
      });
    });
  });
}
