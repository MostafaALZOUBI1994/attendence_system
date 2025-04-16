import 'dart:async';
import 'package:dashed_circular_progress_bar/dashed_circular_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';

import '../../../../core/constants/constants.dart';
import '../../../authentication/domain/entities/login_success_model.dart';
import '../../domain/entities/process_step.dart';
import '../../domain/entities/today_status.dart';
import '../bloc/attendence_bloc.dart';
import '../bloc/attendence_event.dart';
import '../bloc/attendence_state.dart';
import '../widgets/mood_check.dart';
import '../widgets/timeline.dart';

class TimeScreen extends StatelessWidget {
   TimeScreen({Key? key}) : super(key: key);

  final String _currentDate = DateFormat('MMMM d, yyyy').format(DateTime.now());

  final List<ProcessStep> _processSteps = [
    ProcessStep('Off-site Check-in', Icons.wifi, "6:10 AM"),
    ProcessStep('On-site Check-in', Icons.fingerprint, "6:30 AM"),
    ProcessStep('Working', Icons.work, "2:35 PM"),
    ProcessStep('Check-out', Icons.logout, "2:35 PM"),
  ];

   @override
   Widget build(BuildContext context) {
     return Scaffold(
       backgroundColor: Colors.white,
       appBar: AppBar(
         title: const Text("Attendance System", style: TextStyle(color: Colors.white)),
         backgroundColor: primaryColor,
         iconTheme: const IconThemeData(color: Colors.white),
       ),
       body: BlocBuilder<AttendenceBloc, AttendenceState>(
         builder: (context, state) {
           return state.maybeMap(
             loaded: (loadedData) => _buildMainContent(
               loginData: loadedData.loginData,
               currentStepIndex: loadedData.currentStepIndex,
               remainingTime: loadedData.remainingTime,
               progress: loadedData.progress,
               todayStatus: loadedData.todayStatus,
               isCheckInSuccess: false,
               context: context
             ),
             checkInSuccess: (successData) => _buildMainContent(
               loginData: successData.loginData,
               currentStepIndex: successData.currentStepIndex,
               remainingTime: successData.remainingTime,
               progress: successData.progress,
               todayStatus: successData.todayStatus,
               isCheckInSuccess: true,
               context: context
             ),
             orElse: () => const SizedBox(),
           );
         },
       ),
     );
   }

   Widget _buildMainContent({
     required LoginSuccessData loginData,
     required int currentStepIndex,
     required Duration remainingTime,
     required double progress,
     TodayStatus? todayStatus,
     required bool isCheckInSuccess,
     required BuildContext context
   }) {
     return Stack(
       children: [
         _buildBackground(),
         Column(
           children: [
             _buildHeader(loginData),
             const SizedBox(height: 10),
             if (currentStepIndex == 0)
               _buildCard(
                 MoodCheckJoystick(
                   onCheckInWithMood: (mood) => context
                       .read<AttendenceBloc>()
                       .add(AttendenceEvent.checkIn(mood)),
                 ),
               ),
             // For step 1 or beyond, conditionally show Lottie animation (for success) or the check-in button.
             if (currentStepIndex >= 1)
               _buildCard(
                 isCheckInSuccess
                     ? Lottie.asset(
                   'assets/lottie/checkin.json',
                   height: 150,
                 )
                     : _buildCheckInButton(context, Loaded(
                   loginData: loginData,
                   todayStatus: todayStatus,
                   currentStepIndex: currentStepIndex,
                   remainingTime: remainingTime,
                   progress: progress,
                 )),
               ),
             const SizedBox(height: 10),
             _buildCard(_buildTimeline(Loaded(
               loginData: loginData,
               todayStatus: todayStatus,
               currentStepIndex: currentStepIndex,
               remainingTime: remainingTime,
               progress: progress,
             ))),
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

   Widget _buildCheckInButton(BuildContext context, Loaded state) {
     final isWorking = state.currentStepIndex >= 2;
     final progress = state.progress;
     final remaining = state.remainingTime;

     return Container(
       decoration: BoxDecoration(
         color:
         isWorking ? primaryColor.withOpacity(0.1) : Colors.transparent,
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
       )
           : Lottie.asset(
         'assets/lottie/checkin.json',
         height: 150,
         onLoaded: (composition) {
           context
               .read<AttendenceBloc>()
               .add(const AttendenceEvent.loadData());
         },
       ),
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
            return ProcessStep(
              step.title,
              step.icon,
                step.time
            );
          }
        ).toList(),
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

