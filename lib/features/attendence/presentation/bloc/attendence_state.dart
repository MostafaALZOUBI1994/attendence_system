import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../authentication/domain/entities/login_success_model.dart';
import '../../domain/entities/process_step.dart';
import '../../domain/entities/today_status.dart';
import '../widgets/timeline.dart';
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
    @Default([]) List<ProcessStep> processSteps,
  }) = Loaded;

  const factory AttendenceState.checkInSuccess({
    required String message,
    required LoginSuccessData loginData,
    TodayStatus? todayStatus,
    @Default(0) int currentStepIndex,
    @Default(Duration.zero) Duration remainingTime,
    @Default(0.0) double progress,
    @Default([]) List<ProcessStep> processSteps,
  }) = CheckInSuccess;

  const factory AttendenceState.error(String message) = Error;
}

