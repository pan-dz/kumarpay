// import 'package:kumar_pay/app/logger/app_logger.dart';

import '../models/login/login_request_model.dart';
import '../models/login/login_response_model.dart';
import '../../app/config/api.dart';
import '../../core/network/dio_client.dart';
import '../../core/error/exceptions.dart';
import 'package:dio/dio.dart';

class AuthRemoteDataSource {
  final DioClient dioClient;
  AuthRemoteDataSource(this.dioClient);

  /// 登陆
  Future<LoginResModel> loginData(LoginReqModel request) async {
    try {
      final response = await dioClient.post(
        Api.login,
        data: request.toQueryParameters(),
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );

      return LoginResModel.fromJson(response.data);
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException('Request fail: loginData');
    }
  }

  /// 校验是否验证码登陆
  Future<ICheckSmsNewResModel> checkSmsNewData(
    ICheckSmsNewReqModel request,
  ) async {
    try {
      final response = await dioClient.post(
        Api.checkSmsNew,
        data: request.toJson(),
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );
      return ICheckSmsNewResModel.fromJson(response.data);
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException('Request fail: checkSmsNewData');
    }
  }

  /// 获取发送验证码的token
  Future<IGetSendTokenResModel> getSendTokenData(
    IGetSendTokenReqModel request,
  ) async {
    try {
      final response = await dioClient.post(
        Api.getSendToken,
        queryParameters: request.toQueryParameters(),
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );
      return IGetSendTokenResModel.fromJson(response.data);
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException('Request fail: getSendTokenData');
    }
  }

  /// 获取发送登陆验证码
  Future<ISendLoginSmsResModel> getSendLoginSmsData(
    ISendLoginSmsReqModel request,
  ) async {
    try {
      final response = await dioClient.post(
        Api.sendLoginSms,
        data: request.toQueryParameters(),
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );
      return ISendLoginSmsResModel.fromJson(response.data);
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException('Request fail: getSendLoginSmsData');
    }
  }

  /// 重置密码
  Future<IResetPwdResModel> resetPwdData(IResetPwdReqModel request) async {
    try {
      final response = await dioClient.post(
        Api.resetPwd,
        data: request.toQueryParameters(),
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );
      return IResetPwdResModel.fromJson(response.data);
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException('Request fail: resetPwdData');
    }
  }

  /// 发送验证码
  Future<ISendSmsResModel> sendSmsCodeData(ISendCodeReqModel request) async {
    try {
      final response = await dioClient.post(
        Api.sendSmsCode,
        data: request.toQueryParameters(),
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );
      return ISendSmsResModel.fromJson(response.data);
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException('Request fail: sendSmsCodeData');
    }
  }

  /// 注册
  Future<IRegisterResModel> registerData(IRegisterReqModel request) async {
    try {
      final response = await dioClient.post(
        Api.register,
        data: request.toQueryParameters(),
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );
      if (response.data is Map<String, dynamic>) {
        return IRegisterResModel.fromJson(
          response.data as Map<String, dynamic>,
        );
      }
      return IRegisterResModel.fromJson({
        'code': 0,
        'msg': 'success',
        'data': null,
      });
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException('Request fail: registerData');
    }
  }
}
