import 'package:kumar_pay/data/models/api_response.dart';
import 'package:kumar_pay/core/utils/json_conv.dart';

/// 新手奖励
class NewbieRewardModel {
  final ActivityRecord? activityRecord;
  final num newbieReward;
  final String tgGroup;
  final String buyToken;
  final String? allDone;
  final List<ActivityRule> activityRules;

  const NewbieRewardModel({
    required this.activityRecord,
    required this.newbieReward,
    required this.tgGroup,
    required this.buyToken,
    required this.allDone,
    required this.activityRules,
  });

  factory NewbieRewardModel.fromJson(Map<String, dynamic> json) {
    return NewbieRewardModel(
      activityRecord: json['activityRecord'] is Map<String, dynamic>
          ? ActivityRecord.fromJson(
              json['activityRecord'] as Map<String, dynamic>,
            )
          : null,
      newbieReward: asNum(json['newbieReward']),
      tgGroup: asString(json['tgGroup']),
      buyToken: asString(json['buyToken']),
      allDone: asString(json['allDone']),
      activityRules: json['activityRules'] is List
          ? (json['activityRules'] as List)
                .whereType<Map<String, dynamic>>()
                .map((e) => ActivityRule.fromJson(e))
                .toList()
          : const <ActivityRule>[],
    );
  }
}

class ActivityRecord {
  final int id;
  final String username;
  final String rewardRule;
  final String activityCode;
  final num rewardAmt;
  final int condition;
  final num conditionAmt;
  final num settleAmt;
  final int done;
  final int uptDate;
  final String params;
  final int crtDate;

  const ActivityRecord({
    required this.id,
    required this.username,
    required this.rewardRule,
    required this.activityCode,
    required this.rewardAmt,
    required this.condition,
    required this.conditionAmt,
    required this.settleAmt,
    required this.done,
    required this.uptDate,
    required this.params,
    required this.crtDate,
  });

  factory ActivityRecord.fromJson(Map<String, dynamic> json) {
    return ActivityRecord(
      id: asInt(json['id']),
      username: asString(json['username']),
      rewardRule: asString(json['rewardRule']),
      activityCode: asString(json['activityCode']),
      rewardAmt: asNum(json['rewardAmt']),
      condition: asInt(json['condition']),
      conditionAmt: asNum(json['conditionAmt']),
      settleAmt: asNum(json['settleAmt']),
      done: asInt(json['done']),
      uptDate: asInt(json['uptDate']),
      params: asString(json['params']),
      crtDate: asInt(json['crtDate']),
    );
  }
}

class ActivityRule {
  final String rewardRule;
  final String activityCode;
  final String title;
  final int startDate;
  final int endDate;
  final int status;
  final int crtDate;
  final String remark;
  final String frontUrl;
  final int? condition;
  final num rewardAmt;
  final int sort;

  const ActivityRule({
    required this.rewardRule,
    required this.activityCode,
    required this.title,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.crtDate,
    required this.remark,
    required this.frontUrl,
    required this.condition,
    required this.rewardAmt,
    required this.sort,
  });

  factory ActivityRule.fromJson(Map<String, dynamic> json) {
    return ActivityRule(
      rewardRule: asString(json['rewardRule']),
      activityCode: asString(json['activityCode']),
      title: asString(json['title']),
      startDate: asInt(json['startDate']),
      endDate: asInt(json['endDate']),
      status: asInt(json['status']),
      crtDate: asInt(json['crtDate']),
      remark: asString(json['remark']),
      frontUrl: asString(json['frontUrl']),
      condition: json['condition'] == null ? null : asInt(json['condition']),
      rewardAmt: asNum(json['rewardAmt']),
      sort: asInt(json['sort']),
    );
  }
}

class INewbieGuidesResModel extends ApiResponse<NewbieRewardModel> {
  const INewbieGuidesResModel({
    required super.code,
    required super.msg,
    super.data,
  });

  factory INewbieGuidesResModel.fromJson(Map<String, dynamic> json) {
    final base = ApiResponse.fromJsonGeneric<NewbieRewardModel>(
      json,
      (raw) =>
          raw is Map<String, dynamic> ? NewbieRewardModel.fromJson(raw) : null,
    );
    return INewbieGuidesResModel(
      code: base.code,
      msg: base.msg,
      data: base.data,
    );
  }
}

