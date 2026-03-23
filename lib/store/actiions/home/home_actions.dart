import 'package:kumar_pay/store/models/home/home_res_model.dart';
import 'package:kumar_pay/store/request/home/home_api.dart';

class HomeActions {
  final HomeStoreApi homeStore;
  HomeActions(this.homeStore);

  /// 首页信息
  Future<IGetHomeInfoResModel> getHomeConfigApi() async {
    return homeStore.getHomeConfigRequest();
  }

  /// 获取未读消息
  Future<IUnReadCountResModel> unReadCountApi() async {
    return homeStore.unReadCountRequest();
  }

  Future<IGetCustomerServiceResModel> getCustomerServiceApi() async {
    return homeStore.getCustomerServiceRequest();
  }

  Future<IGetCustomerServiceResModel> getCustomerByUserNameApi(
    String username,
  ) async {
    return homeStore.getCustomerByUserNameRequest(username);
  }
}
