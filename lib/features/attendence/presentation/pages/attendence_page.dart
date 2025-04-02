import 'dart:async';
import 'package:attendence_system/features/authentication/domain/entities/login_success_model.dart';
import 'package:dashed_circular_progress_bar/dashed_circular_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/constants.dart';
import '../../bloc/attendence_bloc.dart';
import '../../bloc/attendence_event.dart';
import '../../bloc/attendence_state.dart';
import '../widgets/mood_check.dart';
import '../widgets/timeline.dart';


class TimeScreen extends StatefulWidget {
  const TimeScreen({super.key});

  @override
  _TimeScreenState createState() => _TimeScreenState();
}

class _TimeScreenState extends State<TimeScreen> {
  late Timer _timer;
  String _currentTime = "";
  String _currentDate = "";
  String _currentDay = "";
  int _currentStepIndex = 0;
  late AttendenceBloc _bloc;

  final List<ProcessStep> _processSteps = [
    ProcessStep(title: 'Off-site Check-in', icon: Icons.wifi),
    ProcessStep(title: 'On-site Check-in', icon: Icons.fingerprint),
    ProcessStep(title: 'Working', icon: Icons.work),
    ProcessStep(title: 'Check-out', icon: Icons.logout),
  ];

  @override
  void initState() {
    super.initState();
    _updateDateTime();
    _bloc = context.read<AttendenceBloc>();
    _bloc.add(const AttendenceEvent.loadData());
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) => _updateDateTime());
  }

  void _updateDateTime() {
    final now = DateTime.now();
    setState(() {
      _currentTime = DateFormat('hh:mm a').format(now);
      _currentDate = DateFormat('MMMM d, yyyy').format(now);
      _currentDay = DateFormat('EEEE').format(now);
    });
  }

  void _handleCheckIn() {
    setState(() {
      _currentStepIndex = (_currentStepIndex + 1) % _processSteps.length;
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          _buildBackground(),
          Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 10),
              _buildCard(
                MoodCheckJoystick(
                  onCheckInWithMood: (String mood) {
                    // 1. Trigger BLoC event with mood
                   // _bloc.add(AttendenceEvent.checkInWithMood(mood));

                    // 2. Update UI state
                    setState(() {
                      _currentStepIndex = 1; // Move to next step
                    });

                    // 3. Optional: Show feedback dialog
                    _showFeedbackPopup(context, mood);
                  },
                ),
              ),
              const SizedBox(height: 10),
              _buildCard(_buildTimeline()),
              const SizedBox(height: 10),
             // _buildMoodCheck(),
            ],
          ),
        ],
      )
    );
  }

  // App Bar
  AppBar _buildAppBar() => AppBar(
    title: const Text("Attendance System", style: TextStyle(color: Colors.white)),
    backgroundColor: primaryColor,
    iconTheme: const IconThemeData(color: Colors.white),
  );


  Widget _buildBackground() => Stack(
    children: [
      Positioned(
          top: 150,
          left: -50,
          child: _buildDecorativeCircle(200, primaryColor.withOpacity(0.2))),
      Positioned(
          bottom: -100,
          right: -100,
          child: _buildDecorativeCircle(300, primaryColor.withOpacity(0.3))),
      Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(height: 100, color: primaryColor)),
    ],
  );

  Widget _buildDecorativeCircle(double size, Color color) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(shape: BoxShape.circle, color: color),
  );


  Widget _buildCheckInButton() => GestureDetector(
    onTap: _currentStepIndex == 0 ? _handleCheckIn : null,
    child: Container(
      decoration: BoxDecoration(
          color: _currentStepIndex == 0 ? primaryColor : Colors.transparent,
          shape: BoxShape.circle
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          DashedCircularProgressBar.square(
            dimensions: 150,
            progress: _currentStepIndex == 0 ? 0 : 50,
            startAngle: 270,
            sweepAngle: 360,
            circleCenterAlignment: Alignment.center,
            foregroundColor: primaryColor ,
            backgroundColor: _currentStepIndex == 0 ? primaryColor: lightGray,
            foregroundStrokeWidth: 6,
            backgroundStrokeWidth: 3,
            animation: true,
          ),
          _currentStepIndex == 0
              ? const Column(
            children: [
              Text(
                "Check In",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Icon(
                Icons.wifi,
                color: Colors.white,
                size: 40,
              ),
            ],
          )
              : const Column(
            children: [
              Text(
                "29:00",
                style: TextStyle(
                  color: primaryColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Icon(
                Icons.work,
                color: primaryColor,
                size: 40,
              ),
            ],
          ),
        ],
      ),
    ),
  );

  Widget _buildTimeline() => Column(
    children: [
      const Text("Attendance Timeline", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      const SizedBox(height: 10),
      ProcessTimeline(currentIndex: _currentStepIndex, steps: _processSteps),
    ],
  );

  Widget _buildCard(Widget child) => Card(
    elevation: 5,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    color: Colors.white,
    child: Padding(padding: const EdgeInsets.all(16), child: child),
  );

  Widget _buildHeader() => BlocBuilder<AttendenceBloc, AttendenceState>(
  builder: (context, state) {
    LoginSuccessData savedData = LoginSuccessData(empID: "", empName: "", empNameAR: "", empProfileImage: "");
    if (state is Loaded) {
      savedData = state.loginData;
    }
    final firstName = savedData.empName.isNotEmpty
        ? savedData.empName.split(" ").first
        : "User";
    return Row(
    children: [
      const SizedBox(width: 15),
      const CircleAvatar(radius: 30, backgroundImage: AssetImage("assets/user_profile.jpg")),
      const SizedBox(width: 15),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Text("Hello, ${firstName}", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
          Text(_currentDate, style: const TextStyle(color: lightGray, fontSize: 14)),
        ],
      ),
    ],
  );
  },
);


  void _showFeedbackPopup(BuildContext context, String mood) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Center(
          child: ScaleTransition(
            scale: CurvedAnimation(
              parent: ModalRoute.of(context)!.animation!,
              curve: Curves.easeOutBack,
            ),
            child: AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Row(
                children: [
                  Icon(Icons.feedback, color: primaryColor),
                  SizedBox(width: 10),
                  Text("Share Feedback", style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("You selected \"$mood\". Would you like to share why?"),
                  const SizedBox(height: 10),
                  TextField(
                    decoration: InputDecoration(
                      hintText: "Type your feedback...",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    maxLines: 3,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
                  onPressed: () {
                    Navigator.pop(context);
                    // You can send feedback to the server here
                  },
                  child: const Text("Send", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

}





