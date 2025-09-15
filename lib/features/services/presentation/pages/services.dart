import 'package:moet_hub/features/services/presentation/pages/ask_ai.dart';
import 'package:moet_hub/features/services/presentation/pages/hr_request.dart';
import 'package:moet_hub/features/services/presentation/pages/pantry.dart';
import 'package:moet_hub/features/services/presentation/pages/team_status.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/constants.dart';
import '../bloc/services_bloc.dart';
import 'events.dart';

class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Kick off loading of any data when the screen is first built
    Future.microtask(() {
      context.read<ServicesBloc>().add(const ServicesEvent.loadData());
    });
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Add a section header to introduce the Services page and align with
        // the app's design language.  Using the primary colour ties it back to
        // the rest of the app.
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
          child: Text(
            'services'.tr(),
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
        ),
        Expanded(child: _buildServiceGrid(context)),
      ],
    );
  }

  Widget _buildServiceGrid(BuildContext context) {
    // List of service metadata. Each entry defines the icon, translation key and route.
    final services = [
      {
        'icon': Icons.assignment_ind,
        'title': 'elve'.tr(),
        'route': '/hr-requests',
      },
      // {
      //   'icon': Icons.local_cafe,
      //   'title': 'pantry'.tr(),
      //   'route': '/pantry-request',
      // },
      // {
      //   'icon': Icons.smart_toy_outlined,
      //   'title': 'askBot'.tr(),
      //   'route': '/ask-ai',
      // },
      {
        'icon': Icons.people_alt_outlined,
        'title': 'tmsContacts'.tr(),
        'route': '/team-contacts',
      },
      // {
      //   'icon': Icons.calendar_month,
      //   'title': 'upCmEvents'.tr(),
      //   'route': '/events',
      // },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        itemCount: services.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          // A slightly rectangular aspect ratio gives more vertical space for
          // the header and icon while maintaining a balanced look.
          childAspectRatio: 1.1,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        splashColor: primaryColor.withOpacity(0.2),
        highlightColor: primaryColor.withOpacity(0.1),
        onTap: () => _navigateTo(context, routeName),
        child: Container(
          decoration: BoxDecoration(
            // Use the secondary gradient defined in constants to stay within
            // the established colour palette while adding subtle depth.
            gradient: secondryGradient.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),

          ),
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon inside a lightly tinted circle for a refined look
              Container(
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(12),
                child: Icon(icon, size: 32, color: primaryColor),
              ),
              const SizedBox(height: 14),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: secondaryColor,
                ),
              ),
            ],
          ),
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