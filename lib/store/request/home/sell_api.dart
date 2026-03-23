import 'package:dio/dio.dart';
import 'package:kumar_pay/app/config/api.dart';
import 'package:kumar_pay/core/error/exceptions.dart';
import 'package:kumar_pay/core/network/dio_client.dart';
import 'package:kumar_pay/store/models/home/sell_res_model.dart';

class SellStoreApi {
  final DioClient dioClient;
  SellStoreApi(this.dioClient);

  /// 获取 Sell 信息 (userinfoAndAvailableCt)
  Future<IUserinfoAndAvailableCtResModel>
  userinfoAndAvailableCtRequest() async {
    try {
      final response = await dioClient.get(
        Api.getSellInfo,
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );
      return IUserinfoAndAvailableCtResModel.fromJson(response.data);
    } on AppException {
      rethrow;
    } catch (_) {
      throw UnknownException('Request fail: userinfoAndAvailableCtRequest');
    }
  }
}
