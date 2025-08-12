import 'dart:async';
import 'package:moet_hub/features/authentication/presentation/pages/login_page.dart';
import 'package:moet_hub/features/reports/presentation/bloc/report_bloc.dart';
import 'package:moet_hub/features/services/presentation/bloc/services_bloc.dart';
import 'package:moet_hub/ui/screens/carplay_screen.dart';
import 'package:moet_hub/ui/screens/main_screen.dart';
import 'package:moet_hub/ui/screens/splash_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_carplay/carplay_worker.dart';
import 'package:flutter_carplay/flutter_carplay.dart';
import 'core/constants/constants.dart';
import 'core/injection.dart';
import 'core/local_services/local_services.dart';
import 'features/attendence/domain/repositories/attendence_repository.dart';
import 'features/attendence/presentation/bloc/attendence_bloc.dart';
import 'features/authentication/presentation/bloc/auth_bloc.dart';
import 'features/profile/presentation/bloc/profile_bloc.dart';

const carChannel = MethodChannel('ae.gov.moet.moethub/car');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  await EasyLocalization.ensureInitialized();
  CarPlayService.init();
  carChannel.setMethodCallHandler((call) async {
    if (call.method == 'checkIn') {
      await getIt<AttendenceRepository>().checkIn();
    }
  });
  final savedLocale = getIt<LocalService>().getSavedLocale();
  Intl.defaultLocale = savedLocale.languageCode;
  runApp(
    EasyLocalization(
      useOnlyLangCode: true,
      supportedLocales: const [
        Locale('en'),
        Locale('ar'),
      ],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      startLocale: savedLocale,
      child: const MyApp(),
    ),
  );
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
          create: (context) =>
              getIt<ServicesBloc>()..add(const ServicesEvent.loadData()),
        ),
      ],
      child: MaterialApp(
        locale: context.locale,
        supportedLocales: context.supportedLocales,
        localizationsDelegates: context.localizationDelegates,
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
          '/login': (context) => const LoginScreen(),
          '/main': (context) => const MainScreen(),
        },
      ),
    );
  }
}


