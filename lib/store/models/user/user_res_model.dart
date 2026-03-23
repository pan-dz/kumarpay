import 'package:kumar_pay/data/models/api_response.dart';
import 'package:kumar_pay/core/utils/json_conv.dart';

/// 玩家详情响应
class UserInfoModel {
  final String username;
  final int userType;
  final String realName;
  final String avatar;
  final int gender;
  final String email;
  final String mobile;
  final int status;
  final String crtUser;
  final int crtDate; // 时间戳
  final String parentUser;
  final String platformUser;
  final int level;
  final int payType;
  final num payerRewardFixed;
  final num payerRewardRatio;
  final num payeeRewardFixed;
  final num payeeRewardRatio;
  final String trc20Address;
  final String inviteCode;
  final String agentUser;
  final String remark;
  final int pageSize;
  final String net;
  final num itoken;
  final num frozenItoken;
  final num totalProfit;
  final num todayProfit;
  final num inPayAmount;
  final num totalSucAmount;
  final int teamWorkId;
  final ReceiveTodayModel? receiveToday;
  final num recharge;
  final num reward;
  final num performance;
  final String safetyCode;
  final int ifFinishNewbieActivity;
  final num totalTransferValue;
  final int minSellIToken;
  final String userSellToken;
  final bool chargeFlag;
  final String chargeAmt;
  final Map<String, dynamic> activityOpens;

  const UserInfoModel({
    required this.username,
    required this.userType,
    required this.realName,
    required this.avatar,
    required this.gender,
    required this.email,
    required this.mobile,
    required this.status,
    required this.crtUser,
    required this.crtDate,
    required this.parentUser,
    required this.platformUser,
    required this.level,
    required this.payType,
    required this.payerRewardFixed,
    required this.payerRewardRatio,
    required this.payeeRewardFixed,
    required this.payeeRewardRatio,
    required this.trc20Address,
    required this.inviteCode,
    required this.agentUser,
    required this.remark,
    required this.pageSize,
    required this.net,
    required this.itoken,
    required this.frozenItoken,
    required this.totalProfit,
    required this.todayProfit,
    required this.inPayAmount,
    required this.totalSucAmount,
    required this.teamWorkId,
    required this.receiveToday,
    required this.recharge,
    required this.reward,
    required this.performance,
    required this.safetyCode,
    required this.ifFinishNewbieActivity,
    required this.totalTransferValue,
    required this.minSellIToken,
    required this.userSellToken,
    required this.chargeFlag,
    required this.chargeAmt,
    required this.activityOpens,
  });

  factory UserInfoModel.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> activity = {};
    final rawAct = json['activityOpens'];
    if (rawAct is Map<String, dynamic>) activity = rawAct;

    return UserInfoModel(
      username: asString(json['username']),
      userType: asInt(json['userType']),
      realName: asString(json['realName']),
      avatar: asString(json['avatar']),
      gender: asInt(json['gender']),
      email: asString(json['email']),
      mobile: asString(json['mobile']),
      status: asInt(json['status']),
      crtUser: asString(json['crtUser']),
      crtDate: asInt(json['crtDate']),
      parentUser: asString(json['parentUser']),
      platformUser: asString(json['platformUser']),
      level: asInt(json['level']),
      payType: asInt(json['payType']),
      payerRewardFixed: asNum(json['payerRewardFixed']),
      payerRewardRatio: asNum(json['payerRewardRatio']),
      payeeRewardFixed: asNum(json['payeeRewardFixed']),
      payeeRewardRatio: asNum(json['payeeRewardRatio']),
      trc20Address: asString(json['trc20Address']),
      inviteCode: asString(json['inviteCode']),
      agentUser: asString(json['agentUser']),
      remark: asString(json['remark']),
      pageSize: asInt(json['pageSize']),
      net: asString(json['net']),
      itoken: asNum(json['itoken']),
      frozenItoken: asNum(json['frozenItoken']),
      totalProfit: asNum(json['totalProfit']),
      todayProfit: asNum(json['todayProfit']),
      inPayAmount: asNum(json['inPayAmount']),
      totalSucAmount: asNum(json['totalSucAmount']),
      teamWorkId: asInt(json['teamWorkId']),
      receiveToday: json['receiveToday'] is Map<String, dynamic>
          ? ReceiveTodayModel.fromJson(
              json['receiveToday'] as Map<String, dynamic>,
            )
          : null,
      recharge: asNum(json['recharge']),
      reward: asNum(json['reward']),
      performance: asNum(json['performance']),
      safetyCode: asString(json['safety_code']),
      ifFinishNewbieActivity: asInt(json['ifFinishNewbieActivity']),
      totalTransferValue: asNum(json['totalTransferValue']),
      minSellIToken: asInt(json['minSellIToken']),
      userSellToken: asString(json['userSellToken']),
      chargeFlag: asBool(json['chargeFlag']),
      chargeAmt: asString(json['chargeAmt']),
      activityOpens: activity,
    );
  }

  Map<String, dynamic> toJson() => {
    'username': username,
    'userType': userType,
    'realName': realName,
    'avatar': avatar,
    'gender': gender,
    'email': email,
    'mobile': mobile,
    'status': status,
    'crtUser': crtUser,
    'crtDate': crtDate,
    'parentUser': parentUser,
    'platformUser': platformUser,
    'level': level,
    'payType': payType,
    'payerRewardFixed': payerRewardFixed,
    'payerRewardRatio': payerRewardRatio,
    'payeeRewardFixed': payeeRewardFixed,
    'payeeRewardRatio': payeeRewardRatio,
    'trc20Address': trc20Address,
    'inviteCode': inviteCode,
    'agentUser': agentUser,
    'remark': remark,
    'pageSize': pageSize,
    'net': net,
    'itoken': itoken,
    'frozenItoken': frozenItoken,
    'totalProfit': totalProfit,
    'todayProfit': todayProfit,
    'inPayAmount': inPayAmount,
    'totalSucAmount': totalSucAmount,
    'teamWorkId': teamWorkId,
    'receiveToday': receiveToday?.toJson(),
    'recharge': recharge,
    'reward': reward,
    'performance': performance,
    'safety_code': safetyCode,
    'ifFinishNewbieActivity': ifFinishNewbieActivity,
    'totalTransferValue': totalTransferValue,
    'minSellIToken': minSellIToken,
    'userSellToken': userSellToken,
    'chargeFlag': chargeFlag,
    'chargeAmt': chargeAmt,
    'activityOpens': activityOpens,
  };
}

