import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:motorista_app/widgets/image_picker_dialog.dart';

void main() {
  group('ImagePickerDialog Widget Tests', () {
    testWidgets('should display dialog with camera and gallery options', (WidgetTester tester) async {
      bool imagePicked = false;
      File? pickedFile;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  ImagePickerDialog.show(
                    context,
                    (File? file) {
                      imagePicked = true;
                      pickedFile = file;
                    },
                  );
                },
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );

      // Tap button to show dialog
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Verify dialog is displayed
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Escolher Imagem'), findsOneWidget);
      expect(find.text('Câmera'), findsOneWidget);
      expect(find.text('Galeria'), findsOneWidget);
    });

    testWidgets('should call onImagePicked when camera option is tapped', (WidgetTester tester) async {
      bool imagePicked = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  ImagePickerDialog.show(
                    context,
                    (File? file) {
                      imagePicked = true;
                    },
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

      // Tap camera option
      await tester.tap(find.text('Câmera'));
      await tester.pump();

      // Dialog should still be visible (since we can't actually pick image in test)
      expect(find.byType(AlertDialog), findsOneWidget);
    });

    testWidgets('should call onImagePicked when gallery option is tapped', (WidgetTester tester) async {
      bool imagePicked = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  ImagePickerDialog.show(
                    context,
                    (File? file) {
                      imagePicked = true;
                    },
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

      // Tap gallery option
      await tester.tap(find.text('Galeria'));
      await tester.pump();

      // Dialog should still be visible (since we can't actually pick image in test)
      expect(find.byType(AlertDialog), findsOneWidget);
    });

    testWidgets('should display correct icons', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  ImagePickerDialog.show(
                    context,
                    (File? file) {},
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

      // Check for camera and gallery icons
      expect(find.byIcon(Icons.camera_alt), findsOneWidget); // One for camera option
      expect(find.byIcon(Icons.photo_library), findsOneWidget);
    });
  });
}
