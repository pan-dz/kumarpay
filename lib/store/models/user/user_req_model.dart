/// 玩家详情
class IUserInfoReqModel {}

/// Token 转交记录
class ITransferTokenHistoryReqModel {
  final int page;
  final int limit;

  const ITransferTokenHistoryReqModel({
    required this.page,
    required this.limit,
  });

  Map<String, dynamic> toQueryParameters() {
    return {'page': page, 'limit': limit};
  }
}
