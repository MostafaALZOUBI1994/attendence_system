import 'package:moet_hub/core/constants/constants.dart';
import 'package:moet_hub/core/errors/failures.dart';
import 'package:moet_hub/core/network/dio_extensions.dart';
import 'package:moet_hub/features/services/domain/entities/eleave_entity.dart';
import 'package:moet_hub/features/services/domain/entities/permission_types_entity.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/injection.dart';
import '../../../../core/local_services/local_services.dart';
import '../../../authentication/data/datasources/employee_local_data_source.dart';
import '../../domain/repositories/services_repository.dart';
import '../models/eleave_model.dart';
import '../models/leave_request_params.dart';
import '../models/permission_types_model.dart';

@LazySingleton(as: ServiceRepository)
class ServicesRepositoryImpl implements ServiceRepository {
  final Dio _dio;
  final LocalService _localService;

  ServicesRepositoryImpl(this._dio, this._localService);

  @override
  Future<Either<Failure, EleaveEntity>> getLeaveBalance() async {
    try {
      final employeeId = await getIt<EmployeeLocalDataSource>().getEmployeeId();

      final responseEither = await _dio.safe(
            () => _dio.get(
          '/Eleavebalance',
          queryParameters: { 'employeeid': employeeId},
        ),
            (res) => res,
      );

      return await responseEither.fold(
            (failure) => Left(failure),
            (response) {
          final data = response.data as List<dynamic>;
          final model = EleaveModel.fromJson(data[0] as Map<String, dynamic>);
          final entity = EleaveEntity(
            noOfHrsAllowed: model.noOfHrsAllowed,
            noOfHrsAvailable: model.noOfHrsAvailable,
            noOfHrsUtilized: model.noOfHrsUtilized,
            noOfHrsPending: model.noOfHrsPending,
          );
          return Right(entity);
        },
      );
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<PermissionTypesEntity>>> getPermissionTypes() async {
    try {
      final responseEither = await _dio.safe(
            () => _dio.get(
          '/PermissionTypes',
        ),
            (res) => res,
      );

      return await responseEither.fold(
            (failure) => Left(failure),
            (response) {
          final rawList = response.data as List<dynamic>;
          final entities = rawList
              .map((json) => PermissionTypesModel.fromJson(json as Map<String, dynamic>))
              .map((model) => PermissionTypesEntity(
            permissionCode: model.permissionCode,
            permissionNameEN: model.permissionNameEN,
            permissionNameAR: model.permissionNameAR,
          ))
              .toList();
          return Right(entities);
        },
      );
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, String>> submitLeaveRequest(SubmitLeaveRequestParams params) async {
    try {
      final employeeId = await getIt<EmployeeLocalDataSource>().getEmployeeId();

      final responseEither = await _dio.safe(
            () => _dio.post(
          '/EleaveInsert',
          data: {
            'employeeid': employeeId,
            'datedaytype': params.datedaytype,
            'fromtime': params.fromtime,
            'totime': params.totime,
            'duration': params.duration,
            'reason': params.reason,
            'attachment': params.attachment,
            'userid': 'NLA47014',
            'eleavetype': params.eleavetype,
          },
        ),
            (res) => res,
      );

      return await responseEither.fold(
            (failure) => Left(failure),
            (response) {
          if (response.statusCode != 200) {
            return const Left(ServerFailure('Failed to submit E-leave'));
          }
          final data = response.data as Map<String, dynamic>;

          if (data['_statusCode'] == '101') {
            return Left(ServerFailure(data['_statusMessage'] as String));
          }
          return Right(data['_statusMessage'] as String);
        },
      );
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

}

