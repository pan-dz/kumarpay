import 'dart:convert';

import 'package:kumar_pay/data/models/api_response.dart';
import 'package:kumar_pay/core/utils/json_conv.dart';

typedef UpiListData = List<UpiInfoModel>;
typedef BuyUpiListData = List<UpiInfoModel>;

int? _asNullableInt(Object? v) {
  if (v == null) return null;
  return asInt(v);
}

Map<String, dynamic> _asMap(Object? raw) {
  if (raw is Map<String, dynamic>) return raw;
  if (raw is String && raw.trim().isNotEmpty) {
    try {
      final decoded = json.decode(raw);
      if (decoded is Map<String, dynamic>) return decoded;
    } catch (_) {}
  }
  return <String, dynamic>{};
}

List<String> _asStringList(Object? raw) {
  if (raw is List) {
    return raw.map((e) => e.toString()).toList();
  }
  if (raw is String && raw.trim().isNotEmpty) {
    try {
      final decoded = json.decode(raw);
      if (decoded is List) {
        return decoded.map((e) => e.toString()).toList();
      }
    } catch (_) {
      return [raw];
    }
  }
  return <String>[];
}

/// UPI 账户信息
class UpiInfoModel {
  final int ctType;
  final String account;
  final String upi;
  final String username;
  final num allocationQuota;
  final int userIsActive;
  final int inSell;
  final int userSell;
  final int state;
  final int status;
  final String pnname;
  final int? lastReceivingTime;
  final int id;
  final num accountBalance;
  final List<String> backupUpi;
  final int crtDate;
  final int? lastDisabledTime;
  final int? lastLockTime;
  final int lockTimes;
  final int lockedTime;
  final Map<String, dynamic> loginParams;
  final int uptDate;
  final int priority;
  final int receiving;
  final String statusRemark;
  final int secLimit;
  final int nextLockedTime;
  final int upiMaxReceiveCnt;
  final int onlyPaymentFlag;
  final int lastDisconnectDate;
  final int minSellIToken;

  const UpiInfoModel({
    required this.ctType,
    required this.account,
    required this.upi,
    required this.username,
    required this.allocationQuota,
    required this.userIsActive,
    required this.inSell,
    required this.userSell,
    required this.state,
    required this.status,
    required this.pnname,
    required this.lastReceivingTime,
    required this.id,
    required this.accountBalance,
    required this.backupUpi,
    required this.crtDate,
    required this.lastDisabledTime,
    required this.lastLockTime,
    required this.lockTimes,
    required this.lockedTime,
    required this.loginParams,
    required this.uptDate,
    required this.priority,
    required this.receiving,
    required this.statusRemark,
    required this.secLimit,
    required this.nextLockedTime,
    required this.upiMaxReceiveCnt,
    required this.onlyPaymentFlag,
    required this.lastDisconnectDate,
    required this.minSellIToken,
  });

  factory UpiInfoModel.fromJson(Map<String, dynamic> json) {
    return UpiInfoModel(
      ctType: asInt(json['ctType']),
      account: asString(json['account']),
      upi: asString(json['upi']),
      username: asString(json['username']),
      allocationQuota: asNum(json['allocationQuota']),
      userIsActive: asInt(json['userIsActive']),
      inSell: asInt(json['inSell']),
      userSell: asInt(json['userSell']),
      state: asInt(json['state']),
      status: asInt(json['status']),
      pnname: asString(json['pnname']),
      lastReceivingTime: _asNullableInt(json['lastReceivingTime']),
      id: asInt(json['id']),
      accountBalance: asNum(json['accountBalance']),
      backupUpi: _asStringList(json['backupUpi']),
      crtDate: asInt(json['crtDate']),
      lastDisabledTime: _asNullableInt(json['lastDisabledTime']),
      lastLockTime: _asNullableInt(json['lastLockTime']),
      lockTimes: asInt(json['lockTimes']),
      lockedTime: asInt(json['lockedTime']),
      loginParams: _asMap(json['loginParams']),
      uptDate: asInt(json['uptDate']),
      priority: asInt(json['priority']),
      receiving: asInt(json['receiving']),
      statusRemark: asString(json['statusRemark']),
      secLimit: asInt(json['secLimit']),
      nextLockedTime: asInt(json['nextLockedTime']),
      upiMaxReceiveCnt: asInt(json['upiMaxReceiveCnt']),
      onlyPaymentFlag: asInt(json['onlyPaymentFlag']),
      lastDisconnectDate: asInt(json['lastDisconnectDate']),
      minSellIToken: asInt(json['minSellIToken']),
    );
  }
}

/// 获取UPI列表
class IGetUpiListResModel extends ApiResponse<UpiListData> {
  const IGetUpiListResModel({
    required super.code,
    required super.msg,
    super.data,
  });

