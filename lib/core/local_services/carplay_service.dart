import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_carplay/flutter_carplay.dart';
import 'package:intl/intl.dart';
import '../utils/car_bridge.dart';
import '../injection.dart';
import '../local_services/local_services.dart';
import '../constants/constants.dart';
import 'package:moet_hub/features/authentication/data/datasources/employee_local_data_source.dart';

class CarPlayService {
  static bool _initialized = false;
  static final FlutterCarplay _cp = FlutterCarplay();

  static _Screen _current = _Screen.unknown;
  static bool _busy = false;

  static const _moods = <String, String>{
    'Happy':  '😀',
    'Neutral':'😐',
    'Sad':    '😢',
    'Angry':  '😡',
  };

  static Future<bool> _isLoggedIn() async {
    try {
      final p = await getIt<EmployeeLocalDataSource>().getProfile();
      return p != null;
    } catch (_) {
      return false;
    }
  }

  static Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    _cp.addListenerOnConnectionChange((status) async {
      if (status == CPConnectionStatusTypes.connected) {
        await sync();
      } else {
        _current = _Screen.unknown;
        _busy = false;
      }
    });

    // If CarPlay already connected when app starts
    await sync();
  }

  /// Public: make CarPlay mirror app state.
  static Future<void> sync() async {
    // 0) Not logged in → AuthRequired
    if (!await _isLoggedIn()) {
      if (_current != _Screen.authRequired) {
        await _setRoot(template: _buildAuthTemplate());
        _current = _Screen.authRequired;
      }
      return;
    }

    // 1) Mood first?
    final needMood = CarBridge.needMoodToday();
    if (needMood) {
      if (_current != _Screen.mood) {
        await _setRoot(template: _buildMoodTemplate());
        _current = _Screen.mood;
      }
      return;
    }

    // 2) Main
    if (_current != _Screen.main) {
      await _setRoot(template: _buildMainTemplate());
      _current = _Screen.main;
    } else {
      // refresh info (last time / count)
      try {
        await _setRoot(template: _buildMainTemplate());
      } catch (_) {

      }
    }
  }

  // Show a transient alert with message
  static Future<void> toast({required bool ok, required String message}) async {
    final style = ok ? CPAlertActionStyles.normal : CPAlertActionStyles.destructive;
    final alert = CPAlertTemplate(
      titleVariants: [message],
      actions: [
        CPAlertAction(
          title: 'OK',
          style: style,
          onPress: () {
            try { FlutterCarplay.popModal(animated: true); } catch (_) {}
          },
        ),
      ],
    );

    try {
      FlutterCarplay.showAlert(template: alert);
    } catch (_) {
      try {
        await FlutterCarplay.popModal(animated: false);
        FlutterCarplay.showAlert(template: alert);
      } catch (_) {}
    }

    Timer(const Duration(seconds: 2), () {
      try { FlutterCarplay.popModal(animated: true); } catch (_) {}
    });
  }

  // ---------- Templates ----------

  static CPInformationTemplate _buildAuthTemplate() {
    return CPInformationTemplate(
      title: 'Sign in required',
      layout: CPInformationTemplateLayout.leading,
      informationItems: [
        CPInformationItem(title: 'Open app', detail: 'Please sign in on your phone'),
      ],
      actions: const [], // no actions while locked out
    );
  }

  static CPListTemplate _buildMoodTemplate() {
    final items = _moods.entries.map((e) {
      final label = '${e.value} ${e.key}';
      return CPListItem(
        text: label,
        // Depending on your flutter_carplay version, you may need (item, index)
        onPress: (void Function() completion, CPListItem item) async {
          if (_busy) { completion(); return; }
          _busy = true;
          try {
            final ok = await CarBridge.handleCheckInWithMood(e.key);
            // CarBridge will call toast() and sync() already
          } catch (_) {}
          completion();
          _busy = false;
        },
      );
    }).toList();

    return CPListTemplate(
      title: 'Select Mood',
      sections: [CPListSection(items: items)], systemIcon: '',
    );
  }

  static CPInformationTemplate _buildMainTemplate() {
    final local = getIt<LocalService>();
    final list = (local.getMillisList(checkIns) ?? const <int>[])
      ..sort((a, b) => b.compareTo(a));

    final last = list.isNotEmpty
        ? DateFormat('hh:mm a').format(DateTime.fromMillisecondsSinceEpoch(list.first))
        : '--:--';

    return CPInformationTemplate(
      title: '',
      layout: CPInformationTemplateLayout.leading,
      informationItems: [
        CPInformationItem(title: '',  detail: ""),
        CPInformationItem(title: 'Last Check- in 🫆',  detail: last),
        // CPInformationItem(title: 'Count', detail: list.length.toString()),
      ],
      actions: [
        CPTextButton(
          title: 'Check-in 🫆',
          onPress: () async {
            if (_busy) return;
            _busy = true;
            try {
              final ok = await CarBridge.handleCheckIn();
              // CarBridge will call toast() + sync()
            } catch (_) {}
            _busy = false;
          },
        ),
      ],
    );
  }

  // Accept dynamic since plugin doesn't export a CPTemplate base class
  static Future<void> _setRoot({required dynamic template}) async {
    try {
      await FlutterCarplay.setRootTemplate(rootTemplate: template, animated: false);
      _cp.forceUpdateRootTemplate();
    } catch (_) {}
  }

  // explicit screen enum to avoid loops
  static Future<void> showAuthRequired() async {
    if (_current == _Screen.authRequired) return;
    await _setRoot(template: _buildAuthTemplate());
    _current = _Screen.authRequired;
  }
}

enum _Screen { unknown, authRequired, mood, main }