class ReceiveTodayModel {
  final String username;
  final num inTransation;
  final num todayDeal;
  final num todaySuccess;
  final num todayTimes;

  const ReceiveTodayModel({
    required this.username,
    required this.inTransation,
    required this.todayDeal,
    required this.todaySuccess,
    required this.todayTimes,
  });

  factory ReceiveTodayModel.fromJson(Map<String, dynamic> json) {
    num _n(dynamic v) {
      if (v is num) return v;
      final p = num.tryParse(v.toString());
      return p ?? 0;
    }

    return ReceiveTodayModel(
      username: (json['username'] ?? '').toString(),
      inTransation: _n(json['inTransation']),
      todayDeal: _n(json['todayDeal']),
      todaySuccess: _n(json['todaySuccess']),
      todayTimes: _n(json['todayTimes']),
    );
  }

  Map<String, dynamic> toJson() => {
    'username': username,
    'inTransation': inTransation,
    'todayDeal': todayDeal,
    'todaySuccess': todaySuccess,
    'todayTimes': todayTimes,
  };
}

class IUserInfoResModel extends ApiResponse<UserInfoModel> {
  const IUserInfoResModel({
    required super.code,
    required super.msg,
    super.data,
  });

  factory IUserInfoResModel.fromJson(Map<String, dynamic> json) {
    final base = ApiResponse.fromJsonGeneric<UserInfoModel>(
      json,
      (raw) => raw is Map<String, dynamic> ? UserInfoModel.fromJson(raw) : null,
    );
    return IUserInfoResModel(code: base.code, msg: base.msg, data: base.data);
  }
}

/// 团队今日利润
class TodayProfitModel {
  final int day;
  final String username;
  final int teamWorkId;
  final int newCtCount;
  final int newCwCount;
  final num commission;
  final int dividend;
  final int recharge;
  final num reward;
  final num performance;
  final int bonus;
  final int times;
  final int sellTimes;
  final int urecharge;
  final int utimes;
  final int ureward;

  const TodayProfitModel({
    required this.day,
    required this.username,
    required this.teamWorkId,
    required this.newCtCount,
    required this.newCwCount,
    required this.commission,
    required this.dividend,
    required this.recharge,
    required this.reward,
    required this.performance,
    required this.bonus,
    required this.times,
    required this.sellTimes,
    required this.urecharge,
    required this.utimes,
    required this.ureward,
  });

  factory TodayProfitModel.fromJson(Map<String, dynamic> json) {
    return TodayProfitModel(
      day: asInt(json['day']),
      username: asString(json['username']),
      teamWorkId: asInt(json['teamWorkId']),
      newCtCount: asInt(json['newCtCount']),
      newCwCount: asInt(json['newCwCount']),
      commission: asNum(json['commission']),
      dividend: asInt(json['dividend']),
      recharge: asInt(json['recharge']),
      reward: asNum(json['reward']),
      performance: asNum(json['performance']),
      bonus: asInt(json['bonus']),
      times: asInt(json['times']),
      sellTimes: asInt(json['sellTimes']),
      urecharge: asInt(json['urecharge']),
      utimes: asInt(json['utimes']),
      ureward: asInt(json['ureward']),
    );
  }
}

