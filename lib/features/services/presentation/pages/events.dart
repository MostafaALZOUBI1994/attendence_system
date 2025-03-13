import 'package:flutter/material.dart';
import '../../../../main.dart';
import '../../../app_background.dart';

class EventsScreen extends StatelessWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upcoming Birthdays', style: TextStyle(color: Colors.white),),
        backgroundColor: primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: AppBackground(
        child: Column(
          children: [
            _buildBirthdayCountdown(),
            Expanded(
              child: ListView.builder(
                itemCount: 5,
                itemBuilder: (context, index) => _buildBirthdayCard(index, context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBirthdayCountdown() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
       color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(15),
        ),
      child: Column(
        children: [
          Text(
            'Next Birthday In...',
            style: TextStyle(
              color: primaryColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '3 Days!',
            style: TextStyle(
              color: primaryColor,
              fontSize: 36,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(color: secondaryColor.withOpacity(0.5), blurRadius: 4),
              ],
            ),
          ),

        ],
      ),
    );
  }

  Widget _buildBirthdayCard(int index, BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      color: veryLightGray,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: primaryColor),
         color: Colors.white
          ),

        child: Row(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                CircleAvatar(
                  radius: 35,
                  backgroundImage: const AssetImage('assets/user_profile.jpg'),
                  backgroundColor: lightGray,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Icon(Icons.cake, color: primaryColor, size: 24),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mostafa ALZOUBI',
                    style: TextStyle(
                      color: secondaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Mobile Developer',
                    style: TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.calendar_today, color: primaryColor, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        'October 25',
                        style: TextStyle(color: primaryColor),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}