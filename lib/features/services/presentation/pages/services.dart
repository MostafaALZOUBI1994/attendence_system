import 'package:attendence_system/features/services/presentation/pages/ask_ai.dart';
import 'package:attendence_system/features/services/presentation/pages/hr_request.dart';
import 'package:attendence_system/features/services/presentation/pages/team_status.dart';
import 'package:flutter/material.dart';

import '../../../../main.dart';
import '../../../app_background.dart';
import 'events.dart';

class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Services", style: TextStyle(color: Colors.white)),
        backgroundColor: primaryColor,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: AppBackground(
        child: Column(
          children: [
            Expanded(child: _buildServiceGrid(context)), // Pass context here
          ],
        ),
      ),
    );
  }

  Widget _buildServiceGrid(BuildContext context) {
    final services = [
      {
        'icon': Icons.assignment_ind, // More HR-specific icon
        'title': 'HR Support',
        'route': '/hr-requests',
      },
      {
        'icon': Icons.local_cafe,
        'title': 'Pantry',
        'route': '/pantry',
      },
      {
        'icon': Icons.headset_mic,
        'title': 'Help Desk',
        'route': '/help-desk',
      },
      {
        'icon': Icons.smart_toy_outlined,
        'title': 'Ask Bot',
        'route': '/ask-ai',
      },
      {
        'icon': Icons.people_alt_outlined,
        'title': 'Team Status',
        'route': '/team-status',
      },
      {
        'icon': Icons.calendar_month,
        'title': 'Upcoming Events',
        'route': '/events',
      },
    ];

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView.builder(
        itemCount: services.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemBuilder: (context, index) {
          final service = services[index];
          return _buildServiceCard(
            context,
            service['icon'] as IconData,
            service['title'] as String,
            service['route'] as String,
          );
        },
      ),
    );
  }

  Widget _buildServiceCard(
      BuildContext context, IconData icon, String title, String routeName) {
    return InkWell(
      onTap: () => _navigateTo(context, routeName),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black12, blurRadius: 6, spreadRadius: 2),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: primaryColor),
            SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateTo(BuildContext context, String routeName) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) {
          final Widget? screen = _getScreenForRoute(routeName);
          if (screen == null) {
            throw Exception("No screen found for route: $routeName");
          }
          return screen;
        },
        transitionsBuilder: (_, Animation<double> anim, __, Widget child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: anim, curve: Curves.easeInOut)),
            child: FadeTransition(
              opacity: anim,
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 300), // Adjust duration
      ),
    );
  }


  Widget? _getScreenForRoute(String routeName) {
    switch (routeName) {
      case '/hr-requests':
        return HRRequestScreen();
      case '/ask-ai':
        return AskAIScreen();
      case '/team-status':
        return const TeamStatusScreen();
      case '/events':
        return const EventsScreen();
    }
  }
}