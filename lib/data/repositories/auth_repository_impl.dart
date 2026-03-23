import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import 'package:kumar_pay/data/models/login/login_request_model.dart';
import 'package:kumar_pay/data/models/login/login_response_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource authImpl;
  AuthRepositoryImpl({required this.authImpl});

  /// 登录
  @override
  Future<LoginResModel> login(LoginReqModel request) async {
    try {
      return await authImpl.loginData(LoginReqModel.fromEntity(request));
    } catch (e) {
      rethrow;
    }
  }

  /// 校验是否验证码登陆
  @override
  Future<ICheckSmsNewResModel> checkSmsNewRep(
    ICheckSmsNewReqModel request,
  ) async {
    try {
      return await authImpl.checkSmsNewData(
        ICheckSmsNewReqModel.fromEntity(request),
      );
    } catch (e) {
      rethrow;
    }
  }

  /// 获取发送验证码的token
  @override
  Future<IGetSendTokenResModel> getSendTokenRep(
    IGetSendTokenReqModel request,
  ) async {
    try {
      return await authImpl.getSendTokenData(
        IGetSendTokenReqModel.fromEntity(request),
      );
    } catch (e) {
      rethrow;
    }
  }

  /// 获取发送验证码的token
  @override
  Future<ISendLoginSmsResModel> getSendLoginSmsRep(
    ISendLoginSmsReqModel request,
  ) async {
    try {
      return await authImpl.getSendLoginSmsData(
        ISendLoginSmsReqModel.fromEntity(request),
      );
    } catch (e) {
      rethrow;
    }
  }

  /// 重置密码
  @override
  Future<IResetPwdResModel> resetPwdRep(IResetPwdReqModel request) async {
    try {
      return await authImpl.resetPwdData(IResetPwdReqModel.fromEntity(request));
    } catch (e) {
      rethrow;
    }
  }

  /// 发送验证码
  @override
  Future<ISendSmsResModel> sendSmsCodeRep(ISendCodeReqModel request) async {
    try {
      return await authImpl.sendSmsCodeData(
        ISendCodeReqModel.fromEntity(request),
      );
    } catch (e) {
      rethrow;
    }
  }

  /// 发送验证码
  @override
  Future<IRegisterResModel> registerRep(IRegisterReqModel request) async {
    try {
      return await authImpl.registerData(IRegisterReqModel.fromEntity(request));
    } catch (e) {
      rethrow;
    }
  }
}
