import 'package:dio/dio.dart';
import 'package:kumar_pay/app/config/api.dart';
import 'package:kumar_pay/core/error/exceptions.dart';
import 'package:kumar_pay/core/network/dio_client.dart';
import 'package:kumar_pay/store/models/upi/upi_req_model.dart';
import 'package:kumar_pay/store/models/upi/upi_res_model.dart';

class UpiStoreApi {
  final DioClient dioClient;
  UpiStoreApi(this.dioClient);

  /// 获取UPI列表
  Future<IGetUpiListResModel> getUpiListRequest() async {
    try {
      final response = await dioClient.get(
        Api.upiList,
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );
      return IGetUpiListResModel.fromJson(response.data);
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException('Request fail: getUpiListRequest');
    }
  }

  /// 获取购买UPI列表
  Future<IGetBuyUpiListResModel> getBuyUpiListRequest() async {
    try {
      final response = await dioClient.get(
        Api.getBuyUpiList,
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );
      return IGetBuyUpiListResModel.fromJson(response.data);
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException('Request fail: getBuyUpiListRequest');
    }
  }

  /// 获取UPI详情
  Future<IGetUpiDetailResModel> getUpiDetailRequest(
    IGetUpiDetailReqModel request,
  ) async {
    try {
      final response = await dioClient.get(
        Api.upiDetail + request.name,
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );
      return IGetUpiDetailResModel.fromJson(response.data);
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException('Request fail: getUpiDetailRequest');
    }
  }

  /// 获取UPI详情（按ID）
  Future<IGetUpiDetailsResModel> getUpiDetailsRequest(
    IGetUpiDetailsReqModel request,
  ) async {
    try {
      final response = await dioClient.get(
        Api.getUpiDetails + request.id,
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );
      return IGetUpiDetailsResModel.fromJson(response.data);
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException('Request fail: getUpiDetailsRequest');
    }
  }

  /// 监控第一步
  Future<IGetMonitorflowOneResModel> getMonitorflowOneRequest(
    IGetMonitorflowOneReqModel request,
  ) async {
    try {
      final response = await dioClient.post(
        Api.monitorflowOne,
        data: request.toJson(),
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );
      return IGetMonitorflowOneResModel.fromJson(response.data);
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException('Request fail: getMonitorflowOneRequest');
    }
  }

  /// 监控第二步
  Future<IGetMonitorflowTwoResModel> getMonitorflowTwoRequest(
    IGetMonitorflowTwoReqModel request,
  ) async {
    try {
      final response = await dioClient.post(
        Api.monitorflowTwo,
        data: request.toJson(),
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );
      return IGetMonitorflowTwoResModel.fromJson(response.data);
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException('Request fail: getMonitorflowTwoRequest');
    }
  }

  /// 监控第三步
  Future<IGetMonitorflowTwoResModel> getMonitorflowThreeRequest(
    IGetMonitorflowThreeReqModel request,
  ) async {
    try {
      final response = await dioClient.post(
        Api.monitorflowThree,
        data: request.toJson(),
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );
      return IGetMonitorflowTwoResModel.fromJson(response.data);
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException('Request fail: getMonitorflowThreeRequest');
    }
  }

  /// 监控检查
  Future<IGetMonitorflowCheckResModel> getMonitorflowCheckRequest(
    IGetMonitorflowTCheckReqModel request,
  ) async {
    try {
      final response = await dioClient.post(
        Api.monitorflowCheck,
        data: request.toJson(),
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );
      return IGetMonitorflowCheckResModel.fromJson(response.data);
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException('Request fail: getMonitorflowCheckRequest');
    }
  }

  /// 获取监控结果
  Future<IGetCheckResultResModel> getCheckResultRequest(
    IGetCheckResultReqModel request,
  ) async {
    try {
      final response = await dioClient.post(
        Api.getCheckResult,
        data: request.toJson(),
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );
      return IGetCheckResultResModel.fromJson(response.data);
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException('Request fail: getCheckResultRequest');
    }
  }

  /// 绑定UPI
  Future<IAddUpiResModel> addUpiRequest(IAddUpiReqModel request) async {
    try {
      final response = await dioClient.post(
        Api.addUpi,
        data: request.toJson(),
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );
      return IAddUpiResModel.fromJson(response.data);
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException('Request fail: addUpiRequest');
    }
  }

  /// 更新UPI状态
  Future<IUpdateUpiStatusResModel> updateUpiStatusRequest(
    IUpdateUpiStatusReqModel request,
  ) async {
    try {
      final response = await dioClient.post(
        Api.updateUpiStatus,
        data: request.toJson(),
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );
      return IUpdateUpiStatusResModel.fromJson(response.data);
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException('Request fail: updateUpiStatusRequest');
    }
  }

  /// 停止出售UPI
  Future<IStopSellResModel> stopSellRequest(IStopSellReqModel request) async {
    try {
      final response = await dioClient.post(
        Api.stopSell,
        data: request.toJson(),
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );
      return IStopSellResModel.fromJson(response.data);
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException('Request fail: stopSellRequest');
    }
  }

  /// 开始出售UPI
  Future<IStartSellResModel> startSellRequest(
    IStartSellReqModel request,
  ) async {
    try {
      final response = await dioClient.post(
        Api.startSell,
        data: request.toJson(),
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );
      return IStartSellResModel.fromJson(response.data);
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException('Request fail: startSellRequest');
    }
  }
}
