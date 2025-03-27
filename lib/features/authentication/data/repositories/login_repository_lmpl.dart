import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/login_success_model.dart';
import '../../domain/repositories/login_repository.dart';

@LazySingleton(as: LoginRepository)
class LoginRepositoryImpl implements LoginRepository {
  late Dio _dio;
  LoginRepositoryImpl() {
    _dio = Dio(
        BaseOptions(
      baseUrl: 'https://taapi.moec.gov.ae/api/lgt/',
          connectTimeout: const Duration(seconds: 5000),
          receiveTimeout: const Duration(seconds: 3000),
          contentType: 'application/json',
    ));
  }

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
          return Left(ServerFailure());
        }
        return Right(LoginSuccessData(
          empID: response.data[0]['_employeeid'],
          empName: response.data[0]['_employeename'],
          empNameAR: response.data[0]['_employeenameAr'],
          empProfileImage: response.data[0]['_profileimg'] ?? '',
        ));
      } else {
        return const Left(ServerFailure());
      }
    } catch (e) {
      return Left(ServerFailure());
    }
  }
}