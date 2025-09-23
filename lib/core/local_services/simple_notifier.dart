import 'dart:io';
import 'package:intl/intl.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzdata;

class UaeShiftNotifier {
  static final FlutterLocalNotificationsPlugin _plugin =
  FlutterLocalNotificationsPlugin();

  // --- remove _inited; use a shared Future instead
  static Future<void>? _initFuture;

  // late final is fine once we guarantee single initialization
  static late final tz.Location _dubai;
  static const int _notifId = 1001;

  static const AndroidNotificationDetails _androidDetails =
  AndroidNotificationDetails(
    'shift_end_channel',
    'Shift End',
    channelDescription: 'Reminder to finish work',
    importance: Importance.max,
    priority: Priority.high,
  );

  static const DarwinNotificationDetails _iosDetails =
  DarwinNotificationDetails();

  static const NotificationDetails _details =
  NotificationDetails(android: _androidDetails, iOS: _iosDetails);

  // Run init exactly once, even if called concurrently.
  static Future<void> _ensureInit() =>
      _initFuture ??= _doInit(); // <-- single-flight

  static Future<void> _doInit() async {
    // Time zone setup
    tzdata.initializeTimeZones(); // idempotent
    _dubai = tz.getLocation('Asia/Dubai');

    const init = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      ),
    );
    await _plugin.initialize(init);

    if (Platform.isAndroid) {
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      await android?.requestNotificationsPermission();
    }
  }


  static Future<bool> scheduleTodayUae(String expectedOutTime) async {
    await _ensureInit();

    // Parse strictly in English
    final parsed = DateFormat('hh:mm a', 'en').parse(expectedOutTime.trim());

    final nowDubai = tz.TZDateTime.now(_dubai);
    final targetDubai = tz.TZDateTime(
      _dubai, nowDubai.year, nowDubai.month, nowDubai.day, parsed.hour, parsed.minute,
    );

    // Today only — if already passed, cancel any existing and skip
    if (!targetDubai.isAfter(nowDubai)) {
      await _plugin.cancel(_notifId);
      return false;
    }

    // Replace any previous pending one
    await _plugin.cancel(_notifId);

    await _plugin.zonedSchedule(
      _notifId,
      'حان وقت الانصراف',
      'يعطيك العافية.. ما قصرت',
      targetDubai,
      _details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: null, // one-shot
      payload: 'shift_end',
    );
    return true;
  }

  static Future<void> cancel() => _plugin.cancel(_notifId);
}