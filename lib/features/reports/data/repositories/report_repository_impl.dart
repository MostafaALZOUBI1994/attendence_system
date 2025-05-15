import 'package:attendence_system/core/network/dio_extensions.dart';
import 'package:attendence_system/features/reports/domain/entities/report_model.dart';
import 'package:dio/dio.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/injection.dart';
import '../../../authentication/data/datasources/employee_local_data_source.dart';
import '../../domain/repositories/report_repository.dart';


@LazySingleton(as: ReportRepository)
class ReportRepositoryImpl implements ReportRepository {
  final Dio _dio;

  ReportRepositoryImpl(this._dio);

  @override
  Future<Either<Failure, List<Report>>> fetchReport({
    required String fromDate,
    required String toDate,
  }) async {
    try {
      final employeeId = await getIt<EmployeeLocalDataSource>().getEmployeeId();

      final responseEither = await _dio.safe(
            () => _dio.get(
          'AttendanceReport_New',
          queryParameters: {
            'employeeid': employeeId,
            'fromdate': fromDate,
            'todate': toDate,
          },
        ),
            (res) => res,
      );


      return await responseEither.fold(
            (failure) => Left(failure),
            (response) {
          if (response.statusCode != 200) {

            final msg = (response.data is List && response.data.isNotEmpty)
                ? response.data[0]["_statusMessage"]
                : 'Failed to fetch reports';
            return Left(ServerFailure(msg));
          }

          final List<dynamic> raw = response.data as List<dynamic>;
          final reports = raw.map((e) => Report.fromJson(e)).toList();
          return Right(reports);
        },
      );
    } catch (e) {
      return Left(ServerFailure("An unexpected error occurred: $e"));
    }
  }

}
