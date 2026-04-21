import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:identity_frontend/core/di/injection.dart';
import 'package:identity_frontend/core/firebase/repositories/i_analytics_service.dart';
import 'package:identity_frontend/core/storage/secure_storage.dart';
import 'package:identity_frontend/domain/entities/auth_entity.dart';
import 'package:identity_frontend/domain/usecases/auth/sign_in_usecase.dart';
import 'package:identity_frontend/domain/usecases/auth/sign_up_usecase.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignInUseCase _signInUseCase;
  final SignUpUseCase _signUpUseCase;
  final IAnalyticsService _analytics;

  AuthBloc({
    required SignInUseCase signInUseCase,
    required SignUpUseCase signUpUseCase,
    IAnalyticsService? analytics,
  })  : _signInUseCase = signInUseCase,
        _signUpUseCase = signUpUseCase,
        _analytics = analytics ?? sl<IAnalyticsService>(),
        super(const AuthState()) {
    on<SignInSubmitted>(_onSignIn);
    on<SignUpSubmitted>(_onSignUp);
    on<AuthLoggedOut>(_onLoggedOut);
  }

  Future<void> _onSignIn(SignInSubmitted event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      final auth = await _signInUseCase(
        username: event.username,
        password: event.password,
      );
      await SecureStorage.saveToken(auth.token);
      await SecureStorage.saveUserId(auth.id);
      await SecureStorage.saveUserEmail(auth.email);
      await SecureStorage.saveUserRole(auth.role);
      if (auth.phone != null) await SecureStorage.saveUserPhone(auth.phone!);

      await _analytics.logLogin(method: 'email');
      await _analytics.setUserId(auth.id);
      await _analytics.setUserRole(auth.role);

      emit(state.copyWith(status: AuthStatus.success, auth: auth));
    } catch (e) {
      emit(state.copyWith(status: AuthStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> _onSignUp(SignUpSubmitted event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      final auth = await _signUpUseCase(
        email: event.email,
        phone: event.phone,
        password: event.password,
      );
      await SecureStorage.saveToken(auth.token);
      await SecureStorage.saveUserId(auth.id);
      await SecureStorage.saveUserEmail(event.email);
      await SecureStorage.saveUserPhone(event.phone);

      await _analytics.logSignUp(method: 'email');
      await _analytics.setUserId(auth.id);

      emit(state.copyWith(status: AuthStatus.signedUp, auth: auth));
    } catch (e) {
      emit(state.copyWith(status: AuthStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> _onLoggedOut(AuthLoggedOut event, Emitter<AuthState> emit) async {
    await SecureStorage.clearAll();
    await _analytics.clearUserId();
    emit(const AuthState());
  }
}
