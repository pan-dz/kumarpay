/// 获取购买订单
class IGetBuyOrderListReqModel {
  final int page;
  final int limit;
  final int minAmount;
  final int maxAmount;
  final bool ifAsc;
  final int method;

  IGetBuyOrderListReqModel({
    required this.page,
    required this.limit,
    required this.minAmount,
    required this.maxAmount,
    required this.ifAsc,
    required this.method,
  });

  Map<String, dynamic> toQueryParameters() {
    return {
      'page': page,
      'limit': limit,
      'min_amount': minAmount,
      'max_amount': maxAmount,
      'if_asc': ifAsc,
      'method': method,
    };
  }
}

/// 购买历史
class IGetBuyHistoryReqModel {
  final int page;
  final int limit;
  final String currency;

  IGetBuyHistoryReqModel({
    required this.page,
    required this.limit,
    required this.currency,
  });

  Map<String, dynamic> toQueryParameters() {
    return {'page': page, 'limit': limit, 'currency': currency};
  }
}

/// 确认已付款
class IConfirmPaidReqModel {
  final String orderId;
  final String process;

  IConfirmPaidReqModel({required this.orderId, required this.process});

  Map<String, dynamic> toJson() {
    return {'order_id': orderId, 'process': process};
  }
}

/// 购买-获取付款单
class IBuyITokenReqModel {
  final String orderId;
  final int ctId;
  final int ctType;

  IBuyITokenReqModel({
    required this.orderId,
    required this.ctId,
    required this.ctType,
  });

  Map<String, dynamic> toJson() {
    return {'order_id': orderId, 'ct_id': ctId, 'ctType': ctType};
  }
}

/// 付款单详情
class IPaymentSlipDetailReqModel {
  final String id;
  final int ctime;

  IPaymentSlipDetailReqModel({required this.id, required this.ctime});

  Map<String, dynamic> toQueryParameters() {
    return {'id': id, 'ctime': ctime};
  }
}
