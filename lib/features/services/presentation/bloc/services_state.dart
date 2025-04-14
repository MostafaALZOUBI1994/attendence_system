part of 'services_bloc.dart';

@freezed
class ServicesState with _$ServicesState {
  const factory ServicesState.initial() = _Initial;
  const factory ServicesState.loading() = _Loading;
  const factory ServicesState.loaded({
    required List<PermissionTypesEntity> leaveTypes,
    required EleaveEntity leaveBalance,
  }) = LoadSuccess;
  const factory ServicesState.error(String message) = _LoadFailed;
  const factory ServicesState.submissionSuccess(String message) = _SubmissionSuccess;
  const factory ServicesState.submissionFailure(String message) = _SubmissionFailure;
}

