import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_carplay/flutter_carplay.dart';

class CarPlayService {
  static final FlutterCarplay _cp = FlutterCarplay();

  static late CPInformationTemplate _root;
  static bool _rootSet = false;
  static bool _modalActive = false;

  /// Call once at startup (before runApp).
  static Future<void> init() async {
    _root = CPInformationTemplate(
      title: 'Check-in',
      layout: CPInformationTemplateLayout.leading,
      informationItems: [
        CPInformationItem(title: '\u200B', detail: '\u200B')
      ],
      actions: [
        CPTextButton(title: 'Check-in', onPress: _handleCheckIn),
      ],
    );

    // If CarPlay is already connected when app launches, set root immediately.
    try {
      final status = FlutterCarplay.connectionStatus;
      if (status == CPConnectionStatusTypes.connected) {
        _setRoot();
      }
    } catch (_) {
      // Some plugin versions don’t expose getConnectionStatus reliably.
      // Setting a small delayed attempt helps if a connection is racing.
      Future.delayed(const Duration(milliseconds: 300), _setRoot);
    }

    // Keep root in sync with future connections/disconnections.
    _cp.addListenerOnConnectionChange((s) {
      if (s == CPConnectionStatusTypes.connected) {
        _setRoot();
      } else {
        _rootSet = false;
        _modalActive = false;
      }
    });
  }

  static void _setRoot() {
    if (_rootSet) return;
    FlutterCarplay.setRootTemplate(rootTemplate: _root, animated: false);
    _rootSet = true;
  }

  /// Example async handler – replace body with your repository call.
  static Future<void> _handleCheckIn() async {
    if (!_rootSet) return; // don’t show modals before root exists
    if (_modalActive) return;

    // ---- Replace this with your real call (e.g., getIt<Repo>().checkIn()) ----
    final success = await _fakeCheckIn();
    final msg = success ? 'Checked-in!' : 'Check-in failed';
    final style = success ? CPAlertActionStyles.normal : CPAlertActionStyles.destructive;
    // -------------------------------------------------------------------------

    // Ensure any stale modal is closed.
    try {
      await FlutterCarplay.popModal(animated: false);
    } catch (_) {}

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
      _modalActive = true;
    } on PlatformException {
      // If a modal is already up, try to dismiss then show once.
      try {
        await FlutterCarplay.popModal(animated: false);
        FlutterCarplay.showAlert(template: alert);
        _modalActive = true;
      } catch (_) {}
    }

    // Auto-dismiss after 2 seconds as UX sugar.
    Timer(const Duration(seconds: 2), _dismissModal);
  }

  static void _dismissModal() {
    if (!_modalActive) return;
    try {
      FlutterCarplay.popModal(animated: true);
    } catch (_) {}
    _modalActive = false;
  }

  static Future<bool> _fakeCheckIn() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return true; // toggle to false to test error flow
  }
}