/// 新手奖励
class INewbieRewardReqModel {}

/// 我的团队列表
class IMyTeamListReqModel {
  final int page;
  final int limit;

  const IMyTeamListReqModel({required this.page, required this.limit});

  Map<String, dynamic> toQueryParameters() {
    return {'page': page, 'limit': limit};
  }
}
