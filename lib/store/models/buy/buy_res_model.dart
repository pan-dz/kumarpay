import 'package:kumar_pay/data/models/api_response.dart';
import 'package:kumar_pay/core/utils/json_conv.dart';

/// 购买-获取付款单
class BuyITokenData {
  final int ctType;
  final String walletDomain;
  final String ctAccount;
  final int ctime;

  const BuyITokenData({
    required this.ctType,
    required this.walletDomain,
    required this.ctAccount,
    required this.ctime,
  });

  factory BuyITokenData.fromJson(Map<String, dynamic> json) {
    return BuyITokenData(
      ctType: asInt(json['ctType']),
      walletDomain: asString(json['walletDomain']),
      ctAccount: asString(json['ctAccount']),
      ctime: asInt(json['ctime']),
    );
  }
}

/// 付款单详情
class PaymentSlipDetailData {
  final num amount;
  final int ctType;
  final String payeeBankname;
  final int payerStatus;
  final int countdown;
  final String payeeBankAccount;
  final String rptNo;
  final String ctAccount;
  final String ctAccountUpi;
  final int ctime;
  final String id;
  final String payeeRecipientsName;
  final String payeeIfsc;
  final int confirmMode;
  final int paymentMethod;

  const PaymentSlipDetailData({
    required this.amount,
    required this.ctType,
    required this.payeeBankname,
    required this.payerStatus,
    required this.countdown,
    required this.payeeBankAccount,
    required this.rptNo,
    required this.ctAccount,
    required this.ctAccountUpi,
    required this.ctime,
    required this.id,
    required this.payeeRecipientsName,
    required this.payeeIfsc,
    required this.confirmMode,
    required this.paymentMethod,
  });

  factory PaymentSlipDetailData.fromJson(Map<String, dynamic> json) {
    return PaymentSlipDetailData(
      amount: asNum(json['amount']),
      ctType: asInt(json['ct_type']),
      payeeBankname: asString(json['payee_bankname']),
      payerStatus: asInt(json['payer_status']),
      countdown: asInt(json['countdown']),
      payeeBankAccount: asString(json['payee_bank_account']),
      rptNo: asString(json['rptNo']),
      ctAccount: asString(json['ctAccount']),
      ctAccountUpi: asString(json['ct_account']),
      ctime: asInt(json['ctime']),
      id: asString(json['id']),
      payeeRecipientsName: asString(json['payee_recipients_name']),
      payeeIfsc: asString(json['payee_ifsc']),
      confirmMode: asInt(json['confirm_mode']),
      paymentMethod: asInt(json['payment_method']),
    );
  }
}

class IPaymentSlipDetailResModel extends ApiResponse<PaymentSlipDetailData> {
  const IPaymentSlipDetailResModel({
    required super.code,
    required super.msg,
    super.data,
  });

  factory IPaymentSlipDetailResModel.fromJson(Map<String, dynamic> json) {
    final base = ApiResponse.fromJsonGeneric<PaymentSlipDetailData>(json, (
      raw,
    ) {
      if (raw is Map<String, dynamic>) {
        return PaymentSlipDetailData.fromJson(raw);
      }
      return null;
    });
    return IPaymentSlipDetailResModel(
      code: base.code,
      msg: base.msg,
      data: base.data,
    );
  }
}

class IBuyITokenResModel extends ApiResponse<BuyITokenData> {
  const IBuyITokenResModel({
    required super.code,
    required super.msg,
    super.data,
  });

  factory IBuyITokenResModel.fromJson(Map<String, dynamic> json) {
    final base = ApiResponse.fromJsonGeneric<BuyITokenData>(json, (raw) {
      if (raw is Map<String, dynamic>) return BuyITokenData.fromJson(raw);
      return null;
    });
    return IBuyITokenResModel(code: base.code, msg: base.msg, data: base.data);
  }
}

/// 购买历史条目
class BuyHistoryItem {
  final String rptNo;
  final String userId;
  final String orderNo;
  final String username;
  final int method;
  final num amount;
  final num? itoken;
  final int currency;
  final num exchangeRate;
  final int orderState;
  final int notifyState;
  final String crtUser;
  final int crtDate;
  final String platformUser;
  final int? uptDate;
  final int fnsDate;
  final String acctNo;
  final String acctCode;
  final String acctName;
  final int payType;
  final String payAccount;
  final num realAmount;
  final num? reward;
  final String walletDomain;
  final String ctAccount;
  final String utr;
  final int hideState;

