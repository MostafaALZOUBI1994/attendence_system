import 'package:dio/dio.dart';

class ApiService {
  final Dio dio;

  ApiService(this.dio);

  Future<Response> post(String url, Map<String, dynamic> data) async {
    return await dio.post(url, data: data);
  }
}