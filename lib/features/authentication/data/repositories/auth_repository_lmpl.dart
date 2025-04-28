import 'package:attendence_system/core/local_services/local_services.dart';
import 'package:attendence_system/core/network/dio_extensions.dart';
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
  Future<Either<Failure, LoginSuccessData>> login(
      String email, String password) async {
    final responseEither = await _dio.safe(
          () => _dio.post(
        'login',
        data: {
          'username': email,
          'password': password,
          'imei': '123',
        },
      ),
          (res) => res,
    );

    return await responseEither.fold(
          (failure) async => Left(failure),

          (response) async {
        if (response.statusCode != 200) {
          return const Left(ServerFailure('Failed to log in'));
        }

        final item = response.data[0] as Map<String, dynamic>;

        if (item['_statusCode'] == '101') {
          return Left(ServerFailure(item['_statusMessage']));
        }

        final data = LoginSuccessData(
          empID: item['_employeeid'] as String,
          empName: item['_employeename'] as String,
          empNameAR: item['_employeenameAr'] as String,
          empProfileImage: (item['_profileimg'] as String?) ?? '',
        );

        await _localService.save(empID, data.empID);
        await _localService.save(empName, data.empName);
        await _localService.save(empNameAR, data.empNameAR);
        await _localService.save(profileImage, data.empProfileImage);

        return Right(data);
      },
    );
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