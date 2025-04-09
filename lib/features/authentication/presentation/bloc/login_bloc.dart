import 'package:attendence_system/core/constants/constants.dart';
import 'package:attendence_system/core/local_services/local_services.dart';
import 'package:attendence_system/features/authentication/domain/usecases/login_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_event.dart';
import 'login_state.dart';

@injectable
class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final LoginUseCase _loginUseCase;
  final LocalService _localService;
  LoginBloc(this._loginUseCase, this._localService)
      : super(const LoginState.initial()) {
    on<QrScanned>((event, emit) {
      emit(Login(email: event.email, isScanning: false));
    });

    on<StartScanning>((event, emit) {
      if (state is Login) {
        emit(Login(
          email: (state as Login).email,
          isScanning: true,
        ));
      } else {
        emit(const Login(email: '', isScanning: true));
      }
    });

    on<StopScanning>((event, emit) {
      if (state is Login) {
        emit(Login(
          email: (state as Login).email,
          isScanning: false,
        ));
      }
    });

    on<LoginSubmitted>((event, emit) async {
      emit(const LoginState.loading());
      try {
        final result = await _loginUseCase.execute(event.email, event.password);
        result.fold(
          (failure) => emit(LoginError(failure.message)),
          (successData) async {
            emit(const LoginState.success());
            await _localService.save(empID, successData.empID);
            await _localService.save(empName, successData.empName);
            await _localService.save(empNameAR, successData.empNameAR);
            // await _localService.save(emp, successData.empID);
          },
        );
      } catch (e) {
        emit(LoginError('Unexpected error: $e'));
      }
    });
  }
}
