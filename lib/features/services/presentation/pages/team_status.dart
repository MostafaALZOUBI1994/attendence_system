import 'package:flutter/material.dart';

import '../../../../main.dart';
import '../../../app_background.dart';

class TeamStatusScreen extends StatelessWidget {
  const TeamStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Team Status',style: TextStyle(color: Colors.white),),
        backgroundColor: primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: AppBackground(
        child: Column(
          children: [
            _buildStatusLegend(),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.2,
                ),
                itemCount: 8, // Replace with real data
                itemBuilder: (context, index) => _buildTeamMemberCard(index),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusLegend() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: veryLightGray,
        borderRadius: BorderRadius.circular(15),
      ),
      margin: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildLegendItem(primaryColor, 'Onsite'),
          _buildLegendItem(Colors.orangeAccent, 'Remote'),
          _buildLegendItem(Colors.redAccent, 'Absent'),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(fontWeight: FontWeight.bold, color: secondaryColor),
        ),
      ],
    );
  }

  Widget _buildTeamMemberCard(int index) {
    final status = ['Onsite', 'Remote', 'Absent'][index % 3];
    final color = _getStatusColor(status);

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: color.withOpacity(0.3), width: 2),
      ),
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              CircleAvatar(
                radius: 35,
                backgroundImage: const AssetImage('assets/user_profile.jpg'), // Add your image
                backgroundColor: lightGray,
              ),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: color, width: 2),
                ),
                child: Icon(
                  status == 'Onsite' ? Icons.location_on
                      : status == 'Remote' ? Icons.wifi
                      : Icons.close,
                  color: color,
                  size: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Mostafa ALZOUBI',
            style: TextStyle(fontWeight: FontWeight.bold, color: secondaryColor),
          ),
          Text(
            'Software Engineer',
            style: TextStyle(color: lightGray),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Onsite': return primaryColor;
      case 'Remote': return Colors.orangeAccent;
      default: return Colors.redAccent;
    }
  }
}