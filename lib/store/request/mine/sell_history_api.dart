import 'package:dio/dio.dart';
import 'package:kumar_pay/app/config/api.dart';
import 'package:kumar_pay/core/error/exceptions.dart';
import 'package:kumar_pay/core/network/dio_client.dart';
import 'package:kumar_pay/store/models/mine/sell_history_req_model.dart';
import 'package:kumar_pay/store/models/mine/sell_history_res_model.dart';

class SellHistoryStoreApi {
  final DioClient dioClient;
  SellHistoryStoreApi(this.dioClient);

  /// 售出历史
  Future<IGetSellHistoryResModel> sellHistoryRequest(
    IGetSellHistoryReqModel request,
  ) async {
    try {
      final response = await dioClient.get(
        Api.sellHistory,
        queryParameters: request.toQueryParameters(),
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );
      return IGetSellHistoryResModel.fromJson(response.data);
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException('Request fail: sellHistoryRequest');
    }
  }
}
