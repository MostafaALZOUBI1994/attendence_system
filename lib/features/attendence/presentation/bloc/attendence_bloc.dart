import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:intl/intl.dart';

import 'package:moet_hub/features/attendence/domain/usecases/checkin_usecase.dart';
import 'package:moet_hub/features/attendence/domain/usecases/today_status_usecase.dart';
import 'package:moet_hub/features/authentication/data/mappers/employee_mapper.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/injection.dart';
import '../../../../core/local_services/carplay_service.dart';
import '../../../../core/local_services/local_services.dart';
import '../../../../core/local_services/simple_notifier.dart';
import '../../../../core/sync/offsite_event_bus.dart';
import '../../../authentication/data/datasources/employee_local_data_source.dart';
import '../../../authentication/domain/entities/employee.dart';
import '../../domain/entities/today_status.dart';
import '../../domain/entities/today_status_copywith.dart';

part 'attendence_event.dart';
part 'attendence_state.dart';
part 'attendence_bloc.freezed.dart';

@injectable
class AttendenceBloc extends Bloc<AttendenceEvent, AttendenceState> {
  final EmployeeLocalDataSource _employeeLocalDs;
  final GetTodayStatusUseCase _getTodayStatusUseCase;
  final CheckinUsecase _checkinUsecase;
  final OffsiteEventBus _offsiteBus;                      // << INJECT THIS

  Timer? _countdownTimer;                                 // << NOT injected
  DateTime? _expectedCheckoutTime;                        // << NOT injected
  StreamSubscription<void>? _offsiteSub;                  // << NOT injected

  AttendenceBloc(
      this._getTodayStatusUseCase,
      this._checkinUsecase,
      this._employeeLocalDs,
      this._offsiteBus,                                     // << keep only the bus
      ) : super(const AttendenceState.initial()) {
    on<LoadData>(_onLoadData);
    on<StepChanged>(_onStepChanged);
    on<CheckIn>(_onCheckIn);
    on<Tick>(_onTick);
    on<RefreshOffsites>(_onRefreshOffsites);

    // Create the subscription HERE (don’t inject it)
    _offsiteSub = _offsiteBus.stream.listen((_) {
      add(const AttendenceEvent.refreshOffsites());
    });
  }


  // ----------------- LOAD (called on first open & app resume) -----------------
  Future<void> _onLoadData(LoadData event, Emitter<AttendenceState> emit) async {
    emit(const AttendenceState.loading());

    final model = await _employeeLocalDs.getProfile();
    if (model == null) {
      return emit(AttendenceState.error(
        message: "No cached employee found",
        employee: const Employee("", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""),
        todayStatus: const TodayStatus(),
        phase: AttendancePhase.beforeArrival,
      ));
    }
    final employee = model.toEntity();

    final res = await _getTodayStatusUseCase.execute();
    await res.fold(
          (failure) async {
        // Fall back to local offsites so user can continue
        final local = getIt<LocalService>();
        final offsites = _onlyToday(local.getMillisList(checkIns) ?? const []);
        final status = const TodayStatus().copyWith(offSiteCheckIns: offsites);
        final phase = _derivePhase(status);
        _setupTickerIfOnsite(status);
        emit(AttendenceState.loaded(
          employee: employee,
          todayStatus: status,
          phase: phase,
          currentStepIndex: _mapPhaseToStep(phase),
          remainingTime: _deriveRemaining(status),
          progress: _deriveProgress(status),
        ));
      },
          (statusFromApi) async {
        // Normalize offsites to today only (phone + carplay)
        final filtered = _onlyToday(statusFromApi.offSiteCheckIns);
        final status = statusFromApi.copyWith(offSiteCheckIns: filtered);

        UaeShiftNotifier.scheduleTodayUae(status.expectedOutTime);
        _setupTickerIfOnsite(status);

        final phase = _derivePhase(status);
        emit(AttendenceState.loaded(
          employee: employee,
          todayStatus: status,
          phase: phase,
          currentStepIndex: _mapPhaseToStep(phase),
          remainingTime: _deriveRemaining(status),
          progress: _deriveProgress(status),
        ));
      },
    );
  }

  // ----------------- OFFSITE CHECK-IN -----------------
  Future<void> _onCheckIn(CheckIn event, Emitter<AttendenceState> emit) async {
    final loaded = state.maybeMap(loaded: (s) => s, orElse: () => null);
    if (loaded == null) return;

    final result = await _checkinUsecase.execute(); // network only for check-in
    result.fold(
          (failure) {
        emit(AttendenceState.error(
          message: failure.message,
          employee: loaded.employee,
          todayStatus: loaded.todayStatus,
          phase: loaded.phase,
          currentStepIndex: loaded.currentStepIndex,
          remainingTime: loaded.remainingTime,
        ));
      },
          (successMessage) {
        // 1) Show success once (dialog/Lottie)
        emit(AttendenceState.checkInSuccess(
          message: successMessage,
          employee: loaded.employee,
          todayStatus: loaded.todayStatus,
          phase: loaded.phase,
          currentStepIndex: loaded.currentStepIndex,
          remainingTime: loaded.remainingTime,
        ));
        // 2) Refresh offsites from SharedPreferences only (NO TodayStatus API)
        add(const AttendenceEvent.refreshOffsites());
      },
    );
  }

