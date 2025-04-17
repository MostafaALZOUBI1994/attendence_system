import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../authentication/domain/entities/login_success_model.dart';
import '../../domain/entities/today_status.dart';
part 'attendence_state.freezed.dart';


@freezed
class AttendenceState with _$AttendenceState {
  const factory AttendenceState.initial() = Initial;

  const factory AttendenceState.loaded({
    required LoginSuccessData loginData,
    TodayStatus? todayStatus,
    @Default(0) int currentStepIndex,
    @Default(Duration.zero) Duration remainingTime,
    @Default(0.0) double progress,
  }) = Loaded;

  const factory AttendenceState.checkInSuccess({
    required String message,
    required LoginSuccessData loginData,
    TodayStatus? todayStatus,
    @Default(0) int currentStepIndex,
    @Default(Duration.zero) Duration remainingTime,
    @Default(0.0) double progress,
  }) = CheckInSuccess;

  const factory AttendenceState.error(String message) = Error;
}

