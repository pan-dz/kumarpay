import 'dart:convert';

/// UPI详情
class IGetUpiDetailReqModel {
  final String name;

  IGetUpiDetailReqModel({required this.name});

  Map<String, dynamic> toQueryParameters() {
    return {'name': name};
  }
}

/// 监控第一步
class IGetMonitorflowOneReqModel {
  final String ctType;
  final String account;
  final String pnname;
  final String pin;
  final String ctId;
  final String deviceId;

  IGetMonitorflowOneReqModel({
    required this.ctType,
    required this.account,
    required this.pnname,
    required this.pin,
    required this.ctId,
    required this.deviceId,
  });

  Map<String, String?> toJson() {
    return {
      'ct_type': ctType,
      'account': account,
      'pnname': pnname,
      'pin': pin,
      'ct_id': ctId,
      'deviceId': deviceId,
    };
  }

  Map<String, dynamic> toQueryParameters() {
    return {
      'ct_type': ctType,
      'account': account,
      'pnname': pnname,
      'pin': pin,
      'ct_id': ctId,
      'deviceId': deviceId,
    };
  }
}

/// 监控第二步
class IGetMonitorflowTwoReqModel {
  final String ctType;
  final String pk;
  final String deviceId;

  IGetMonitorflowTwoReqModel({
    required this.ctType,
    required this.pk,
    required this.deviceId,
  });

  Map<String, String?> toJson() {
    return {'ct_type': ctType, 'pk': pk, 'deviceId': deviceId};
  }

  Map<String, dynamic> toQueryParameters() {
    return {'ct_type': ctType, 'pk': pk, 'deviceId': deviceId};
  }
}

/// 监控第三步
class IGetMonitorflowThreeReqModel {
  final String ctType;
  final String pk;
  final String account;
  final Map<String, dynamic> loginParams;

  IGetMonitorflowThreeReqModel({
    required this.ctType,
    required this.pk,
    required this.account,
    required this.loginParams,
  });

  Map<String, String?> toJson() {
    return {
      'ct_type': ctType,
      'pk': pk,
      'account': account,
      'login_params': loginParams.isNotEmpty ? jsonEncode(loginParams) : null,
    };
  }

  Map<String, dynamic> toQueryParameters() {
    return {
      'ct_type': ctType,
      'pk': pk,
      'account': account,
      'login_params': loginParams,
    };
  }
}

/// 监控检查
class IGetMonitorflowTCheckReqModel {
  final String ctType;
  final String account;
  final String ctId;

  IGetMonitorflowTCheckReqModel({
    required this.ctType,
    required this.account,
    required this.ctId,
  });

  Map<String, String?> toJson() {
    return {'ct_type': ctType, 'account': account, 'ct_id': ctId};
  }

  Map<String, dynamic> toQueryParameters() {
    return {'ct_type': ctType, 'account': account, 'ct_id': ctId};
  }
}

/// 获取监控结果
class IGetCheckResultReqModel {
  final String ctType;
  final String account;
  final String ctId;
  final String pk;

  IGetCheckResultReqModel({
    required this.ctType,
    required this.account,
    required this.ctId,
    required this.pk,
  });

  Map<String, String?> toJson() {
    return {'ct_type': ctType, 'account': account, 'ct_id': ctId, 'pk': pk};
  }

  Map<String, dynamic> toQueryParameters() {
    return {'ct_type': ctType, 'account': account, 'ct_id': ctId, 'pk': pk};
  }
}

/// 绑定UPI
class IAddUpiReqModel {
  final String upi;
  final String pnname;
  final String id;
  IAddUpiReqModel({required this.upi, required this.pnname, required this.id});

  Map<String, String?> toJson() {
    return {'upi': upi, 'pnname': pnname, 'id': id};
  }

  Map<String, dynamic> toQueryParameters() {
    return {'upi': upi, 'pnname': pnname, 'id': id};
  }
}

/// 更新UPI状态
class IUpdateUpiStatusReqModel {
  final String id;
  final int status;

  IUpdateUpiStatusReqModel({required this.id, required this.status});

  Map<String, String?> toJson() {
    return {'id': id, 'status': status.toString()};
  }
}

/// 停止出售UPI
class IStopSellReqModel {
  final String ctId;

  IStopSellReqModel({required this.ctId});

  Map<String, String?> toJson() {
    return {'ct_id': ctId};
  }
}

/// 开始出售UPI
class IStartSellReqModel {
  final String ctId;

  IStartSellReqModel({required this.ctId});

  Map<String, String?> toJson() {
    return {'ct_id': ctId};
  }
}

/// 获取UPI详情（按ID）
class IGetUpiDetailsReqModel {
  final String id;

  IGetUpiDetailsReqModel({required this.id});
}
