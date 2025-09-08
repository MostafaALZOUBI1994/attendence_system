import 'dart:async';
import 'package:moet_hub/features/attendence/domain/usecases/checkin_usecase.dart';
import 'package:moet_hub/features/attendence/domain/usecases/today_status_usecase.dart';
import 'package:moet_hub/features/authentication/data/mappers/employee_mapper.dart';
import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:intl/intl.dart';
import '../../../../core/local_services/local_services.dart';
import '../../../../core/local_services/simple_notifier.dart';
import '../../../authentication/data/datasources/employee_local_data_source.dart';
import '../../../authentication/domain/entities/employee.dart';
import '../../domain/entities/today_status.dart';
part 'attendence_event.dart';
part 'attendence_state.dart';
part 'attendence_bloc.freezed.dart';

@injectable
class AttendenceBloc extends Bloc<AttendenceEvent, AttendenceState> {
  final EmployeeLocalDataSource _employeeLocalDs;
  final GetTodayStatusUseCase _getTodayStatusUseCase;
  final CheckinUsecase _checkinUsecase;

  Timer? _countdownTimer;
  DateTime? _expectedCheckoutTime;

  AttendenceBloc(
      this._getTodayStatusUseCase,
      this._checkinUsecase,
      this._employeeLocalDs,
      ) : super(const AttendenceState.initial()) {
    on<LoadData>(_onLoadData);
    on<StepChanged>(_onStepChanged);
    on<CheckIn>(_onCheckIn);
    on<Tick>(_onTick);
  }

  Future<void> _onLoadData(
      LoadData event, Emitter<AttendenceState> emit) async {
    final model = await _employeeLocalDs.getProfile();
    if (model == null) {
      // no cached user
      return emit(const AttendenceState.error(message: "No cached employee found", employee: Employee(
          "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "","",""), todayStatus: TodayStatus()));
    }
    final employee = model.toEntity();


    final todayStatusResult = await _getTodayStatusUseCase.execute();

    todayStatusResult.fold(
          (failure) {
        emit(AttendenceState.loaded(employee: employee, todayStatus: TodayStatus()));
      },
          (todayStatus) {
        int initialStep = 0;
        if (todayStatus.expectedOutTime != "00:00") {
          initialStep = 2;
        }

        if (todayStatus.expectedOutTime != "00:00") {
          final parsedTime =
          DateFormat('hh:mm a', "en").parse(todayStatus.expectedOutTime);
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

        UaeShiftNotifier.scheduleTodayUae(todayStatus.expectedOutTime);
        emit(AttendenceState.loaded(
          employee: employee,
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
    if (state is! Loaded) return;
    final loaded = state as Loaded;

    final result = await _checkinUsecase.execute();
    result.fold(
          (failure) {
        emit(AttendenceState.error(
          message: failure.message,
          employee: loaded.employee,
          todayStatus: loaded.todayStatus,
          currentStepIndex: loaded.currentStepIndex,
          remainingTime: loaded.remainingTime,
          progress: loaded.progress,
        ));
      },
          (successMessage) {
        emit(AttendenceState.checkInSuccess(
          message: successMessage,
          employee: loaded.employee,
          todayStatus: loaded.todayStatus,
          currentStepIndex: loaded.currentStepIndex + 1,
          remainingTime: loaded.remainingTime,
          progress: loaded.progress,
        ));

        Future.delayed(const Duration(milliseconds: 1500), () {
          add(const AttendenceEvent.loadData());
        });
      },
    );
  }



  void _onTick(Tick event, Emitter<AttendenceState> emit) {
    if (state is Loaded && _expectedCheckoutTime != null) {
      final now = DateTime.now();
      final remaining = _expectedCheckoutTime!.difference(now);

      double progress = 0.0;
      final loaded = state as Loaded;
      try {
        final checkIn = DateFormat('hh:mm a','en')
            .parse(loaded.todayStatus.checkInTime);
        final checkOut = DateFormat('hh:mm a','en')
            .parse(loaded.todayStatus.expectedOutTime);
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

