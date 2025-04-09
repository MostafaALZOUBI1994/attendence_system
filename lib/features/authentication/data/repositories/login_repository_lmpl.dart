import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/login_success_model.dart';
import '../../domain/repositories/login_repository.dart';

@LazySingleton(as: LoginRepository)
class LoginRepositoryImpl implements LoginRepository {
  final Dio _dio;
  LoginRepositoryImpl(this._dio);

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
        return Right(LoginSuccessData(
          empID: response.data[0]['_employeeid'],
          empName: response.data[0]['_employeename'],
          empNameAR: response.data[0]['_employeenameAr'],
          empProfileImage: response.data[0]['_profileimg'] ?? '',
        ));
      } else {
        return const Left(ServerFailure('Failed to log in '));
      }
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred: $e'));
    }
  }
}