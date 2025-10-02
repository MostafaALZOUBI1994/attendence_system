import 'package:flutter/cupertino.dart';
import 'package:intl/date_symbol_data_local.dart' as intl_data;
import '../injection.dart';
import '../utils/car_channel.dart';

@pragma('vm:entry-point')
Future<void> carEntryPoint() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  await intl_data.initializeDateFormatting('en');
  await CarChannel.register();
}
