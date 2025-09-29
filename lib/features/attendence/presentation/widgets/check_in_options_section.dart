import 'dart:ui' as ui;
import 'package:dashed_circular_progress_bar/dashed_circular_progress_bar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:slide_countdown/slide_countdown.dart';

import '../../../../core/constants/constants.dart';
import '../../../authentication/domain/entities/employee.dart';
import '../../../mood/presentation/bloc/mood_bloc.dart';
import '../../../mood/presentation/mappers/mood_ui_mapper.dart';
import '../../domain/entities/today_status.dart';
import '../bloc/attendence_bloc.dart';
import 'card_container.dart';
import 'mood_check.dart';

class CheckInOptionsSection extends StatelessWidget {
  final Employee employee;
  final TodayStatus todayStatus;
  final AttendancePhase phase;

  const CheckInOptionsSection({
    Key? key,
    required this.employee,
    required this.todayStatus,
    required this.phase,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Before arrival → mood joystick
    if (phase == AttendancePhase.beforeArrival) {
      return CardContainer(
        child: Center(
          child: MoodCheckJoystick(
            onCheckInWithMood: (mood) async {
              context.read<AttendenceBloc>().add(AttendenceEvent.checkIn(mood));
              final mapped = mapUIMood((mood).toUIMood());
              context.read<MoodBloc>().add(SubmitMood(
                moodId: mapped.id,
                mood: mapped.label,
                note: '',
                date: DateTime.now(),
              ));
            },
          ),
        ),
      );
    }

    // Offsite → countdown during grace window (no Stream.periodic)
    final last = todayStatus.offSiteCheckIns.isNotEmpty
        ? DateTime.fromMillisecondsSinceEpoch(todayStatus.offSiteCheckIns.last)
        : null;

    final graceMinutes = int.tryParse(employee.gracePeriod) ?? 0;
    final total = Duration(minutes: graceMinutes);

    // Compute remaining once; SlideCountdown will tick internally
    final remaining = () {
      if (last == null || graceMinutes <= 0) return Duration.zero;
      final elapsed = DateTime.now().difference(last);
      final rem = total - elapsed;
      return rem.isNegative ? Duration.zero : rem;
    }();

    return CardContainer(
      child: _OffsiteCountdownCard(
        key: ValueKey(last?.millisecondsSinceEpoch ?? 0), // restart only on new offsite check-in
        total: total,
        remaining: remaining,
        onTap: () => context.read<AttendenceBloc>().add(const AttendenceEvent.checkIn('happy')),
      ),
    );
  }
}

class _OffsiteCountdownCard extends StatelessWidget {
  final Duration total;
  final Duration remaining;
  final VoidCallback onTap;

  const _OffsiteCountdownCard({
    super.key,
    required this.total,
    required this.remaining,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // If no grace or already expired
    final hasWindow = total.inSeconds > 0 && remaining > Duration.zero;

    // Start progress from the *current* fraction and linearly animate to 100%
    final startFrac = hasWindow
        ? 1.0 - (remaining.inSeconds / total.inSeconds)
        : 1.0; // 100% if no window

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 280,
        height: 280,
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: startFrac, end: 1.0),
          duration: hasWindow ? remaining : Duration.zero,
          curve: Curves.linear,
          builder: (context, frac, _) {
            final percent = (frac.clamp(0.0, 1.0) * 100);

            return RepaintBoundary( // isolates repaints to the ring
              child: DashedCircularProgressBar(
                progress: percent,
                seekColor: primaryColor,
                foregroundColor: primaryColor,
                backgroundColor: lightGray,
                width: 100,
                height: 100,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "chkIn".tr(),
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Directionality(
                        textDirection: ui.TextDirection.ltr,
                        child: hasWindow
                            ? SlideCountdown(
                          // SlideCountdown manages its own 1s ticker internally.
                          // This widget won’t rebuild unless the key changes.
                          duration: remaining,
                          onDone: () {
                            // Optional: disable tap or visually indicate expiry
                          },
                          decoration: const BoxDecoration(color: Colors.transparent),
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
                        )
                            : const Text(
                          '00:00',
                          style: TextStyle(
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
            );
          },
        ),
      ),
    );
  }
}