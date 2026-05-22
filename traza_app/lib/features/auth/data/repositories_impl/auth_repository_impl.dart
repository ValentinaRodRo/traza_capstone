import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl
    implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<User> login({
    required String email,
    required String password,
  }) async {
    final user = await remoteDataSource.login(
      email: email,
      password: password,
    );

    await localDataSource.cacheUser(user);

    return user;
  }

  @override
  Future<User> register({
    required String email,
    required String password,
    required String role,
  }) async {
    final user = await remoteDataSource.register(
      email: email,
      password: password,
      role: role,
    );

    await localDataSource.cacheUser(user);

    return user;
  }

  @override
  Future<void> logout() async {
    await localDataSource.clearSession();
  }

  @override
  Future<User?> getCurrentUser() async {
    return await localDataSource.getCachedUser();
  }
}