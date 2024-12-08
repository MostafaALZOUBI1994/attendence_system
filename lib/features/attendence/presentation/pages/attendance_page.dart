import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/constants.dart';
import '../bloc/attendance_bloc.dart';

class AttendancePage extends StatelessWidget {
  const AttendancePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final attendanceBloc = context.read<AttendanceBloc>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(Strings.attendanceTitle,style: TextStyle(color: Colors.white),),
        centerTitle: true,
        backgroundColor: const Color(0xFF673AB7),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              Strings.markAttendancePrompt,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildAttendanceOption(
              context,
              icon: Icons.check_circle,
              color: Colors.green,
              title: Strings.present,
              onTap: () => _markAttendance(
                context,
                attendanceBloc,
                Strings.present,
                Strings.presentMarkedMessage,
              ),
            ),
            _buildAttendanceOption(
              context,
              icon: Icons.error_outline,
              color: Colors.orange,
              title: Strings.missedPunch,
              onTap: () => _markAttendance(
                context,
                attendanceBloc,
                Strings.missedPunch,
                Strings.missedPunchMarkedMessage,
              ),
            ),
            _buildAttendanceOption(
              context,
              icon: Icons.alarm_off,
              color: Colors.red,
              title: Strings.earlyOut,
              onTap: () => _markAttendance(
                context,
                attendanceBloc,
                Strings.earlyOut,
                Strings.earlyOutMarkedMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceOption(
      BuildContext context, {
        required IconData icon,
        required Color color,
        required String title,
        required VoidCallback onTap,
      }) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 600),
      tween: Tween<double>(begin: 0, end: 1),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - value)), // Slide from below
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 4,
        child: ListTile(
          leading: Icon(icon, color: color),
          title: Text(
            title,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          onTap: onTap,
        ),
      ),
    );
  }

  void _markAttendance(
      BuildContext context,
      AttendanceBloc attendanceBloc,
      String status,
      String message,
      ) {
    attendanceBloc.add(
      MarkAttendance(
        date: DateTime.now().toString(),
        status: status,
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
