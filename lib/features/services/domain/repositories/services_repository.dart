import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/eleave_entity.dart';
import '../entities/permission_types_entity.dart';

abstract class ServiceRepository {
  Future<Either<Failure, EleaveEntity>> getLeaveBalance();
  Future<Either<Failure, List<PermissionTypesEntity>>> getPermissionTypes();
}