import 'package:kumar_pay/store/models/home/sell_res_model.dart';
import 'package:kumar_pay/store/request/home/sell_api.dart';

class SellActions {
  final SellStoreApi sellStore;
  SellActions(this.sellStore);

  /// 获取 Sell 信息 (userinfoAndAvailableCt)
  Future<IUserinfoAndAvailableCtResModel> userinfoAndAvailableCtApi() async {
    return sellStore.userinfoAndAvailableCtRequest();
  }
}