/// 邀请好友
class InviteFriendsModel {
  final ActivityRecord? activityRecord;
  final OldRptNewReward? oldRptNewReward;

  const InviteFriendsModel({
    required this.activityRecord,
    required this.oldRptNewReward,
  });

  factory InviteFriendsModel.fromJson(Map<String, dynamic> json) {
    return InviteFriendsModel(
      activityRecord: json['activityRecord'] is Map<String, dynamic>
          ? ActivityRecord.fromJson(
              json['activityRecord'] as Map<String, dynamic>,
            )
          : null,
      oldRptNewReward: json['oldRptNewReward'] is Map<String, dynamic>
          ? OldRptNewReward.fromJson(
              json['oldRptNewReward'] as Map<String, dynamic>,
            )
          : null,
    );
  }
}

class OldRptNewReward {
  final String name;
  final num fixed;
  final num ratio;
  final int minCondi;
  final int ruleActive;
  final String rule;

  const OldRptNewReward({
    required this.name,
    required this.fixed,
    required this.ratio,
    required this.minCondi,
    required this.ruleActive,
    required this.rule,
  });

  factory OldRptNewReward.fromJson(Map<String, dynamic> json) {
    return OldRptNewReward(
      name: asString(json['name']),
      fixed: asNum(json['fixed']),
      ratio: asNum(json['ratio']),
      minCondi: asInt(json['minCondi']),
      ruleActive: asInt(json['ruleActive']),
      rule: asString(json['rule']),
    );
  }
}

class IInviteFriendsResModel extends ApiResponse<InviteFriendsModel> {
  const IInviteFriendsResModel({
    required super.code,
    required super.msg,
    super.data,
  });

  factory IInviteFriendsResModel.fromJson(Map<String, dynamic> json) {
    final base = ApiResponse.fromJsonGeneric<InviteFriendsModel>(
      json,
      (raw) =>
          raw is Map<String, dynamic> ? InviteFriendsModel.fromJson(raw) : null,
    );
    return IInviteFriendsResModel(
      code: base.code,
      msg: base.msg,
      data: base.data,
    );
  }
}

class IInviteFriendsRewardResModel extends ApiResponse<dynamic> {
  const IInviteFriendsRewardResModel({
    required super.code,
    required super.msg,
    super.data,
  });

  factory IInviteFriendsRewardResModel.fromJson(Map<String, dynamic> json) {
    final base = ApiResponse.fromJsonGeneric<dynamic>(json, (raw) => raw);
    return IInviteFriendsRewardResModel(
      code: base.code,
      msg: base.msg,
      data: base.data,
    );
  }
}

/// 团队信息
class TeamInfoModel {
  final TeamInfo teaminfo;
  final TeamToday today;
  final String inviteCode;
  final String rsUrl;
  final String inrBuyDividend;

  const TeamInfoModel({
    required this.teaminfo,
    required this.today,
    required this.inviteCode,
    required this.rsUrl,
    required this.inrBuyDividend,
  });

  factory TeamInfoModel.fromJson(Map<String, dynamic> json) {
    return TeamInfoModel(
      teaminfo: json['teaminfo'] is Map<String, dynamic>
          ? TeamInfo.fromJson(json['teaminfo'] as Map<String, dynamic>)
          : const TeamInfo(),
      today: json['today'] is Map<String, dynamic>
          ? TeamToday.fromJson(json['today'] as Map<String, dynamic>)
          : const TeamToday(),
      inviteCode: asString(json['inviteCode']),
      rsUrl: asString(json['rsUrl']),
      inrBuyDividend: asString(json['inrBuyDividend']),
    );
  }
}

class TeamInfo {
  final String username;
  final int newCtCount;
  final int newCwCount;
  final num commission;
  final num dividend;
  final num recharge;
  final num reward;
  final num performance;
  final num bonus;
  final int teamWorkId;
  final int parentTeamWorkId;
  final num parentCommission;
  final int count;
  final int teamCount;
  final String parentUser;
  final num payerRewardFixed;
  final num payerRewardRatio;

  const TeamInfo({
    this.username = '',
    this.newCtCount = 0,
    this.newCwCount = 0,
    this.commission = 0,
    this.dividend = 0,
    this.recharge = 0,
    this.reward = 0,
    this.performance = 0,
    this.bonus = 0,
    this.teamWorkId = 0,
    this.parentTeamWorkId = 0,
    this.parentCommission = 0,
    this.count = 0,
    this.teamCount = 0,
    this.parentUser = '',
    this.payerRewardFixed = 0,
    this.payerRewardRatio = 0,
  });

