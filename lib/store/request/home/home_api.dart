import 'package:kumar_pay/app/config/api.dart';
import 'package:kumar_pay/core/error/exceptions.dart';
import 'package:kumar_pay/core/network/dio_client.dart';
import 'package:kumar_pay/store/models/home/home_res_model.dart';

class HomeStoreApi {
  final DioClient dioClient;
  HomeStoreApi(this.dioClient);

  /// 首页信息
  Future<IGetHomeInfoResModel> getHomeConfigRequest() async {
    try {
      final response = await dioClient.get(Api.getHomeConfig);
      return IGetHomeInfoResModel.fromJson(response.data);
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException('Request fail: getHomeConfigRequest');
    }
  }

  /// 获取未读消息
  Future<IUnReadCountResModel> unReadCountRequest() async {
    try {
      final response = await dioClient.get(Api.unReadCount);
      return IUnReadCountResModel.fromJson(response.data);
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException('Request fail: unReadCountRequest');
    }
  }

  Future<IGetCustomerServiceResModel> getCustomerServiceRequest() async {
    try {
      final response = await dioClient.get(Api.getCustomerService);
      return IGetCustomerServiceResModel.fromJson(response.data);
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException('Request fail: getCustomerServiceRequest');
    }
  }

  Future<IGetCustomerServiceResModel> getCustomerByUserNameRequest(
    String username,
  ) async {
    try {
      final response = await dioClient.get(
        Api.getCustomerByUserName,
        queryParameters: {'username': username},
      );
      return IGetCustomerServiceResModel.fromJson(response.data);
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException('Request fail: getCustomerByUserNameRequest');
    }
  }
}
