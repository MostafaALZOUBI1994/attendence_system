import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants/constants.dart';
import '../../core/injection.dart';
import '../../features/attendence/presentation/bloc/attendence_bloc.dart';
import '../../features/attendence/presentation/pages/attendence_page.dart';
import '../../features/authentication/presentation/bloc/auth_bloc.dart';
import '../../features/profile/presentation/bloc/profile_bloc.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/reports/presentation/bloc/report_bloc.dart';
import '../../features/reports/presentation/pages/reports_page.dart';
import '../../features/services/presentation/bloc/services_bloc.dart';
import '../../features/services/presentation/pages/services.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final _controller = NotchBottomBarController(index: 0);
  int _currentIndex = 0;

  final List<Widget> _pages = [
    TimeScreen(),
    const ServicesScreen(),
    const ReportsScreen(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => getIt<ProfileBloc>(),
        ),
        BlocProvider(create: (context) => getIt<AuthBloc>()),
        BlocProvider(
          create: (context) =>
          getIt<AttendenceBloc>()..add(const AttendenceEvent.loadData()),
        ),
        BlocProvider(
          create: (context) => getIt<ReportBloc>(),
        ),
        BlocProvider(
          create: (context) =>
          getIt<ServicesBloc>()..add(const ServicesEvent.loadData()),
        ),
      ],
  child: Scaffold(
      extendBody: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          SafeArea(top: true,
              bottom: false,  child:  _pages[_currentIndex]),
        ],
      ),
      bottomNavigationBar: SizedBox(
        height: 80 + MediaQuery.of(context).padding.bottom,
        child: AnimatedNotchBottomBar(
          showLabel: true,
          notchColor: primaryColor.withOpacity(0.7),
          color: veryLightGray.withOpacity(1.0),
          itemLabelStyle: const TextStyle(
            fontSize: 10.0,
            fontWeight: FontWeight.w500,
          ),
          bottomBarItems: [
            _bottomBarItem(Icons.home, "home".tr()),
            _bottomBarItem(Icons.build, "services".tr()),
            _bottomBarItem(Icons.list_alt, "reports".tr()),
            _bottomBarItem(Icons.person, "profile".tr()),
          ],
          onTap: (index) => setState(() => _currentIndex = index),
          notchBottomBarController: _controller,
          removeMargins: true,
          kBottomRadius: 60.0,
          elevation: 0,
          shadowElevation: 0,
          showShadow: false,
          bottomBarHeight: 90.0,
          kIconSize: 20,
        ),
      ),

    ),
);
  }

  BottomBarItem _bottomBarItem(IconData icon, String label) {
    return BottomBarItem(
    inActiveItem: Icon(icon, color: Colors.grey),
    activeItem: Icon(icon, color: Colors.white),
    itemLabel: label,
  );
  }
}