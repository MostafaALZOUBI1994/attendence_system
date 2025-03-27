import 'package:attendence_system/core/constants/constants.dart';
import 'package:attendence_system/features/authentication/domain/entities/login_success_model.dart';
import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../core/local_services/local_services.dart';
import 'attendence_event.dart';
import 'attendence_state.dart';

@injectable
class AttendenceBloc extends Bloc<AttendenceEvent, AttendenceState> {
  final LocalService _localService;

  AttendenceBloc(this._localService) : super(const AttendenceState.initial()) {
    on<AttendenceEvent>((event, emit) async {
      if (event is LoadData) {
        final user = LoginSuccessData(
            empID: _localService.get(empID) ?? "",
            empName: _localService.get(empName) ?? "",
            empNameAR: _localService.get(empNameAR) ?? "",
            empProfileImage: _localService.get(empID) ?? "");
        emit(AttendenceState.loaded(loginData: user));
      }
    });
  }
}
