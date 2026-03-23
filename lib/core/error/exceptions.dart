abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic details;

  AppException(this.message, {this.code, this.details});

  @override
  String toString() {
    return 'AppException{message: $message, code: $code}';
  }
}

class ServerException extends AppException {
  ServerException(super.message, {super.code, super.details});
}

class NetworkException extends AppException {
  NetworkException(super.message, {super.code, super.details});
}

class CacheException extends AppException {
  CacheException(super.message, {super.code, super.details});
}

class ValidationException extends AppException {
  ValidationException(super.message, {super.code, super.details});
}

class UnknownException extends AppException {
  UnknownException(super.message, {super.code, super.details});
}
