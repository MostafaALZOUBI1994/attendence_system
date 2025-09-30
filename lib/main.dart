import 'dart:async';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:moet_hub/core/local_services/carplay_service.dart';
import 'package:moet_hub/features/authentication/presentation/pages/login_page.dart';
import 'package:moet_hub/features/reports/presentation/bloc/report_bloc.dart';
import 'package:moet_hub/features/services/presentation/bloc/services_bloc.dart';
import 'package:moet_hub/ui/screens/main_screen.dart';
import 'package:moet_hub/ui/screens/splash_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/constants/constants.dart';
import 'core/injection.dart';
import 'core/local_services/local_services.dart';
import 'core/utils/car_channel.dart';
import 'features/attendence/presentation/bloc/attendence_bloc.dart';
import 'features/authentication/presentation/bloc/auth_bloc.dart';
import 'features/mood/presentation/bloc/mood_bloc.dart';
import 'features/profile/presentation/bloc/profile_bloc.dart';
import 'firebase_options.dart';
import 'core/local_services/car_entry.dart' as car;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await configureDependencies(); // OK: fast
  await EasyLocalization.ensureInitialized(); // OK: needed before runApp

  // ✅ Do NOT wait for Firebase Messaging / APNs before runApp
  // Initialize Firebase core only (fast)
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  final savedLocale = getIt<LocalService>().getSavedLocale();
  Intl.defaultLocale = savedLocale.languageCode;

  runApp(
    EasyLocalization(
      useOnlyLangCode: true,
      supportedLocales: const [Locale('en'), Locale('ar')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      startLocale: savedLocale,
      child: const MyApp(),
    ),
  );

  // ✅ Kick off slower stuff AFTER the first frame (non-blocking)
  //   (don’t await; let UI show immediately)
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _initFirebaseMessagingNonInteractive(); // no await
  });
}

@pragma('vm:entry-point')
Future<void> carEntryPoint() => car.carEntryPoint();

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Initialise Firebase in the background isolate before using other services
  await Firebase.initializeApp();
  // TODO: handle the background message (e.g. store it, update local DB, etc.)
  // In background isolates, Firebase might not be initialized yet:
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
}


Future<void> _initFirebaseMessagingNonInteractive() async {
  final m = FirebaseMessaging.instance;
  await m.setAutoInitEnabled(true);
  // ignore: discarded_futures
  m.getToken().then((t){ if (t != null) debugPrint('FCM token: $t'); })
      .catchError((e){ debugPrint('getToken error: $e'); });
  m.onTokenRefresh.listen((t) => debugPrint('FCM token refreshed: $t'));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  void initState() {
    super.initState();
    // ⬇️ Defer to after first frame (and off the build path)
    WidgetsBinding.instance.addPostFrameCallback((_) => _initCarPlay());
  }

  Future<void> _initCarPlay() async {
    try {
      if (Platform.isIOS) {
        await CarPlayService.init();   // keep idempotent
        await CarChannel.register();
      }
    } catch (e) {
      debugPrint('CarPlay init skipped: $e');
    }
  }
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<ProfileBloc>()),
        BlocProvider(create: (_) => getIt<AuthBloc>()),
        BlocProvider(create: (_) => getIt<AttendenceBloc>()),
        BlocProvider(create: (_) => getIt<MoodBloc>()),
        BlocProvider(create: (_) => getIt<ReportBloc>()),
        BlocProvider(create: (_) => getIt<ServicesBloc>()
          ..add(const ServicesEvent.loadData())),
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
        ),
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        routes: {
          '/':      (_) => const SplashScreen(),
          '/login': (_) => const LoginScreen(),
          '/main':  (_) => const MainScreen(),
        },
      ),
    );
  }
}
