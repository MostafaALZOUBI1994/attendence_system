import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/constants/constants.dart';
import '../../core/injection.dart';
import '../../core/local_services/local_services.dart';
import '../../features/authentication/presentation/pages/login_page.dart';
import 'main_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () async {
      final localService = getIt<LocalService>();
      final empId = localService.get(empID);
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) =>
          empId != null ? const MainScreen() : const LoginScreen(),
        ),
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
            Image.asset('assets/logo.png',
                width: 150, height: 150),
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