import 'dart:async';

import 'package:attendence_system/core/constants/constants.dart';
import 'package:attendence_system/features/attendence/domain/usecases/checkin_usecase.dart';
import 'package:attendence_system/features/attendence/domain/usecases/today_status_usecase.dart';
import 'package:attendence_system/features/authentication/domain/entities/login_success_model.dart';
import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:intl/intl.dart';
import '../../../../core/local_services/local_services.dart';
import 'attendence_event.dart';
import 'attendence_state.dart';

@injectable
class AttendenceBloc extends Bloc<AttendenceEvent, AttendenceState> {
  final LocalService _localService;
  final GetTodayStatusUseCase _getTodayStatusUseCase;
  final CheckinUsecase _checkinUsecase;

  Timer? _countdownTimer;
  DateTime? _expectedCheckoutTime;

  AttendenceBloc(
      this._localService,
      this._getTodayStatusUseCase,
      this._checkinUsecase,
      ) : super(const AttendenceState.initial()) {
    on<LoadData>(_onLoadData);
    on<StepChanged>(_onStepChanged);
    on<CheckIn>(_onCheckIn);
    on<Tick>(_onTick);
  }

  Future<void> _onLoadData(
      LoadData event, Emitter<AttendenceState> emit) async {
    final loginData = LoginSuccessData(
      empID: _localService.get(empID) ?? "",
      empName: _localService.get(empName) ?? "",
      empNameAR: _localService.get(empNameAR) ?? "",
      empProfileImage: _localService.get(empID) ?? "",
    );

    final todayStatusResult = await _getTodayStatusUseCase.execute();

    todayStatusResult.fold(
          (failure) {
        emit(AttendenceState.loaded(loginData: loginData));
      },
          (todayStatus) {
        int initialStep = 0;
        if (todayStatus.expectedOutTime != "00:00") {
          initialStep = 2;
        }

        if (todayStatus.expectedOutTime != "00:00") {
          final parsedTime =
          DateFormat('hh:mm a').parse(todayStatus.expectedOutTime);
          final now = DateTime.now();
          _expectedCheckoutTime = DateTime(
            now.year,
            now.month,
            now.day,
            parsedTime.hour,
            parsedTime.minute,
          );
          if (_expectedCheckoutTime!.isBefore(now)) {
            _expectedCheckoutTime =
                _expectedCheckoutTime!.add(const Duration(days: 1));
          }
          _startTicker();
        }

        emit(AttendenceState.loaded(
          loginData: loginData,
          todayStatus: todayStatus,
          currentStepIndex: initialStep,
          remainingTime: _expectedCheckoutTime != null
              ? _expectedCheckoutTime!.difference(DateTime.now())
              : Duration.zero,
          progress: 0.0,
        ));
      },
    );
  }

  void _onStepChanged(
      StepChanged event, Emitter<AttendenceState> emit) {
    if (state is Loaded) {
      final loaded = state as Loaded;
      emit(loaded.copyWith(currentStepIndex: event.newIndex));
    }
  }

  Future<void> _onCheckIn(CheckIn event, Emitter<AttendenceState> emit) async {
    try {
      final checkIn = await _checkinUsecase.execute();
      checkIn.fold(
            (failure) => emit(AttendenceState.error(failure.message)),
            (success) {
          if (state is Loaded) {
            final loaded = state as Loaded;
            emit(AttendenceState.checkInSuccess(
              message: success,
              loginData: loaded.loginData,
              todayStatus: loaded.todayStatus,
              currentStepIndex: loaded.currentStepIndex + 1,
              remainingTime: loaded.remainingTime,
              progress: loaded.progress,
            ));
            Future.delayed(const Duration(milliseconds: 1500), () {
              add(AttendenceEvent.loadData());
            });
          }
        },
      );
    } catch (e) {
      emit(AttendenceState.error(e.toString()));
    }
  }


  void _onTick(Tick event, Emitter<AttendenceState> emit) {
    if (state is Loaded && _expectedCheckoutTime != null) {
      final now = DateTime.now();
      final remaining = _expectedCheckoutTime!.difference(now);

      double progress = 0.0;
      final loaded = state as Loaded;
      if (loaded.todayStatus?.checkInTime != null) {
        try {
          final checkIn = DateFormat('hh:mm a')
              .parse(loaded.todayStatus!.checkInTime);
          final checkOut = DateFormat('hh:mm a')
              .parse(loaded.todayStatus!.expectedOutTime);
          final nowDate = DateTime.now();
          final checkInDateTime = DateTime(
            nowDate.year,
            nowDate.month,
            nowDate.day,
            checkIn.hour,
            checkIn.minute,
          );
          var expectedCheckout = DateTime(
            nowDate.year,
            nowDate.month,
            nowDate.day,
            checkOut.hour,
            checkOut.minute,
          );
          if (expectedCheckout.isBefore(checkInDateTime)) {
            expectedCheckout = expectedCheckout.add(const Duration(days: 1));
          }
          final totalDuration = expectedCheckout.difference(checkInDateTime).inSeconds;
          final elapsed = now.difference(checkInDateTime).inSeconds;
          progress = (elapsed / totalDuration * 100).clamp(0.0, 100.0);
        } catch (e) {

        }
      }
      emit(loaded.copyWith(remainingTime: remaining, progress: progress));
    }
  }

  void _startTicker() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      add(const AttendenceEvent.tick());
    });
  }

  @override
  Future<void> close() {
    _countdownTimer?.cancel();
    return super.close();
  }
}

