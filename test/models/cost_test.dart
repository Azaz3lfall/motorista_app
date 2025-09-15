import 'package:flutter_test/flutter_test.dart';
import 'package:motorista_app/models/cost.dart';

void main() {
  group('Cost Model Tests', () {
    test('should create Cost from JSON', () {
      // Arrange
      final json = {
        'id': 1,
        'viagem_id': 1,
        'tipo_custo': 'PEDAGIO',
        'descricao': 'Pedágio SP-RJ',
        'valor': 25.50,
        'vehicle_id': 1,
      };

      // Act
      final cost = Cost.fromJson(json);

      // Assert
      expect(cost.id, 1);
      expect(cost.tripId, 1);
      expect(cost.tipoCusto, CostType.pedagio);
      expect(cost.descricao, 'Pedágio SP-RJ');
      expect(cost.valor, 25.50);
      expect(cost.vehicleId, 1);
    });

    test('should convert Cost to JSON', () {
      // Arrange
      final cost = Cost(
        id: 1,
        tripId: 1,
        tipoCusto: CostType.pedagio,
        descricao: 'Pedágio SP-RJ',
        valor: 25.50,
        vehicleId: 1,
      );

      // Act
      final json = cost.toJson();

      // Assert
      expect(json['id'], 1);
      expect(json['viagem_id'], 1);
      expect(json['tipo_custo'], 'PEDAGIO');
      expect(json['descricao'], 'Pedágio SP-RJ');
      expect(json['valor'], 25.50);
      expect(json['vehicle_id'], 1);
    });

    test('should return correct string representation', () {
      // Arrange
      final cost = Cost(
        tripId: 1,
        tipoCusto: CostType.pedagio,
        descricao: 'Pedágio SP-RJ',
        valor: 25.50,
        vehicleId: 1,
      );

      // Act
      final string = cost.toString();

      // Assert
      expect(string, 'Cost(id: null, tripId: 1, type: Pedágio, description: Pedágio SP-RJ, value: 25.5)');
    });

    test('should handle all cost types', () {
      // Test each cost type
      final costTypes = [
        CostType.pedagio,
        CostType.alimentacao,
        CostType.manutencao,
        CostType.outros,
      ];

      for (final costType in costTypes) {
        final cost = Cost(
          tripId: 1,
          tipoCusto: costType,
          descricao: 'Test',
          valor: 10.0,
          vehicleId: 1,
        );

        expect(cost.tipoCusto, costType);
        expect(cost.tipoCusto.displayName, isNotEmpty);
      }
    });

    test('should parse cost type from string', () {
      // Test valid cost types
      expect(CostType.fromString('PEDAGIO'), CostType.pedagio);
      expect(CostType.fromString('ALIMENTACAO'), CostType.alimentacao);
      expect(CostType.fromString('MANUTENCAO'), CostType.manutencao);
      expect(CostType.fromString('OUTROS'), CostType.outros);

      // Test invalid cost type should default to outros
      expect(CostType.fromString('INVALID'), CostType.outros);
    });
  });
}
