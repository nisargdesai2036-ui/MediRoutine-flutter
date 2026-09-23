import '../models/user_model.dart';

/// Abstract contract for authentication operations.
/// Allows seamless switching between MockAuthRepository and future RestAuthRepository.
abstract class AuthRepository {
  UserModel? get currentUser;
  bool get isAuthenticated;

  Future<UserModel> login({required String email, required String password});

  Future<UserModel> signUp({
    required String name,
    required String email,
    required String password,
  });

  Future<UserModel> loginWithGoogle();

  Future<UserModel> loginWithApple();

  Future<void> sendPasswordResetEmail(String email);

  Future<void> logout();
}
