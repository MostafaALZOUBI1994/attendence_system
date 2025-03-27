import 'package:flutter/material.dart';

import '../../../../core/constants/constants.dart';
import '../../../app_background.dart';

class TeamContactScreen extends StatelessWidget {
  const TeamContactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Team Contacts',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: AppBackground(
        child: Column(
          children: [
            _buildContactLegend(),
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

  Widget _buildContactLegend() {
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
          _buildLegendItem(Icons.email, 'Email'),
          _buildLegendItem(Icons.phone, 'Extension'),
        ],
      ),
    );
  }

  Widget _buildLegendItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          color: secondaryColor,
          size: 18,
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.bold, color: secondaryColor),
        ),
      ],
    );
  }

  Widget _buildTeamMemberCard(int index) {
    // Sample data for demonstration purposes
    final List<Map<String, String>> teamMembers = [
      {'name': 'Mostafa ALZOUBI', 'email': 'MALZoubi@economy.ae', 'extension': '1234'},
      {'name': 'Mostafa ALZOUBI', 'email': 'MALZoubi@economy.ae', 'extension': '1234'},
      {'name': 'Mostafa ALZOUBI', 'email': 'MALZoubi@economy.ae', 'extension': '1234'},
      {'name': 'Mostafa ALZOUBI', 'email': 'MALZoubi@economy.ae', 'extension': '1234'},
      {'name': 'Mostafa ALZOUBI', 'email': 'MALZoubi@economy.ae', 'extension': '1234'},
      {'name': 'Mostafa ALZOUBI', 'email': 'MALZoubi@economy.ae', 'extension': '1234'},
      {'name': 'Mostafa ALZOUBI', 'email': 'MALZoubi@economy.ae', 'extension': '1234'},
      {'name': 'Mostafa ALZOUBI', 'email': 'MALZoubi@economy.ae', 'extension': '1234'}
    ];

    final member = teamMembers[index];

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: lightGray.withOpacity(0.3), width: 2),
      ),
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircleAvatar(
            radius: 35,
            backgroundImage: AssetImage('assets/user_profile.jpg'), // Add your image
            backgroundColor: lightGray,
          ),
          const SizedBox(height: 8),
          Text(
            member['name']!,
            style: const TextStyle(fontWeight: FontWeight.bold, color: secondaryColor),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.email, color: primaryColor, size: 16),
              const SizedBox(width: 4),
              Text(
                member['email']!,
                style: const TextStyle(fontSize: 12, color: lightGray),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.phone, color: primaryColor, size: 16),
              const SizedBox(width: 4),
              Text(
                'Ext: ${member['extension']}',
                style: const TextStyle(fontSize: 12, color: lightGray),
              ),
            ],
          ),
        ],
      ),
    );
  }
}