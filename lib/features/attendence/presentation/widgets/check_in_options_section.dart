import 'dart:ui' as ui;
import 'package:dashed_circular_progress_bar/dashed_circular_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moet_hub/features/attendence/presentation/widgets/mood_check.dart';
import 'package:slide_countdown/slide_countdown.dart';
import '../../../../core/constants/constants.dart';
import '../../../authentication/domain/entities/employee.dart';
import '../../domain/entities/today_status.dart';
import '../bloc/attendence_bloc.dart';
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
                GestureDetector(
                  onTap: () => context
                      .read<AttendenceBloc>()
                      .add(const AttendenceEvent.checkIn('happy')),
                  child: SizedBox(
                    width: 380,
                    height: 380,
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
                      width: 100,
                      height: 100,
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text("Check in Again", style:  TextStyle(
                              color: Colors.black54,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),),
                            Directionality(
                              textDirection: ui.TextDirection.ltr,
                              child: SlideCountdown(
                                duration: remaining.isNegative ? Duration.zero : remaining,
                                decoration:
                                const BoxDecoration(color: Colors.transparent),
                                style: const TextStyle(
                                  color: primaryColor,
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                ),
                                separatorStyle: const TextStyle(
                                  color: primaryColor,
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Icon(Icons.fingerprint, color: primaryColor, size: 80),
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
