import 'package:kumar_pay/store/models/buy/buy_req_model.dart';
import 'package:kumar_pay/store/models/buy/buy_res_model.dart';
import 'package:kumar_pay/store/models/buy/usdt_res_model.dart';
import 'package:kumar_pay/store/request/buy/buy_api.dart';

class BuyActions {
  final BuyStoreApi buyStore;
  BuyActions(this.buyStore);

  /// 新手奖励
  Future<IGetBuyOrderListResModel> getBuyOrderListApi(
    IGetBuyOrderListReqModel request,
  ) async {
    return buyStore.buyOrderListRequest(request);
  }

  /// 购买历史
  Future<IGetBuyHistoryResModel> getBuyHistoryApi(
    IGetBuyHistoryReqModel request,
  ) async {
    return buyStore.buyHistoryRequest(request);
  }

  /// 确认已付款
  Future<IConfirmPaidResModel> confirmPaidApi(
    IConfirmPaidReqModel request,
  ) async {
    return buyStore.confirmPaidRequest(request);
  }

  /// 购买-获取付款单
  Future<IBuyITokenResModel> buyITokenApi(IBuyITokenReqModel request) async {
    return buyStore.buyITokenRequest(request);
  }

  /// 付款单详情
  Future<IPaymentSlipDetailResModel> paymentslipDetailApi(
    IPaymentSlipDetailReqModel request,
  ) async {
    return buyStore.paymentslipDetailRequest(request);
  }

  /// USDT 列表
  Future<UsdtListResponse> getUsdtListApi({required String address}) async {
    return buyStore.getUsdtListRequest(address: address);
  }

  /// 获取 USDT 购买记录
  Future<IGetBuyUsdtListResModel> getBuyUsdtListApi() async {
    return buyStore.getBuyUsdtListRequest();
  }

  /// 取消购买
  Future<IProcessPaymentslipsResModel> processpaymentslipsApi({
    required String orderId,
    required String process,
    String? cancelRemark,
  }) async {
    return buyStore.processpaymentslipsRequest(
      orderId: orderId,
      process: process,
      cancelRemark: cancelRemark,
    );
  }

  /// USDT 购买通知（轮询）
  Future<void> buyUsdtNotifyApi() async {
    return buyStore.buyUsdtNotifyRequest();
  }
}
