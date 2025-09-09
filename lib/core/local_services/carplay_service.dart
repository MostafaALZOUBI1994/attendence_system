// lib/core/local_services/carplay_service.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_carplay/flutter_carplay.dart';

class CarPlayService {
  /// Ensure we only register listeners once
  static bool _initialized = false;

  static final FlutterCarplay _cp = FlutterCarplay();
  static Future<bool> Function()? onCheckIn;

  static late CPInformationTemplate _root;
  static bool _rootWasPushed = false;
  static bool _modalActive = false;

  /// Initialise CarPlay. Safe to call multiple times thanks to the guard.
  static Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    _root = CPInformationTemplate(
      title: 'Check-in ',
      layout: CPInformationTemplateLayout.leading,
      informationItems: [
        CPInformationItem(title: 'Good', detail: 'morning ☀️'),
      ],
      actions: [
        CPTextButton(title: 'Check-in ✅', onPress: _handleCheckIn),
      ],
    );

    _cp.addListenerOnConnectionChange((status) {
      if (status == CPConnectionStatusTypes.connected) {
        _pushRoot(safe: true);
      } else {
        _rootWasPushed = false;
        _modalActive = false;
      }
    });

    await _bootstrapRootAttempts();
  }

  static void _pushRoot({bool safe = false}) {
    if (_rootWasPushed && safe) return;
    try {
      FlutterCarplay.setRootTemplate(rootTemplate: _root, animated: false);
      _rootWasPushed = true;
    } catch (_) {
      // ignore – will retry
    }
  }

  static Future<void> _bootstrapRootAttempts() async {
    const attempts = 10;
    const step = Duration(milliseconds: 250);
    for (var i = 0; i < attempts; i++) {
      _pushRoot(safe: false);
      await Future.delayed(step);
      if (_rootWasPushed) break;
    }
  }

  /// Called when the “Check‑in” button is pressed.
  static Future<void> _handleCheckIn() async {
    // Immediately mark modal active to debounce multiple taps
    if (_modalActive) return;
    _modalActive = true;

    bool success = false;
    try {
      if (onCheckIn != null) {
        success = await onCheckIn!.call();
      } else {
        debugPrint('CarPlayService.onCheckIn not set');
      }
    } catch (e, st) {
      debugPrint('CarPlay check-in error: $e\n$st');
      success = false;
    }

    final msg   = success ? 'Checked-in!'   : 'Check-in failed';
    final style = success ? CPAlertActionStyles.normal
        : CPAlertActionStyles.destructive;

    try { await FlutterCarplay.popModal(animated: false); } catch (_) {}

    final alert = CPAlertTemplate(
      titleVariants: [msg],
      actions: [
        CPAlertAction(
          title: 'OK',
          style: style,
          onPress: _dismissModal,
        ),
      ],
    );

    try {
      FlutterCarplay.showAlert(template: alert);
    } catch (_) {
      // If an alert is already showing, dismiss it first
      try {
        await FlutterCarplay.popModal(animated: false);
        FlutterCarplay.showAlert(template: alert);
      } catch (_) {}
    }

    Timer(const Duration(seconds: 2), _dismissModal);
  }

  static void _dismissModal() {
    if (!_modalActive) return;
    try {
      FlutterCarplay.popModal(animated: true);
    } catch (_) {}
    _modalActive = false;
  }
}
