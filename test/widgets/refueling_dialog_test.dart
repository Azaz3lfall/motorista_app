import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:motorista_app/models/vehicle.dart';
import 'package:motorista_app/models/refueling.dart';
import 'package:motorista_app/widgets/refueling_dialog.dart';

void main() {
  group('RefuelingDialog Widget Tests', () {
    final vehicles = [
      Vehicle(id: 1, name: 'Caminhão 001'),
      Vehicle(id: 2, name: 'Caminhão 002'),
    ];

    testWidgets('should display dialog with all required fields', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showDialog<void>(
                    context: context,
                    builder: (context) => RefuelingDialog(
                      vehicles: vehicles,
                      onRefuelingAdded: (Refueling refueling) {},
                    ),
                  );
                },
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );

      // Show dialog
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Verify dialog is displayed with correct title
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Abastecimento Avulso'), findsOneWidget);

      // Verify all form fields are present
      expect(find.text('Veículo'), findsOneWidget);
      expect(find.text('Hodômetro (km)'), findsOneWidget);
      expect(find.text('Litros'), findsOneWidget);
      expect(find.text('Valor Total (R\$)'), findsOneWidget);
      expect(find.text('Nome do Posto'), findsOneWidget);
      expect(find.text('Cidade'), findsOneWidget);
      expect(find.text('Tanque Cheio'), findsOneWidget);
      expect(find.text('Foto Bomba (opcional)'), findsOneWidget);
      expect(find.text('Foto Hodômetro (opcional)'), findsOneWidget);

      // Verify action buttons
      expect(find.text('Cancelar'), findsOneWidget);
      expect(find.text('Registrar'), findsOneWidget);
    });

    testWidgets('should display vehicle dropdown when multiple vehicles', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showDialog<void>(
                    context: context,
                    builder: (context) => RefuelingDialog(
                      vehicles: vehicles,
                      onRefuelingAdded: (Refueling refueling) {},
                    ),
                  );
                },
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );

      // Show dialog
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Verify dropdown is present
      expect(find.byType(DropdownButtonFormField<int>), findsOneWidget);
    });

    testWidgets('should display vehicle name when single vehicle', (WidgetTester tester) async {
      final singleVehicle = [Vehicle(id: 1, name: 'Caminhão 001')];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showDialog<void>(
                    context: context,
                    builder: (context) => RefuelingDialog(
                      vehicles: singleVehicle,
                      onRefuelingAdded: (Refueling refueling) {},
                    ),
                  );
                },
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );

      // Show dialog
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Verify vehicle name is displayed instead of dropdown
      expect(find.text('Veículo: Caminhão 001'), findsOneWidget);
      expect(find.byType(DropdownButtonFormField<int>), findsNothing);
    });

    testWidgets('should show trip title when tripId is provided', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showDialog<void>(
                    context: context,
                    builder: (context) => RefuelingDialog(
                      vehicles: vehicles,
                      tripId: 1,
                      onRefuelingAdded: (Refueling refueling) {},
                    ),
                  );
                },
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );

      // Show dialog
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Verify trip title is displayed
      expect(find.text('Abastecimento em Viagem'), findsOneWidget);
    });

    testWidgets('should validate required fields', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showDialog<void>(
                    context: context,
                    builder: (context) => RefuelingDialog(
                      vehicles: vehicles,
                      onRefuelingAdded: (Refueling refueling) {},
                    ),
                  );
                },
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );

      // Show dialog
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Try to submit without filling fields
      await tester.tap(find.text('Registrar'));
      await tester.pumpAndSettle();

      // Should show validation errors
      expect(find.text('Campo Hodômetro é obrigatório'), findsOneWidget);
      expect(find.text('Campo Litros é obrigatório'), findsOneWidget);
      expect(find.text('Campo Valor Total é obrigatório'), findsOneWidget);
      expect(find.text('Nome do posto é obrigatório'), findsOneWidget);
      expect(find.text('Cidade é obrigatória'), findsOneWidget);
    });

    testWidgets('should show loading indicator when submitting', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showDialog<void>(
                    context: context,
                    builder: (context) => RefuelingDialog(
                      vehicles: vehicles,
                      onRefuelingAdded: (Refueling refueling) async {
                        // Simulate async operation
                        await Future.delayed(const Duration(seconds: 1));
                      },
                    ),
                  );
                },
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );

      // Show dialog
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Fill required fields
      await tester.enterText(find.byType(TextFormField).at(0), '1000'); // Odometer
      await tester.enterText(find.byType(TextFormField).at(1), '50'); // Liters
      await tester.enterText(find.byType(TextFormField).at(2), '200'); // Cost
      await tester.enterText(find.byType(TextFormField).at(3), 'Posto Shell'); // Posto
      await tester.enterText(find.byType(TextFormField).at(4), 'São Paulo'); // City

      // Submit form
      await tester.tap(find.text('Registrar'));
      await tester.pump();

      // Should show loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