  factory IGetUpiListResModel.fromJson(Map<String, dynamic> json) {
    final base = ApiResponse.fromJsonGeneric<UpiListData>(json, (raw) {
      if (raw is List) {
        return raw
            .whereType<Map<String, dynamic>>()
            .map((e) => UpiInfoModel.fromJson(e))
            .toList();
      }
      return <UpiInfoModel>[];
    });
    return IGetUpiListResModel(code: base.code, msg: base.msg, data: base.data);
  }
}

/// 获取购买UPI列表
class IGetBuyUpiListResModel extends ApiResponse<BuyUpiListData> {
  const IGetBuyUpiListResModel({
    required super.code,
    required super.msg,
    super.data,
  });

  factory IGetBuyUpiListResModel.fromJson(Object? json) {
    if (json is List) {
      final data = json
          .whereType<Map<String, dynamic>>()
          .map(UpiInfoModel.fromJson)
          .toList();
      return IGetBuyUpiListResModel(code: 0, msg: '', data: data);
    }
    if (json is Map<String, dynamic>) {
      final base = ApiResponse.fromJsonGeneric<BuyUpiListData>(json, (raw) {
        if (raw is List) {
          return raw
              .whereType<Map<String, dynamic>>()
              .map((e) => UpiInfoModel.fromJson(e))
              .toList();
        }
        return <UpiInfoModel>[];
      });
      return IGetBuyUpiListResModel(
        code: base.code,
        msg: base.msg,
        data: base.data,
      );
    }
    return const IGetBuyUpiListResModel(
      code: -1,
      msg: 'Invalid response format',
      data: <UpiInfoModel>[],
    );
  }
}

/// 获取UPI详情
class UpiOrderModel {
  final String rptNo;
  final int orderState;
  final int uptDate;

  const UpiOrderModel({
    required this.rptNo,
    required this.orderState,
    required this.uptDate,
  });

  factory UpiOrderModel.fromJson(Map<String, dynamic> json) {
    return UpiOrderModel(
      rptNo: asString(json['rptNo']),
      orderState: asInt(json['orderState']),
      uptDate: asInt(json['uptDate']),
    );
  }
}

class UpiDetailData {
  final UpiInfoModel? vo;
  final List<UpiOrderModel> orders;

  const UpiDetailData({this.vo, this.orders = const []});

  factory UpiDetailData.fromJson(Map<String, dynamic> json) {
    final voRaw = json['vo'];
    final vo = voRaw is Map<String, dynamic>
        ? UpiInfoModel.fromJson(voRaw)
        : null;

    final ordersRaw = json['orders'];
    final orders = (ordersRaw is List)
        ? ordersRaw
              .whereType<Map<String, dynamic>>()
              .map(UpiOrderModel.fromJson)
              .toList()
        : <UpiOrderModel>[];

    return UpiDetailData(vo: vo, orders: orders);
  }
}

class IGetUpiDetailResModel extends ApiResponse<UpiDetailData> {
  const IGetUpiDetailResModel({
    required super.code,
    required super.msg,
    super.data,
  });

  factory IGetUpiDetailResModel.fromJson(Map<String, dynamic> json) {
    final base = ApiResponse.fromJsonGeneric<UpiDetailData>(json, (raw) {
      if (raw is Map<String, dynamic>) {
        return UpiDetailData.fromJson(raw);
      }
      return const UpiDetailData();
    });
    return IGetUpiDetailResModel(
      code: base.code,
      msg: base.msg,
      data: base.data,
    );
  }
}

/// 获取UPI详情（按ID）
class IGetUpiDetailsResModel extends ApiResponse<UpiInfoModel> {
  const IGetUpiDetailsResModel({
    required super.code,
    required super.msg,
    super.data,
  });

  factory IGetUpiDetailsResModel.fromJson(Map<String, dynamic> json) {
    final base = ApiResponse.fromJsonGeneric<UpiInfoModel>(
      json,
      (raw) => raw is Map<String, dynamic> ? UpiInfoModel.fromJson(raw) : null,
    );
    return IGetUpiDetailsResModel(
      code: base.code,
      msg: base.msg,
      data: base.data,
    );
  }
}

/// 更新UPI状态
class IUpdateUpiStatusResModel extends ApiResponse<bool> {
  const IUpdateUpiStatusResModel({
    required super.code,
    required super.msg,
    super.data,
  });

  factory IUpdateUpiStatusResModel.fromJson(Map<String, dynamic> json) {
    final base = ApiResponse.fromJsonGeneric<bool>(json, (raw) {
      if (raw is bool) return raw;
      if (raw is num) return raw.toInt() == 1;
      if (raw is String) {
        final v = raw.toLowerCase();
        if (v == 'true' || v == '1') return true;
        if (v == 'false' || v == '0') return false;
      }
      return false;
    });
    return IUpdateUpiStatusResModel(
      code: base.code,
      msg: base.msg,
      data: base.data,
    );
  }
}

/// 停止出售UPI
class IStopSellResModel extends ApiResponse<bool> {
  const IStopSellResModel({
    required super.code,
    required super.msg,
    super.data,
  });