  // ----------------- REFRESH OFFSITES (LOCAL ONLY) -----------------
  Future<void> _onRefreshOffsites(RefreshOffsites event, Emitter<AttendenceState> emit) async {
    final local = getIt<LocalService>();
    final updated = List<int>.from(local.getMillisList(checkIns) ?? const []);

    state.maybeWhen(
      loaded: (employee, ts, phase, idx, remaining, progress) async {
        final ts2 = ts.copyWith(offSiteCheckIns: List<int>.unmodifiable(updated));
        final phase2 = _derivePhase(ts2);
        emit(AttendenceState.loaded(
          employee: employee,
          todayStatus: ts2,
          phase: phase2,
          currentStepIndex: _mapPhaseToStep(phase2),
          remainingTime: remaining,
          progress: progress,
        ));
        await CarPlayService.sync();
      },
      checkInSuccess: (msg, employee, ts, phase, idx, remaining) async {
        final ts2 = ts.copyWith(offSiteCheckIns: List<int>.unmodifiable(updated));
        final phase2 = _derivePhase(ts2);
        emit(AttendenceState.loaded(
          employee: employee,
          todayStatus: ts2,
          phase: phase2,
          currentStepIndex: _mapPhaseToStep(phase2),
          remainingTime: remaining,
          progress: 0.0,
        ));
        await CarPlayService.sync();
      },
      orElse: () async {
        await CarPlayService.sync();
      },
    );
  }

  // ----------------- STEP CHANGE (optional) -----------------
  void _onStepChanged(StepChanged event, Emitter<AttendenceState> emit) {
    state.maybeWhen(
      loaded: (employee, ts, phase, _, remaining, progress) {
        emit(AttendenceState.loaded(
          employee: employee,
          todayStatus: ts,
          phase: phase,
          currentStepIndex: event.newIndex,
          remainingTime: remaining,
          progress: progress,
        ));
      },
      orElse: () {},
    );
  }

  // ----------------- TICK -----------------
  void _onTick(Tick event, Emitter<AttendenceState> emit) {
    state.maybeWhen(
      loaded: (employee, ts, phase, idx, _, __) {
        if (_expectedCheckoutTime == null) return;
        final rem = _expectedCheckoutTime!.difference(DateTime.now());
        emit(AttendenceState.loaded(
          employee: employee,
          todayStatus: ts,
          phase: phase,
          currentStepIndex: idx,
          remainingTime: rem.isNegative ? Duration.zero : rem,
          progress: _deriveProgress(ts),
        ));
      },
      orElse: () {},
    );
  }

  // ----------------- HELPERS -----------------
  void _setupTickerIfOnsite(TodayStatus s) {
    final end = _parseTodayTime(s.expectedOutTime);
    if (end == null) {
      _countdownTimer?.cancel();
      _expectedCheckoutTime = null;
      return;
    }
    final now = DateTime.now();
    _expectedCheckoutTime = end.isBefore(now) ? end.add(const Duration(days: 1)) : end;
    _startTicker();
  }

  AttendancePhase _derivePhase(TodayStatus s) {
    final hasOffsite  = s.offSiteCheckIns.isNotEmpty;
    final hasOnsite   = s.punchInOffice.trim().isNotEmpty && s.punchInOffice != "00:00";
    final hasExpected = s.expectedOutTime.trim().isNotEmpty && s.expectedOutTime != "00:00";
    final hasOut      = s.outTime.trim().isNotEmpty && s.outTime != "00:00";

    if (hasOut)                   return AttendancePhase.checkedOut; // 4th
    if (hasOnsite && hasExpected) return AttendancePhase.onsite;     // 3rd
    if (hasOffsite)               return AttendancePhase.offsite;    // 2nd
    return AttendancePhase.beforeArrival;                            // 1st
  }

  int _mapPhaseToStep(AttendancePhase p) {
    switch (p) {
      case AttendancePhase.beforeArrival: return 0;
      case AttendancePhase.offsite:       return 1;
      case AttendancePhase.onsite:        return 2;
      case AttendancePhase.checkedOut:    return 3;
    }
  }

  Duration _deriveRemaining(TodayStatus s) {
    final end = _parseTodayTime(s.expectedOutTime);
    if (end == null) return Duration.zero;
    final diff = end.difference(DateTime.now());
    return diff.isNegative ? Duration.zero : diff;
    // Countdown shows only after onsite punch / expectedOutTime is set
  }

  double _deriveProgress(TodayStatus s) {
    try {
      final inT  = _parseTodayTime(s.checkInTime);
      final outT = _parseTodayTime(s.expectedOutTime);
      if (inT == null || outT == null) return 0.0;
      final total = outT.difference(inT).inSeconds;
      if (total <= 0) return 0.0;
      final elapsed = DateTime.now().difference(inT).inSeconds;
      return (elapsed / total * 100).clamp(0.0, 100.0).toDouble();
    } catch (_) {
      return 0.0;
    }
  }

  DateTime? _parseTodayTime(String raw) {
    final t = raw.trim();
    if (t.isEmpty || t == "00:00") return null;
    final now = DateTime.now();
    try {
      final p12 = DateFormat('hh:mm a', 'en').parseStrict(t);
      return DateTime(now.year, now.month, now.day, p12.hour, p12.minute);
    } catch (_) {
      try {
        final p24 = DateFormat('HH:mm').parseStrict(t);
        return DateTime(now.year, now.month, now.day, p24.hour, p24.minute);
      } catch (_) {
        return null;
      }
    }
  }

  List<int> _onlyToday(List<int> ms) {
    if (ms.isEmpty) return const [];
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day).millisecondsSinceEpoch;
    final end = start + const Duration(days: 1).inMilliseconds;
    return ms.where((e) => e >= start && e < end).toList()..sort();
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
    awaitFutureOrNull(_offsiteSub?.cancel());
    return super.close();
  }
}

// optional tiny helper:
Future<void> awaitFutureOrNull(Future<void>? f) async { if (f != null) await f;
}