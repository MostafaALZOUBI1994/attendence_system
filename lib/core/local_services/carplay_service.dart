// CarPlayService.dart
// Ensures CarPlay screen updates (especially in release) after mood selection and check-in,
// and shows short toasts for both flows.

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
  CarPlayService._(); // no instances

  static bool _initialized = false;
  static final FlutterCarplay _cp = FlutterCarplay();

  static _Screen _current = _Screen.unknown;
  static bool _busy = false;
  static Timer? _toastTimer;
  static const _moods = <String, String>{
    'Happy': '😀',
    'Neutral': '😐',
    'Sad': '😢',
    'Angry': '😡',
  };

  // ---------- Lifecycle ----------

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

    // If CarPlay is already connected when the app starts
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
      } else {
        // idempotent re-root to ensure UI refresh in release if needed
        await _setRoot(template: _buildMoodTemplate());
      }
      return;
    }

    // 2) Main
    if (_current != _Screen.main) {
      await _setRoot(template: _buildMainTemplate());
      _current = _Screen.main;
    } else {
      // Refresh info (last time / count) to avoid stale UI in release
      await _setRoot(template: _buildMainTemplate());
    }
  }

  // ---------- Helpers ----------

  static Future<bool> _isLoggedIn() async {
    try {
      final p = await getIt<EmployeeLocalDataSource>().getProfile();
      return p != null;
    } catch (_) {
      return false;
    }
  }

  /// Aggressive root replacement that helps some head units in release mode.
  static Future<void> _reroot(dynamic template) async {
    try {
      await FlutterCarplay.setRootTemplate(rootTemplate: template, animated: false);
      // tiny delay helps some head units in release
      await Future<void>.delayed(const Duration(milliseconds: 60));
      _cp.forceUpdateRootTemplate();
    } catch (_) {}
  }

  // Accept dynamic since plugin doesn't export a common CPTemplate base class
  static Future<void> _setRoot({required dynamic template}) async {
    await _reroot(template);
  }

  // Show a transient alert with message
  static Future<void> toast({
    required bool ok,
    required String message,
    Duration duration = const Duration(milliseconds: 1200), // short!
  }) async {
    // Kill any previous toast/timer first to avoid stacking
    _toastTimer?.cancel();
    try { await FlutterCarplay.popModal(animated: false); } catch (_) {}

    final alert = CPAlertTemplate(
      titleVariants: [message],
      actions: const [], // no OK button
    );

    // Show alert; if something is already presented, pop and retry once
    try {
      FlutterCarplay.showAlert(template: alert);
    } catch (_) {
      try {
        await FlutterCarplay.popModal(animated: false);
        FlutterCarplay.showAlert(template: alert);
      } catch (_) {}
    }

    // Auto-dismiss after a short delay
    _toastTimer = Timer(duration, () {
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
        // NOTE: If your flutter_carplay version expects (CPListItem item, int index, void Function() completion),
        // change the lambda accordingly and keep the body the same.
        onPress: (void Function() completion, CPListItem item) async {
          if (_busy) {
            completion();
            return;
          }
          _busy = true;

          try {
            final ok = await CarBridge.handleCheckInWithMood(e.key);
            await toast(ok: ok == true, message: ok == true ? 'Mood saved' : 'Failed to save mood');
            // move to main deterministically in release
            await sync();
          } catch (_) {
            await toast(ok: false, message: 'Error saving mood');
          } finally {
            completion();
            _busy = false;
          }
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
    final list = (local.getMillisList(checkIns) ?? const <int>[])..sort((a, b) => b.compareTo(a));

    final last = list.isNotEmpty
        ? DateFormat('hh:mm a').format(DateTime.fromMillisecondsSinceEpoch(list.first))
        : '--:--';

    return CPInformationTemplate(
      title: '',
      layout: CPInformationTemplateLayout.leading,
      informationItems: [
        CPInformationItem(title: '', detail: ''),
      ]..addAll([
        CPInformationItem(title: 'Last Check- in 🫆', detail: last),
      ]),
      actions: [
        CPTextButton(
          title: 'Check-in 🫆',
          onPress: () async {
            if (_busy) return;
            _busy = true;
            try {
              final ok = await CarBridge.handleCheckIn();
              await toast(ok: ok == true, message: ok == true ? 'Checked in' : 'Check-in failed');
              await sync();
            } catch (_) {
              await toast(ok: false, message: 'Error during check-in');
            } finally {
              _busy = false;
            }
          },
        ),
      ],
    );
  }

  // ---------- External triggers ----------

  /// Explicit screen switch callable from outside if needed.
  static Future<void> showAuthRequired() async {
    if (_current == _Screen.authRequired) return;
    await _setRoot(template: _buildAuthTemplate());
    _current = _Screen.authRequired;
  }
}

enum _Screen { unknown, authRequired, mood, main }