  factory TeamInfo.fromJson(Map<String, dynamic> json) {
    return TeamInfo(
      username: asString(json['username']),
      newCtCount: asInt(json['newCtCount']),
      newCwCount: asInt(json['newCwCount']),
      commission: asNum(json['commission']),
      dividend: asNum(json['dividend']),
      recharge: asNum(json['recharge']),
      reward: asNum(json['reward']),
      performance: asNum(json['performance']),
      bonus: asNum(json['bonus']),
      teamWorkId: asInt(json['teamWorkId']),
      parentTeamWorkId: asInt(json['parentTeamWorkId']),
      parentCommission: asNum(json['parentCommission']),
      count: asInt(json['count']),
      teamCount: asInt(json['teamCount']),
      parentUser: asString(json['parentUser']),
      payerRewardFixed: asNum(json['payerRewardFixed']),
      payerRewardRatio: asNum(json['payerRewardRatio']),
    );
  }
}

class TeamToday {
  final int newCtCount;
  final int newCwCount;
  final num commission;
  final num dividend;
  final num recharge;
  final num reward;
  final num performance;
  final num bonus;
  final num parentCommission;

  const TeamToday({
    this.newCtCount = 0,
    this.newCwCount = 0,
    this.commission = 0,
    this.dividend = 0,
    this.recharge = 0,
    this.reward = 0,
    this.performance = 0,
    this.bonus = 0,
    this.parentCommission = 0,
  });

  factory TeamToday.fromJson(Map<String, dynamic> json) {
    return TeamToday(
      newCtCount: asInt(json['newCtCount']),
      newCwCount: asInt(json['newCwCount']),
      commission: asNum(json['commission']),
      dividend: asNum(json['dividend']),
      recharge: asNum(json['recharge']),
      reward: asNum(json['reward']),
      performance: asNum(json['performance']),
      bonus: asNum(json['bonus']),
      parentCommission: asNum(json['parentCommission']),
    );
  }
}

class ITeamInfoResModel extends ApiResponse<TeamInfoModel> {
  const ITeamInfoResModel({
    required super.code,
    required super.msg,
    super.data,
  });

  factory ITeamInfoResModel.fromJson(Map<String, dynamic> json) {
    final base = ApiResponse.fromJsonGeneric<TeamInfoModel>(
      json,
      (raw) => raw is Map<String, dynamic> ? TeamInfoModel.fromJson(raw) : null,
    );
    return ITeamInfoResModel(code: base.code, msg: base.msg, data: base.data);
  }
}

/// 团队每日数据
class TeamDailyDataModel {
  final int day;
  final String username;
  final int teamWorkId;
  final int newCtCount;
  final int newCwCount;
  final num commission;
  final num dividend;
  final num recharge;
  final num reward;
  final num performance;
  final num bonus;
  final int times;
  final int sellTimes;
  final num urecharge;
  final int utimes;
  final num ureward;

  const TeamDailyDataModel({
    this.day = 0,
    this.username = '',
    this.teamWorkId = 0,
    this.newCtCount = 0,
    this.newCwCount = 0,
    this.commission = 0,
    this.dividend = 0,
    this.recharge = 0,
    this.reward = 0,
    this.performance = 0,
    this.bonus = 0,
    this.times = 0,
    this.sellTimes = 0,
    this.urecharge = 0,
    this.utimes = 0,
    this.ureward = 0,
  });

  factory TeamDailyDataModel.fromJson(Map<String, dynamic> json) {
    return TeamDailyDataModel(
      day: asInt(json['day']),
      username: asString(json['username']),
      teamWorkId: asInt(json['teamWorkId']),
      newCtCount: asInt(json['newCtCount']),
      newCwCount: asInt(json['newCwCount']),
      commission: asNum(json['commission']),
      dividend: asNum(json['dividend']),
      recharge: asNum(json['recharge']),
      reward: asNum(json['reward']),
      performance: asNum(json['performance']),
      bonus: asNum(json['bonus']),
      times: asInt(json['times']),
      sellTimes: asInt(json['sellTimes']),
      urecharge: asNum(json['urecharge']),
      utimes: asInt(json['utimes']),
      ureward: asNum(json['ureward']),
    );
  }
}

