import '../entities/user.dart';

abstract class AuthRepository {
  Future<User> login({
    required String email,
    required String password,
  });

  Future<User> register({
    required String email,
    required String password,
    required String role,
  });

  Future<void> logout();

  Future<User?> getCurrentUser();
}