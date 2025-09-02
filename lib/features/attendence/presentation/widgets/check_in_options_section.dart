import 'dart:ui' as ui;

import 'package:dashed_circular_progress_bar/dashed_circular_progress_bar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moet_hub/features/attendence/presentation/widgets/mood_check.dart';
import 'package:slide_countdown/slide_countdown.dart';

import '../../../../core/constants/constants.dart';
import '../../../authentication/domain/entities/employee.dart';
import '../../domain/entities/today_status.dart';
import '../bloc/attendence_bloc.dart';
import 'analog_clock.dart';
import 'card_container.dart';

class CheckInOptionsSection extends StatelessWidget {
  final Employee employee;
  final TodayStatus todayStatus;

  const CheckInOptionsSection({
    Key? key,
    required this.employee,
    required this.todayStatus,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DateTime>(
      stream: Stream.periodic(const Duration(seconds: 1), (_) => DateTime.now()),
      initialData: DateTime.now(),
      builder: (context, snapshot) {
        final now = snapshot.data ?? DateTime.now();
        final last = todayStatus.offSiteCheckIns.isNotEmpty
            ? DateTime.fromMillisecondsSinceEpoch(todayStatus.offSiteCheckIns.last)
            : now;
        final graceMinutes = int.tryParse(employee.gracePeriod) ?? 0;
        final endTime = last.add(Duration(minutes: graceMinutes));
        final remaining = endTime.difference(now);

        if (todayStatus.offSiteCheckIns.isEmpty) {
          return CardContainer(
            child: Center(
              child: MoodCheckJoystick(
                onCheckInWithMood: (mood) =>
                    context.read<AttendenceBloc>().add(AttendenceEvent.checkIn(mood)),
              ),
            ),
          );
        } else {
          return CardContainer(
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                AnalogAttendanceClock(
                  eventTimestamps: todayStatus.offSiteCheckIns,
                  ringGradient: primaryGradient,
                ),
                Positioned(
                  child: GestureDetector(
                    onTap: () => context
                        .read<AttendenceBloc>()
                        .add(const AttendenceEvent.checkIn('happy')),
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: primaryGradient,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'chkIn'.tr(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
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
                        final total = endTime.difference(last).inSeconds;
                        final passed = now.difference(last).inSeconds;
                        if (passed <= 0 || total == 0) return 0.0;
                        return (passed / total).clamp(0.0, 1.0) * 100;
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
                                duration: remaining.isNegative ? Duration.zero : remaining,
                                decoration:
                                const BoxDecoration(color: Colors.transparent),
                                style: const TextStyle(
                                  color: primaryColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                separatorStyle: const TextStyle(
                                  color: primaryColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Icon(Icons.timer, color: primaryColor, size: 20),
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
      },
    );
  }
}
