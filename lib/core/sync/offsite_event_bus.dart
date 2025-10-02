import 'dart:async';

import 'package:injectable/injectable.dart';

import '../utils/car_channel.dart';

@LazySingleton()
class OffsiteEventBus {
  final _controller = StreamController<void>.broadcast();

  void notifyChanged() {
    if (!_controller.isClosed) _controller.add(null);
    CarChannel.notifyCarToResync(); // Phone -> Car refresh
  }

  Stream<void> get stream => _controller.stream;
  void dispose() => _controller.close();
}
