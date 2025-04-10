part of 'services_bloc.dart';

@freezed
class ServicesState with _$ServicesState {
  const factory ServicesState.initial() = Initial;
  const factory ServicesState.loading() = Loading;
  const factory ServicesState.loaded({
    required List<PermissionTypesEntity> leaveTypes,
    required EleaveEntity leaveBalance,
  }) = Loaded;
  const factory ServicesState.error(String message) = Error;
}
