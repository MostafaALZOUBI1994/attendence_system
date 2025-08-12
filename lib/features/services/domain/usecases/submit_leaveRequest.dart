import 'package:moet_hub/features/services/domain/repositories/services_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../../data/models/leave_request_params.dart';

@injectable
class SubmitLeaveRequestUseCase {
  final ServiceRepository _repository;

  SubmitLeaveRequestUseCase(this._repository);

  Future<Either<Failure, String>> execute(SubmitLeaveRequestParams params) async {
    return await _repository.submitLeaveRequest(params);
  }
}