  const BuyHistoryItem({
    required this.rptNo,
    required this.userId,
    required this.orderNo,
    required this.username,
    required this.method,
    required this.amount,
    required this.itoken,
    required this.currency,
    required this.exchangeRate,
    required this.orderState,
    required this.notifyState,
    required this.crtUser,
    required this.crtDate,
    required this.platformUser,
    required this.uptDate,
    required this.fnsDate,
    required this.acctNo,
    required this.acctCode,
    required this.acctName,
    required this.payType,
    required this.payAccount,
    required this.realAmount,
    required this.reward,
    required this.walletDomain,
    required this.ctAccount,
    required this.hideState,
    required this.utr,
  });

  factory BuyHistoryItem.fromJson(Map<String, dynamic> json) {
    return BuyHistoryItem(
      rptNo: asString(json['rptNo']),
      userId: asString(json['userId']),
      orderNo: asString(json['orderNo']),
      username: asString(json['username']),
      method: asInt(json['method']),
      amount: asNum(json['amount']),
      itoken: json['itoken'] == null ? null : asNum(json['itoken']),
      currency: asInt(json['currency']),
      exchangeRate: asNum(json['exchangeRate']),
      orderState: asInt(json['orderState']),
      notifyState: asInt(json['notifyState']),
      crtUser: asString(json['crtUser']),
      crtDate: asInt(json['crtDate']),
      platformUser: asString(json['platformUser']),
      uptDate: json['uptDate'] == null ? null : asInt(json['uptDate']),
      fnsDate: asInt(json['fnsDate']),
      acctNo: asString(json['acctNo']),
      acctCode: asString(json['acctCode']),
      acctName: asString(json['acctName']),
      payType: asInt(json['payType']),
      payAccount: asString(json['payAccount']),
      realAmount: asNum(json['realAmount']),
      reward: json['reward'] == null ? null : asNum(json['reward']),
      walletDomain: asString(json['walletDomain']),
      ctAccount: asString(json['ctAccount']),
      utr: asString(json['utr']),
      hideState: asInt(json['hideState']),
    );
  }
}

/// USDT 购买记录条目
class BuyUsdtListItem {
  final String rptNo;
  final String colletAddress;
  final String username;
  final int keyType;
  final int currency;
  final num amount;
  final num exchangeRate;
  final num itoken;
  final int orderState;
  final String crtUser;
  final int crtDate;
  final String platformUser;
  final String transactionHash;
  final String fromAddress;
  final num reward;

  const BuyUsdtListItem({
    required this.rptNo,
    required this.colletAddress,
    required this.username,
    required this.keyType,
    required this.currency,
    required this.amount,
    required this.exchangeRate,
    required this.itoken,
    required this.orderState,
    required this.crtUser,
    required this.crtDate,
    required this.platformUser,
    required this.transactionHash,
    required this.fromAddress,
    required this.reward,
  });

  factory BuyUsdtListItem.fromJson(Map<String, dynamic> json) {
    return BuyUsdtListItem(
      rptNo: asString(json['rptNo']),
      colletAddress: asString(json['colletAddress']),
      username: asString(json['username']),
      keyType: asInt(json['keyType']),
      currency: asInt(json['currency']),
      amount: asNum(json['amount']),
      exchangeRate: asNum(json['exchangeRate']),
      itoken: asNum(json['itoken']),
      orderState: asInt(json['orderState']),
      crtUser: asString(json['crtUser']),
      crtDate: asInt(json['crtDate']),
      platformUser: asString(json['platformUser']),
      transactionHash: asString(json['transactionHash']),
      fromAddress: asString(json['fromAddress']),
      reward: asNum(json['reward']),
    );
  }
}

/// 获取 USDT 购买记录
class IGetBuyUsdtListResModel extends ApiResponse<List<BuyUsdtListItem>> {
  const IGetBuyUsdtListResModel({
    required super.code,
    required super.msg,
    super.data,
  });

  factory IGetBuyUsdtListResModel.fromJson(Object? json) {
    if (json is List) {
      final data = json
          .whereType<Map<String, dynamic>>()
          .map(BuyUsdtListItem.fromJson)
          .toList();
      return IGetBuyUsdtListResModel(code: 0, msg: '', data: data);
    }
    if (json is Map<String, dynamic>) {
      final base = ApiResponse.fromJsonGeneric<List<BuyUsdtListItem>>(json, (
        raw,
      ) {
        if (raw is List) {
          return raw
              .whereType<Map<String, dynamic>>()
              .map(BuyUsdtListItem.fromJson)
              .toList();
        }
        return <BuyUsdtListItem>[];
      });
      return IGetBuyUsdtListResModel(
        code: base.code,
        msg: base.msg,
        data: base.data,
      );
    }
    return const IGetBuyUsdtListResModel(
      code: -1,
      msg: 'Invalid response format',
      data: <BuyUsdtListItem>[],
    );
  }
}

