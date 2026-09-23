import 'dart:async';
import '../models/user_model.dart';
import 'auth_repository.dart';

/// In-memory mock authentication repository with realistic network delay
/// and mock user accounts for UI/UX showcase and client demo.
class MockAuthRepository implements AuthRepository {
  UserModel? _currentUser;

  // Seeded mock accounts: email -> (name, password, id)
  final Map<String, _MockUserAccount> _mockDatabase = {
    'demo@mediroutine.com': _MockUserAccount(
      id: 1,
      name: 'Dr. Alex Vance',
      email: 'demo@mediroutine.com',
      password: 'password123',
    ),
    'alex@example.com': _MockUserAccount(
      id: 2,
      name: 'Alex Johnson',
      email: 'alex@example.com',
      password: 'password123',
    ),
  };

  int _nextId = 3;

  @override
  UserModel? get currentUser => _currentUser;

  @override
  bool get isAuthenticated => _currentUser != null;

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    // Simulate realistic async network roundtrip
    await Future.delayed(const Duration(milliseconds: 900));

    final normalizedEmail = email.trim().toLowerCase();
    final account = _mockDatabase[normalizedEmail];

    if (account == null) {
      // For friendly demo experience, if it looks like a valid email but isn't seeded,
      // allow signing in as a dynamic mock user unless password is  wrong
      if (password == 'wrong' || password.length < 6) {
        throw Exception('Invalid email or password. Please try again.');
      }
      final newUser = UserModel(
        id: _nextId++,
        name: normalizedEmail
            .split('@')
            .first
            .replaceAll('.', ' ')
            .toUpperCase(),
        email: normalizedEmail,
      );
      _currentUser = newUser;
      return newUser;
    }

    if (account.password != password) {
      throw Exception('Incorrect password. Please verify and retry.');
    }

    final user = UserModel(
      id: account.id,
      name: account.name,
      email: account.email,
    );
    _currentUser = user;
    return user;
  }

  @override
  Future<UserModel> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 1000));

    final normalizedEmail = email.trim().toLowerCase();

    if (_mockDatabase.containsKey(normalizedEmail)) {
      throw Exception('An account with this email already exists.');
    }

    final newAccount = _MockUserAccount(
      id: _nextId++,
      name: name.trim(),
      email: normalizedEmail,
      password: password,
    );

    _mockDatabase[normalizedEmail] = newAccount;
    final user = UserModel(
      id: newAccount.id,
      name: newAccount.name,
      email: newAccount.email,
    );
    _currentUser = user;
    return user;
  }

  @override
  Future<UserModel> loginWithGoogle() async {
    await Future.delayed(const Duration(milliseconds: 800));
    final user = UserModel(
      id: _nextId++,
      name: 'Google User',
      email: 'user.google@mediroutine.com',
    );
    _currentUser = user;
    return user;
  }

  @override
  Future<UserModel> loginWithApple() async {
    await Future.delayed(const Duration(milliseconds: 800));
    final user = UserModel(
      id: _nextId++,
      name: 'Apple User',
      email: 'user.apple@privaterelay.appleid.com',
    );
    _currentUser = user;
    return user;
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await Future.delayed(const Duration(milliseconds: 700));
    final normalizedEmail = email.trim().toLowerCase();
    if (normalizedEmail.isEmpty) {
      throw Exception('Please enter an email address.');
    }
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _currentUser = null;
  }
}

class _MockUserAccount {
  final int id;
  final String name;
  final String email;
  final String password;

  _MockUserAccount({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
  });
}
