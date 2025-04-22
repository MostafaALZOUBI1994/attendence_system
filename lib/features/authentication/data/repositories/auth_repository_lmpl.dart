import 'package:attendence_system/core/local_services/local_services.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:restart_app/restart_app.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/login_success_model.dart';
import '../../domain/repositories/auth_repository.dart';


@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final Dio _dio;
  final LocalService _localService;
  AuthRepositoryImpl(this._dio, this._localService);

  @override
  Future<Either<Failure, LoginSuccessData>> login(String email, String password) async {
    try {
      final response = await _dio.post(
        'login?langcode=en-US',
        data: {
          "username": email,
          "password": password,
          "imei": "123"
        },
      );

      if (response.statusCode == 200) {
        if (response.data[0]['_statusCode'] == '101') {
          return Left(ServerFailure(response.data[0]['_statusMessage']));
        }
        final data = LoginSuccessData(
          empID: response.data[0]['_employeeid'],
          empName: response.data[0]['_employeename'],
          empNameAR: response.data[0]['_employeenameAr'],
          empProfileImage: response.data[0]['_profileimg'] ?? '',
        );
        await _localService.save(empID, data.empID);
        await _localService.save(empName, data.empName);
        await _localService.save(empNameAR, data.empNameAR);
        await _localService.save(profileImage, data.empProfileImage);
        return Right(data);
      } else {
        return const Left(ServerFailure('Failed to log in '));
      }
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> signOut() async {
    try {
      await _localService.clearAll();
      Restart.restartApp();
      return Right(true);
    } catch (e) {
      return Left(ServerFailure('signout failed $e'));
    }

  }

  @override
  Future<Either<Failure, LoginSuccessData>> getProfileData() async {
    try {
      final data = LoginSuccessData(
        empID: await _localService.get(empID) ?? "",
        empName: await _localService.get(empName) ?? "",
        empNameAR: await _localService.get(empNameAR) ?? "",
        empProfileImage: await _localService.get(profileImage) ?? "",
      );
      return Right(data);
    }catch(e){
      return Left(ServerFailure('load profile data failed $e'));
    }
  }
}