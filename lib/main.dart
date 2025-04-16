import 'dart:async';
import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
import 'package:attendence_system/features/attendence/presentation/bloc/attendence_event.dart';
import 'package:attendence_system/features/authentication/presentation/bloc/login_bloc.dart';
import 'package:attendence_system/features/authentication/presentation/pages/login_page.dart';
import 'package:attendence_system/features/reports/presentation/bloc/report_bloc.dart';
import 'package:attendence_system/features/services/presentation/bloc/services_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/constants/constants.dart';
import 'core/injection.dart';
import 'core/local_services/local_services.dart';
import 'features/attendence/presentation/bloc/attendence_bloc.dart';
import 'features/attendence/presentation/pages/attendence_page.dart';
import 'features/profile/presentation/bloc/profile_bloc.dart';
import 'features/profile/presentation/pages/profile_page.dart';
import 'features/reports/presentation/pages/reports_page.dart';
import 'features/services/presentation/pages/services.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => getIt<ProfileBloc>(),
        ),
        BlocProvider(create: (context) => getIt<LoginBloc>()),
        BlocProvider(
          create: (context) =>
              getIt<AttendenceBloc>()..add(const AttendenceEvent.loadData()),
        ),
        BlocProvider(
          create: (context) => getIt<ReportBloc>(),
        ),
        BlocProvider(
          create: (context) => getIt<ServicesBloc>()..add(const ServicesEvent.loadData()),
        ),
      ],
      child: MaterialApp(
        theme: ThemeData(
          colorScheme: ColorScheme.fromSwatch().copyWith(
            primary: primaryColor,
            secondary: secondaryColor,
          ),
          inputDecorationTheme: InputDecorationTheme(
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: primaryColor),
            ),
          ),
          // Other theme settings...
        ),
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(),
          '/main': (context) => const MainScreen(),
        },
      ),
    );
  }
}

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
                width: 150, height: 150), // Your logo
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
