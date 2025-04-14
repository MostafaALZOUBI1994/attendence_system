import 'package:attendence_system/features/services/domain/entities/eleave_entity.dart';
import 'package:attendence_system/features/services/domain/entities/permission_types_entity.dart';
import 'package:attendence_system/features/services/domain/usecases/get_allowed_hours.dart';
import 'package:attendence_system/features/services/domain/usecases/get_permission_types.dart';
import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

import '../../data/models/leave_request_params.dart';
import '../../domain/usecases/submit_leaveRequest.dart';

part 'services_event.dart';

part 'services_state.dart';

part 'services_bloc.freezed.dart';

@LazySingleton()
class ServicesBloc extends Bloc<ServicesEvent, ServicesState> {
  final GetPermissionTypesUseCase _getPermissionTypesUseCase;
  final GetAllowedHourseUseCase _getAllowedHourseUseCase;
  final SubmitLeaveRequestUseCase _submitLeaveRequestUseCase;

  ServicesBloc({
    required GetPermissionTypesUseCase getPermissionTypesUseCase,
    required GetAllowedHourseUseCase getAllowedHourseUseCase,
    required SubmitLeaveRequestUseCase submitLeaveRequestUseCase,
  })  : _getPermissionTypesUseCase = getPermissionTypesUseCase,
        _getAllowedHourseUseCase = getAllowedHourseUseCase,
        _submitLeaveRequestUseCase = submitLeaveRequestUseCase,
        super(const ServicesState.initial()) {
    on<ServicesEvent>(_onEvent);
    add(const LoadData());
  }

  Future<void> _onEvent(
    ServicesEvent event,
    Emitter<ServicesState> emit,
  ) async {
    await event.when(
      started: () async {},
      loadData: () async => await _loadData(emit),
      submitRequest: (
          String dateDayType,
          String fromTime,
          String toTime,
          String duration,
          String reason,
          String attachment,
          String eLeaveType) async {
       await  _submitRequest(emit, dateDayType, fromTime, toTime,
            duration, reason, attachment, eLeaveType);
      },
    );
  }

  Future<void> _loadData(Emitter<ServicesState> emit) async {
    emit(const ServicesState.loading());
    final leaveTypesResult = await _getPermissionTypesUseCase.execute();
    final leaveBalanceResult = await _getAllowedHourseUseCase.execute();

    if (leaveTypesResult.isRight() && leaveBalanceResult.isRight()) {
      final leaveTypes = leaveTypesResult.getOrElse(() => []);
      final leaveBalance = leaveBalanceResult.getOrElse(() => EleaveEntity(
          noOfHrsAllowed: "noOfHrsAllowed",
          noOfHrsAvailable: "noOfHrsAvailable",
          noOfHrsUtilized: "noOfHrsUtilized",
          noOfHrsPending: "noOfHrsPending"));
      emit(ServicesState.loaded(
          leaveTypes: leaveTypes, leaveBalance: leaveBalance));
    } else {
      emit(const ServicesState.error("Failed to load data"));
    }
  }

  Future<void> _submitRequest(
    Emitter<ServicesState> emit,
    String dateDayType,
    String fromTime,
    String toTime,
    String duration,
    String reason,
    String attachment,
    String eLeaveType,
  ) async {
    emit(const ServicesState.loading());

    final params = SubmitLeaveRequestParams(
      datedaytype: dateDayType,
      fromtime: fromTime,
      totime: toTime,
      duration: duration,
      reason: reason,
      attachment: attachment,
      eleavetype: eLeaveType,
    );

    final result = await _submitLeaveRequestUseCase.execute(params);

    result.fold(
      (failure) => emit(ServicesState.submissionFailure(failure.message)),
      (message) => emit(ServicesState.submissionSuccess(message)),
    );
  }
}