class ITeamDailyDataResModel extends ApiResponse<TeamDailyDataModel> {
  const ITeamDailyDataResModel({
    required super.code,
    required super.msg,
    super.data,
  });

  factory ITeamDailyDataResModel.fromJson(Map<String, dynamic> json) {
    final base = ApiResponse.fromJsonGeneric<TeamDailyDataModel>(
      json,
      (raw) =>
          raw is Map<String, dynamic> ? TeamDailyDataModel.fromJson(raw) : null,
    );
    return ITeamDailyDataResModel(
      code: base.code,
      msg: base.msg,
      data: base.data,
    );
  }
}

/// 我的团队列表
class MyTeamItemModel {
  final String username;
  final int newCtCount;
  final int newCwCount;
  final num commission;
  final String lgTime;
  final num dividend;
  final num recharge;
  final num reward;
  final num performance;
  final num bonus;
  final int times;
  final int teamWorkId;
  final int parentTeamWorkId;
  final num parentCommission;
  final int count;
  final int teamCount;
  final String parentUser;
  final num payerRewardFixed;
  final num payerRewardRatio;
  final String lgExpiredTime;
  final num urecharge;
  final int utimes;
  final num ureward;

  const MyTeamItemModel({
    this.username = '',
    this.newCtCount = 0,
    this.newCwCount = 0,
    this.commission = 0,
    this.dividend = 0,
    this.recharge = 0,
    this.reward = 0,
    this.performance = 0,
    this.bonus = 0,
    this.times = 0,
    this.teamWorkId = 0,
    this.parentTeamWorkId = 0,
    this.parentCommission = 0,
    this.count = 0,
    this.teamCount = 0,
    this.parentUser = '',
    this.payerRewardFixed = 0,
    this.payerRewardRatio = 0,
    this.lgTime = '',
    this.lgExpiredTime = '',
    this.urecharge = 0,
    this.utimes = 0,
    this.ureward = 0,
  });

  factory MyTeamItemModel.fromJson(Map<String, dynamic> json) {
    return MyTeamItemModel(
      username: asString(json['username']),
      newCtCount: asInt(json['newCtCount']),
      newCwCount: asInt(json['newCwCount']),
      commission: asNum(json['commission']),
      dividend: asNum(json['dividend']),
      recharge: asNum(json['recharge']),
      reward: asNum(json['reward']),
      performance: asNum(json['performance']),
      bonus: asNum(json['bonus']),
      times: asInt(json['times']),
      teamWorkId: asInt(json['teamWorkId']),
      parentTeamWorkId: asInt(json['parentTeamWorkId']),
      parentCommission: asNum(json['parentCommission']),
      count: asInt(json['count']),
      teamCount: asInt(json['teamCount']),
      parentUser: asString(json['parentUser']),
      payerRewardFixed: asNum(json['payerRewardFixed']),
      payerRewardRatio: asNum(json['payerRewardRatio']),
      lgTime: asString(json['lgTime'] ?? ''),
      lgExpiredTime: asString(json['lgExpiredTime'] ?? ''),
      urecharge: asNum(json['urecharge']),
      utimes: asInt(json['utimes']),
      ureward: asNum(json['ureward']),
    );
  }
}

class MyTeamListDataModel {
  final int total;
  final List<MyTeamItemModel> list;

  const MyTeamListDataModel({required this.total, required this.list});

  factory MyTeamListDataModel.fromJson(Map<String, dynamic> json) {
    final rawList = json['list'];
    final list = rawList is List
        ? rawList
              .whereType<Map<String, dynamic>>()
              .map((e) => MyTeamItemModel.fromJson(e))
              .toList()
        : <MyTeamItemModel>[];

    return MyTeamListDataModel(total: asInt(json['total']), list: list);
  }
}

class IMyTeamListResModel extends ApiResponse<MyTeamListDataModel> {
  const IMyTeamListResModel({
    required super.code,
    required super.msg,
    super.data,
  });

  factory IMyTeamListResModel.fromJson(Map<String, dynamic> json) {
    final base = ApiResponse.fromJsonGeneric<MyTeamListDataModel>(
      json,
      (raw) => raw is Map<String, dynamic>
          ? MyTeamListDataModel.fromJson(raw)
          : null,
    );
    return IMyTeamListResModel(code: base.code, msg: base.msg, data: base.data);
  }
}
