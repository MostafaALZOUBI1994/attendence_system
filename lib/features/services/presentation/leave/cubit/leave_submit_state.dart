part of 'leave_submit_cubit.dart';

@freezed
class LeaveSubmitState with _$LeaveSubmitState {
  const factory LeaveSubmitState.idle() = _Idle;
  const factory LeaveSubmitState.submitting() = _Submitting;
  const factory LeaveSubmitState.success(String message) = _Success;
  const factory LeaveSubmitState.failure(String message) = _Failure;
}
