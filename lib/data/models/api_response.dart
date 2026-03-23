///
/// 通用响应实体 - Domain层
///
class ApiResponse<T> {
  final int code;
  final String? msg;
  final T? data;

  const ApiResponse({required this.code, this.msg = '', this.data});

  /// 是否成功（0 表示成功）
  bool get success => code == 0;

  /// 通用的 JSON 解析：兼容不同后端字段与类型
  static ApiResponse<T> fromJsonGeneric<T>(
    Map<String, dynamic> json,
    T? Function(Object? rawData) dataMapper,
  ) {
    int parseCode(dynamic raw) {
      if (raw is int) return raw;
      if (raw is num) return raw.toInt();
      final parsed = int.tryParse('$raw');
      return parsed ?? -1;
    }

    String parseMsg(Map<String, dynamic> map) {
      final m = map['msg'] ?? map['message'];
      return (m is String) ? m : (m?.toString() ?? '');
    }

    final code = parseCode(json['code']);
    final msg = parseMsg(json);
    final data = dataMapper(json['data']);

    return ApiResponse<T>(code: code, msg: msg, data: data);
  }
}
