import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/constants/constants.dart';
import '../../core/injection.dart';
import '../../core/local_services/local_services.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;
  @override
  void initState() {
    super.initState();

    // Create an animation controller for splash effects.
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    // Scale animation: from slightly smaller to full size.
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    // Fade animation: from transparent to fully opaque.
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();

    // Wait for a few seconds then navigate to the next screen.
    Timer(const Duration(seconds: 3), () {
      final localService = getIt<LocalService>();  // Using dependency injection.
      final empId = localService.get(empID);
      Navigator.of(context).pushReplacementNamed(
        empId != null ? '/main' : '/login',
      );
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,

        children:[
          Image.asset(
            'assets/c1.png',
            fit: BoxFit.cover,
            color: Colors.black.withOpacity(0.4),
            colorBlendMode: BlendMode.darken,
          ),
          Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0x00000000),
                const Color(0x00000000),
                const Color(0xFFFFFFFF),
                const Color(0xB0FFF8E1),
                const Color(0x00000000),
                const Color(0x00000000),
              ],
            ),
          ),
          child: Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/logo.png',
                      width: 150,
                      height: 150,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "Welcome to Employee App",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: primaryColor, // Refined gold tone.
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
    ]
      ),
    );
  }
}