/// 购买历史
class BuyHistoryData {
  final int total;
  final List<BuyHistoryItem> list;

  const BuyHistoryData({required this.total, required this.list});

  factory BuyHistoryData.fromJson(Map<String, dynamic> json) {
    return BuyHistoryData(
      total: asInt(json['total']),
      list: json['list'] is List
          ? (json['list'] as List)
                .whereType<Map<String, dynamic>>()
                .map(BuyHistoryItem.fromJson)
                .toList()
          : const <BuyHistoryItem>[],
    );
  }
}

class IGetBuyHistoryResModel extends ApiResponse<BuyHistoryData> {
  const IGetBuyHistoryResModel({
    required super.code,
    required super.msg,
    super.data,
  });

  factory IGetBuyHistoryResModel.fromJson(Map<String, dynamic> json) {
    final base = ApiResponse.fromJsonGeneric<BuyHistoryData>(
      json,
      (raw) =>
          raw is Map<String, dynamic> ? BuyHistoryData.fromJson(raw) : null,
    );
    return IGetBuyHistoryResModel(
      code: base.code,
      msg: base.msg,
      data: base.data,
    );
  }
}

/// 确认已付款
class IConfirmPaidResModel extends ApiResponse<bool> {
  const IConfirmPaidResModel({
    required super.code,
    required super.msg,
    super.data,
  });

  factory IConfirmPaidResModel.fromJson(Map<String, dynamic> json) {
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
    return IConfirmPaidResModel(
      code: base.code,
      msg: base.msg,
      data: base.data,
    );
  }
}

/// 获取购买订单
class BuyOrderListData {
  final int total;
  final List<BuyOrderListItem> list;

  const BuyOrderListData({required this.total, required this.list});

  factory BuyOrderListData.fromJson(Map<String, dynamic> json) {
    return BuyOrderListData(
      total: asInt(json['total']),
      list: json['list'] is List
          ? (json['list'] as List)
                .whereType<Map<String, dynamic>>()
                .map((e) => BuyOrderListItem.fromJson(e))
                .toList()
          : const <BuyOrderListItem>[],
    );
  }
}

class BuyOrderListItem {
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
  final String platformUser;
  final int? uptDate;
  final int fnsDate;
  final String acctNo;
  final String acctCode;
  final String acctName;
  final num realAmount;
  final num? reward;
  final int hideState;

  const BuyOrderListItem({
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
    required this.platformUser,
    required this.uptDate,
    required this.fnsDate,
    required this.acctNo,
    required this.acctCode,
    required this.acctName,
    required this.realAmount,
    required this.reward,
    required this.hideState,
  });

  factory BuyOrderListItem.fromJson(Map<String, dynamic> json) {
    return BuyOrderListItem(
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
      platformUser: asString(json['platformUser']),
      uptDate: json['uptDate'] == null ? null : asInt(json['uptDate']),
      fnsDate: asInt(json['fnsDate']),
      acctNo: asString(json['acctNo']),
      acctCode: asString(json['acctCode']),
      acctName: asString(json['acctName']),
      realAmount: asNum(json['realAmount']),
      reward: json['reward'] == null ? null : asNum(json['reward']),
      hideState: asInt(json['hideState']),
    );
  }
}

class IGetBuyOrderListResModel extends ApiResponse<BuyOrderListData> {
  const IGetBuyOrderListResModel({
    required super.code,
    required super.msg,
    super.data,
  });

  factory IGetBuyOrderListResModel.fromJson(Map<String, dynamic> json) {
    final base = ApiResponse.fromJsonGeneric<BuyOrderListData>(
      json,
      (raw) =>
          raw is Map<String, dynamic> ? BuyOrderListData.fromJson(raw) : null,
    );
    return IGetBuyOrderListResModel(
      code: base.code,
      msg: base.msg,
      data: base.data,
    );
  }
}

class IProcessPaymentslipsResModel extends ApiResponse<String> {
  const IProcessPaymentslipsResModel({
    required super.code,
    required super.msg,
    super.data,
  });

  factory IProcessPaymentslipsResModel.fromJson(Map<String, dynamic> json) {
    final base = ApiResponse.fromJsonGeneric<String>(json, (_) => null);
    return IProcessPaymentslipsResModel(
      code: base.code,
      msg: base.msg,
      data: base.data,
    );
  }
}
