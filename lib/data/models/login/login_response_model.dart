import '../api_response.dart';

/// 文件内通用解析助手（data 为空时给空串）
ApiResponse<String> _stringRespDefaultEmpty(Map<String, dynamic> json) {
  return ApiResponse.fromJsonGeneric<String>(
    json,
    (raw) => (raw is String) ? raw : (raw?.toString() ?? ''),
  );
}

/// 文件内通用解析助手（data 允许为 null）
ApiResponse<String> _stringRespNullable(Map<String, dynamic> json) {
  return ApiResponse.fromJsonGeneric<String>(
    json,
    (raw) => raw is String ? raw : raw?.toString(),
  );
}

class RegisterUserModel {
  final String username;

  const RegisterUserModel({required this.username});

  factory RegisterUserModel.fromJson(Map<String, dynamic> json) {
    final rawUsername =
        json['username'] ??
        json['userName'] ??
        json['phone'] ??
        json['account'];
    final username = rawUsername?.toString().trim() ?? '';
    return RegisterUserModel(username: username);
  }

  Map<String, dynamic> toJson() => {'username': username};
}

class LoginResModel extends ApiResponse<String> {
  const LoginResModel({required super.code, required super.msg, super.data});

  factory LoginResModel.fromJson(Map<String, dynamic> json) {
    final base = _stringRespDefaultEmpty(json);
    return LoginResModel(code: base.code, msg: base.msg ?? '', data: base.data);
  }

  ///
  /// 将登陆响应模型转换为JSON
  ///
  Map<String, dynamic> toJson() => {'code': code, 'msg': msg, 'data': data};
}

/// 校验是否验证码登陆 响应实体
class ICheckSmsNewResModel extends ApiResponse<String> {
  const ICheckSmsNewResModel({
    required super.code,
    required super.msg,
    super.data,
  });

  factory ICheckSmsNewResModel.fromJson(Map<String, dynamic> json) {
    final base = _stringRespDefaultEmpty(json);
    return ICheckSmsNewResModel(
      code: base.code,
      msg: base.msg ?? '',
      data: base.data,
    );
  }
}

/// 获取发送验证码的token 响应实体
class IGetSendTokenResModel extends ApiResponse<String> {
  const IGetSendTokenResModel({
    required super.code,
    required super.msg,
    super.data,
  });

  factory IGetSendTokenResModel.fromJson(Map<String, dynamic> json) {
    final base = _stringRespNullable(json);
    return IGetSendTokenResModel(
      code: base.code,
      msg: base.msg ?? '',
      data: base.data,
    );
  }
}

/// 发送登陆验证码 响应实体
class ISendLoginSmsResModel extends ApiResponse<String> {
  const ISendLoginSmsResModel({
    required super.code,
    required super.msg,
    super.data,
  });

  factory ISendLoginSmsResModel.fromJson(Map<String, dynamic> json) {
    final base = _stringRespNullable(json);
    return ISendLoginSmsResModel(
      code: base.code,
      msg: base.msg ?? '',
      data: base.data,
    );
  }
}

/// 重置密码 响应实体
class IResetPwdResModel extends ApiResponse<String> {
  const IResetPwdResModel({
    required super.code,
    required super.msg,
    super.data,
  });

  factory IResetPwdResModel.fromJson(Map<String, dynamic> json) {
    final base = _stringRespNullable(json);
    return IResetPwdResModel(
      code: base.code,
      msg: base.msg ?? '',
      data: base.data,
    );
  }
}

/// 发送登陆验证码 响应实体
class ISendSmsResModel extends ApiResponse<String> {
  const ISendSmsResModel({required super.code, required super.msg, super.data});

  factory ISendSmsResModel.fromJson(Map<String, dynamic> json) {
    final base = _stringRespNullable(json);
    return ISendSmsResModel(
      code: base.code,
      msg: base.msg ?? '',
      data: base.data,
    );
  }
}

/// 注册 响应实体
class IRegisterResModel extends ApiResponse<RegisterUserModel> {
  const IRegisterResModel({
    required super.code,
    required super.msg,
    super.data,
  });

  factory IRegisterResModel.fromJson(Map<String, dynamic> json) {
    final base = ApiResponse.fromJsonGeneric<RegisterUserModel>(json, (raw) {
      if (raw is Map<String, dynamic>) {
        return RegisterUserModel.fromJson(raw);
      }
      if (raw is String && raw.trim().isNotEmpty) {
        return RegisterUserModel(username: raw.trim());
      }
      return const RegisterUserModel(username: '');
    });
    return IRegisterResModel(
      code: base.code,
      msg: base.msg ?? '',
      data: base.data,
    );
  }
}
