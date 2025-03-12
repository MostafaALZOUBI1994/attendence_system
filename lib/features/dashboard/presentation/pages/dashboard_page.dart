import 'dart:async';
import 'dart:math';

import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
import 'package:attendence_system/data/data/leave_request_model.dart';
import 'package:dashed_circular_progress_bar/dashed_circular_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:timelines_plus/timelines_plus.dart';
import '../../../../core/constants/constants.dart';
import '../../../../main.dart';


class TimeScreen extends StatefulWidget {
  @override
  _TimeScreenState createState() => _TimeScreenState();
}

class _TimeScreenState extends State<TimeScreen> {
  late Timer _timer;
  String _currentTime = "";
  String _currentDate = "";
  String _currentDay = "";
  int _currentStepIndex = 0;
  final _controller = NotchBottomBarController(index: 0);

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
    _timer = Timer.periodic(Duration(seconds: 1), (timer) => _updateDateTime());
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
              SizedBox(height: 10),
              _buildCard(_buildCheckInButton()),
              SizedBox(height: 10),
              _buildCard(_buildTimeline()),
              SizedBox(height: 10),
              _buildMoodCheck(),
            ],
          ),
        ],
      )
    );
  }

  // App Bar
  AppBar _buildAppBar() => AppBar(
    title: Text("Attendance System", style: TextStyle(color: Colors.white)),
    backgroundColor: primaryColor,
    leading: IconButton(icon: Icon(Icons.menu, color: Colors.white), onPressed: () {}),
    iconTheme: IconThemeData(color: Colors.white),
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
              ? Column(
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
              : Column(
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

  // Attendance Timeline
  Widget _buildTimeline() => Column(
    children: [
      Text("Attendance Timeline", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      SizedBox(height: 10),
      ProcessTimeline(currentIndex: _currentStepIndex, steps: _processSteps),
    ],
  );

  // Other UI Components
  Widget _buildCard(Widget child) => Card(
    elevation: 5,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    color: Colors.white,
    child: Padding(padding: EdgeInsets.all(16), child: child),
  );

  Widget _buildHeader() => Row(
    children: [
      SizedBox(width: 15),
      CircleAvatar(radius: 30, backgroundImage: AssetImage("assets/user_profile.jpg")),
      SizedBox(width: 15),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Hello, Mohammed", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
          Text(_currentDate, style: TextStyle(color: lightGray, fontSize: 14)),
        ],
      ),
    ],
  );

  Widget _buildMoodCheck() => Padding(
    padding: EdgeInsets.all(20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("How are you feeling today?", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _moodEmoji("😀", "Happy"),
            _moodEmoji("😐", "Neutral"),
            _moodEmoji("😞", "Sad"),
            _moodEmoji("😡", "Angry"),
          ],
        ),
      ],
    ),
  );

  Widget _moodEmoji(String emoji, String label) => Column(
    children: [
      Text(emoji, style: TextStyle(fontSize: 30)),
      SizedBox(height: 5),
      Text(label, style: TextStyle(fontSize: 14)),
    ],
  );


  Widget _buildBottomNavigationBar() => AnimatedNotchBottomBar(
    showLabel: true,
    notchColor: primaryColor,
    bottomBarItems: [
      _bottomBarItem(Icons.home, "Home"),
      _bottomBarItem(Icons.settings, "Services"),
      _bottomBarItem(Icons.list_alt, "Attendance"),
      _bottomBarItem(Icons.person, "Profile"),
    ],
    onTap: (index) => setState(() {}),
    notchBottomBarController: _controller,
    color: veryLightGray,
    kBottomRadius: 28.0,
    elevation: 100,
    shadowElevation: 5,
    showShadow: true, kIconSize: 20,
  );

  BottomBarItem _bottomBarItem(IconData icon, String label) => BottomBarItem(
    inActiveItem: Icon(icon, color: Colors.grey),
    activeItem: Icon(icon, color: Colors.white),
    itemLabel: label,
  );
}

class ProcessTimeline extends StatelessWidget {
  final int currentIndex;
  final List<ProcessStep> steps;

