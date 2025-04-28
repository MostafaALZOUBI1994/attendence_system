import 'package:dio/dio.dart';
import '../errors/failures.dart';

class ErrorMappingInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    String message;
    switch (err.type) {
      case DioExceptionType.connectionError:
        message = 'Could not reach the server. Please check your internet connection.';
        break;
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        message = 'The request timed out. Please try again.';
        break;
      case DioExceptionType.badResponse:
        message = 'Server responded with an error. Please try again later.';
        break;
      default:
        message = 'Something went wrong. Please try again.';
    }
    handler.next(
      DioException(
        requestOptions: err.requestOptions,
        error: ServerFailure(message),
        type: err.type,
        response: err.response,
      ),
    );
  }
}
