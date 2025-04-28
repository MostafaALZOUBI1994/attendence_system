import 'package:attendence_system/core/constants/constants.dart';
import 'package:attendence_system/core/network/dio_extensions.dart';
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


      final responseEither = await _dio.safe(
            () =>
            _dio.get(
              'EmployeeTodayTime',
              queryParameters: {'employeeid': employeeId},
            ),
            (res) => res,
      );


      return await responseEither.fold(
            (failure) async => Left(failure),
            (response) async {
          if (response.statusCode != 200) {
            return const Left(ServerFailure('An unexpected error occurred'));
          }

          final item = response.data[0] as Map<String, dynamic>;
          if (item['_statusCode'] == '101') {
            return Left(ServerFailure(item['_statusMessage'] as String));
          }

          final status = TodayStatus(
            checkInTime: item['In_Time'] as String,
            delay: item['LateIn'] as String,
            expectedOutTime: item['ExpectedOutTime'] as String,
            offSiteCheckIns: _localService.getMillisList(checkIns) ?? [],
          );
          return Right(status);
        },
      );
    }catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }
  @override
  Future<Either<Failure, String>> checkIn() async {
    try {
      final String? employeeId = _localService.get(empID);
      final String time = intl.DateFormat('dd/MM/yyyy HH:mm:ss')
          .format(await NTP.now());
      final responseEither = await _dio.safe(
            () => _dio.post(
          '/CheckIn',
          data: {
            'employeeid': employeeId,
            'location': 'DUBAI',
            'latitude': 0.0,
            'longitude': 0.0,
            'checkintime': time,
            'locStateDevice': '1',
            'locStateApp': '1',
            'batteryPercent': '1',
            'cellInfo': '1',
            'accuracy': '1',
            'locTS': '1',
            'spoofingEnb': '0',
            'providerNetTime': time,
          },
        ),
            (res) => res,
      );

      return await responseEither.fold(
            (failure) async => Left(failure),
            (response) async {
          if (response.statusCode != 200) {
            return const Left(ServerFailure('Failed to check in'));
          }

          final data = response.data as Map<String, dynamic>;
          if (data['_statusCode'] == '101') {
            return Left(ServerFailure(data['_statusMessage'] as String));
          }

          _localService.addMillis(
            checkIns,
            DateTime.now().millisecondsSinceEpoch,
          );
          return Right(data['_statusMessage'] as String);
        },
      );
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

}
