import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'network/error_mapping_interceptor.dart';


@module
abstract class SharedModule {
  @preResolve
  Future<SharedPreferences> get prefs => SharedPreferences.getInstance();

  @preResolve
  @lazySingleton
  Future<Dio> get dio async {
    final sp = await prefs;
    final lang = sp.getString('langcode') ?? 'en-US';
    return Dio(
    BaseOptions(
      baseUrl: 'https://taapi.moec.gov.ae/api/lgt/',
      connectTimeout: const Duration(seconds: 5000),
      receiveTimeout: const Duration(seconds: 3000),
      contentType: 'application/json',
      queryParameters: {
        'langcode': lang,
      },
    ),
  )
    ..interceptors.add(ErrorMappingInterceptor());
  }
}
