import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';


@module
abstract class SharedModule {
  @preResolve
  Future<SharedPreferences> get prefs => SharedPreferences.getInstance();
  @lazySingleton
  Dio get dio => Dio(
    BaseOptions(
      baseUrl: 'https://taapi.moec.gov.ae/api/lgt/',
      connectTimeout: const Duration(seconds: 5000),
      receiveTimeout: const Duration(seconds: 3000),
      contentType: 'application/json',
    ),
  );
}
