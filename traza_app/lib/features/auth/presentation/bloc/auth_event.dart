abstract class AuthEvent {}

class LoginEvent extends AuthEvent {
  final String email;
  final String password;

  LoginEvent({
    required this.email,
    required this.password,
  });
}

class RegisterEvent extends AuthEvent {
  final String email;
  final String password;
  final String role;

  RegisterEvent({
    required this.email,
    required this.password,
    required this.role,
  });
}

class LogoutEvent extends AuthEvent {}

class CheckAuthEvent extends AuthEvent {}