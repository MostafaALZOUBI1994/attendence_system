import 'package:attendence_system/core/constants/constants.dart';
import 'package:attendence_system/features/attendence/domain/entities/today_status.dart';
import 'package:attendence_system/features/attendence/domain/repositories/attendence_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/local_services/local_services.dart';

@LazySingleton(as: AttendenceRepository)
class AttendenceRepositoryImpl implements AttendenceRepository {
  final Dio _dio;
  final LocalService _localService;

  AttendenceRepositoryImpl(this._dio, this._localService);

  @override
  Future<Either<Failure, TodayStatus>> getTodayStatus() async {
    try {
      final String? employeeId = _localService.get(empID);
      final response = await _dio.get(
        'EmployeeTodayTime?langcode=en-US&employeeid=$employeeId',
      );

      if (response.statusCode == 200) {
        if (response.data[0]['_statusCode'] == '101') {
          return Left(ServerFailure());
        }
        return Right(TodayStatus(
          checkInTime: response.data[0]['In_Time'],
          delay: response.data[0]['LateIn'],
          expectedOutTime: response.data[0]['ExpectedOutTime'],
        ));
      } else {
        return const Left(ServerFailure());
      }
    } catch (e) {
      return Left(ServerFailure());
    }
  }
}
