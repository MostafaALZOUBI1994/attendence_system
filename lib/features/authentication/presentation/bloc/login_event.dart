import 'package:freezed_annotation/freezed_annotation.dart';

part 'login_event.freezed.dart';

@freezed
class LoginEvent with _$LoginEvent {
  const factory LoginEvent.qrScanned(String email) = QrScanned;
  const factory LoginEvent.loginSubmitted({
    required String email,
    required String password,
  }) = LoginSubmitted;
  const factory LoginEvent.startScanning() = StartScanning;
  const factory LoginEvent.stopScanning() = StopScanning;
}
