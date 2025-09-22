import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'car_bridge.dart';

const MethodChannel _channel = MethodChannel('ae.gov.moet.moethub/car');

class CarChannel {
  static bool _registered = false;

  static Future<void> register() async {
    if (_registered) return;
    _registered = true;

    _channel.setMethodCallHandler((call) async {
      if (call.method == 'checkIn') {
        // Native Auto path: just do a check-in (mood handled natively there)
        return await CarBridge.handleCheckIn(); // returns bool
      }
      return null;
    });
  }
}