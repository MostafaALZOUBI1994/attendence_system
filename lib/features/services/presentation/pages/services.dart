import 'package:attendence_system/features/services/presentation/pages/ask_ai.dart';
import 'package:attendence_system/features/services/presentation/pages/hr_request.dart';
import 'package:attendence_system/features/services/presentation/pages/pantry.dart';
import 'package:attendence_system/features/services/presentation/pages/team_status.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/constants.dart';
import 'events.dart';

class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return  Column(
        children: [
          Expanded(child: _buildServiceGrid(context)),
        ],
      );
  }

  Widget _buildServiceGrid(BuildContext context) {
    final services = [
      {
        'icon': Icons.assignment_ind,
        'title': 'hrSupport'.tr(),
        'route': '/hr-requests',
      },
      {
        'icon': Icons.local_cafe,
        'title': 'pantry'.tr(),
        'route': '/pantry-request',
      },
      {
        'icon': Icons.headset_mic,
        'title': 'helpDesk'.tr(),
        'route': '/help-desk',
      },
      {
        'icon': Icons.smart_toy_outlined,
        'title': 'askBot'.tr(),
        'route': '/ask-ai',
      },
      {
        'icon': Icons.people_alt_outlined,
        'title': 'tmsContacts'.tr(),
        'route': '/team-contacts',
      },
      {
        'icon': Icons.calendar_month,
        'title': 'upCmEvents'.tr(),
        'route': '/events',
      },
    ];

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView.builder(
        itemCount: services.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
          color: Colors.white.withOpacity(0.8),
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 6, spreadRadius: 2),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: primaryColor),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
        return const HRRequestScreen();
      case '/ask-ai':
        return const AskAIScreen();
      case '/team-contacts':
        return const TeamContactScreen();
      case '/events':
        return const EventsScreen();
      case '/pantry-request':
        return const PantryRequestScreen();
    }
    return null;
  }
}