import 'dart:async';

import 'package:injectable/injectable.dart';

/// Broadcasts "off-site check-ins changed".
@LazySingleton()
class OffsiteEventBus {
  final _controller = StreamController<void>.broadcast();

  void notifyChanged() {
    if (!_controller.isClosed) _controller.add(null);
  }

  Stream<void> get stream => _controller.stream;

  void dispose() => _controller.close();
}