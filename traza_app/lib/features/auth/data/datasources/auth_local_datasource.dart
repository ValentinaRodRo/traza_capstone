import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<void> cacheUser(UserModel user);

  Future<UserModel?> getCachedUser();

  Future<void> clearSession();
}

class AuthLocalDataSourceImpl
    implements AuthLocalDataSource {
  final SharedPreferences prefs;

  AuthLocalDataSourceImpl(this.prefs);

  static const String cachedUserKey =
      'CACHED_USER';

  @override
  Future<void> cacheUser(UserModel user) async {
    await prefs.setString(
      cachedUserKey,
      jsonEncode(user.toJson()),
    );
  }

  @override
  Future<UserModel?> getCachedUser() async {
    final jsonString =
        prefs.getString(cachedUserKey);

    if (jsonString == null) return null;

    return UserModel.fromJson(
      jsonDecode(jsonString),
    );
  }

  @override
  Future<void> clearSession() async {
    await prefs.remove(cachedUserKey);
  }
}