  factory IStopSellResModel.fromJson(Map<String, dynamic> json) {
    final base = ApiResponse.fromJsonGeneric<bool>(json, (raw) {
      if (raw is bool) return raw;
      if (raw is num) return raw.toInt() == 1;
      if (raw is String) {
        final v = raw.toLowerCase();
        if (v == 'true' || v == '1') return true;
        if (v == 'false' || v == '0') return false;
      }
      return false;
    });
    return IStopSellResModel(code: base.code, msg: base.msg, data: base.data);
  }
}

/// 开始出售UPI
class IStartSellResModel extends ApiResponse<bool> {
  const IStartSellResModel({
    required super.code,
    required super.msg,
    super.data,
  });

  factory IStartSellResModel.fromJson(Map<String, dynamic> json) {
    final base = ApiResponse.fromJsonGeneric<bool>(json, (raw) {
      if (raw is bool) return raw;
      if (raw is num) return raw.toInt() == 1;
      if (raw is String) {
        final v = raw.toLowerCase();
        if (v == 'true' || v == '1') return true;
        if (v == 'false' || v == '0') return false;
      }
      return false;
    });
    return IStartSellResModel(code: base.code, msg: base.msg, data: base.data);
  }
}

/// 监控第一步
class IGetMonitorflowOneModel {
  final String pk;
  const IGetMonitorflowOneModel({required this.pk});

  factory IGetMonitorflowOneModel.fromJson(Map<String, dynamic> json) {
    return IGetMonitorflowOneModel(pk: asString(json['pk']));
  }
}

class IGetMonitorflowOneResModel extends ApiResponse<IGetMonitorflowOneModel> {
  const IGetMonitorflowOneResModel({
    required super.code,
    required super.msg,
    super.data,
  });

  factory IGetMonitorflowOneResModel.fromJson(Map<String, dynamic> json) {
    final base = ApiResponse.fromJsonGeneric<IGetMonitorflowOneModel>(json, (
      raw,
    ) {
      if (raw is Map<String, dynamic>) {
        return IGetMonitorflowOneModel.fromJson(raw);
      }
      return const IGetMonitorflowOneModel(pk: '');
    });
    return IGetMonitorflowOneResModel(
      code: base.code,
      msg: base.msg,
      data: base.data,
    );
  }
}

/// 监控第二步
class IGetMonitorflowTwoResModel extends ApiResponse<String> {
  const IGetMonitorflowTwoResModel({
    required super.code,
    required super.msg,
    super.data,
  });

  factory IGetMonitorflowTwoResModel.fromJson(Map<String, dynamic> json) {
    final base = ApiResponse.fromJsonGeneric<String>(json, (raw) {
      return (raw is String) ? raw : (raw?.toString() ?? '');
    });
    return IGetMonitorflowTwoResModel(
      code: base.code,
      msg: base.msg,
      data: base.data,
    );
  }
}

/// 监控检查
class IGetMonitorflowCheckModel {
  final List<String> backupUpi;
  final String id;

  const IGetMonitorflowCheckModel({required this.backupUpi, required this.id});

  factory IGetMonitorflowCheckModel.fromJson(Map<String, dynamic> json) {
    return IGetMonitorflowCheckModel(
      backupUpi: _asStringList(json['backup_upi']),
      id: asString(json['id']),
    );
  }
}

class IGetMonitorflowCheckResModel
    extends ApiResponse<IGetMonitorflowCheckModel> {
  const IGetMonitorflowCheckResModel({
    required super.code,
    required super.msg,
    super.data,
  });

  factory IGetMonitorflowCheckResModel.fromJson(Map<String, dynamic> json) {
    final base = ApiResponse.fromJsonGeneric<IGetMonitorflowCheckModel>(json, (
      raw,
    ) {
      if (raw is Map<String, dynamic>) {
        return IGetMonitorflowCheckModel.fromJson(raw);
      }
      return const IGetMonitorflowCheckModel(backupUpi: <String>[], id: '');
    });
    return IGetMonitorflowCheckResModel(
      code: base.code,
      msg: base.msg,
      data: base.data,
    );
  }
}

/// 获取监控结果
class IGetCheckResultResModel extends ApiResponse<String> {
  const IGetCheckResultResModel({
    required super.code,
    required super.msg,
    super.data,
  });

  factory IGetCheckResultResModel.fromJson(Map<String, dynamic> json) {
    final base = ApiResponse.fromJsonGeneric<String>(json, (raw) {
      return (raw is String) ? raw : (raw?.toString() ?? '');
    });
    return IGetCheckResultResModel(
      code: base.code,
      msg: base.msg,
      data: base.data,
    );
  }
}

/// 绑定UPI
class IAddUpiResModel extends ApiResponse<String> {
  const IAddUpiResModel({required super.code, required super.msg, super.data});

  factory IAddUpiResModel.fromJson(Map<String, dynamic> json) {
    final base = ApiResponse.fromJsonGeneric<String>(json, (raw) {
      return (raw is String) ? raw : (raw?.toString() ?? '');
    });
    return IAddUpiResModel(code: base.code, msg: base.msg, data: base.data);
  }
}
