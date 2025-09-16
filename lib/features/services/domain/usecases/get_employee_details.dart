import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../entities/employee_details_entity.dart';
import '../repositories/services_repository.dart';

@injectable
class GetEmployeeDetailsUseCase {
  final ServiceRepository _repository;
  GetEmployeeDetailsUseCase(this._repository);

  Future<Either<Failure, List<EmployeeDetailsEntity>>> execute(String department) {
    return _repository.getEmployeeDetails(department: department);
  }
}
