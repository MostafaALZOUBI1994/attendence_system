import 'package:moet_hub/features/reports/domain/entities/report_model.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/report_repository.dart';


@injectable
class FetchReport {
  final ReportRepository repository;

  FetchReport(this.repository);

  Future<Either<Failure, List<Report>>> get({
    required String fromDate,
    required String toDate,
  }) {
    return repository.fetchReport(fromDate: fromDate, toDate: toDate);
  }
}