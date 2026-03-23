import 'package:kumar_pay/store/models/user/user_req_model.dart';
import 'package:kumar_pay/store/models/user/user_res_model.dart';
import 'package:kumar_pay/store/request/user/user_api.dart';

class UserActions {
  final UserStoreApi userStore;
  UserActions(this.userStore);

  /// 用户信息
  Future<IUserInfoResModel> userInfoApi(IUserInfoReqModel request) async {
    return userStore.userInfoRequest(request);
  }

  /// 团队今日利润
  Future<ITodayProfitResModel> todayProfitApi() async {
    return userStore.todayProfitRequest();
  }

  /// 客服列表
  Future<ICustomerserviceResModel> customerserviceApi() async {
    return userStore.customerserviceRequest();
  }

  /// 最小出售 IToken
  Future<IMinSellITokenResModel> minSellITokenApi({
    required int min,
    required int max,
  }) async {
    return userStore.minSellITokenRequest(min: min, max: max);
  }

  /// token 转交记录
  Future<ITransferTokenHistoryResModel> transferTokenHistoryApi(
    ITransferTokenHistoryReqModel request,
  ) async {
    return userStore.transferTokenHistoryRequest(request);
  }
}
