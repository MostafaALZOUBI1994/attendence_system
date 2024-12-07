import 'package:flutter/material.dart';

class AttendanceSummaryCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Attendance Summary', style: Theme.of(context).textTheme.titleLarge,),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatItem('Days Worked', '20'),
                _buildStatItem('Leave Balance', '5'),
                _buildStatItem('Pending Requests', '1'),
              ],
            ),
            const SizedBox(height: 16),
            Text('Attendance History', style: Theme.of(context).textTheme.bodyMedium),
            // Add more details here
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String title, String value) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text(title, style: TextStyle(fontSize: 14)),
      ],
    );
  }
}
