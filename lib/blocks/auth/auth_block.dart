import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:local_auth/local_auth.dart';

import '../../services/notification_services.dart';
import 'aurh_state.dart';
import 'auth_event.dart';


class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final LocalAuthentication _localAuth = LocalAuthentication();

  AuthBloc() : super(AuthState.initial()) {
    on<LoginRequested>(_onLoginRequested);
    on<OnSignUpRequested>(_onSignupSubmitted);
    on<LogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onLoginRequested(LoginRequested event, Emitter<AuthState> emit) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );
      emit(state.copyWith(isAuthenticated: true));
      NotificationService.showNotification("Login", "Successfully logged in!");
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onSignupSubmitted(
      OnSignUpRequested event,
      Emitter<AuthState> emit,
      ) async {
    emit(state.copyWith(isLoading: true));
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );

      // Update display name
      await credential.user?.updateDisplayName(event.name);

      emit(state.copyWith(isLoading: false));
    } on FirebaseAuthException catch (e) {

      String errorMessage;
      switch (e.code) {
        case 'weak-password':
          errorMessage = 'The password provided is too weak.';
          break;
        case 'email-already-in-use':
          errorMessage = 'An account already exists for this email.';
          break;
        case 'invalid-email':
          errorMessage = 'Please enter a valid email address.';
          break;
        default:
          errorMessage = 'An error occurred. Please try again.';
          emit(state.copyWith(isLoading: false,error: errorMessage));


      }
    } catch (e) {
      emit(state.copyWith(isLoading: false));
    }
  }


  Future<void> _onBiometricLoginRequested(OnSignUpRequested event, Emitter<AuthState> emit) async {
    try {
      final authenticated = await _localAuth.authenticate(localizedReason: 'Authenticate to login');
      if (authenticated) {
        emit(state.copyWith(isAuthenticated: true));
      }
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onLogoutRequested(LogoutRequested event, Emitter<AuthState> emit) async {
    await _auth.signOut();
    emit(AuthState.initial());
  }
}
