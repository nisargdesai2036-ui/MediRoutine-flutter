import 'package:flutter_test/flutter_test.dart';
import 'package:mediroutine/data/repositories/mock_auth_repository.dart';

void main() {
  group('MockAuthRepository Tests', () {
    late MockAuthRepository repo;

    setUp(() {
      repo = MockAuthRepository();
    });

    test('initial state is unauthenticated', () {
      expect(repo.isAuthenticated, isFalse);
      expect(repo.currentUser, isNull);
    });

    test('login succeeds with valid seeded credentials', () async {
      final user = await repo.login(
        email: 'alex@example.com',
        password: 'password123',
      );

      expect(user.email, 'alex@example.com');
      expect(repo.isAuthenticated, isTrue);
      expect(repo.currentUser?.id, user.id);
    });

    test('login throws exception on wrong password', () async {
      expect(
        () => repo.login(email: 'alex@example.com', password: 'wrongPassword'),
        throwsA(isA<Exception>()),
      );
    });

    test('signUp succeeds and registers new account', () async {
      final user = await repo.signUp(
        name: 'Jane Doe',
        email: 'jane@example.com',
        password: 'securePass123',
      );

      expect(user.name, 'Jane Doe');
      expect(user.email, 'jane@example.com');
      expect(repo.isAuthenticated, isTrue);
    });

    test('signUp fails when email already exists', () async {
      expect(
        () => repo.signUp(
          name: 'Duplicate Alex',
          email: 'alex@example.com',
          password: 'password123',
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('social logins succeed', () async {
      final googleUser = await repo.loginWithGoogle();
      expect(googleUser.email, contains('google'));
      expect(repo.isAuthenticated, isTrue);

      final appleUser = await repo.loginWithApple();
      expect(appleUser.email, contains('apple'));
      expect(repo.isAuthenticated, isTrue);
    });

    test('logout clears current user', () async {
      await repo.login(email: 'alex@example.com', password: 'password123');
      expect(repo.isAuthenticated, isTrue);

      await repo.logout();
      expect(repo.isAuthenticated, isFalse);
      expect(repo.currentUser, isNull);
    });
  });
}
