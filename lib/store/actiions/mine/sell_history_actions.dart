import 'package:kumar_pay/store/models/mine/sell_history_req_model.dart';
import 'package:kumar_pay/store/models/mine/sell_history_res_model.dart';
import 'package:kumar_pay/store/request/mine/sell_history_api.dart';

class SellHistoryActions {
  final SellHistoryStoreApi sellHistoryStore;
  SellHistoryActions(this.sellHistoryStore);

  /// 售出历史
  Future<IGetSellHistoryResModel> getSellHistoryApi(
    IGetSellHistoryReqModel request,
  ) async {
    return sellHistoryStore.sellHistoryRequest(request);
  }
}
