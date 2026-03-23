import 'package:kumar_pay/store/models/login/login_res_model.dart';
import 'package:kumar_pay/store/request/login/login_api.dart';

class LoginActions {
  final LoginStoreApi loginStore;
  LoginActions(this.loginStore);

  /// 账号池列表
  Future<IAccountPoolListResModel> getAccountPoolListApi() async {
    return loginStore.getAccountPoolListRequest();
  }
}
