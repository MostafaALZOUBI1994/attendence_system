part of 'services_bloc.dart';

@freezed
class ServicesEvent with _$ServicesEvent {
  const factory ServicesEvent.started() = Started;
  const factory ServicesEvent.loadData() = LoadData;
  const factory ServicesEvent.submitRequest({
    required String dateDayType,
    required String fromTime,
    required String toTime,
    required String duration,
    required String reason,
    required String attachment,
    required String eLeaveType,
  }) = SubmitRequest;

  const factory ServicesEvent.fetchEmployees({
    required String department,
  }) = FetchEmployees;
}
