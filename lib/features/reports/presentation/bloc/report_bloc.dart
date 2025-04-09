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
  }
}
