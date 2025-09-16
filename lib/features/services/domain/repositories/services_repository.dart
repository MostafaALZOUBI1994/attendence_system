import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../data/models/leave_request_params.dart';
import '../entities/eleave_entity.dart';
import '../entities/employee_details_entity.dart';
import '../entities/permission_types_entity.dart';

abstract class ServiceRepository {
  Future<Either<Failure, EleaveEntity>> getLeaveBalance();
  Future<Either<Failure, List<PermissionTypesEntity>>> getPermissionTypes();
  Future<Either<Failure, String>> submitLeaveRequest(SubmitLeaveRequestParams params);
  Future<Either<Failure, List<EmployeeDetailsEntity>>> getEmployeeDetails({
    required String department,
  });
}