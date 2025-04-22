import 'package:attendence_system/features/authentication/domain/usecases/login_usecase.dart';
import 'package:attendence_system/features/authentication/domain/usecases/sign_out_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/login_success_model.dart';
import '../../domain/usecases/load_profile_data_usecase.dart';

part 'auth_event.dart';

part 'auth_state.dart';

part 'auth_bloc.freezed.dart';

@injectable
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase _loginUseCase;
  final SignOutUseCase _signOutUseCase;
  final LoadProfileDataUsecase _loadProfileDataUsecase;

  AuthBloc(
      this._loginUseCase, this._signOutUseCase, this._loadProfileDataUsecase)
      : super(const AuthState.initial()) {
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
      emit(const AuthState.loading());
      try {
        final result = await _loginUseCase.execute(event.email, event.password);
        result.fold(
          (failure) => emit(AuthError(failure.message)),
          (successData) => emit( AuthState.success(successData)),
        );
      } catch (e) {
        emit(AuthError('Unexpected error: $e'));
      }
    });

    on<SignOut>((event, emit) async {
      emit(const AuthState.loading());
      try {
        final result = await _signOutUseCase.execute();
        result.fold(
          (failure) => emit(AuthError(failure.message)),
          (successData) => emit(AuthState.success(LoginSuccessData(
              empID: '', empName: '', empNameAR: '', empProfileImage: ''))),
        );
        emit(const AuthState.unauthenticated());
      } catch (e) {
        emit(AuthError('Unexpected error: $e'));
      }
    });

    on<GetProfileData>((event, emit) async {
      emit(const AuthState.loading());
      try {
        final result = await _loadProfileDataUsecase.execute();
        result.fold(
          (failure) => emit(AuthError(failure.message)),
          (successData) => emit(AuthState.success(successData)),
        );
      } catch (e) {
        emit(AuthError('Unexpected error: $e'));
      }
    });
  }
}
