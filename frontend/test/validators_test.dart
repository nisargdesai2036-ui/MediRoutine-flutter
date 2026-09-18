import 'package:flutter_test/flutter_test.dart';
import 'package:mediroutine/core/utils/validators.dart';

void main() {
  group('Validators Tests', () {
    test('validateEmail validates correctly', () {
      expect(Validators.validateEmail(''), 'Email address is required');
      expect(Validators.validateEmail(null), 'Email address is required');
      expect(
        Validators.validateEmail('invalid-email'),
        'Please enter a valid email address',
      );
      expect(
        Validators.validateEmail('test@domain'),
        'Please enter a valid email address',
      );
      expect(Validators.validateEmail('user@example.com'), isNull);
      expect(Validators.validateEmail('user.name+tag@sub.domain.co'), isNull);
    });

    test('validatePassword validates correctly', () {
      expect(Validators.validatePassword(''), 'Password is required');
      expect(Validators.validatePassword(null), 'Password is required');
      expect(
        Validators.validatePassword('12345'),
        'Password must be at least 6 characters',
      );
      expect(Validators.validatePassword('123456'), isNull);
      expect(Validators.validatePassword('securePass123!'), isNull);
    });

    test('validateName validates correctly', () {
      expect(Validators.validateName(''), 'Full name is required');
      expect(Validators.validateName(null), 'Full name is required');
      expect(Validators.validateName('A'), 'Please enter a valid full name');
      expect(Validators.validateName('Alex Morgan'), isNull);
    });

    test('validateConfirmPassword validates correctly', () {
      expect(
        Validators.validateConfirmPassword('', 'secret123'),
        'Please confirm your password',
      );
      expect(
        Validators.validateConfirmPassword(null, 'secret123'),
        'Please confirm your password',
      );
      expect(
        Validators.validateConfirmPassword('wrong', 'secret123'),
        'Passwords do not match',
      );
      expect(
        Validators.validateConfirmPassword('secret123', 'secret123'),
        isNull,
      );
    });
  });
}
