import 'package:attendence_system/features/services/domain/entities/eleave_entity.dart';
import 'package:attendence_system/features/services/domain/entities/permission_types_entity.dart';
import 'package:attendence_system/features/services/domain/usecases/get_allowed_hours.dart';
import 'package:attendence_system/features/services/domain/usecases/get_permission_types.dart';
import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
part 'services_event.dart';
part 'services_state.dart';
part 'services_bloc.freezed.dart';

@LazySingleton()
class ServicesBloc extends Bloc<ServicesEvent, ServicesState> {
  final GetPermissionTypesUseCase _getPermissionTypesUseCase;
  final GetAllowedHourseUseCase _getAllowedHourseUseCase;

  ServicesBloc({
    required GetPermissionTypesUseCase getPermissionTypesUseCase,
    required GetAllowedHourseUseCase getAllowedHourseUseCase,
  })  : _getPermissionTypesUseCase = getPermissionTypesUseCase,
        _getAllowedHourseUseCase = getAllowedHourseUseCase,
        super(const ServicesState.initial()) {
    on<ServicesEvent>(_onEvent);
  }
  Future<void> _onEvent(ServicesEvent event, Emitter<ServicesState> emit) async {

    if (event is SubmitRequest) {
      await _submitRequest(emit);
    }
  }

  Future<void> _loadData(Emitter<ServicesState> emit) async {
    emit(const ServicesState.loading());
    final leaveTypesResult = await _getPermissionTypesUseCase.execute();
    final leaveBalanceResult = await _getAllowedHourseUseCase.execute();

    if (leaveTypesResult.isRight() && leaveBalanceResult.isRight()) {
      final leaveTypes = leaveTypesResult.getOrElse(() => []);
      final leaveBalance = leaveBalanceResult.getOrElse(() => EleaveEntity(noOfHrsAllowed: "noOfHrsAllowed", noOfHrsAvailable: "noOfHrsAvailable", noOfHrsUtilized: "noOfHrsUtilized", noOfHrsPending: "noOfHrsPending"));
      emit(ServicesState.loaded(leaveTypes: leaveTypes, leaveBalance: leaveBalance));
    } else {
      emit(const ServicesState.error("Failed to load data"));
    }
  }

  Future<void> _submitRequest(Emitter<ServicesState> emit) async {
    emit(const ServicesState.error("Request submitted successfully"));
  }
}
