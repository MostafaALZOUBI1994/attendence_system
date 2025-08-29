part of 'report_bloc.dart';

@freezed
class ReportState with _$ReportState {
  const factory ReportState.initial() = ReportInitial;
  const factory ReportState.loading() = ReportLoading;
  const factory ReportState.loaded({required List<Report> report,    required List<Report> filteredReport}) = ReportLoaded;
  const factory ReportState.error(String message) = ReportError;
}
