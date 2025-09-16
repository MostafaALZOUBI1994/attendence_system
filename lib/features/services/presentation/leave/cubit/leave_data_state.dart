
part of 'leave_data_cubit.dart';

@freezed
class LeaveDataState with _$LeaveDataState {
  const factory LeaveDataState.initial() = _Initial;
  const factory LeaveDataState.loading() = _Loading;
  const factory LeaveDataState.loaded({
    required List<PermissionTypesEntity> leaveTypes,
    required EleaveEntity leaveBalance,
  }) = _Loaded;
  const factory LeaveDataState.error(String message) = _Error;
}
