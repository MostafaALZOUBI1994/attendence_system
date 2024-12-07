import 'package:attendence_system/features/leave/presentation/pages/leave_request_form.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../attendence/presentation/pages/attendance_page.dart';
import '../../../leave/presentation/pages/leave_history_page.dart';
import '../../../leave/presentation/pages/leave_page.dart';


class DashboardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance Dashboard'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome and today's date
            Text(
              "Welcome Back!",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text(
              "Today: ${DateFormat('EEE, MMM d').format(DateTime.now())}",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),

            // Attendance summary cards
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSummaryCard(
                  title: "Days Worked",
                  value: "22",
                  color: Colors.green,
                ),
                _buildSummaryCard(
                  title: "Leave Balance",
                  value: "5",
                  color: Colors.blue,
                ),
                _buildSummaryCard(
                  title: "Pending Requests",
                  value: "2",
                  color: Colors.orange,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Navigation buttons
            Text(
              "Quick Actions",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildQuickAction(
                  icon: Icons.check_circle_outline,
                  label: "Mark Attendance",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AttendancePage()),
                    );
                  },
                ),
                _buildQuickAction(
                  icon: Icons.calendar_today,
                  label: "Request Leave",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LeaveRequestForm()),
                    );
                  },
                ),
                // Add navigation to Leave History Page here
                _buildQuickAction(
                  icon: Icons.history,
                  label: "Leave History",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => LeaveHistoryPage()),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Build a summary card widget
  Widget _buildSummaryCard(
      {required String title, required String value, required Color color}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Container(
        padding: const EdgeInsets.all(16),
        width: 100,
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(fontSize: 24, color: color),
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
      {required IconData icon,
        required String label,
        required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.blue,
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
}

