import 'package:flutter_test/flutter_test.dart';
import 'package:motorista_app/models/trip.dart';

void main() {
  group('Trip Model Tests', () {
    test('should create Trip from JSON', () {
      // Arrange
      final json = {
        'id': 1,
        'start_city': 'São Paulo',
        'end_city': 'Rio de Janeiro',
        'start_date': '2024-01-15T10:00:00Z',
        'status': 'Em Andamento',
      };

      // Act
      final trip = Trip.fromJson(json);

      // Assert
      expect(trip.id, 1);
      expect(trip.startCity, 'São Paulo');
      expect(trip.endCity, 'Rio de Janeiro');
      expect(trip.startDate, '2024-01-15T10:00:00Z');
      expect(trip.status, 'Em Andamento');
    });

    test('should convert Trip to JSON', () {
      // Arrange
      final trip = Trip(
        id: 1,
        startCity: 'São Paulo',
        endCity: 'Rio de Janeiro',
        startDate: '2024-01-15T10:00:00Z',
        status: 'Em Andamento',
      );

      // Act
      final json = trip.toJson();

      // Assert
      expect(json['id'], 1);
      expect(json['start_city'], 'São Paulo');
      expect(json['end_city'], 'Rio de Janeiro');
      expect(json['start_date'], '2024-01-15T10:00:00Z');
      expect(json['status'], 'Em Andamento');
    });

    test('should return correct string representation', () {
      // Arrange
      final trip = Trip(
        id: 1,
        startCity: 'São Paulo',
        endCity: 'Rio de Janeiro',
        startDate: '2024-01-15T10:00:00Z',
        status: 'Em Andamento',
      );

      // Act
      final string = trip.toString();

      // Assert
      expect(string, 'Trip(id: 1, from: São Paulo to: Rio de Janeiro, date: 2024-01-15T10:00:00Z, status: Em Andamento)');
    });

    test('should handle null values in JSON', () {
      // Arrange
      final json = {
        'id': 1,
        'start_city': null,
        'end_city': null,
        'start_date': null,
        'status': null,
      };

      // Act
      final trip = Trip.fromJson(json);

      // Assert
      expect(trip.id, 1);
      expect(trip.startCity, '');
      expect(trip.endCity, '');
      expect(trip.startDate, '');
      expect(trip.status, '');
    });

    test('should be equal when same properties', () {
      // Arrange
      final trip1 = Trip(
        id: 1,
        startCity: 'São Paulo',
        endCity: 'Rio de Janeiro',
        startDate: '2024-01-15T10:00:00Z',
        status: 'Em Andamento',
      );
      final trip2 = Trip(
        id: 1,
        startCity: 'São Paulo',
        endCity: 'Rio de Janeiro',
        startDate: '2024-01-15T10:00:00Z',
        status: 'Em Andamento',
      );

      // Act & Assert
      expect(trip1, equals(trip2));
      expect(trip1.hashCode, equals(trip2.hashCode));
    });
  });
}

