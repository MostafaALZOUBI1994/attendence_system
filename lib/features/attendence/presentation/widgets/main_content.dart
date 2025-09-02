import 'package:flutter/material.dart';
import 'package:moet_hub/features/attendence/presentation/widgets/timeline_card_section.dart';

import '../../../authentication/domain/entities/employee.dart';
import '../../domain/entities/today_status.dart';
import 'checkIn_status_section.dart';
import 'check_in_options_section.dart';
import 'header_section.dart';
import 'off_site_checkins_grid.dart';

class MainContent extends StatelessWidget {
  final Employee employee;
  final int currentStepIndex;
  final Duration remainingTime;
  final double progress;
  final TodayStatus todayStatus;
  final bool isCheckInSuccess;

  const MainContent({
    Key? key,
    required this.employee,
    required this.currentStepIndex,
    required this.remainingTime,
    required this.progress,
    required this.todayStatus,
    required this.isCheckInSuccess,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ListView(
          shrinkWrap: true,
          children: [
            HeaderSection(employee: employee),
            const SizedBox(height: 10),
            if (currentStepIndex == 0)
              CheckInOptionsSection(employee: employee, todayStatus: todayStatus),
            if (currentStepIndex >= 1)
              CheckInStatusSection(
                employee: employee,
                todayStatus: todayStatus,
                currentStepIndex: currentStepIndex,
                remainingTime: remainingTime,
                progress: progress,
                isCheckInSuccess: isCheckInSuccess,
              ),
            const SizedBox(height: 10),
            TimelineCardSection(
              employee: employee,
              todayStatus: todayStatus,
              currentStepIndex: currentStepIndex,
              remainingTime: remainingTime,
              progress: progress,
            ),
            const SizedBox(height: 10),
            if (todayStatus.offSiteCheckIns.isNotEmpty)
              OffSiteCheckInsGrid(offSiteCheckIns: todayStatus.offSiteCheckIns),
          ],
        ),
      ],
    );
  }
}
