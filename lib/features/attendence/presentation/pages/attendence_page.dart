import 'dart:math';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:dashed_circular_progress_bar/dashed_circular_progress_bar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:ui' as ui;
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:slide_countdown/slide_countdown.dart';
import '../../../../core/constants/constants.dart';
import '../../../authentication/domain/entities/employee.dart';
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
                employee: l.employee,
                currentStepIndex: l.currentStepIndex,
                remainingTime: l.remainingTime,
                progress: l.progress,
                todayStatus: l.todayStatus,
                isCheckInSuccess: false,
                context: context,
              ),
              checkInSuccess: (s) => _buildMainContent(
                employee: s.employee,
                currentStepIndex: s.currentStepIndex,
                remainingTime: s.remainingTime,
                progress: s.progress,
                todayStatus: s.todayStatus,
                isCheckInSuccess: true,
                context: context,
              ),
              error: (e) => _buildMainContent(
                employee: e.employee,
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
      {required Employee employee,
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
            _buildHeader(employee, context),
            const SizedBox(height: 10),

            // Step 0: Check-in options
            if (currentStepIndex == 0)
              _buildCheckInOptions(context, employee, todayStatus),

            // Step 1+: Check-in status
            if (currentStepIndex >= 1)
              _buildCheckInStatus(context, employee, todayStatus,
                  currentStepIndex, remainingTime, progress, isCheckInSuccess),

            const SizedBox(height: 10),
            _buildTimelineCard(employee, todayStatus, currentStepIndex,
                remainingTime, progress),
          ],
        ),
      ],
    );
  }


  Widget _buildHeader(Employee employee, BuildContext context) {
    final lang = context.locale.languageCode;
    final fullName = (lang == 'ar' && employee.employeeNameInAr.isNotEmpty)
        ? employee.employeeNameInAr
        : employee.employeeNameInEn;

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
                width: 266,
                height: 266,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: primaryGradient,
                ),
                padding: const EdgeInsets.all(8), // border thickness
                child: Container(
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

                      CustomPaint(
                        size: const Size(250, 250),
                        painter: ClockTicksPainter(),
                      ),
                      Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Directionality(
                              textDirection: ui.TextDirection.ltr,
                              child: SlideCountdown(duration: remaining, decoration: const BoxDecoration(
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
                            ),
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
                  state.todayStatus.punchInOffice),
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

  Widget _buildCheckInOptions(BuildContext context, Employee loginData,
      TodayStatus todayStatus) {
    final last = todayStatus.offSiteCheckIns.isNotEmpty
        ? DateTime.fromMillisecondsSinceEpoch(todayStatus.offSiteCheckIns.last)
        : DateTime.now();
    final endTime = last.add(const Duration(minutes: 30));
    final now = DateTime.now();
    final rawRem = endTime.difference(now);
    final remaining = rawRem.isNegative ? Duration.zero : rawRem;
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
        clipBehavior: Clip.none,
        children: [
          AnalogAttendanceClock(
            eventTimestamps: todayStatus.offSiteCheckIns,
            ringGradient: primaryGradient,
          ),


          Positioned(
            child: _buildCheckInButtonOverlay(context),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: SizedBox(
              width: 80,
              height: 80,
              child: DashedCircularProgressBar(
                seekColor: primaryColor,
                foregroundColor: primaryColor,
                backgroundColor: lightGray,
                progress: () {
                  final now = DateTime.now();
                  final total = endTime.difference(last).inSeconds;
                  final passed = now.difference(last).inSeconds;
                  return (total / passed)*100;
                }(),
                width: 10,
                height: 10,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Directionality(
                        textDirection: ui.TextDirection.ltr,
                        child: SlideCountdown(
                          duration: () {
                            final now = DateTime.now();
                            final diff = endTime.difference(now);
                            return diff.isNegative ? Duration.zero : diff;
                          }(),
                          decoration: const BoxDecoration(color: Colors.transparent),
                          style: TextStyle(
                            color: primaryColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          separatorStyle: TextStyle(
                            color: primaryColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Icon(Icons.timer, color: primaryColor, size: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),

        ],
      ),
          );
  }

  Widget _buildCheckInButtonOverlay(BuildContext context) {
    return GestureDetector(
      onTap: () => context
          .read<AttendenceBloc>()
          .add(AttendenceEvent.checkIn("happy")),
      child: Center(
        child: Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: primaryGradient
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
    );
  }

  Widget _buildCheckInStatus(
      BuildContext context,
      Employee employee,
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
                employee: employee,
                todayStatus: todayStatus,
                currentStepIndex: currentStepIndex,
                remainingTime: remainingTime,
                progress: progress,
              ),
            ),
    );
  }

  Widget _buildTimelineCard(Employee employee, TodayStatus todayStatus,
      int currentStepIndex, Duration remainingTime, double progress) {
    return Card(
        elevation: 5,
        color: Colors.white.withOpacity(0.7),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: _buildTimeline(Loaded(
            employee: employee,
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



