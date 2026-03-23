import 'package:dio/dio.dart';
import 'package:kumar_pay/app/config/api.dart';
import 'package:kumar_pay/core/error/exceptions.dart';
import 'package:kumar_pay/core/network/dio_client.dart';
import 'package:kumar_pay/store/models/buy/buy_req_model.dart';
import 'package:kumar_pay/store/models/buy/buy_res_model.dart';
import 'package:kumar_pay/store/models/buy/usdt_res_model.dart';

class BuyStoreApi {
  final DioClient dioClient;
  BuyStoreApi(this.dioClient);

  /// 获取购买订单
  Future<IGetBuyOrderListResModel> buyOrderListRequest(
    IGetBuyOrderListReqModel request,
  ) async {
    try {
      final response = await dioClient.get(
        Api.buyOrderList,
        queryParameters: request.toQueryParameters(),
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );
      return IGetBuyOrderListResModel.fromJson(response.data);
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException('Request fail: buyOrderListRequest');
    }
  }

  /// 购买历史
  Future<IGetBuyHistoryResModel> buyHistoryRequest(
    IGetBuyHistoryReqModel request,
  ) async {
    try {
      final response = await dioClient.get(
        Api.buyHistory,
        queryParameters: request.toQueryParameters(),
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );
      return IGetBuyHistoryResModel.fromJson(response.data);
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException('Request fail: buyHistoryRequest');
    }
  }

  /// 取消购买
  Future<IProcessPaymentslipsResModel> processpaymentslipsRequest({
    required String orderId,
    required String process,
    String? cancelRemark,
  }) async {
    try {
      final response = await dioClient.post(
        Api.processpaymentslips,
        data: {
          'order_id': orderId,
          'process': process,
          if (cancelRemark != null) 'cancel_remark': cancelRemark,
        },
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );
      return IProcessPaymentslipsResModel.fromJson(response.data);
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException('Request fail: processpaymentslipsRequest');
    }
  }

  /// 确认已付款
  Future<IConfirmPaidResModel> confirmPaidRequest(
    IConfirmPaidReqModel request,
  ) async {
    try {
      final response = await dioClient.post(
        Api.confirmPaid,
        data: request.toJson(),
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );
      return IConfirmPaidResModel.fromJson(response.data);
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException('Request fail: confirmPaidRequest');
    }
  }

  /// 购买-获取付款单
  Future<IBuyITokenResModel> buyITokenRequest(
    IBuyITokenReqModel request,
  ) async {
    try {
      final response = await dioClient.post(
        Api.buyIToken,
        data: request.toJson(),
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );
      return IBuyITokenResModel.fromJson(response.data);
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException('Request fail: buyITokenRequest');
    }
  }

  /// 付款单详情
  Future<IPaymentSlipDetailResModel> paymentslipDetailRequest(
    IPaymentSlipDetailReqModel request,
  ) async {
    try {
      final response = await dioClient.get(
        Api.paymentslipDetail,
        queryParameters: request.toQueryParameters(),
      );
      return IPaymentSlipDetailResModel.fromJson(response.data);
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException('Request fail: paymentslipDetailRequest');
    }
  }

  /// USDT 列表
  Future<UsdtListResponse> getUsdtListRequest({required String address}) async {
    try {
      final response = await dioClient.get(
        '${Api.getUsdtList}$address/transactions/trc20',
        queryParameters: {'limit': 200},
      );
      return UsdtListResponse.fromJson(
        response.data is Map<String, dynamic>
            ? response.data as Map<String, dynamic>
            : <String, dynamic>{},
      );
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException('Request fail: getUsdtListRequest');
    }
  }

  /// 获取 USDT 购买记录
  Future<IGetBuyUsdtListResModel> getBuyUsdtListRequest() async {
    try {
      final response = await dioClient.get(
        Api.getBuyUsdtList,
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );
      return IGetBuyUsdtListResModel.fromJson(response.data);
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException('Request fail: getBuyUsdtListRequest');
    }
  }

  /// USDT 购买通知（轮询）
  Future<void> buyUsdtNotifyRequest() async {
    try {
      await dioClient.get(
        Api.buyUsdtNotify,
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException('Request fail: buyUsdtNotifyRequest');
    }
  }
}
