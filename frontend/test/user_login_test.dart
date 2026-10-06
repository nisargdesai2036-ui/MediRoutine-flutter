import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/Sessions/UserSession.dart';
import 'package:frontend/models/UserLogin.dart';

void main() {
  group('Userlogin model tests', () {
    test('toJson returns correct map', () {
      final login = Userlogin(email: 'test@example.com', password: 'password123');
      final json = login.toJson();
      expect(json['email'], 'test@example.com');
      expect(json['password'], 'password123');
    });

    test('fromJson handles standard and nullable inputs', () {
      final login = Userlogin.fromJson({
        'email': 'test@example.com',
        'password': 'password123',
      });
      expect(login.email, 'test@example.com');
      expect(login.password, 'password123');

      final empty = Userlogin.fromJson({});
      expect(empty.email, '');
      expect(empty.password, '');
    });
  });

  group('UserSession datatype tests', () {
    test('setUser handles valid data and types', () {
      UserSession.setUser(
        Userid: 1,
        Name: 'Test User',
        Email: 'test@example.com',
      );
      expect(UserSession.userid, 1);
      expect(UserSession.name, 'Test User');
      expect(UserSession.email, 'test@example.com');
    });

    test('setUser handles null values safely without type errors', () {
      UserSession.setUser(
        Userid: null,
        Name: null,
        Email: null,
      );
      expect(UserSession.userid, isNull);
      expect(UserSession.name, isNull);
      expect(UserSession.email, isNull);
    });

    test('unrestUser clears session', () {
      UserSession.setUser(
        Userid: 5,
        Name: 'User 5',
        Email: 'user5@test.com',
      );
      UserSession.unrestUser();
      expect(UserSession.userid, isNull);
      expect(UserSession.name, isNull);
      expect(UserSession.email, isNull);
    });
  });
}
