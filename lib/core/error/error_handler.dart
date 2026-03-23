import 'package:dio/dio.dart';
import 'exceptions.dart';

class ErrorHandler {
  static AppException handle(dynamic error) {
    if (error is AppException) {
      return error;
    }

    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return NetworkException('Request timed out', code: 'TIMEOUT');
        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          if (statusCode != null) {
            if (statusCode >= 400 && statusCode < 500) {
              return ServerException(
                'Client error: ${error.response?.statusMessage ?? "Unknown error"}',
                code: statusCode.toString(),
              );
            } else if (statusCode >= 500) {
              return ServerException(
                'Server error: ${error.response?.statusMessage ?? "Unknown error"}',
                code: statusCode.toString(),
              );
            }
          }
          return ServerException(
            error.response?.statusMessage ?? 'Server response error',
            code: error.response?.statusCode?.toString(),
          );
        case DioExceptionType.cancel:
          return NetworkException('Request cancelled', code: 'CANCELLED');
        case DioExceptionType.connectionError:
          return NetworkException(
            'Network connection error',
            code: 'CONNECTION_ERROR',
          );
        case DioExceptionType.badCertificate:
          return NetworkException(
            'Certificate verification failed',
            code: 'BAD_CERTIFICATE',
          );
        case DioExceptionType.unknown:
          return NetworkException(
            'Network request failed: ${error.message}',
            code: 'UNKNOWN',
          );
      }
    }

    return UnknownException(error.toString());
  }
}
