import 'package:flutter_test/flutter_test.dart';
import 'package:motorista_app/utils/helpers.dart';

void main() {
  group('Helpers Tests', () {
    group('Date formatting', () {
      test('should format date correctly', () {
        final date = DateTime(2024, 1, 15);
        expect(Helpers.formatDate(date), '15/01/2024');
      });

      test('should format date time correctly', () {
        final dateTime = DateTime(2024, 1, 15, 14, 30);
        expect(Helpers.formatDateTime(dateTime), '15/01/2024 14:30');
      });

      test('should format time correctly', () {
        final dateTime = DateTime(2024, 1, 15, 14, 30);
        expect(Helpers.formatTime(dateTime), '14:30');
      });
    });

    group('Currency formatting', () {
      test('should format currency correctly', () {
        expect(Helpers.formatCurrency(1234.56), 'R\$ 1.234,56');
        expect(Helpers.formatCurrency(0), 'R\$ 0,00');
        expect(Helpers.formatCurrency(100), 'R\$ 100,00');
      });
    });

    group('Number formatting', () {
      test('should format number with default decimal places', () {
        expect(Helpers.formatNumber(1234.567), '1.234,57');
        expect(Helpers.formatNumber(0), '0,00');
      });

      test('should format number with custom decimal places', () {
        expect(Helpers.formatNumber(1234.567, decimalPlaces: 1), '1.234,6');
        expect(Helpers.formatNumber(1234.567, decimalPlaces: 0), '1.235,');
      });
    });

    group('String utilities', () {
      test('should capitalize first letter', () {
        expect(Helpers.capitalize('hello'), 'Hello');
        expect(Helpers.capitalize('HELLO'), 'Hello');
        expect(Helpers.capitalize(''), '');
      });

      test('should capitalize words', () {
        expect(Helpers.capitalizeWords('hello world'), 'Hello World');
        expect(Helpers.capitalizeWords('HELLO WORLD'), 'Hello World');
        expect(Helpers.capitalizeWords(''), '');
      });
    });

    group('Input parsing', () {
      test('should parse double correctly', () {
        expect(Helpers.parseDouble('123.45'), 123.45);
        expect(Helpers.parseDouble('123,45'), 123.45);
        expect(Helpers.parseDouble('0'), 0.0);
        expect(Helpers.parseDouble(null), isNull);
        expect(Helpers.parseDouble(''), isNull);
        expect(Helpers.parseDouble('abc'), isNull);
      });

      test('should parse int correctly', () {
        expect(Helpers.parseInt('123'), 123);
        expect(Helpers.parseInt('0'), 0);
        expect(Helpers.parseInt(null), isNull);
        expect(Helpers.parseInt(''), isNull);
        expect(Helpers.parseInt('abc'), isNull);
      });
    });

    group('Validation helpers', () {
      test('should validate email correctly', () {
        expect(Helpers.isValidEmail('test@example.com'), isTrue);
        expect(Helpers.isValidEmail('user.name@domain.co.uk'), isTrue);
        expect(Helpers.isValidEmail('invalid-email'), isFalse);
        expect(Helpers.isValidEmail('test@'), isFalse);
        expect(Helpers.isValidEmail('@example.com'), isFalse);
      });

      test('should validate phone correctly', () {
        expect(Helpers.isValidPhone('(11) 99999-9999'), isTrue);
        expect(Helpers.isValidPhone('(11) 9999-9999'), isTrue);
        expect(Helpers.isValidPhone('11999999999'), isFalse);
        expect(Helpers.isValidPhone('(11) 99999-999'), isFalse);
      });
    });

    group('File helpers', () {
      test('should get file extension correctly', () {
        expect(Helpers.getFileExtension('image.jpg'), 'jpg');
        expect(Helpers.getFileExtension('document.pdf'), 'pdf');
        expect(Helpers.getFileExtension('file'), 'file');
      });

      test('should check if file is image', () {
        expect(Helpers.isImageFile('image.jpg'), isTrue);
        expect(Helpers.isImageFile('image.png'), isTrue);
        expect(Helpers.isImageFile('image.jpeg'), isTrue);
        expect(Helpers.isImageFile('image.gif'), isTrue);
        expect(Helpers.isImageFile('document.pdf'), isFalse);
        expect(Helpers.isImageFile('text.txt'), isFalse);
      });

      test('should format file size correctly', () {
        expect(Helpers.formatFileSize(1024), '1.0 KB');
        expect(Helpers.formatFileSize(1024 * 1024), '1.0 MB');
        expect(Helpers.formatFileSize(1024 * 1024 * 1024), '1.0 GB');
        expect(Helpers.formatFileSize(512), '512 B');
      });
    });
  });
}
