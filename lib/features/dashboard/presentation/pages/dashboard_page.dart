import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/constants/constants.dart';
import '../../../attendence/presentation/pages/attendance_page.dart';
import '../../../leave/presentation/bloc/leave_bloc.dart';
import '../../../leave/presentation/bloc/leave_event.dart';
import '../../../leave/presentation/bloc/leave_state.dart';
import '../../../leave/presentation/pages/leave_request_form.dart';
import '../../../leave/presentation/pages/leave_history_page.dart';


class DashboardPage extends StatefulWidget {
  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final Color primaryColor = const Color(0xFF673AB7);
  int totalLeaveDays = 0;
  @override
  void initState() {
    super.initState();
    // Fetch leaves when the widget initializes
    context.read<LeaveBloc>().add(FetchLeaves());
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(Strings.appTitle),
        centerTitle: true,
        backgroundColor: primaryColor,
      ),
      body: BlocBuilder<LeaveBloc, LeaveState>(
  builder: (context, state) {
    if (state is LeaveLoaded) {
      // calculate total leave days
      totalLeaveDays = state.leaveRequests
          .map((leave) => DateTimeRange(
        start: DateTime.parse(leave.startDate),
        end: DateTime.parse(leave.endDate),
      ).duration.inDays + 1)
          .reduce((a, b) => a + b);
    }
    else if (state is LeaveRequestFailure) {
      // Handle error state, maybe show a snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.errorMessage)),
      );
      // If there's a failure, use the existing leaves or an empty list
      totalLeaveDays = state.currentLeaves
          .map((leave) =>
      DateTimeRange(
        start: DateTime.parse(leave.startDate),
        end: DateTime.parse(leave.endDate),
      ).duration.inDays + 1)
          .fold(0, (a, b) => a + b); // Use fold with initial value 0
    }
    return SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedOpacity(
              opacity: 1.0,
              duration: const Duration(seconds: 1),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    Strings.welcomeMessage,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "${Strings.todayLabel} ${DateFormat('EEE, MMM d').format(DateTime.now())}",
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Attendance summary cards
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSummaryCard(
                  title: Strings.daysWorkedTitle,
                  value: "22",
                  color: Colors.green,
                ),
                _buildSummaryCard(
                  title: Strings.leaveBalanceTitle,
                  value: (30 - totalLeaveDays).toString(), // Calculate leave balance
                  color: Colors.blue,
                ),
                _buildSummaryCard(
                  title: Strings.pendingRequestsTitle,
                  value: "2",
                  color: Colors.orange,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Pie chart
            Text(
              Strings.attendanceOverviewTitle,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Center(
              child: SizedBox(
                height: 200,
                child: PieChart(
                  PieChartData(
                    sections: _getPieChartSections(totalLeaveDays),
                    centerSpaceRadius: 50,
                    sectionsSpace: 4,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Quick actions
            Text(
              Strings.quickActionsTitle,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildQuickAction(
                  icon: Icons.check_circle_outline,
                  label: Strings.markAttendanceLabel,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AttendancePage()),
                    );
                  },
                ),
                _buildQuickAction(
                  icon: Icons.calendar_today,
                  label: Strings.requestLeaveLabel,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LeaveRequestForm()),
                    );
                  },
                ),
                _buildQuickAction(
                  icon: Icons.history,
                  label: Strings.leaveHistoryLabel,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LeaveHistoryPage()),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      );
  },
),
    );
  }

  // Build a summary card widget
  Widget _buildSummaryCard(
      {required String title, required String value, required Color color}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: AnimatedContainer(
        duration: const Duration(seconds: 1),
        padding: const EdgeInsets.all(16),
        width: 110,
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(fontSize: 24, color: color, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  // Build a quick action button
  Widget _buildQuickAction(
      {required IconData icon, required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: primaryColor,
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  // Pie chart sections
  List<PieChartSectionData> _getPieChartSections(int totalLeaveDays) {
    final workedDaysPercentage = ((300 - totalLeaveDays) / 300) * 100;
    final leaveDaysPercentage = (totalLeaveDays / 300) * 100;

    return [
      PieChartSectionData(
        value: workedDaysPercentage,
        color:  Colors.blue,
        radius: 50,
        title: '${workedDaysPercentage.toStringAsFixed(0)}%',
        titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      PieChartSectionData(
        value: leaveDaysPercentage,
        color: Colors.orange,
        radius: 50,
        title: '${leaveDaysPercentage.toStringAsFixed(0)}%',
        titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    ];
  }
}
