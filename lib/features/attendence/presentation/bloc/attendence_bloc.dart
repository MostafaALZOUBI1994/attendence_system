import 'package:attendence_system/core/constants/constants.dart';
import 'package:attendence_system/features/authentication/domain/entities/login_success_model.dart';
import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/local_services/local_services.dart';
import '../../domain/repositories/attendence_repository.dart';
import 'attendence_event.dart';
import 'attendence_state.dart';

@injectable
class AttendenceBloc extends Bloc<AttendenceEvent, AttendenceState> {
  final LocalService _localService;
  final AttendenceRepository _attendanceRepository;
  AttendenceBloc(this._localService, this._attendanceRepository) : super(const AttendenceState.initial()) {
    on<LoadData>(_onLoadData);
    on<StepChanged>(_onStepChanged);
  }

  void _onLoadData(LoadData event, Emitter<AttendenceState> emit) async {
    final loginData = LoginSuccessData(
        empID: _localService.get(empID) ?? "",
        empName: _localService.get(empName) ?? "",
        empNameAR: _localService.get(empNameAR) ?? "",
        empProfileImage: _localService.get(empID) ?? ""
    );

    final todayStatusResult = await _attendanceRepository.getTodayStatus();

    todayStatusResult.fold(
            (failure) => emit(AttendenceState.loaded(loginData: loginData)),
            (todayStatus) {
          int initialStep = 0;

          if(todayStatus.expectedOutTime != "00:00") {
            initialStep = 2;
          }

          emit(AttendenceState.loaded(
              loginData: loginData,
              todayStatus: todayStatus,
              currentStepIndex: initialStep
          ));
        }
    );
  }
  void _onStepChanged(StepChanged event, Emitter<AttendenceState> emit) {
    if (state is Loaded) {
      emit(
        (state as Loaded).copyWith(
          currentStepIndex: event.newIndex,
        ),
      );
    }
  }
}
