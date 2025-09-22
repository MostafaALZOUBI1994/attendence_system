part of 'attendence_bloc.dart';

/// Reads naturally with your day: offsite → onsite → checkout.
enum AttendancePhase { beforeArrival, offsite, onsite, checkedOut }

@freezed
class AttendenceState with _$AttendenceState {
  const factory AttendenceState.initial() = Initial;
  const factory AttendenceState.loading() = Loading;

  // attendence_state.dart
  const factory AttendenceState.loaded({
    required Employee employee,
    required TodayStatus todayStatus,
    required AttendancePhase phase,         // 👈 add
    @Default(0) int currentStepIndex,
    @Default(Duration.zero) Duration remainingTime,
    @Default(0.0) double progress,
  }) = Loaded;

  const factory AttendenceState.checkInSuccess({
    required String message,
    required Employee employee,
    required TodayStatus todayStatus,
    required AttendancePhase phase,         // 👈 add
    @Default(0) int currentStepIndex,
    @Default(Duration.zero) Duration remainingTime,
  }) = CheckInSuccess;

  const factory AttendenceState.error({
    required String message,
    required Employee employee,
    required TodayStatus todayStatus,
    required AttendancePhase phase,         // 👈 add
    @Default(0) int currentStepIndex,
    @Default(Duration.zero) Duration remainingTime,
  }) = Error;
}