  const ProcessTimeline({required this.currentIndex, required this.steps});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: Timeline.tileBuilder(
        theme: TimelineThemeData(
          direction: Axis.horizontal,
          connectorTheme: ConnectorThemeData(space: 20.0, thickness: 5.0),
        ),
        builder: TimelineTileBuilder.connected(
          connectionDirection: ConnectionDirection.before,
          itemExtentBuilder: (_, __) => (MediaQuery.of(context).size.width - 20) / steps.length,
          oppositeContentsBuilder: (context, index) => Padding(
            padding: EdgeInsets.only(bottom: 15),
            child: Icon(steps[index].icon, color: _getColor(index)),
          ),
          contentsBuilder: (context, index) => Padding(
            padding: EdgeInsets.only(top: 15),
            child: Text(
              steps[index].title,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: _getColor(index),
              ),
            ),
          ),
          indicatorBuilder: (_, index) => _buildIndicator(index),
          connectorBuilder: (_, index, type) => _buildConnector(index, type),
          itemCount: steps.length,
        ),
      ),
    );
  }

  Color _getColor(int index) => index <= currentIndex ? primaryColor : Colors.grey;

  Widget _buildIndicator(int index) {
    return Stack(
      children: [
        CustomPaint(
          size: Size(30, 30),
          painter: _BezierPainter(
            color: _getColor(index),
            drawStart: index > 0,
            drawEnd: index < currentIndex,
          ),
        ),
        DotIndicator(
          size: 30,
          color: _getColor(index),
          child: _buildIndicatorChild(index),
        ),
      ],
    );
  }

  Widget? _buildIndicatorChild(int index) {
    if (index == currentIndex) {
      return Padding(
          padding: EdgeInsets.all(8),
          child: CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation(Colors.white),
          ));
    }
    return index < currentIndex
        ? Icon(Icons.check, color: Colors.white, size: 15)
        : null;
  }

  Widget _buildConnector(int index, ConnectorType type) {
    if (index == 0) return SizedBox.shrink();
    final colors = [
      Color.lerp(_getColor(index-1), _getColor(index), 0.5)!,
      _getColor(index)
    ];
    return DecoratedLineConnector(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: type == ConnectorType.start
            ? colors.reversed.toList()
            : colors),
      ),
    );
  }
}

class ProcessStep {
  final String title;
  final IconData icon;

  ProcessStep({required this.title, required this.icon});
}

class _BezierPainter extends CustomPainter {
  const _BezierPainter({
    required this.color,
    this.drawStart = true,
    this.drawEnd = true,
  });

  final Color color;
  final bool drawStart;
  final bool drawEnd;

