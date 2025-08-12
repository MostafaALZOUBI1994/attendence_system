import 'package:moet_hub/features/services/presentation/pages/base_screen.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/constants.dart';


class EventsScreen extends StatelessWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      titleKey: 'Upcoming Birthdays',
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
    );
  }

  Widget _buildBirthdayCountdown() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
       color: Colors.white.withOpacity(0.90),
        borderRadius: BorderRadius.circular(15),
        ),
      child: Column(
        children: [
          const Text(
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
         color: Colors.white.withOpacity(0.6)
          ),

        child: const Row(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                CircleAvatar(
                  radius: 35,
                  backgroundImage: AssetImage('assets/user_profile.jpg'),
                  backgroundColor: lightGray,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Icon(Icons.cake, color: primaryColor, size: 24),
                ),
              ],
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'John Doe',
                    style: TextStyle(
                      color: secondaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Mobile Developer',
                    style: TextStyle(color: Colors.white),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.calendar_today, color: primaryColor, size: 16),
                      SizedBox(width: 4),
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