part of 'services_bloc.dart';

@freezed
class ServicesEvent with _$ServicesEvent {
  const factory ServicesEvent.started() = Started;
  const factory ServicesEvent.loadData() = LoadData;
  const factory ServicesEvent.submitRequest() = SubmitRequest;
}
