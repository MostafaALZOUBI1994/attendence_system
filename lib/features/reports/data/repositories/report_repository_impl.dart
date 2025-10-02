import 'package:moet_hub/core/network/dio_extensions.dart';
import 'package:moet_hub/features/reports/domain/entities/report_model.dart';
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

      final resEither = await _dio.safe(
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

      return resEither.fold(
        Left.new,
            (res) {
          final data = res.data;

          // treat the API's "No data found" sentinel as an empty list
          if (_looksLikeNoData(data)) {
            return const Right(<Report>[]);
          }

          final list = (data as List)
              .whereType<Map<String, dynamic>>()
              .map((e) => Report.fromJson(Map<String, dynamic>.from(e)))

              .toList(); // <- List<ReportModel> which extends Report

          return Right(list); // <- OK because ReportModel : Report
        },
      );
    } catch (e) {
      return Left(ServerFailure( e.toString()));
    }
  }

  bool _looksLikeNoData(dynamic data) {
    if (data is! List || data.isEmpty || data.first is! Map) return false;
    final m = data.first as Map;
    final code = m['_statusCode']?.toString();
    final msg = (m['_statusMessage'] ?? '').toString().toLowerCase();

    final businessFieldsNullOrEmpty = [
      'EmployeeID','pdate'
    ].every((k) {
      final v = m[k];
      return v == null || (v is String && v.trim().isEmpty);
    });

    return code == '101' || msg.contains('no data') || businessFieldsNullOrEmpty;
  }


}
