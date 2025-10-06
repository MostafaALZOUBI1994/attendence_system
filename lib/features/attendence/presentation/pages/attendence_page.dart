import 'dart:io';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/attendence_bloc.dart';
import '../widgets/main_content.dart';

class TimeScreen extends StatefulWidget {
  const TimeScreen({Key? key}) : super(key: key);

  @override
  State<TimeScreen> createState() => _TimeScreenState();
}

class _TimeScreenState extends State<TimeScreen> with WidgetsBindingObserver {
  @override
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AttendenceBloc>().add(const AttendenceEvent.loadData());
      _askPushPermissionOnce();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      context.read<AttendenceBloc>().add(const AttendenceEvent.loadData());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AttendenceBloc, AttendenceState>(
      listenWhen: (previous, current) {
        // show dialog only when *entering* success/error
        final prevType = previous.runtimeType;
        final currType = current.runtimeType;
        final isTarget = current.maybeMap(
          checkInSuccess: (_) => true,
          error: (_) => true,
          orElse: () => false,
        );
        return isTarget && prevType != currType;
      },
      buildWhen: (prev, curr) {
        if (prev is Loaded && curr is Loaded) {
          final samePayload =
              identical(prev.employee, curr.employee) &&
                  prev.phase == curr.phase &&
                  prev.currentStepIndex == curr.currentStepIndex &&
                  // We reuse the same TodayStatus instance in _onTick, so identity check works:
                  identical(prev.todayStatus, curr.todayStatus);
          // If only remainingTime/progress changed, skip rebuilding the whole page.
          return !samePayload;
        }
        if (prev is CheckInSuccess && curr is Loaded) {
          // allow rebuild when leaving success
          return true;
        }
        return prev.runtimeType != curr.runtimeType;
      },
      listener: (context, state) {
        state.maybeMap(
          checkInSuccess: (s) => AwesomeDialog(
            context: context,
            dialogType: DialogType.success,
            animType: AnimType.rightSlide,
            title: 'success'.tr(),
            desc: s.message,
            btnOkOnPress: () {},
          ).show(),
          error: (e) => AwesomeDialog(
            context: context,
            dialogType: DialogType.error,
            animType: AnimType.rightSlide,
            title: 'oops'.tr(),
            desc: e.message,
            btnOkOnPress: () {},
          ).show(),
          orElse: () {},
        );
      },
      builder: (context, state) {
        return state.maybeMap(
          loading: (_) => const Center(child: CircularProgressIndicator()),
          loaded: (l) => MainContent(
            employee: l.employee,
            currentStepIndex: l.currentStepIndex,
            remainingTime: l.remainingTime,
            todayStatus: l.todayStatus,
            phase: l.phase,
            isCheckInSuccess: false,
          ),
          checkInSuccess: (s) => MainContent(
            employee: s.employee,
            currentStepIndex: s.currentStepIndex,
            remainingTime: s.remainingTime,
            todayStatus: s.todayStatus,
            phase: s.phase,
            isCheckInSuccess: true,
          ),
          error: (e) => MainContent(
            employee: e.employee,
            currentStepIndex: e.currentStepIndex,
            remainingTime: e.remainingTime,
            todayStatus: e.todayStatus,
            phase: e.phase,
            isCheckInSuccess: false,
          ),
          orElse: () => const SizedBox.shrink(),
        );
      },
    );
  }
  Future<void> _askPushPermissionOnce() async {
    if (!Platform.isIOS) return;
    final m = FirebaseMessaging.instance;
    final s = await m.getNotificationSettings();
    if (s.authorizationStatus == AuthorizationStatus.notDetermined) {
      await m.requestPermission(alert: true, badge: true, sound: true);
      await m.setForegroundNotificationPresentationOptions(
        alert: true, badge: true, sound: true,
      );
    }
  }
}

