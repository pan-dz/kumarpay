import 'package:kumar_pay/data/models/login/login_request_model.dart';
import 'package:kumar_pay/data/models/login/login_response_model.dart';

abstract class AuthRepository {
  /// 登陆
  Future<LoginResModel> login(LoginReqModel request);

  /// 校验是否验证码登陆
  Future<ICheckSmsNewResModel> checkSmsNewRep(ICheckSmsNewReqModel request);

  /// 获取发送验证码的token
  Future<IGetSendTokenResModel> getSendTokenRep(IGetSendTokenReqModel request);

  /// 发送登陆验证码
  Future<ISendLoginSmsResModel> getSendLoginSmsRep(
    ISendLoginSmsReqModel request,
  );

  /// 重置密码
  Future<IResetPwdResModel> resetPwdRep(IResetPwdReqModel request);

  /// 发送验证码
  Future<ISendSmsResModel> sendSmsCodeRep(ISendCodeReqModel request);

  /// 发送验证码
  Future<IRegisterResModel> registerRep(IRegisterReqModel request);
}
