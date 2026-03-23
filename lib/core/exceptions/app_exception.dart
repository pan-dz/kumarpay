/// 应用程序异常基类
///
/// 职责：
/// - 定义统一的异常处理机制
/// - 提供应用程序特定异常的基类
/// - 支持异常消息和错误码
///
/// 设计决策：
/// - 继承自Exception，符合Dart异常处理规范
/// - 包含message和code属性，提供详细错误信息
/// - 可扩展，允许创建特定类型的异常
class AppException implements Exception {
  /// 错误消息
  final String message;

  /// 错误代码
  final String? code;

  /// 构造函数
  const AppException(this.message, {this.code});

  @override
  String toString() =>
      'AppException: $message${code != null ? ' (Code: $code)' : ''}';
}

/// 网络异常
class NetworkException extends AppException {
  const NetworkException(String message, {String? code})
    : super(message, code: code);
}

/// 服务器异常
class ServerException extends AppException {
  const ServerException(String message, {String? code})
    : super(message, code: code);
}

/// 未知异常
class UnknownException extends AppException {
  const UnknownException(String message, {String? code})
    : super(message, code: code);
}
