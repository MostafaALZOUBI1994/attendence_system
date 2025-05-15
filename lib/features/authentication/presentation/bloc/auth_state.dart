part of 'auth_bloc.dart';

@freezed
class AuthState with _$AuthState {
  const factory AuthState.initial() = AuthInitial;
  const factory AuthState.loading() = AuthLoading;
  const factory AuthState.login({
    required String email,
    @Default(false) bool isScanning,
  }) = Login;
  const factory AuthState.success(Employee data) = AuthSuccess;
  const factory AuthState.unauthenticated() = UnAuthenticated;
  const factory AuthState.error(String message) = AuthError;
}