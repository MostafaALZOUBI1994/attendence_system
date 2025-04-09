part of 'services_bloc.dart';

@freezed
class ServicesState with _$ServicesState {
  const factory ServicesState.initial() = _Initial;
  const factory ServicesState.loading() = _Loading;
  const factory ServicesState.loaded({
    required List<PermissionTypesEntity> leaveTypes,
    required EleaveEntity leaveBalance,
  }) = _Loaded;
  const factory ServicesState.error(String message) = _Error;
}
