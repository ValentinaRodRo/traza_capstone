import 'package:http/http.dart' as http;

import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login({
    required String email,
    required String password,
  });

  Future<UserModel> register({
    required String email,
    required String password,
    required String role,
  });
}

class AuthRemoteDataSourceImpl
    implements AuthRemoteDataSource {
  final http.Client client;

  AuthRemoteDataSourceImpl(this.client);

  final String baseUrl = 'http://TU_API_URL/auth';

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {

    // LOGIN HARDCODEADO TEMPORAL
    await Future.delayed(
      const Duration(seconds: 1),
    );

    if (email == 'admin@test.com' &&
        password == '123456') {

      return UserModel(
        email: email,
        role: 'admin',
      );
    }

    throw Exception('Credenciales incorrectas');



    /*
    final response = await client.post(
      Uri.parse('$baseUrl/login'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);

      return UserModel.fromJson(decoded);
    } else {
      throw Exception('Error login');
    }
    */
  }

  @override
  Future<UserModel> register({
    required String email,
    required String password,
    required String role,
  }) async {

    // REGISTER HARDCODEADO TEMPORAL
    await Future.delayed(
      const Duration(seconds: 1),
    );

    return UserModel(
      email: email,
      role: role,
    );



    /*
    final response = await client.post(
      Uri.parse('$baseUrl/register'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'password': password,
        'role': role,
      }),
    );

    if (response.statusCode == 201 ||
        response.statusCode == 200) {

      final decoded = jsonDecode(response.body);

      return UserModel.fromJson(decoded);
    } else {
      throw Exception('Error register');
    }
    */
  }
}