import 'dart:math';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:slide_countdown/slide_countdown.dart';
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
    return  BlocConsumer<AttendenceBloc, AttendenceState>(
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
          });
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
        const SizedBox(width: 25),
        Lottie.asset(
          "assets/lottie/sunny.json",
          width: 48,
          height: 48,
          fit: BoxFit.cover,
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
            Center(
              child: Container(
                // 1) Outer gradient ring
                width: 266,  // 250 + 2*8px border
                height: 266,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: primaryGradient,
                ),
                padding: const EdgeInsets.all(8), // border thickness
                child: Container(
                  // 2) Inner white face with shadows
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 12,
                        offset: const Offset(4, 4),
                      ),
                      BoxShadow(
                        color: Colors.white.withOpacity(0.7),
                        blurRadius: 12,
                        offset: const Offset(-4, -4),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // clock ticks
                      CustomPaint(
                        size: const Size(250, 250),
                        painter: ClockTicksPainter(),
                      ),
                      // digital timer + icon
                      Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SlideCountdown(duration: remaining, decoration: const BoxDecoration(
                              color: Colors.transparent,
                            ),style: TextStyle(
                              color: primaryColor,
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                            ),
                              separatorStyle: TextStyle(
                                color: primaryColor,
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                              ),),
                            const SizedBox(height: 8),
                            Icon(Icons.work, color: primaryColor, size: 40),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
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
          color: Colors.white.withOpacity(0.7),
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
      child: GestureDetector(
        onTap: () => context
            .read<AttendenceBloc>()
            .add(AttendenceEvent.checkIn("happy")),
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
            child: Center(
                child: Text(
              "chkIn".tr(),
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700),
            )),
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
        color: Colors.white.withOpacity(0.7),
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


class ClockTicksPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;
    final tickPaint = Paint()..color = Colors.black..strokeWidth = 2;

    for (int i = 0; i < 60; i++) {
      final angle = 2 * pi * i / 60;
      final isHour = i % 5 == 0;
      final length = isHour ? 15.0 : 7.0;
      final start = Offset(
        center.dx + (radius - length) * cos(angle),
        center.dy + (radius - length) * sin(angle),
      );
      final end = Offset(
        center.dx + radius * cos(angle),
        center.dy + radius * sin(angle),
      );
      canvas.drawLine(start, end, tickPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}



