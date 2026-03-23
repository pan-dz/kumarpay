import 'package:kumar_pay/store/models/upi/upi_req_model.dart';
import 'package:kumar_pay/store/models/upi/upi_res_model.dart';
import 'package:kumar_pay/store/request/upi/upi_api.dart';

class UpiActions {
  final UpiStoreApi upiStore;
  UpiActions(this.upiStore);

  /// 获取upi列表
  Future<IGetUpiListResModel> getUpiListApi() async {
    return upiStore.getUpiListRequest();
  }

  /// 获取购买upi列表
  Future<IGetBuyUpiListResModel> getBuyUpiListApi() async {
    return upiStore.getBuyUpiListRequest();
  }

  /// 获取upi详情
  Future<IGetUpiDetailResModel> getUpiDetailApi(
    IGetUpiDetailReqModel request,
  ) async {
    return upiStore.getUpiDetailRequest(request);
  }

  /// 获取upi详情（按ID）
  Future<IGetUpiDetailsResModel> getUpiDetailsApi(
    IGetUpiDetailsReqModel request,
  ) async {
    return upiStore.getUpiDetailsRequest(request);
  }

  /// 监控第一步
  Future<IGetMonitorflowOneResModel> getMonitorflowOneApi(
    IGetMonitorflowOneReqModel request,
  ) async {
    return upiStore.getMonitorflowOneRequest(request);
  }

  /// 监控第二步
  Future<IGetMonitorflowTwoResModel> getMonitorflowTwoApi(
    IGetMonitorflowTwoReqModel request,
  ) async {
    return upiStore.getMonitorflowTwoRequest(request);
  }

  /// 监控第三步
  Future<IGetMonitorflowTwoResModel> getMonitorflowThreeApi(
    IGetMonitorflowThreeReqModel request,
  ) async {
    return upiStore.getMonitorflowThreeRequest(request);
  }

  /// 监控检查
  Future<IGetMonitorflowCheckResModel> getMonitorflowCheckApi(
    IGetMonitorflowTCheckReqModel request,
  ) async {
    return upiStore.getMonitorflowCheckRequest(request);
  }

  /// 获取监控结果
  Future<IGetCheckResultResModel> getCheckResultApi(
    IGetCheckResultReqModel request,
  ) async {
    return upiStore.getCheckResultRequest(request);
  }

  /// 绑定UPI
  Future<IAddUpiResModel> addUpiApi(IAddUpiReqModel request) async {
    return upiStore.addUpiRequest(request);
  }

  /// 更新UPI状态
  Future<IUpdateUpiStatusResModel> updateUpiStatusApi(
    IUpdateUpiStatusReqModel request,
  ) async {
    return upiStore.updateUpiStatusRequest(request);
  }

  /// 停止出售UPI
  Future<IStopSellResModel> stopSellApi(IStopSellReqModel request) async {
    return upiStore.stopSellRequest(request);
  }

  /// 开始出售UPI
  Future<IStartSellResModel> startSellApi(IStartSellReqModel request) async {
    return upiStore.startSellRequest(request);
  }
}
