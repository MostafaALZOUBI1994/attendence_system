import 'dart:async';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
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
import 'core/utils/car_bridge.dart' hide getIt;
import 'core/utils/car_channel.dart' hide getIt;
import 'features/attendence/domain/repositories/attendence_repository.dart';
import 'features/attendence/presentation/bloc/attendence_bloc.dart';
import 'features/authentication/presentation/bloc/auth_bloc.dart';
import 'features/profile/presentation/bloc/profile_bloc.dart';
import 'firebase_options.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await configureDependencies();
  await EasyLocalization.ensureInitialized();

  await CarChannel.register();
  await _initFirebaseMessaging();
  if (Platform.isIOS) {
    await CarPlayService.init();
    CarPlayService.onCheckIn = CarBridge.handleCheckIn;
  }

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
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
}
@pragma('vm:entry-point')
Future<void> carEntryPoint() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  await CarChannel.register();
  await CarPlayService.init();
  CarPlayService.onCheckIn = CarBridge.handleCheckIn;
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Initialise Firebase in the background isolate before using other services
  await Firebase.initializeApp();
  // TODO: handle the background message (e.g. store it, update local DB, etc.)
}
Future<void> _initFirebaseMessaging() async {
  final messaging = FirebaseMessaging.instance;

  // Request permission on iOS (no-op on Android)
  await messaging.requestPermission(alert: true, badge: true, sound: true);

  // Allow foreground notification presentation on iOS
  await messaging.setForegroundNotificationPresentationOptions(
    alert: true, badge: true, sound: true,
  );



    final fcmToken = await messaging.getToken();
    if (fcmToken != null) {
      debugPrint('FCM token: $fcmToken');
      // TODO: send to your backend
    }
   else {
    // FCM token will be delivered via onTokenRefresh when ready
    messaging.onTokenRefresh.listen((newToken) {
      debugPrint('FCM token refreshed: $newToken');
      // TODO: send to your backend
    });
  }

  FirebaseMessaging.onMessage.listen((message) {
    debugPrint('Foreground message: ${message.messageId}');
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<ProfileBloc>()),
        BlocProvider(create: (_) => getIt<AuthBloc>()),
        BlocProvider(create: (_) => getIt<AttendenceBloc>()
          ..add(const AttendenceEvent.loadData())),
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