class ITodayProfitResModel extends ApiResponse<TodayProfitModel> {
  const ITodayProfitResModel({
    required super.code,
    required super.msg,
    super.data,
  });

  factory ITodayProfitResModel.fromJson(Map<String, dynamic> json) {
    final base = ApiResponse.fromJsonGeneric<TodayProfitModel>(
      json,
      (raw) =>
          raw is Map<String, dynamic> ? TodayProfitModel.fromJson(raw) : null,
    );
    return ITodayProfitResModel(
      code: base.code,
      msg: base.msg,
      data: base.data,
    );
  }
}

/// 客服列表
class CustomerserviceModel {
  final String label;
  final String nickname;
  final String type;
  final String url;
  final String? extendValue;
  final String? groupType;

  const CustomerserviceModel({
    required this.label,
    required this.nickname,
    required this.type,
    required this.url,
    required this.extendValue,
    required this.groupType,
  });

  factory CustomerserviceModel.fromJson(Map<String, dynamic> json) {
    return CustomerserviceModel(
      label: asString(json['label']),
      nickname: asString(json['nickname']),
      type: asString(json['type']),
      url: asString(json['url']),
      extendValue: asString(json['extendValue']),
      groupType: asString(json['groupType']),
    );
  }
}

class ICustomerserviceResModel extends ApiResponse<List<CustomerserviceModel>> {
  const ICustomerserviceResModel({
    required super.code,
    required super.msg,
    super.data,
  });

  factory ICustomerserviceResModel.fromJson(Map<String, dynamic> json) {
    final base = ApiResponse.fromJsonGeneric<List<CustomerserviceModel>>(json, (
      raw,
    ) {
      if (raw is List) {
        return raw
            .whereType<Map<String, dynamic>>()
            .map((e) => CustomerserviceModel.fromJson(e))
            .toList();
      }
      return <CustomerserviceModel>[];
    });
    return ICustomerserviceResModel(
      code: base.code,
      msg: base.msg,
      data: base.data,
    );
  }
}

/// 最小出售 IToken
class IMinSellITokenResModel extends ApiResponse<dynamic> {
  const IMinSellITokenResModel({
    required super.code,
    required super.msg,
    super.data,
  });

  factory IMinSellITokenResModel.fromJson(Map<String, dynamic> json) {
    final base = ApiResponse.fromJsonGeneric<dynamic>(json, (raw) => raw);
    return IMinSellITokenResModel(
      code: base.code,
      msg: base.msg,
      data: base.data,
    );
  }
}

/// token 转交记录
class TransferTokenHistoryItemModel {
  final int id;
  final String transferIn;
  final String transferOut;
  final num itoken;
  final int transferType;
  final int orderState;
  final int crtDate;
  final String showNote;
  final int userShow;

  const TransferTokenHistoryItemModel({
    required this.id,
    required this.transferIn,
    required this.transferOut,
    required this.itoken,
    required this.transferType,
    required this.orderState,
    required this.crtDate,
    required this.showNote,
    required this.userShow,
  });

  factory TransferTokenHistoryItemModel.fromJson(Map<String, dynamic> json) {
    return TransferTokenHistoryItemModel(
      id: asInt(json['id']),
      transferIn: asString(json['transferIn']),
      transferOut: asString(json['transferOut']),
      itoken: asNum(json['itoken']),
      transferType: asInt(json['transferType']),
      orderState: asInt(json['orderState']),
      crtDate: asInt(json['crtDate']),
      showNote: asString(json['showNote']),
      userShow: asInt(json['userShow']),
    );
  }
}

class TransferTokenHistoryDataModel {
  final int total;
  final List<TransferTokenHistoryItemModel> list;

  const TransferTokenHistoryDataModel({
    required this.total,
    required this.list,
  });

  factory TransferTokenHistoryDataModel.fromJson(Map<String, dynamic> json) {
    final rawList = json['list'];
    final list = rawList is List
        ? rawList
              .whereType<Map<String, dynamic>>()
              .map((e) => TransferTokenHistoryItemModel.fromJson(e))
              .toList()
        : <TransferTokenHistoryItemModel>[];

    return TransferTokenHistoryDataModel(
      total: asInt(json['total']),
      list: list,
    );
  }
}

class ITransferTokenHistoryResModel
    extends ApiResponse<TransferTokenHistoryDataModel> {
  const ITransferTokenHistoryResModel({
    required super.code,
    required super.msg,
    super.data,
  });

  factory ITransferTokenHistoryResModel.fromJson(Map<String, dynamic> json) {
    final base = ApiResponse.fromJsonGeneric<TransferTokenHistoryDataModel>(
      json,
      (raw) => raw is Map<String, dynamic>
          ? TransferTokenHistoryDataModel.fromJson(raw)
          : null,
    );
    return ITransferTokenHistoryResModel(
      code: base.code,
      msg: base.msg,
      data: base.data,
    );
  }
}
