import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/constants.dart';
import '../bloc/attendance_bloc.dart';
import '../bloc/attendance_event.dart';
import '../bloc/attendance_state.dart';

class AttendancePage extends StatelessWidget {
  const AttendancePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          Strings.appBarTitle,
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xFF673AB7),
      ),
      body: BlocProvider(
        create: (context) => AttendanceBloc()..add(LoadAttendance()),
        child: BlocBuilder<AttendanceBloc, AttendanceState>(
          builder: (context, state) {
            if (state is AttendanceInitial) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is AttendanceLoaded) {
              return _buildAttendanceList(context, state.records);
            } else {
              return const Center(child: Text(Strings.somethingWentWrong));
            }
          },
        ),
      ),
    );
  }

  Widget _buildAttendanceList(
      BuildContext context, List<Map<String, dynamic>> records) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text(
            Strings.markAttendanceTitle,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          _buildAttendanceOption(
            context,
            icon: Icons.check_circle,
            color: Colors.green,
            title: Strings.present,
            onTap: () => _markAttendance(context, Strings.present),
          ),
          _buildAttendanceOption(
            context,
            icon: Icons.error_outline,
            color: Colors.orange,
            title: Strings.missedPunch,
            onTap: () => _markAttendance(context, Strings.missedPunch),
          ),
          _buildAttendanceOption(
            context,
            icon: Icons.alarm_off,
            color: Colors.red,
            title: Strings.earlyOut,
            onTap: () => _markAttendance(context, Strings.earlyOut),
          ),
          const SizedBox(height: 16),
          Text(
            Strings.attendanceRowsTitle,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: records.length,
              itemBuilder: (context, index) {
                final record = records[index];
                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _getStatusColor(record['status']),
                      child: Text(
                        record['status'][0].toUpperCase(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(record['status']),
                    subtitle: Text(record['date']),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _markAttendance(BuildContext context, String status) {
    final attendanceBloc = context.read<AttendanceBloc>();
    final date = DateTime.now().toString();

    attendanceBloc.add(MarkAttendance(date: date, status: status));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$status ${Strings.snackBarMessage}')),
    );
  }

  Widget _buildAttendanceOption(BuildContext context,
      {required IconData icon,
        required Color color,
        required String title,
        required VoidCallback onTap}) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 4,
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(title),
        onTap: onTap,
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case Strings.present:
        return Colors.green;
      case Strings.missedPunch:
        return Colors.orange;
      case Strings.earlyOut:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
