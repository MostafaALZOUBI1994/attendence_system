
import 'package:attendence_system/core/errors/failures.dart';
import 'package:attendence_system/features/services/domain/entities/eleave_entity.dart';
import 'package:attendence_system/features/services/domain/entities/permission_types_entity.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/local_services/local_services.dart';
import '../../domain/repositories/services_repository.dart';
import '../models/eleave_model.dart';
import '../models/permission_types_model.dart';

@LazySingleton(as: ServiceRepository)
class ServicesRepositoryImpl implements ServiceRepository {
  final Dio _dio;
  final LocalService _localService;

  ServicesRepositoryImpl(this._dio, this._localService);

  @override
  Future<Either<Failure, EleaveEntity>> getLeaveBalance() async {
    try {
      final response = await _dio.get('/Eleavebalance', queryParameters: {'langcode': 'en-US'});
      final List<dynamic> data = response.data;
      final leaveBalances =  EleaveModel.fromJson(data[0]);
      return Right( EleaveEntity(
        noOfHrsAllowed: leaveBalances.noOfHrsAllowed,
        noOfHrsAvailable: leaveBalances.noOfHrsAvailable,
        noOfHrsUtilized: leaveBalances.noOfHrsUtilized,
        noOfHrsPending: leaveBalances.noOfHrsPending,
      ));
    } catch (e) {
      return Left(ServerFailure("An unexpected error occurred: $e"));
    }
  }

  @override
  Future<Either<Failure, List<PermissionTypesEntity>>> getPermissionTypes() async {
    try {
      final response = await _dio.get('/PermissionTypes', queryParameters: {'langcode': 'en-US'});
      final List<dynamic> data = response.data;
      final permissionTypes = data.map((json) => PermissionTypesModel.fromJson(json)).toList();
      return Right(permissionTypes.map((model) => PermissionTypesEntity(
        permissionCode: model.permissionCode,
        permissionNameEN: model.permissionNameEN,
        permissionNameAR: model.permissionNameAR,
      )).toList());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

