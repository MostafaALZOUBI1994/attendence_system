import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/attendance_bloc.dart';

class AttendancePage extends StatelessWidget {
  const AttendancePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final attendanceBloc = context.read<AttendanceBloc>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mark Attendance'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Options for attendance marking
            ListTile(
              title: const Text("Present"),
              leading: const Icon(Icons.check_circle, color: Colors.green),
              onTap: () {
                attendanceBloc.add(MarkAttendance(
                  date: DateTime.now().toString(),
                  status: "Present",
                ));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Attendance marked as Present!')),
                );
              },
            ),
            ListTile(
              title: const Text("Missed Punch"),
              leading: const Icon(Icons.error_outline, color: Colors.orange),
              onTap: () {
                attendanceBloc.add(MarkAttendance(
                  date: DateTime.now().toString(),
                  status: "Missed Punch",
                ));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Attendance marked as Missed Punch!')),
                );
              },
            ),
            ListTile(
              title: const Text("Early Out"),
              leading: const Icon(Icons.alarm_off, color: Colors.red),
              onTap: () {
                attendanceBloc.add(MarkAttendance(
                  date: DateTime.now().toString(),
                  status: "Early Out",
                ));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Attendance marked as Early Out!')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
