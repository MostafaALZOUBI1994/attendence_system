
import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../core/constants/constants.dart';
import '../../features/attendence/presentation/pages/attendence_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/reports/presentation/pages/reports_page.dart';
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
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: AnimatedNotchBottomBar(
        showLabel: false,
        notchColor: primaryColor,
        bottomBarItems: [
          _bottomBarItem(Icons.home, "home".tr()),
          _bottomBarItem(Icons.build, "services".tr()),
          _bottomBarItem(Icons.list_alt, "reports".tr()),
          _bottomBarItem(Icons.person, "profile".tr()),
        ],
        onTap: (index) => setState(() => _currentIndex = index),
        notchBottomBarController: _controller,
        color: veryLightGray,
        kBottomRadius: 28.0,
        elevation: 100,
        shadowElevation: 5,
        showShadow: true,
        removeMargins: true,
        bottomBarHeight: 82.0,
        kIconSize: 20,
      ),
    );
  }

  BottomBarItem _bottomBarItem(IconData icon, String label) => BottomBarItem(
    inActiveItem: Icon(icon, color: Colors.grey),
    activeItem: Icon(icon, color: Colors.white),
    itemLabel: label,
  );
}