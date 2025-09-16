// features/services/presentation/services_screen.dart
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:moet_hub/features/services/presentation/pages/team_status.dart';
import '../../../../core/constants/constants.dart';
import '../registry/service_registry.dart';
import 'hr_request.dart';


// Feature screens:


class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  List<ServiceDef> _services(BuildContext context) => [
    ServiceDef(
      icon: Icons.assignment_ind,
      titleKey: 'elve',
      builder: (_) => const HRRequestScreen(),
    ),
    ServiceDef(
      icon: Icons.people_alt_outlined,
      titleKey: 'tmsContacts',
      builder: (_) => const TeamContactScreen(),
    ),
    // Add more here whenever you need
  ];

  @override
  Widget build(BuildContext context) {
    final services = _services(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
          child: Text(
            'services'.tr(),
            style: const TextStyle(
              fontSize: 26, fontWeight: FontWeight.bold, color: primaryColor,
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.builder(
              itemCount: services.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, childAspectRatio: 1.1, crossAxisSpacing: 16, mainAxisSpacing: 16,
              ),
              itemBuilder: (context, i) => _ServiceCard(def: services[i]),
            ),
          ),
        ),
      ],
    );
  }
}

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({required this.def});
  final ServiceDef def;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        splashColor: primaryColor.withOpacity(0.2),
        highlightColor: primaryColor.withOpacity(0.1),
        onTap: () => Navigator.of(context).push(PageRouteBuilder(
          pageBuilder: (_, __, ___) => def.builder(context),
          transitionsBuilder: (_, anim, __, child) => SlideTransition(
            position: Tween<Offset>(begin: const Offset(1,0), end: Offset.zero)
                .animate(CurvedAnimation(parent: anim, curve: Curves.easeInOut)),
            child: FadeTransition(opacity: anim, child: child),
          ),
          transitionDuration: const Duration(milliseconds: 300),
        )),
        child: Container(
          decoration: BoxDecoration(
            gradient: secondryGradient.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.15), shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(12),
                child: Icon(def.icon, size: 32, color: primaryColor),
              ),
              const SizedBox(height: 14),
              Text(
                def.titleKey.tr(),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: secondaryColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
