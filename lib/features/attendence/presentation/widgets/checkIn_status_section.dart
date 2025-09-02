import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:slide_countdown/slide_countdown.dart';

import '../../../../core/constants/constants.dart';
import '../../../authentication/domain/entities/employee.dart';
import '../../domain/entities/today_status.dart';
import 'analog_clock.dart';
import 'card_container.dart';

/// Shows a circular check‑in button or a success animation depending on state.
class CheckInStatusSection extends StatelessWidget {
  final Employee employee;
  final TodayStatus todayStatus;
  final int currentStepIndex;
  final Duration remainingTime;
  final double progress;
  final bool isCheckInSuccess;

  const CheckInStatusSection({
    Key? key,
    required this.employee,
    required this.todayStatus,
    required this.currentStepIndex,
    required this.remainingTime,
    required this.progress,
    required this.isCheckInSuccess,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CardContainer(
      child: isCheckInSuccess
          ? Lottie.asset('assets/lottie/checkin.json', height: 150)
          : _buildCheckInButton(context),
    );
  }

  /// Builds the circular check‑in button with countdown and icon.
  Widget _buildCheckInButton(BuildContext context) {
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
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: primaryGradient,
              ),
              padding: const EdgeInsets.all(8),
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
                    // tick marks imported from analog_clock.dart via ClockTicksPainter
                    CustomPaint(
                      size: const Size(250, 250),
                      painter: ClockTicksPainter(tickColor: primaryColor),
                    ),
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Directionality(
                            textDirection: ui.TextDirection.ltr,
                            child: SlideCountdown(
                              duration: remainingTime,
                              decoration: const BoxDecoration(
                                color: Colors.transparent,
                              ),
                              style: const TextStyle(
                                color: primaryColor,
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                              ),
                              separatorStyle: const TextStyle(
                                color: primaryColor,
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Icon(Icons.work, color: primaryColor, size: 40),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
