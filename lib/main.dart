import 'dart:async';
import 'package:attendence_system/features/authentication/presentation/pages/login_page.dart';
import 'package:attendence_system/features/reports/presentation/bloc/report_bloc.dart';
import 'package:attendence_system/features/services/presentation/bloc/services_bloc.dart';
import 'package:attendence_system/ui/screens/main_screen.dart';
import 'package:attendence_system/ui/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/constants/constants.dart';
import 'core/injection.dart';
import 'features/attendence/domain/repositories/attendence_repository.dart';
import 'features/attendence/presentation/bloc/attendence_bloc.dart';
import 'features/authentication/presentation/bloc/auth_bloc.dart';
import 'features/profile/presentation/bloc/profile_bloc.dart';



const carChannel = MethodChannel('com.example.attendence_system/car');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  carChannel.setMethodCallHandler((call) async {
    if (call.method == 'checkIn') {
      await getIt<AttendenceRepository>().checkIn();
    }
  });
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
        BlocProvider(create: (context) => getIt<AuthBloc>()),
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
          '/login': (context) => const  LoginScreen(),
          '/main': (context) => const MainScreen(),

        },
      ),
    );
  }
}

