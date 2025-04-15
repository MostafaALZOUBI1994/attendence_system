import 'package:attendence_system/core/constants/constants.dart';
import 'package:attendence_system/features/attendence/domain/entities/today_status.dart';
import 'package:attendence_system/features/attendence/domain/repositories/attendence_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:intl/intl.dart' as intl;
import 'package:ntp/ntp.dart';
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
          return Left(ServerFailure(response.data[0]['_statusMessage']));
        }
        return Right(TodayStatus(
          checkInTime: response.data[0]['In_Time'],
          delay: response.data[0]['LateIn'],
          expectedOutTime: response.data[0]['ExpectedOutTime'],
        ));
      } else {
        return const Left(ServerFailure("'An unexpected error occurred"));
      }
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, String>> checkIn() async {
    final String? employeeId = _localService.get(empID);
    String time =
    intl.DateFormat('dd/MM/yyyy HH:mm:ss').format(await NTP.now());
    try{
      final response = await _dio.post(
        '/CheckIn',
        queryParameters: {'langcode': 'en-US'},
        data: {
          "employeeid": employeeId,
          "location": "DUBAI",
          "latitude": 0.0,
          "longitude": 0.0,
          "checkintime": time,
          "locStateDevice": "1",
          "locStateApp": "1",
          "batteryPercent": "1",
          "cellInfo": "1",
          "accuracy": "1",
          "locTS": "1",
          "spoofingEnb": "0",
          "providerNetTime": time
        }
      );
      if (response.statusCode == 200) {
      if (response.data['_statusCode'] == '101') {
        return Left(ServerFailure(response.data['_statusMessage']));
      }
      return Right(response.data['_statusMessage'] as String);
    } else {
      return const Left(ServerFailure('Failed to Check in'));
    }
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred: $e'));
    }
  }
}
