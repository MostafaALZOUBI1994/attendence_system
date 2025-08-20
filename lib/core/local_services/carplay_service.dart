// lib/services/carplay_service.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_carplay/flutter_carplay.dart';

class CarPlayService {
  static final FlutterCarplay _cp = FlutterCarplay();
  static Future<bool> Function()? onCheckIn;

  static late CPInformationTemplate _root;
  static bool _rootWasPushed = false;
  static bool _modalActive = false;

  static Future<void> init() async {
    _root = CPInformationTemplate(
      title: 'Check-in 🚗',
      layout: CPInformationTemplateLayout.leading,
      informationItems: [CPInformationItem(title: 'Good', detail: 'morning ☀️')],
      actions: [CPTextButton(title: 'Check-in ✅', onPress: _handleCheckIn)],
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
    } catch (_) {}
  }

  static Future<void> _bootstrapRootAttempts() async {
    for (var i = 0; i < 10; i++) {
      _pushRoot(safe: false);
      await Future.delayed(const Duration(milliseconds: 250));
      if (_rootWasPushed) break;
    }
  }

  static Future<void> _handleCheckIn() async {
    if (_modalActive) return;
    bool success = false;
    try {
      if (onCheckIn != null) success = await onCheckIn!.call();
    } catch (_) { success = false; }

    final msg = success ? 'Checked-in!' : 'Check-in failed';
    final style = success ? CPAlertActionStyles.normal : CPAlertActionStyles.destructive;

    try { await FlutterCarplay.popModal(animated: false); } catch (_) {}

    final alert = CPAlertTemplate(
      titleVariants: [msg],
      actions: [CPAlertAction(title: 'OK', style: style, onPress: _dismissModal)],
    );

    try {
      FlutterCarplay.showAlert(template: alert);
      _modalActive = true;
    } catch (_) {
      try {
        await FlutterCarplay.popModal(animated: false);
        FlutterCarplay.showAlert(template: alert);
        _modalActive = true;
      } catch (_) {}
    }

    Timer(const Duration(seconds: 2), _dismissModal);
  }

  static void _dismissModal() {
    if (!_modalActive) return;
    try { FlutterCarplay.popModal(animated: true); } catch (_) {}
    _modalActive = false;
  }
}
