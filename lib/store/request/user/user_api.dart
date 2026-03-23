import 'package:kumar_pay/app/config/api.dart';
import 'package:kumar_pay/core/error/exceptions.dart';
import 'package:kumar_pay/core/network/dio_client.dart';
import 'package:kumar_pay/store/models/user/user_req_model.dart';
import 'package:kumar_pay/store/models/user/user_res_model.dart';

class UserStoreApi {
  final DioClient dioClient;
  UserStoreApi(this.dioClient);

  /// 用户详情
  Future<IUserInfoResModel> userInfoRequest(IUserInfoReqModel request) async {
    try {
      final response = await dioClient.get(Api.userinfo);
      return IUserInfoResModel.fromJson(response.data);
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException('Request fail: userInfoRequest');
    }
  }

  /// 团队今日利润
  Future<ITodayProfitResModel> todayProfitRequest() async {
    try {
      final response = await dioClient.get(Api.todayProfit);
      return ITodayProfitResModel.fromJson(response.data);
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException('Request fail: todayProfitRequest');
    }
  }

  /// 客服列表
  Future<ICustomerserviceResModel> customerserviceRequest() async {
    try {
      final response = await dioClient.get(Api.customerservice);
      return ICustomerserviceResModel.fromJson(response.data);
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException('Request fail: customerserviceRequest');
    }
  }

  /// 最小出售 IToken
  Future<IMinSellITokenResModel> minSellITokenRequest({
    required int min,
    required int max,
  }) async {
    try {
      final response = await dioClient.get('${Api.minSellIToken}/$min/$max');
      return IMinSellITokenResModel.fromJson(response.data);
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException('Request fail: minSellITokenRequest');
    }
  }

  /// token 转交记录
  Future<ITransferTokenHistoryResModel> transferTokenHistoryRequest(
    ITransferTokenHistoryReqModel request,
  ) async {
    try {
      final response = await dioClient.get(
        Api.transferTokenHistory,
        queryParameters: request.toQueryParameters(),
      );
      return ITransferTokenHistoryResModel.fromJson(response.data);
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException('Request fail: transferTokenHistoryRequest');
    }
  }
}
