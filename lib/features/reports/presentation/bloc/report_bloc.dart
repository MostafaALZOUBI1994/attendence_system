import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/report_model.dart';
import '../../domain/usecases/fetch_report.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
part 'report_event.dart';
part 'report_state.dart';
part 'report_bloc.freezed.dart';

@LazySingleton()
class ReportBloc extends Bloc<ReportEvent, ReportState> {
  final FetchReport fetchReport;

  ReportBloc({required this.fetchReport}) : super(const ReportState.initial()) {
    on<FetchReportEvent>((event, emit) async {
      emit(const ReportState.loading());
      final result = await fetchReport.get(
        fromDate: event.fromDate,
        toDate: event.toDate,
      );
      result.fold(
            (failure) => emit(ReportState.error(failure.message)),
            (reports) {
          final filteredReports = reports.where(
                (r) => (r.lateIn.isNotEmpty || r.earlyOut.isNotEmpty),
          ).toList();

          emit(ReportState.loaded(
            report: reports,
            filteredReport: filteredReports,
          ));
        },
      );
    });
    final now = DateTime.now();
    final df = DateFormat('dd/MM/yyyy');
    final from = df.format(DateTime.utc(now.year, 1, 1));
    final to = df.format(now);
    add(ReportEvent.fetchReport(fromDate: from, toDate: to));
  }
}
