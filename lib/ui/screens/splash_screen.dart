import 'dart:async';
import 'package:attendence_system/features/authentication/data/mappers/employee_mapper.dart';
import 'package:flutter/material.dart';

import '../../core/constants/constants.dart';
import '../../core/injection.dart';
import '../../core/local_services/local_services.dart';
import '../../features/authentication/data/datasources/employee_local_data_source.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late final AnimationController _logoController;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _textFadeAnimation;

  late final AnimationController _bgController;
  late final Animation<double> _bgAnimation;

  @override
  void initState() {
    super.initState();
    _goNextAfterDelay();
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _scaleAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );


    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeIn),
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.decelerate),
    );

    _textFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: const Interval(0.6, 1.0, curve: Curves.easeIn)),
    );

    _logoController.forward();

    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat(reverse: true);

    _bgAnimation = Tween<double>(begin: 0.0, end: -50.0).animate(
      CurvedAnimation(parent: _bgController, curve: Curves.linear),
    );


  }
  Future<void> _goNextAfterDelay() async {
    final localDs = getIt<EmployeeLocalDataSource>();
    final model = await localDs.getProfile();
    final employee = model!.toEntity();

    await Future.delayed(const Duration(seconds: 3));

    if (employee.id.isNotEmpty) {
      Navigator.of(context).pushReplacementNamed(
        '/main',
        arguments: employee,
      );
    } else {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _bgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Animated background image.
          AnimatedBuilder(
            animation: _bgAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(_bgAnimation.value, 0),
                child: child,
              );
            },
            child: Image.asset(
              'assets/c1.png',
              fit: BoxFit.cover,
            ),
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
                ),
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Image.asset(
                      'assets/logo.png',
                      width: 150,
                      height: 150,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Animated welcome text (slide + fade).
                SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _textFadeAnimation,
                    child: const Text(
                      "Welcome to MOEC Employee App",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
