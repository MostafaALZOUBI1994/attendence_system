import 'package:moet_hub/core/constants/constants.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:moet_hub/core/utils/base64_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'local_services/local_services.dart';
import 'network/error_mapping_interceptor.dart';


@module
abstract class SharedModule {
  @preResolve
  Future<SharedPreferences> get prefs => SharedPreferences.getInstance();
}


@module
abstract class NetworkModule {
  @lazySingleton
  Dio dio(LocalService localService) {
    final langCode = localService.get(localeKey) == 'ar' ? 'ar-AE' : 'en-US';
    return Dio(BaseOptions(
      baseUrl: 'https://taapi.moec.gov.ae/api/lgt/',
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 3),
      contentType: 'application/json',
      queryParameters: {'langcode': langCode},
    ))..interceptors.add(ErrorMappingInterceptor());
  }
}

