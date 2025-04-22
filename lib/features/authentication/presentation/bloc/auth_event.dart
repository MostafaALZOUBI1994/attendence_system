part of 'auth_bloc.dart';

@freezed
class AuthEvent with _$AuthEvent {
  const factory AuthEvent.qrScanned(String email) = QrScanned;
  const factory AuthEvent.loginSubmitted({
    required String email,
    required String password,
  }) = LoginSubmitted;
  const factory AuthEvent.startScanning() = StartScanning;
  const factory AuthEvent.stopScanning() = StopScanning;
  const factory AuthEvent.signOut() = SignOut;
  const factory AuthEvent.getProfileData() = GetProfileData;
}
