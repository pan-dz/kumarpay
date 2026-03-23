/// 售出历史
class IGetSellHistoryReqModel {
  final int page;
  final int limit;
  final int status;

  IGetSellHistoryReqModel({
    required this.page,
    required this.limit,
    required this.status,
  });

  Map<String, dynamic> toQueryParameters() {
    return {'page': page, 'limit': limit, 'status': status};
  }
}
