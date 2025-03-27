import 'package:freezed_annotation/freezed_annotation.dart';

import '../../authentication/domain/entities/login_success_model.dart';
part 'attendence_state.freezed.dart';

@freezed
class AttendenceState with _$AttendenceState {
  const factory AttendenceState.initial() = Initial;
  const factory AttendenceState.loaded({required LoginSuccessData loginData}) = Loaded;
}
