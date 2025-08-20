import 'dart:convert';

import 'package:moet_hub/core/network/dio_extensions.dart';
import 'package:moet_hub/features/authentication/data/mappers/employee_mapper.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:restart_app/restart_app.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/employee.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/employee_local_data_source.dart';
import '../models/employee_model.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final Dio _dio;
  final EmployeeLocalDataSource _localDs;

  AuthRepositoryImpl(this._dio, this._localDs);

  @override
  Future<Either<Failure, Employee>> login(String email, String password) async {
    final username = email.trim();
    final responseEither = await _dio.safe(
          () => _dio.post(
        'GetEmployeeDetailsAD',
        data: {'username': username, 'password': password, 'imei': '123'},
      ),
          (res) => res,
    );

    return responseEither.fold(
          (failure) => Left(failure),
          (response) async {
        if (response.statusCode != 200) {
          return const Left(ServerFailure('Failed to log in'));
        }

        final details = response.data['EmployeeDeatils'] as Map<String, dynamic>;

        if (details['_statusCode'] == '101') {
          return Left(ServerFailure(details['_statusMessage'] as String));
        }

        // parse your full JSON into the model
        final model = EmployeeModel.fromJson(details);

        // cache the entire model
        await _localDs.cacheEmployee(model);

        // map to domain entity and return
        return Right(model.toEntity());
      },
    );
  }

  @override
  Future<Either<Failure, bool>> signOut() async {
    try {
      await _localDs.cacheEmployee(EmployeeModel(
          "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "","",""));
      await Restart.restartApp();
      return const Right(true);
    } catch (e) {
      return Left(ServerFailure('Sign out failed: $e'));
    }
  }

  @override
  Future<Either<Failure, Employee>> getProfileData() async {
    try {
      final model = await _localDs.getProfile();
      if (model == null) {
        return const Left(ServerFailure('No cached profile found'));
      }
      return Right(model.toEntity());
    } catch (e) {
      return Left(ServerFailure('Load profile data failed: $e'));
    }
  }
}
