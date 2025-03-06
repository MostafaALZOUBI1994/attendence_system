import 'package:attendence_system/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:flutter/material.dart';
import 'package:dashed_circular_progress_bar/dashed_circular_progress_bar.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:timelines_plus/timelines_plus.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TimeScreen(),
    );
  }
}

class TimeScreen extends StatefulWidget {
  @override
  _TimeScreenState createState() => _TimeScreenState();
}

class _TimeScreenState extends State<TimeScreen> {
  late Timer _timer;
  String _currentTime = "";
  String _currentDate = "";
  String _currentDay = "";

  @override
  void initState() {
    super.initState();
    _updateDateTime();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _updateDateTime();
      });
    });
  }

  void _updateDateTime() {
    DateTime now = DateTime.now();
    _currentTime = DateFormat('hh:mm a').format(now);
    _currentDate = DateFormat('MMMM d, yyyy').format(now);
    _currentDay = DateFormat('EEEE').format(now);
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
      appBar: AppBar(
        title: Text("Attendance System"),
        backgroundColor: Color(0xFFB68A35),
        actions: [
          IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {},
          ),
        ],
      ),
      body: Stack(
        children: [
          _buildBackground(),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _buildCard(_buildClock()),
              SizedBox(width: 20),
              _buildCard(_buildTimeline()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Stack(
      children: [
        Positioned(
          top: 150,
          left: -50,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.2),
              shape: BoxShape.circle,
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
              color: primaryColor.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 150,
            decoration: BoxDecoration(
              color: primaryColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCard(Widget child) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: child,
      ),
    );
  }

  Widget _buildClock() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            DashedCircularProgressBar.square(
              dimensions: 150,
              progress: 60,
              startAngle: 270,
              sweepAngle: 360,
              circleCenterAlignment: Alignment.center,
              foregroundColor: Color(0xFFB68A35),
              backgroundColor: Colors.grey[200]!,
              foregroundStrokeWidth: 6,
              backgroundStrokeWidth: 3,
              animation: true,
            ),
            Column(
              children: [
                Text(_currentDay, style: TextStyle(color: Colors.black54, fontSize: 14)),
                Text(_currentTime, style: TextStyle(color: Colors.black, fontSize: 22, fontWeight: FontWeight.bold)),
                Text(_currentDate, style: TextStyle(color: Colors.black54, fontSize: 12)),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTimeline() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text("Attendance Timeline", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 10),
        FixedTimeline.tileBuilder(
          theme: TimelineThemeData(
            nodePosition: 0.1,
            connectorTheme: ConnectorThemeData(thickness: 3.5),
          ),
          builder: TimelineTileBuilder.connected(
            connectionDirection: ConnectionDirection.before,
            itemCount: 3,
            contentsBuilder: (context, index) => Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("08:00 AM - Check-In", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text("Feb 23, 2019", style: TextStyle(color: Colors.black54, fontSize: 14)),
                ],
              ),
            ),
            indicatorBuilder: (context, index) {
              return CircleAvatar(radius: 12, backgroundColor: primaryColor);
            },
            connectorBuilder: (context, index, _) {
              return SolidLineConnector(color: primaryColor, thickness: 3.5);
            },
          ),
        ),
      ],
    );
  }
}
