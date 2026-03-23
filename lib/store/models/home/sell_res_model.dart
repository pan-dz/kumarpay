import 'package:kumar_pay/core/utils/json_conv.dart';
import 'package:kumar_pay/data/models/api_response.dart';

class ReceiveTodayModel {
  final String username;
  final int inTransation;
  final int todayDeal;
  final int todaySuccess;
  final int todayTimes;

  const ReceiveTodayModel({
    required this.username,
    required this.inTransation,
    required this.todayDeal,
    required this.todaySuccess,
    required this.todayTimes,
  });

  factory ReceiveTodayModel.fromJson(Map<String, dynamic> json) {
    return ReceiveTodayModel(
      username: asString(json['username']),
      inTransation: asInt(json['inTransation']),
      todayDeal: asInt(json['todayDeal']),
      todaySuccess: asInt(json['todaySuccess']),
      todayTimes: asInt(json['todayTimes']),
    );
  }
}

class KycPartnerModel {
  final int ctType;
  final String account;
  final String upi;
  final String username;
  final bool userIsActive;
  final bool inSell;

  const KycPartnerModel({
    required this.ctType,
    required this.account,
    required this.upi,
    required this.username,
    required this.userIsActive,
    required this.inSell,
  });

  factory KycPartnerModel.fromJson(Map<String, dynamic> json) {
    return KycPartnerModel(
      ctType: asInt(json['ctType']),
      account: asString(json['account']),
      upi: asString(json['upi']),
      username: asString(json['username']),
      userIsActive: asBool(json['userIsActive']),
      inSell: asBool(json['inSell']),
    );
  }
}

class UserinfoAndAvailableCtModel {
  final String username;
  final String realName;
  final String avatar;
  final int itoken;
  final int frozenItoken;
  final int todayProfit;
  final int totalProfit;
  final ReceiveTodayModel? receiveToday;
  final List<KycPartnerModel> kycpartnerVOList;

  const UserinfoAndAvailableCtModel({
    required this.username,
    required this.realName,
    required this.avatar,
    required this.itoken,
    required this.frozenItoken,
    required this.todayProfit,
    required this.totalProfit,
    required this.receiveToday,
    required this.kycpartnerVOList,
  });

  factory UserinfoAndAvailableCtModel.fromJson(Map<String, dynamic> json) {
    final receiveRaw = json['receiveToday'];
    final receive = receiveRaw is Map<String, dynamic>
        ? ReceiveTodayModel.fromJson(receiveRaw)
        : null;

    final kycRaw = json['kycpartnerVOList'];
    final kycList = kycRaw is List
        ? kycRaw
              .whereType<Map<String, dynamic>>()
              .map(KycPartnerModel.fromJson)
              .toList()
        : <KycPartnerModel>[];

    return UserinfoAndAvailableCtModel(
      username: asString(json['username']),
      realName: asString(json['realName']),
      avatar: asString(json['avatar']),
      itoken: asInt(json['itoken']),
      frozenItoken: asInt(json['frozenItoken']),
      todayProfit: asInt(json['todayProfit']),
      totalProfit: asInt(json['totalProfit']),
      receiveToday: receive,
      kycpartnerVOList: kycList,
    );
  }
}

class IUserinfoAndAvailableCtResModel
    extends ApiResponse<UserinfoAndAvailableCtModel> {
  const IUserinfoAndAvailableCtResModel({
    required super.code,
    required super.msg,
    super.data,
  });

  factory IUserinfoAndAvailableCtResModel.fromJson(Map<String, dynamic> json) {
    final base = ApiResponse.fromJsonGeneric<UserinfoAndAvailableCtModel>(
      json,
      (raw) => raw is Map<String, dynamic>
          ? UserinfoAndAvailableCtModel.fromJson(raw)
          : null,
    );
    return IUserinfoAndAvailableCtResModel(
      code: base.code,
      msg: base.msg,
      data: base.data,
    );
  }
}
