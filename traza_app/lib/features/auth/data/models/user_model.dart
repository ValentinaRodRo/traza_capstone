import '../../domain/entities/user.dart';

class UserModel extends User {
  
  UserModel({
    required String email,
    required String role,
    required String token,
  }) : super(
          email: email,
          role: role,
          token: token,
        );

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      email: json['email'],
      role: json['role'],
      token: json['token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'role': role,
      'token': token,
    };
  }
}