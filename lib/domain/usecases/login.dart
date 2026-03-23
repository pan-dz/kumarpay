import '../repositories/auth_repository.dart';
import 'package:kumar_pay/data/models/login/login_request_model.dart';
import 'package:kumar_pay/data/models/login/login_response_model.dart';

class Login {
  final AuthRepository authRep;
  Login(this.authRep);

  /// 登陆
  Future<LoginResModel> loginApi(LoginReqModel request) async {
    return authRep.login(request);
  }

  /// 校验是否验证码登陆
  Future<ICheckSmsNewResModel> checkSmsNewApi(
    ICheckSmsNewReqModel request,
  ) async {
    return authRep.checkSmsNewRep(request);
  }

  /// 获取发送验证码的token
  Future<IGetSendTokenResModel> getSendTokenApi(
    IGetSendTokenReqModel request,
  ) async {
    return authRep.getSendTokenRep(request);
  }

  /// 发送登陆验证码
  Future<ISendLoginSmsResModel> sendLoginSmsApi(
    ISendLoginSmsReqModel request,
  ) async {
    return authRep.getSendLoginSmsRep(request);
  }

  /// 重置密码
  Future<IResetPwdResModel> resetPwdApi(IResetPwdReqModel request) async {
    return authRep.resetPwdRep(request);
  }

  /// 发送验证码
  Future<ISendSmsResModel> sendSmsCodeApi(ISendCodeReqModel request) async {
    return authRep.sendSmsCodeRep(request);
  }

  /// 注册
  Future<IRegisterResModel> registerApi(IRegisterReqModel request) async {
    return authRep.registerRep(request);
  }
}
