part of 'report_bloc.dart';


@freezed
class ReportEvent with _$ReportEvent {
  const factory ReportEvent.fetchReport({
    required String fromDate,
    required String toDate,
  })= FetchReportEvent;
  const factory ReportEvent.init()= Init;
}
