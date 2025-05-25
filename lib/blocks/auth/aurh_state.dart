
import '../../models/user.dart';

class AuthState {
  final bool isAuthenticated,isLoading;
  final String? error;
  final User? user;
  AuthState({required this.isAuthenticated,required this.user,required this.isLoading, this.error});

  factory AuthState.initial() => AuthState(isAuthenticated: false,user: User(uid: "", email: ""),isLoading: false);

  AuthState copyWith({bool? isAuthenticated, String? error,bool? isLoading,User? user}) {
    return AuthState(
      user: user,
      isLoading: isLoading??false,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      error: error,
    );
  }
}
