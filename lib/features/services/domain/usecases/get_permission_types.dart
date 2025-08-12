import 'package:moet_hub/features/services/domain/entities/permission_types_entity.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/services_repository.dart';

@injectable
class GetPermissionTypesUseCase {
  final ServiceRepository _repository;

  GetPermissionTypesUseCase(this._repository);

  Future<Either<Failure, List<PermissionTypesEntity>>> execute() async {
    return await _repository.getPermissionTypes();
  }
}