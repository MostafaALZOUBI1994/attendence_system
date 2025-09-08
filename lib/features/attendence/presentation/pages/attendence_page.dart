import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/attendence_bloc.dart';
import '../widgets/main_content.dart';

class TimeScreen extends StatefulWidget {
  TimeScreen({Key? key}) : super(key: key);

  @override
  State<TimeScreen> createState() => _TimeScreenState();
}

class _TimeScreenState extends State<TimeScreen> with WidgetsBindingObserver{

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
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
          loaded: (l) => MainContent(
            employee: l.employee,
            currentStepIndex: l.currentStepIndex,
            remainingTime: l.remainingTime,
            progress: l.progress,
            todayStatus: l.todayStatus,
            isCheckInSuccess: false,
          ),
          checkInSuccess: (s) => MainContent(
            employee: s.employee,
            currentStepIndex: s.currentStepIndex,
            remainingTime: s.remainingTime,
            progress: s.progress,
            todayStatus: s.todayStatus,
            isCheckInSuccess: true,
          ),
          error: (e) => MainContent(
            employee: e.employee,
            currentStepIndex: e.currentStepIndex,
            remainingTime: e.remainingTime,
            progress: e.progress,
            todayStatus: e.todayStatus,
            isCheckInSuccess: false,
          ),
          orElse: () => const SizedBox.shrink(),
        );
      },
    );
  }
}