  Offset _offset(double radius, double angle) {
    return Offset(
      radius * cos(angle) + radius,
      radius * sin(angle) + radius,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = color;

    final radius = size.width / 2;

    var angle;
    var offset1;
    var offset2;

    var path;

    if (drawStart) {
      angle = 3 * pi / 4;
      offset1 = _offset(radius, angle);
      offset2 = _offset(radius, -angle);
      path = Path()
        ..moveTo(offset1.dx, offset1.dy)
        ..quadraticBezierTo(0.0, size.height / 2, -radius,
            radius) // TODO connector start & gradient
        ..quadraticBezierTo(0.0, size.height / 2, offset2.dx, offset2.dy)
        ..close();

      canvas.drawPath(path, paint);
    }
    if (drawEnd) {
      angle = -pi / 4;
      offset1 = _offset(radius, angle);
      offset2 = _offset(radius, -angle);

      path = Path()
        ..moveTo(offset1.dx, offset1.dy)
        ..quadraticBezierTo(size.width, size.height / 2, size.width + radius,
            radius) // TODO connector end & gradient
        ..quadraticBezierTo(size.width, size.height / 2, offset2.dx, offset2.dy)
        ..close();

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_BezierPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.drawStart != drawStart ||
        oldDelegate.drawEnd != drawEnd;
  }
}



//
// class DashboardPage extends StatefulWidget {
//   @override
//   State<DashboardPage> createState() => _DashboardPageState();
// }
//
// class _DashboardPageState extends State<DashboardPage> with SingleTickerProviderStateMixin {
//
//   int totalLeaveDays = 0;
//   late AnimationController _controller;
//   late Animation<double> _pieChartAnimation;
//   late Animation<double> _cardsAnimation;
//
//   @override
//   void initState() {
//     super.initState();
//     _initializeAnimations();
//     _fetchLeaveData();
//   }
//
//   void _initializeAnimations() {
//     // Initialize the animation controller
//     _controller = AnimationController(
//       duration: const Duration(milliseconds: 2000),
//       vsync: this,
//     );
//
//     // Pie chart animation sequence
//     _pieChartAnimation = TweenSequence<double>([
//       TweenSequenceItem(tween: Tween<double>(begin: 0, end: 25), weight: 25),
//       TweenSequenceItem(tween: Tween<double>(begin: 25, end: 50), weight: 25),
//       TweenSequenceItem(tween: Tween<double>(begin: 50, end: 75), weight: 25),
//       TweenSequenceItem(tween: Tween<double>(begin: 75, end: 100), weight: 25),
//     ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
//
//     // Cards animation
//     _cardsAnimation = CurvedAnimation(
//       parent: _controller,
//       curve: const Interval(0.2, 1.0, curve: Curves.easeInOut),
//     );
//
//     // Start the animation
//     _controller.forward();
//   }
//
//   void _fetchLeaveData() {
//     // Trigger the fetching of leave data
//     context.read<LeaveBloc>().add(FetchLeaves());
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: _buildAppBar(),
//       body: BlocBuilder<LeaveBloc, LeaveState>(
//         builder: (context, state) {
//           _handleLeaveState(state);
//
//           return SingleChildScrollView(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 _buildWelcomeMessage(),
//                 const SizedBox(height: 16),
//                 FittedBox(child: _buildSummaryCards()),
//                 const SizedBox(height: 24),
//                 _buildAttendanceOverview(),
//                 const SizedBox(height: 24),
//                 _buildQuickActions(),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
//
//   // AppBar builder
//   AppBar _buildAppBar() {
//     return AppBar(
//       title: const Text(Strings.appTitle, style: TextStyle(color: Colors.white)),
//       centerTitle: true,
//       backgroundColor: primaryColor, // Use the updated primary color
//     );
//   }
//
//   // Handle different leave states (Loaded, Failure)
//   void _handleLeaveState(LeaveState state) {
//     if (state is LeaveLoaded) {
//       totalLeaveDays = _calculateLeaveDays(state.leaveRequests);
//     } else if (state is LeaveRequestFailure) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text(state.errorMessage)),
//       );
//       totalLeaveDays = _calculateLeaveDays(state.currentLeaves);
//     }
//   }
//
//   // Calculate total leave days from a list of leave requests
//   int _calculateLeaveDays(List<LeaveRequest> leaves) {
//     if (leaves.isNotEmpty) {
//       return leaves
//           .map((leave) => DateTimeRange(
//         start: DateTime.parse(leave.startDate),
//         end: DateTime.parse(leave.endDate),
//       ).duration.inDays + 1)
//           .reduce((a, b) => a + b);
//     }
//     return 0;
//   }
//
//   // Welcome message and today's date
//   Widget _buildWelcomeMessage() {
//     return AnimatedOpacity(
//       opacity: 1.0,
//       duration: const Duration(seconds: 1),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             Strings.welcomeMessage,
//             style: Theme.of(context).textTheme.titleLarge?.copyWith(
//               color: primaryColor,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           Text(
//             "${Strings.todayLabel} ${DateFormat('EEE, MMM d').format(DateTime.now())}",
//             style: Theme.of(context).textTheme.bodyLarge,
//           ),
//         ],
//       ),
//     );
//   }
//
//   // Summary cards showing leave balance, days worked, and pending requests
//   Widget _buildSummaryCards() {
//     return SlideTransition(
//       position: Tween<Offset>(begin: const Offset(0.0, 0.5), end: Offset.zero).animate(_cardsAnimation),
//       child: FadeTransition(
//         opacity: _cardsAnimation,
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//           children: [
//             _buildSummaryCard(title: Strings.daysWorkedTitle, value: "22", color: secondaryColor),
//             _buildSummaryCard(title: Strings.leaveBalanceTitle, value: (30 - totalLeaveDays).toString(), color: primaryColor),
//             _buildSummaryCard(title: Strings.pendingRequestsTitle, value: "2", color: lightGray),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // Attendance overview section (Pie chart showing worked and leave days)
//   Widget _buildAttendanceOverview() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           Strings.attendanceOverviewTitle,
//           style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
//         ),
//         const SizedBox(height: 20),
//         Center(
//           child: ScaleTransition(
//             scale: Tween<double>(begin: 0.0, end: 1.0).animate(_cardsAnimation),
//             child: AnimatedBuilder(
//               animation: _pieChartAnimation,
//               builder: (context, child) {
//                 final workedDaysPercentage = ((30 - totalLeaveDays) / 30) * 100;
//                 final leaveDaysPercentage = (totalLeaveDays / 30) * 100;
//
//                 final animatedWorkedValue = (workedDaysPercentage * _pieChartAnimation.value) / 100;
//                 final animatedLeaveValue = (leaveDaysPercentage * _pieChartAnimation.value) / 100;
//
//                 return SizedBox(
//                   height: 200,
//                   child: Stack(
//                     children: [
//                       PieChart(
//                         PieChartData(
//                           startDegreeOffset: -90,
//                           sections: [
//                             PieChartSectionData(value: animatedWorkedValue, color: primaryColor, radius: 50, showTitle: false), // Updated primaryColor
//                             PieChartSectionData(value: animatedLeaveValue, color: secondaryColor, radius: 50, showTitle: false), // Updated secondaryColor
//                             PieChartSectionData(value: 100 - (animatedWorkedValue + animatedLeaveValue), color: veryLightGray, radius: 50, showTitle: false), // Updated veryLightGray
//                           ],
//                           centerSpaceRadius: 60,
//                           sectionsSpace: 4,
//                         ),
//                       ),
//                       Center(
//                         child: Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Text(
//                               'Present\n${(workedDaysPercentage * (_pieChartAnimation.value / 100)).toStringAsFixed(1)}%',
//                               textAlign: TextAlign.center,
//                               style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 16), // Updated primaryColor
//                             ),
//                             const SizedBox(height: 8),
//                             Text(
//                               'Leave\n${(leaveDaysPercentage * (_pieChartAnimation.value / 100)).toStringAsFixed(1)}%',
//                               textAlign: TextAlign.center,
//                               style: TextStyle(color: secondaryColor, fontWeight: FontWeight.bold, fontSize: 16), // Updated secondaryColor
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 );
//               },
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   // Quick actions section (Attendance, Leave request, Leave history)
//   Widget _buildQuickActions() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           Strings.quickActionsTitle,
//           style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
//         ),
//         const SizedBox(height: 8),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//           children: [
//             _buildQuickAction(
//               icon: Icons.check_circle_outline,
//               label: Strings.markAttendanceLabel,
//               onTap: () {
//                 Navigator.push(context, MaterialPageRoute(builder: (context) => const AttendancePage()));
//               },
//             ),
//             _buildQuickAction(
//               icon: Icons.calendar_today,
//               label: Strings.requestLeaveLabel,
//               onTap: () {
//                 Navigator.push(context, MaterialPageRoute(builder: (context) => LeaveRequestForm()));
//               },
//             ),
//             _buildQuickAction(
//               icon: Icons.history,
//               label: Strings.leaveHistoryLabel,
//               onTap: () {
//                 Navigator.push(context, MaterialPageRoute(builder: (context) => LeaveHistoryPage()));
//               },
//             ),
//           ],
//         ),
//       ],
//     );
//   }
//
//   // Helper method to build summary cards
//   Widget _buildSummaryCard({required String title, required String value, required Color color}) {
//     return Card(
//       elevation: 4,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 200),
//         padding: const EdgeInsets.all(16),
//         width: 110,
//         child: Column(
//           children: [
//             TweenAnimationBuilder<double>(
//               duration: const Duration(milliseconds: 2000),
//               curve: Curves.easeOut,
//               tween: Tween(begin: 0, end: double.parse(value)),
//               builder: (context, value, child) {
//                 return Text(
//                   value.toStringAsFixed(0),
//                   style: TextStyle(fontSize: 24, color: color, fontWeight: FontWeight.bold),
//                 );
//               },
//             ),
//             const SizedBox(height: 8),
//             Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 14)),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // Helper method to build quick action buttons
//   Widget _buildQuickAction({required IconData icon, required String label, required VoidCallback onTap}) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Column(
//         children: [
//           CircleAvatar(radius: 28, backgroundColor: primaryColor, child: Icon(icon, color: Colors.white)),
//           const SizedBox(height: 8),
//           Text(label, style: const TextStyle(fontSize: 14)),
//         ],
//       ),
//     );
//   }
// }
