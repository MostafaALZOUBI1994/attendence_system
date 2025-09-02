import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:moet_hub/features/attendence/presentation/widgets/timeline.dart';
import '../../../authentication/domain/entities/employee.dart';
import '../../domain/entities/process_step.dart';
import '../../domain/entities/today_status.dart';

/// Wraps the process timeline in a card.
class TimelineCardSection extends StatelessWidget {
  final Employee employee;
  final TodayStatus todayStatus;
  final int currentStepIndex;
  final Duration remainingTime;
  final double progress;

  const TimelineCardSection({
    Key? key,
    required this.employee,
    required this.todayStatus,
    required this.currentStepIndex,
    required this.remainingTime,
    required this.progress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Build process steps list from todayStatus
    final steps = <ProcessStep>[
      ProcessStep(
        'offSiteCheckIns'.tr(),
        Icons.wifi,
        todayStatus.offSiteCheckIns.isNotEmpty
            ? DateFormat('hh:mm a', 'en')
            .format(DateTime.fromMillisecondsSinceEpoch(
            todayStatus.offSiteCheckIns.last))
            : '--:--',
      ),
      ProcessStep('onSiteCheckIn'.tr(), Icons.fingerprint, todayStatus.punchInOffice),
      ProcessStep('working'.tr(), Icons.work, todayStatus.expectedOutTime),
      ProcessStep('chkOut'.tr(), Icons.logout, todayStatus.expectedOutTime),
    ];
    return Card(
      elevation: 5,
      color: Colors.white.withOpacity(0.7),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'attSystem'.tr(),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ProcessTimeline(currentIndex: currentStepIndex, steps: steps),
          ],
        ),
      ),
    );
  }
}