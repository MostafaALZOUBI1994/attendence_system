part of 'attendence_bloc.dart';


@freezed
class AttendenceState with _$AttendenceState {
  const factory AttendenceState.initial() = Initial;

  const factory AttendenceState.loaded({
    required LoginSuccessData loginData,
    required TodayStatus todayStatus,
    @Default(0) int currentStepIndex,
    @Default(Duration.zero) Duration remainingTime,
    @Default(0.0) double progress,
  }) = Loaded;

  const factory AttendenceState.checkInSuccess({
    required String message,
    required LoginSuccessData loginData,
    required TodayStatus todayStatus,
    @Default(0) int currentStepIndex,
    @Default(Duration.zero) Duration remainingTime,
    @Default(0.0) double progress,
  }) = CheckInSuccess;

  const factory AttendenceState.error({
    required String message,
    required LoginSuccessData loginData,
    required TodayStatus todayStatus,
    @Default(0) int currentStepIndex,
    @Default(Duration.zero) Duration remainingTime,
    @Default(0.0) double progress,
  }) = Error;
}

