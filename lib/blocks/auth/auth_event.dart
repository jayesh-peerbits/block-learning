
abstract class AuthEvent {}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;
  LoginRequested(this.email, this.password);
}

class OnSignUpRequested extends AuthEvent {
  final String name;
  final String email;
  final String password;

  OnSignUpRequested({
    required this.name,
    required this.email,
    required this.password,
  });
}

class LogoutRequested extends AuthEvent {}

class CheckAuthStatus extends AuthEvent {} // New event to check login status
