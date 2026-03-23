import 'package:kumar_pay/app/config/api.dart';
import 'package:kumar_pay/core/error/exceptions.dart';
import 'package:kumar_pay/core/network/dio_client.dart';
import 'package:kumar_pay/store/models/login/login_res_model.dart';

class LoginStoreApi {
  final DioClient dioClient;
  LoginStoreApi(this.dioClient);

  /// 获取账户池列表
  Future<IAccountPoolListResModel> getAccountPoolListRequest() async {
    try {
      final response = await dioClient.get(Api.accountPoolList);
      return IAccountPoolListResModel.fromJson(response.data);
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException('Request fail: getAccountPoolListRequest');
    }
  }
}
