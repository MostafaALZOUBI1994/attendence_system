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
  }) = Loaded;
  const factory AttendenceState.error(String message) = Error;
  const factory AttendenceState.checkInSucess(String message) = CheckInSucess;
}
