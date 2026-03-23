import 'package:kumar_pay/data/models/api_response.dart';
import 'package:kumar_pay/core/utils/json_conv.dart';

/// 售出历史条目
class SellHistoryItem {
  final String rptNo;
  final String userId;
  final String orderNo;
  final int method;
  final num amount;
  final int currency;
  final num exchangeRate;
  final int orderState;
  final int notifyState;
  final String crtUser;
  final int crtDate;
  final int? uptDate;
  final int? fnsDate;
  final String platformUser;
  final String username;
  final String receiveAccount;
  final String utr;
  final String payAccount;
  final num realAmount;
  final int ctType;
  final int releaseState;
  final int? utrDate;
  final int? utrType;
  final int? bindType;
  final int secLimit;

  const SellHistoryItem({
    required this.rptNo,
    required this.userId,
    required this.orderNo,
    required this.method,
    required this.amount,
    required this.currency,
    required this.exchangeRate,
    required this.orderState,
    required this.notifyState,
    required this.crtUser,
    required this.crtDate,
    required this.uptDate,
    required this.fnsDate,
    required this.platformUser,
    required this.username,
    required this.receiveAccount,
    required this.utr,
    required this.payAccount,
    required this.realAmount,
    required this.ctType,
    required this.releaseState,
    required this.utrDate,
    required this.utrType,
    required this.bindType,
    required this.secLimit,
  });

  factory SellHistoryItem.fromJson(Map<String, dynamic> json) {
    return SellHistoryItem(
      rptNo: asString(json['rptNo']),
      userId: asString(json['userId']),
      orderNo: asString(json['orderNo']),
      method: asInt(json['method']),
      amount: asNum(json['amount']),
      currency: asInt(json['currency']),
      exchangeRate: asNum(json['exchangeRate']),
      orderState: asInt(json['orderState']),
      notifyState: asInt(json['notifyState']),
      crtUser: asString(json['crtUser']),
      crtDate: asInt(json['crtDate']),
      uptDate: json['uptDate'] == null ? null : asInt(json['uptDate']),
      fnsDate: json['fnsDate'] == null ? null : asInt(json['fnsDate']),
      platformUser: asString(json['platformUser']),
      username: asString(json['username']),
      receiveAccount: asString(json['receiveAccount']),
      utr: asString(json['utr']),
      payAccount: asString(json['payAccount']),
      realAmount: asNum(json['realAmount']),
      ctType: asInt(json['ctType']),
      releaseState: asInt(json['releaseState']),
      utrDate: json['utrDate'] == null ? null : asInt(json['utrDate']),
      utrType: json['utrType'] == null ? null : asInt(json['utrType']),
      bindType: json['bindType'] == null ? null : asInt(json['bindType']),
      secLimit: asInt(json['secLimit']),
    );
  }
}

/// 售出历史
class SellHistoryData {
  final int total;
  final List<SellHistoryItem> list;

  const SellHistoryData({required this.total, required this.list});

  factory SellHistoryData.fromJson(Map<String, dynamic> json) {
    return SellHistoryData(
      total: asInt(json['total']),
      list: json['list'] is List
          ? (json['list'] as List)
                .whereType<Map<String, dynamic>>()
                .map(SellHistoryItem.fromJson)
                .toList()
          : const <SellHistoryItem>[],
    );
  }
}

class IGetSellHistoryResModel extends ApiResponse<SellHistoryData> {
  const IGetSellHistoryResModel({
    required super.code,
    required super.msg,
    super.data,
  });

  factory IGetSellHistoryResModel.fromJson(Map<String, dynamic> json) {
    final base = ApiResponse.fromJsonGeneric<SellHistoryData>(
      json,
      (raw) =>
          raw is Map<String, dynamic> ? SellHistoryData.fromJson(raw) : null,
    );
    return IGetSellHistoryResModel(
      code: base.code,
      msg: base.msg,
      data: base.data,
    );
  }
}
