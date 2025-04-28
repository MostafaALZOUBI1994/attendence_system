import 'package:attendence_system/core/network/dio_extensions.dart';
import 'package:attendence_system/features/reports/domain/entities/report_model.dart';
import 'package:dio/dio.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/constants/constants.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/local_services/local_services.dart';
import '../../domain/repositories/report_repository.dart';


@LazySingleton(as: ReportRepository)
class ReportRepositoryImpl implements ReportRepository {
  final Dio _dio;
  final LocalService _localService;

  ReportRepositoryImpl(this._dio, this._localService);

  @override
  Future<Either<Failure, List<Report>>> fetchReport({
    required String fromDate,
    required String toDate,
  }) async {
    try {
      final String? employeeId = _localService.get(empID);

      final responseEither = await _dio.safe(
            () => _dio.get(
          'AttendanceReport',
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
