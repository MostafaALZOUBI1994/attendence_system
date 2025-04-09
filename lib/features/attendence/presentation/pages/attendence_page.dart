import 'dart:async';
import 'package:dashed_circular_progress_bar/dashed_circular_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';

import '../../../../core/constants/constants.dart';
import '../../../authentication/domain/entities/login_success_model.dart';
import '../bloc/attendence_bloc.dart';
import '../bloc/attendence_event.dart';
import '../bloc/attendence_state.dart';
import '../widgets/mood_check.dart';
import '../widgets/timeline.dart';

class TimeScreen extends StatefulWidget {
  const TimeScreen({super.key});

  @override
  State<TimeScreen> createState() => _TimeScreenState();
}

class _TimeScreenState extends State<TimeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final AttendenceBloc _bloc;
  Timer? _countdownTimer;
  DateTime? _expectedCheckoutTime;
  Duration _remainingTime = Duration.zero;
  final String _currentDate = DateFormat('MMMM d, yyyy').format(DateTime.now());

  final List<ProcessStep> _processSteps = [
    ProcessStep(title: 'Off-site Check-in', icon: Icons.wifi),
    ProcessStep(title: 'On-site Check-in', icon: Icons.fingerprint),
    ProcessStep(title: 'Working', icon: Icons.work),
    ProcessStep(title: 'Check-out', icon: Icons.logout),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this);
    _bloc = context.read<AttendenceBloc>()
      ..add(const AttendenceEvent.loadData());

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_expectedCheckoutTime != null) {
        final now = DateTime.now();
        setState(() => _remainingTime = _expectedCheckoutTime!.difference(now));
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _handleMoodSelected(String mood) {
    _bloc.add(const AttendenceEvent.stepChanged(1));
  }

  double _calculateProgress(Loaded state) {
    if (_expectedCheckoutTime == null || state.todayStatus?.checkInTime == null)
      return 0;

    try {
      final checkIn =
          DateFormat('hh:mm a').parse(state.todayStatus!.checkInTime);
      final checkOut =
          DateFormat('hh:mm a').parse(state.todayStatus!.expectedOutTime);

      final checkInDateTime = DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
        checkIn.hour,
        checkIn.minute,
      );

      var expectedCheckout = DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
        checkOut.hour,
        checkOut.minute,
      );

      if (expectedCheckout.isBefore(checkInDateTime)) {
        expectedCheckout = expectedCheckout.add(const Duration(days: 1));
      }

      final totalDuration =
          expectedCheckout.difference(checkInDateTime).inSeconds;
      final elapsed = DateTime.now().difference(checkInDateTime).inSeconds;
      return (elapsed / totalDuration * 100).clamp(0.0, 100.0);
    } catch (e) {
      return 0.0;
    }
  }

  Widget _buildCheckInButton(BuildContext context, Loaded state) {
    final progress = _calculateProgress(state);
    final isWorking = state.currentStepIndex >= 2;

    return Container(
      decoration: BoxDecoration(
        color: isWorking ? primaryColor.withOpacity(0.1) : Colors.transparent,
        shape: BoxShape.circle,
      ),
      child: isWorking
          ? Stack(
              alignment: Alignment.center,
              children: [
                DashedCircularProgressBar.square(
                  dimensions: 150,
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
                      '${_remainingTime.inHours.toString().padLeft(2, '0')}:'
                      '${(_remainingTime.inMinutes % 60).toString().padLeft(2, '0')}:'
                      '${(_remainingTime.inSeconds % 60).toString().padLeft(2, '0')}',
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
            )
          : Lottie.asset(
              'assets/lottie/checkin.json',
              height: 150,
              controller: _animationController,
              onLoaded: (composition) {
                _animationController
                  ..duration = composition.duration
                  ..forward().then((_) {
                    if (mounted) {
                      _bloc.add(const AttendenceEvent.stepChanged(2));
                    }
                  });
              },
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Attendance System",
            style: TextStyle(color: Colors.white)),
        backgroundColor: primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: BlocBuilder<AttendenceBloc, AttendenceState>(
        builder: (context, state) {
          if (state is! Loaded) return const SizedBox();

          // Update expected checkout time
          if (state.todayStatus?.expectedOutTime != "00:00" &&
              state.todayStatus?.expectedOutTime != null) {
            final parsedTime =
                DateFormat('hh:mm a').parse(state.todayStatus!.expectedOutTime);
            final now = DateTime.now();
            _expectedCheckoutTime = DateTime(
              now.year,
              now.month,
              now.day,
              parsedTime.hour,
              parsedTime.minute,
            );
            if (_expectedCheckoutTime!.isBefore(now)) {
              _expectedCheckoutTime =
                  _expectedCheckoutTime!.add(const Duration(days: 1));
            }
          } else {
            _expectedCheckoutTime = null;
          }

          return Stack(
            children: [
              _buildBackground(),
              Column(
                children: [
                  _buildHeader(state.loginData),
                  const SizedBox(height: 10),
                  if (state.currentStepIndex == 0)
                    _buildCard(MoodCheckJoystick(
                        onCheckInWithMood: _handleMoodSelected)),
                  if (state.currentStepIndex >= 1)
                    _buildCard(_buildCheckInButton(context, state)),
                  const SizedBox(height: 10),
                  _buildCard(_buildTimeline(state)),
                ],
              ),
            ],
          );
        },
      ),
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

  Widget _buildHeader(LoginSuccessData userData) {
    final firstName = userData.empName.isNotEmpty
        ? userData.empName.split(' ').first
        : 'User';
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
            Text(
              'Hello, $firstName',
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

  Widget _buildTimeline(Loaded state) => Column(
        children: [
          const Text(
            'Attendance Timeline',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          ProcessTimeline(
            currentIndex: state.currentStepIndex,
            steps: _processSteps.map((step) {
              if (step.title == 'Working' && state.currentStepIndex >= 2) {
                return ProcessStep(
                  title:
                      'Working (${state.todayStatus?.expectedOutTime ?? ''})',
                  icon: Icons.work,
                );
              }
              return step;
            }).toList(),
          ),
        ],
      );

  Widget _buildCard(Widget child) => Card(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: child,
        ),
      );
}
