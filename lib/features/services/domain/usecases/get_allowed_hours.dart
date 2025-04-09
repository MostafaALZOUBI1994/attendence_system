import 'package:attendence_system/features/services/domain/entities/eleave_entity.dart';
import 'package:attendence_system/features/services/domain/repositories/services_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../../../authentication/domain/entities/login_success_model.dart';

@injectable
class GetAllowedHourseUseCase {
  final ServiceRepository _repository;

  GetAllowedHourseUseCase(this._repository);

  Future<Either<Failure, EleaveEntity>> execute() {
    return _repository.getLeaveBalance();
  }
}


