import 'package:flutter_test/flutter_test.dart';
import 'package:motorista_app/models/driver_profile.dart';
import 'package:motorista_app/models/vehicle.dart';

void main() {
  group('DriverProfile Model Tests', () {
    test('should create DriverProfile from JSON', () {
      // Arrange
      final json = {
        'id': 1,
        'name': 'João Silva',
        'associated_vehicles': [
          {'id': 1, 'name': 'Caminhão 001'},
          {'id': 2, 'name': 'Caminhão 002'},
        ],
      };

      // Act
      final driverProfile = DriverProfile.fromJson(json);

      // Assert
      expect(driverProfile.id, 1);
      expect(driverProfile.name, 'João Silva');
      expect(driverProfile.associatedVehicles.length, 2);
      expect(driverProfile.associatedVehicles[0].name, 'Caminhão 001');
      expect(driverProfile.associatedVehicles[1].name, 'Caminhão 002');
    });

    test('should convert DriverProfile to JSON', () {
      // Arrange
      final vehicles = [
        Vehicle(id: 1, name: 'Caminhão 001'),
        Vehicle(id: 2, name: 'Caminhão 002'),
      ];
      final driverProfile = DriverProfile(
        id: 1,
        name: 'João Silva',
        associatedVehicles: vehicles,
      );

      // Act
      final json = driverProfile.toJson();

      // Assert
      expect(json['id'], 1);
      expect(json['name'], 'João Silva');
      expect(json['associated_vehicles'], isA<List>());
      expect(json['associated_vehicles'].length, 2);
    });

    test('should return correct string representation', () {
      // Arrange
      final vehicles = [Vehicle(id: 1, name: 'Caminhão 001')];
      final driverProfile = DriverProfile(
        id: 1,
        name: 'João Silva',
        associatedVehicles: vehicles,
      );

      // Act
      final string = driverProfile.toString();

      // Assert
      expect(string, 'DriverProfile(id: 1, name: João Silva, vehicles: 1)');
    });

    test('should handle empty vehicles list', () {
      // Arrange
      final json = {
        'id': 1,
        'name': 'João Silva',
        'associated_vehicles': [],
      };

      // Act
      final driverProfile = DriverProfile.fromJson(json);

      // Assert
      expect(driverProfile.associatedVehicles, isEmpty);
    });
  });
}
