
import 'dart:async';

import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
import 'package:flutter/material.dart';

import 'features/attendence/presentation/pages/attendance_page.dart';
import 'features/dashboard/presentation/pages/dashboard_page.dart';
import 'features/profile/presentation/pages/profile_page.dart';
import 'features/services/presentation/pages/hr_request.dart';
import 'features/services/presentation/pages/services.dart';


const Color deepTeal = Color(0xFF2A6559);
const Color softCoral = Color(0xFFF4A27E);
final Color primaryColor = Color.fromRGBO(182, 138, 53, 1.0);
final Color secondaryColor = Color.fromRGBO(65, 64, 66, 1.0);
final Color lightGray = Color.fromRGBO(198, 198, 198, 1.0);
final Color veryLightGray = Color.fromRGBO(225, 225, 225, 1.0);


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => MainScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/logo.png', width: 150, height: 150), // Your logo
            const SizedBox(height: 20),
            // const CircularProgressIndicator(
            //   valueColor: AlwaysStoppedAnimation<Color>(primarColor),
            // ),
          ],
        ),
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final _controller = NotchBottomBarController(index: 0);
  int _currentIndex = 0;

  final List<Widget> _pages = [
    TimeScreen(),
    ServicesScreen(),
    ReportsScreen(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: AnimatedNotchBottomBar(
        showLabel: true,
        notchColor: primaryColor,
        bottomBarItems: [
          _bottomBarItem(Icons.home, "Home"),
          _bottomBarItem(Icons.build, "Service"),
          _bottomBarItem(Icons.list_alt, "Reports"),
          _bottomBarItem(Icons.person, "Profile"),
        ],
        onTap: (index) => setState(() => _currentIndex = index),
        notchBottomBarController: _controller,
        color: veryLightGray,
        kBottomRadius: 28.0,
        elevation: 100,
        shadowElevation: 5,
        showShadow: true,
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