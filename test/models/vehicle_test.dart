import 'package:flutter_test/flutter_test.dart';
import 'package:motorista_app/models/vehicle.dart';

void main() {
  group('Vehicle Model Tests', () {
    test('should create Vehicle from JSON', () {
      // Arrange
      final json = {
        'id': 1,
        'name': 'Caminhão 001',
      };

      // Act
      final vehicle = Vehicle.fromJson(json);

      // Assert
      expect(vehicle.id, 1);
      expect(vehicle.name, 'Caminhão 001');
    });

    test('should convert Vehicle to JSON', () {
      // Arrange
      final vehicle = Vehicle(id: 1, name: 'Caminhão 001');

      // Act
      final json = vehicle.toJson();

      // Assert
      expect(json['id'], 1);
      expect(json['name'], 'Caminhão 001');
    });

    test('should return correct string representation', () {
      // Arrange
      final vehicle = Vehicle(id: 1, name: 'Caminhão 001');

      // Act
      final string = vehicle.toString();

      // Assert
      expect(string, 'Vehicle(id: 1, name: Caminhão 001)');
    });

    test('should be equal when same id and name', () {
      // Arrange
      final vehicle1 = Vehicle(id: 1, name: 'Caminhão 001');
      final vehicle2 = Vehicle(id: 1, name: 'Caminhão 001');

      // Act & Assert
      expect(vehicle1, equals(vehicle2));
      expect(vehicle1.hashCode, equals(vehicle2.hashCode));
    });

    test('should not be equal when different properties', () {
      // Arrange
      final vehicle1 = Vehicle(id: 1, name: 'Caminhão 001');
      final vehicle2 = Vehicle(id: 2, name: 'Caminhão 002');

      // Act & Assert
      expect(vehicle1, isNot(equals(vehicle2)));
    });
  });
}

