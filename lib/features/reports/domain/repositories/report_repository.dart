import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/report_model.dart';



abstract class ReportRepository {
  Future<Either<Failure, List<Report>>> fetchReport({
    required String fromDate,
    required String toDate,
  });
}