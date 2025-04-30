import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:dashed_circular_progress_bar/dashed_circular_progress_bar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import '../../../../core/constants/constants.dart';
import '../../../authentication/domain/entities/login_success_model.dart';
import '../../domain/entities/process_step.dart';
import '../../domain/entities/today_status.dart';
import '../bloc/attendence_bloc.dart';
import '../widgets/analog_clock.dart';
import '../widgets/mood_check.dart';
import '../widgets/timeline.dart';

class TimeScreen extends StatelessWidget {
  TimeScreen({Key? key}) : super(key: key);

  final String _currentDate =
      DateFormat('MMMM d, yyyy   HH:mm a' ,'en').format(DateTime.now());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title:  Text("home".tr(),
              style: TextStyle(color: Colors.white)),
          backgroundColor: primaryColor,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: BlocConsumer<AttendenceBloc, AttendenceState>(
            listener: (context, state) {
          state.maybeMap(
            checkInSuccess: (s) {
              AwesomeDialog(
                context: context,
                dialogType: DialogType.success,
                animType: AnimType.rightSlide,
                title: 'success'.tr(),
                desc: s.message,
                btnOkOnPress: () {},
              ).show();
            },
            error: (e) {
              AwesomeDialog(
                context: context,
                dialogType: DialogType.error,
                animType: AnimType.rightSlide,
                title: 'oops'.tr(),
                desc: e.message,
                btnOkOnPress: () {},
              ).show();
            },
            orElse: () {},
          );
        }, builder: (context, state) {
          return state.maybeMap(
            loaded: (l) => _buildMainContent(
              loginData: l.loginData,
              currentStepIndex: l.currentStepIndex,
              remainingTime: l.remainingTime,
              progress: l.progress,
              todayStatus: l.todayStatus,
              isCheckInSuccess: false,
              context: context,
            ),
            checkInSuccess: (s) => _buildMainContent(
              loginData: s.loginData,
              currentStepIndex: s.currentStepIndex,
              remainingTime: s.remainingTime,
              progress: s.progress,
              todayStatus: s.todayStatus,
              isCheckInSuccess: true,
              context: context,
            ),
            error: (e) => _buildMainContent(
              loginData: e.loginData,
              currentStepIndex: e.currentStepIndex,
              remainingTime: e.remainingTime,
              progress: e.progress,
              todayStatus: e.todayStatus,
              isCheckInSuccess: false,
              context: context,
            ),
            orElse: () => const SizedBox.shrink(),
          );
        }));
  }

  Widget _buildMainContent(
      {required LoginSuccessData loginData,
      required int currentStepIndex,
      required Duration remainingTime,
      required double progress,
      required TodayStatus todayStatus,
      required bool isCheckInSuccess,
      required BuildContext context}) {
    return Stack(
      children: [
        _buildBackground(),
        ListView(
          shrinkWrap: true,
          children: [
            _buildHeader(loginData, context),
            const SizedBox(height: 10),

            // Step 0: Check-in options
            if (currentStepIndex == 0)
              _buildCheckInOptions(context, loginData, todayStatus),

            // Step 1+: Check-in status
            if (currentStepIndex >= 1)
              _buildCheckInStatus(context, loginData, todayStatus,
                  currentStepIndex, remainingTime, progress, isCheckInSuccess),

            const SizedBox(height: 10),
            _buildTimelineCard(loginData, todayStatus, currentStepIndex,
                remainingTime, progress),
          ],
        ),
      ],
    );
  }

  Widget _buildBackground() => Stack(
        children: [
          Positioned(
            top: 150,
            left: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primaryColor.withOpacity(0.2),
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primaryColor.withOpacity(0.3),
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(height: 100, color: primaryColor),
          ),
        ],
      );

  Widget _buildHeader(LoginSuccessData userData, BuildContext context) {
    final lang = context.locale.languageCode;
    final fullName = (lang == 'ar' && userData.empNameAR.isNotEmpty)
        ? userData.empNameAR
        : userData.empName;

    final firstName = fullName.split(' ').first;


    final greeting = 'helloName'.tr(namedArgs: {'name': firstName});

    return Row(
      children: [
        const SizedBox(width: 15),
        const CircleAvatar(
          radius: 30,
          backgroundImage: AssetImage('assets/user_profile.jpg'),
        ),
        const SizedBox(width: 15),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(greeting,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              _currentDate,
              style: const TextStyle(color: lightGray, fontSize: 14),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCheckInButton(BuildContext context, Loaded state) {
    final progress = state.progress;
    final remaining = state.remainingTime;

    return Container(
        decoration: BoxDecoration(
          color: primaryColor.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            DashedCircularProgressBar.square(
              dimensions: 290,
              progress: progress,
              startAngle: 270,
              sweepAngle: 360,
              foregroundColor: primaryColor,
              foregroundStrokeWidth: 6,
              backgroundStrokeWidth: 3,
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${remaining.inHours.toString().padLeft(2, '0')}:'
                  '${(remaining.inMinutes % 60).toString().padLeft(2, '0')}:'
                  '${(remaining.inSeconds % 60).toString().padLeft(2, '0')}',
                  style: const TextStyle(
                    color: primaryColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Icon(Icons.work, color: primaryColor, size: 40),
              ],
            ),
          ],
        ));
  }

  Widget _buildTimeline(Loaded state) => Column(
        children: [
           Text(
            'attSystem'.tr(),
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          ProcessTimeline(
            currentIndex: state.currentStepIndex,
            steps: [
              ProcessStep(
                'offSiteCheckIns'.tr(),
                Icons.wifi,
                state.todayStatus.offSiteCheckIns.isNotEmpty
                    ? DateFormat('hh:mm a','en')
                        .format(DateTime.fromMillisecondsSinceEpoch(
                            state.todayStatus.offSiteCheckIns.last))
                        .toString()
                    : '--:--',
              ),
              ProcessStep('onSiteCheckIn'.tr(), Icons.fingerprint,
                  state.todayStatus.checkInTime),
              ProcessStep(
                  'working'.tr(), Icons.work, state.todayStatus.expectedOutTime),
              ProcessStep(
                  'chkOut'.tr(), Icons.logout, state.todayStatus.expectedOutTime),
            ],
          ),
        ],
      );

  Widget _buildCard(Widget child) => SizedBox(
        width: 300,
        height: 300,
        child: Card(
          elevation: 5,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ),
      );

  Widget _buildCheckInOptions(BuildContext context, LoginSuccessData loginData,
      TodayStatus todayStatus) {
    return todayStatus.offSiteCheckIns.isEmpty
        ? _buildCard(
            Center(
              child: MoodCheckJoystick(
                onCheckInWithMood: (mood) => context
                    .read<AttendenceBloc>()
                    .add(AttendenceEvent.checkIn(mood)),
              ),
            ),
          )
        : _buildCard(
            Stack(
              alignment: Alignment.center,
              children: [
                AnalogAttendanceClock(
                  eventTimestamps: todayStatus.offSiteCheckIns,
                  accentColor: primaryColor,
                ),
                _buildCheckInButtonOverlay(context),
              ],
            ),
          );
  }

  Widget _buildCheckInButtonOverlay(BuildContext context) {
    return Positioned.fill(
      child: Center(
        child: Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                primaryColor.withOpacity(0.6),
                primaryColor.withOpacity(0.9),
              ],
              radius: 0.6,
            ),
          ),
          child: GestureDetector(
            child:  Center(
                child: Text(
              "chkIn".tr(),
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700),
            )),
            onTap: () => context
                .read<AttendenceBloc>()
                .add(AttendenceEvent.checkIn("happy")),
          ),
        ),
      ),
    );
  }

  Widget _buildCheckInStatus(
      BuildContext context,
      LoginSuccessData loginData,
      TodayStatus todayStatus,
      int currentStepIndex,
      Duration remainingTime,
      double progress,
      bool isCheckInSuccess) {
    return _buildCard(
      isCheckInSuccess
          ? Lottie.asset('assets/lottie/checkin.json', height: 150)
          : _buildCheckInButton(
              context,
              Loaded(
                loginData: loginData,
                todayStatus: todayStatus,
                currentStepIndex: currentStepIndex,
                remainingTime: remainingTime,
                progress: progress,
              ),
            ),
    );
  }

  Widget _buildTimelineCard(LoginSuccessData loginData, TodayStatus todayStatus,
      int currentStepIndex, Duration remainingTime, double progress) {
    return Card(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: _buildTimeline(Loaded(
            loginData: loginData,
            todayStatus: todayStatus,
            currentStepIndex: currentStepIndex,
            remainingTime: remainingTime,
            progress: progress,
          )),
        ));
  }
}
