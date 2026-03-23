/// 登陆
class LoginReqModel {
  /// 手机号
  final String phone;

  /// 密码
  final String password;

  /// IP地址
  final String ip;

  /// 客户端ID
  final String clientId;

  /// 发送令牌(可选)
  final String? sendToken;

  /// 短信验证码(可选)
  final String? smsCode;

  LoginReqModel({
    required this.phone,
    required this.password,
    required this.ip,
    required this.clientId,
    this.sendToken,
    this.smsCode,
  });

  /// 从LoginRequest实体创建模型
  factory LoginReqModel.fromEntity(LoginReqModel entity) {
    return LoginReqModel(
      phone: entity.phone,
      password: entity.password,
      ip: entity.ip,
      clientId: entity.clientId,
      sendToken: entity.sendToken,
      smsCode: entity.smsCode,
    );
  }

  Map<String, String?> toJson() {
    return {
      'phone': phone,
      'password': password,
      'ip': ip,
      'clientId': clientId,
      if (sendToken != null) 'sendToken': sendToken,
      if (smsCode != null) 'smsCode': smsCode,
    };
  }

  ///
  /// 将登录请求模型转换为查询参数Map
  ///
  Map<String, dynamic> toQueryParameters() {
    final params = {
      'phone': phone,
      'password': password,
      'ip': ip,
      'clientId': clientId,
    };

    if (sendToken != null) {
      params['sendtoken'] = sendToken!;
    }

    if (smsCode != null) {
      params['smscode'] = smsCode!;
    }

    return params;
  }
}

/// 校验短信
class ICheckSmsNewReqModel {
  final String phone;
  final String password;

  ICheckSmsNewReqModel({required this.phone, required this.password});

  factory ICheckSmsNewReqModel.fromEntity(ICheckSmsNewReqModel entity) {
    return ICheckSmsNewReqModel(phone: entity.phone, password: entity.password);
  }

  Map<String, String?> toJson() {
    return {'phone': phone, 'password': password};
  }

  Map<String, dynamic> toQueryParameters() {
    return {'phone': phone, 'password': password};
  }
}

/// 获取发送验证码的token
class IGetSendTokenReqModel {
  final String? phone;
  final String? clientId; // 设备id
  final String token; // 验证码token

  IGetSendTokenReqModel({
    required this.phone,
    required this.clientId,
    required this.token,
  });

  factory IGetSendTokenReqModel.fromEntity(IGetSendTokenReqModel entity) {
    return IGetSendTokenReqModel(
      phone: entity.phone,
      clientId: entity.clientId,
      token: entity.token,
    );
  }

  Map<String, dynamic> toQueryParameters() {
    final Map<String, dynamic> params = {'token': token};
    if (phone != null) {
      params['phone'] = phone;
    }
    if (clientId != null) {
      params['clientId'] = clientId;
    }
    return params;
  }
}

/// 获取发送验证码的token
class ISendLoginSmsReqModel {
  final String phone;
  final String clientId; // 设备id
  final String sendtoken; // 发送验证码的token
  final String password;

  ISendLoginSmsReqModel({
    required this.phone,
    required this.clientId,
    required this.sendtoken,
    required this.password,
  });

  factory ISendLoginSmsReqModel.fromEntity(ISendLoginSmsReqModel entity) {
    return ISendLoginSmsReqModel(
      phone: entity.phone,
      clientId: entity.clientId,
      sendtoken: entity.sendtoken,
      password: entity.password,
    );
  }

  Map<String, String?> toJson() {
    return {
      'phone': phone,
      'clientId': clientId,
      'sendtoken': sendtoken,
      'password': password,
    };
  }

  Map<String, dynamic> toQueryParameters() {
    return {
      'phone': phone,
      'clientId': clientId,
      'sendtoken': sendtoken,
      'password': password,
    };
  }
}

/// 重置密码
class IResetPwdReqModel {
  final String phone;
  final String sendtoken; // 发送验证码的token
  final String password;
  final String smscode;

  IResetPwdReqModel({
    required this.phone,
    required this.smscode,
    required this.sendtoken,
    required this.password,
  });

  factory IResetPwdReqModel.fromEntity(IResetPwdReqModel entity) {
    return IResetPwdReqModel(
      phone: entity.phone,
      smscode: entity.smscode,
      sendtoken: entity.sendtoken,
      password: entity.password,
    );
  }

  Map<String, dynamic> toQueryParameters() {
    return {
      'phone': phone,
      'smscode': smscode,
      'sendtoken': sendtoken,
      'password': password,
    };
  }
}

/// 短信验证码
class ISendCodeReqModel {
  final String phone;
  final String sendtoken; // 发送验证码的token
  final String purpose;

  ISendCodeReqModel({
    required this.phone,
    required this.purpose,
    required this.sendtoken,
  });

  factory ISendCodeReqModel.fromEntity(ISendCodeReqModel entity) {
    return ISendCodeReqModel(
      phone: entity.phone,
      purpose: entity.purpose,
      sendtoken: entity.sendtoken,
    );
  }

  Map<String, dynamic> toQueryParameters() {
    return {'phone': phone, 'purpose': purpose, 'sendtoken': sendtoken};
  }
}

/// 注册
class IRegisterReqModel {
  final String phone;
  final String smscode;
  final String sendtoken; // 发送验证码的token
  final String password;
  final String referral_code;
  final String channel;

  IRegisterReqModel({
    required this.phone,
    required this.smscode,
    required this.sendtoken,
    required this.password,
    required this.referral_code,
    required this.channel,
  });

  factory IRegisterReqModel.fromEntity(IRegisterReqModel entity) {
    return IRegisterReqModel(
      phone: entity.phone,
      smscode: entity.smscode,
      sendtoken: entity.sendtoken,
      password: entity.password,
      referral_code: entity.referral_code,
      channel: entity.channel,
    );
  }

  Map<String, dynamic> toQueryParameters() {
    return {
      'phone': phone,
      'smscode': smscode,
      'sendtoken': sendtoken,
      'password': password,
      'referral_code': referral_code,
      'channel': channel,
    };
  }
}
