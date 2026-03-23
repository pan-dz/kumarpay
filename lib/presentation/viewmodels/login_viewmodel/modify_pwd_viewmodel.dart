import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';
import 'package:kumar_pay/app/config/storage_keys.dart';
import 'package:kumar_pay/app/toast/app_toast.dart';
import 'package:kumar_pay/core/di/providers.dart';
import 'package:kumar_pay/core/utils/base.dart';
import 'package:kumar_pay/data/models/login/login_request_model.dart';
import 'package:kumar_pay/data/models/login/login_response_model.dart';
import 'package:kumar_pay/presentation/pages/login_page/login_page.dart';
import 'package:kumar_pay/presentation/widgets/success_result_page.dart';
import 'package:kumar_pay/presentation/widgets/otp_verification_dialog.dart';

class ModifyPwdViewModel extends ChangeNotifier {
  ModifyPwdViewModel({this.phone = ''});

  String phone;
  String password = '';
  String confirm = '';
  bool obscure = true;
  bool obscureConfirm = true;
  String? _sendToken;
  bool _isLoading = false;

  bool get canSubmit =>
      phoneValid && passwordValid && confirm.isNotEmpty && !confirmMismatch;
  bool get confirmMismatch =>
      password.isNotEmpty && confirm.isNotEmpty && password != confirm;

  bool get phoneValid => isValidIndianPhone(phone);
  bool get phoneInvalid => phone.isNotEmpty && !phoneValid;
  bool get passwordValid => isValidPassword(password);
  String? get sendToken => _sendToken;
  bool get isLoading => _isLoading;

  void _setLoading(bool value) {
    if (_isLoading == value) return;
    _isLoading = value;
    notifyListeners();
  }

  void setPassword(String value) {
    password = value;
    notifyListeners();
  }

  void setConfirm(String value) {
    confirm = value;
    notifyListeners();
  }

  void setPhone(String value) {
    phone = value.trim();
    notifyListeners();
  }

  void toggleObscure() {
    obscure = !obscure;
    notifyListeners();
  }

  void toggleObscureConfirm() {
    obscureConfirm = !obscureConfirm;
    notifyListeners();
  }

  /// 发送验证码
  Future<bool> sendCode(BuildContext context) async {
    if (phone.isEmpty || password.isEmpty) {
      AppToast.warning(
        context,
        "Please enter your mobile phone number and password.",
      );
      return false;
    }
    if (!phoneValid) {
      AppToast.warning(context, "Please enter a valid phone number.");
      return false;
    }
    if (!passwordValid) {
      AppToast.warning(
        context,
        "Passwords must be 6-30 characters long and can contain numbers or letters.",
      );
      return false;
    }

    try {
      // 获取Riverpod容器，读取登录用例
      final container = ProviderScope.containerOf(context, listen: false);
      final loginUseCase = container.read(loginProvider);

      // 获取发送验证码token
      final getSendTokenRes = await loginUseCase.getSendTokenApi(
        IGetSendTokenReqModel(phone: null, clientId: null, token: '1'),
      );

      // 存在token 发送验证码
      if (getSendTokenRes.success && getSendTokenRes.data != null) {
        _sendToken = getSendTokenRes.data;
        final codeResult = await loginUseCase.sendSmsCodeApi(
          ISendCodeReqModel(
            phone: phone,
            purpose: 'forgotpassword',
            sendtoken: _sendToken!,
          ),
        );
        if (codeResult.success) {
          return true;
        } else {
          AppToast.error(context, codeResult.msg ?? 'Send code failed.');
          return false;
        }
      }
    } catch (e) {
      _setLoading(false);
      AppToast.error(context, 'Modify password exception: $e');
      return false;
    }
    return false;
  }

  /// 提交修改密码
  Future<void> modifyPwd(
    BuildContext context, {
    required String sendToken,
    required String smsCode,
  }) async {
    if (!canSubmit) {
      AppToast.warning(context, "Please fill in all fields correctly.");
      return;
    }

    try {
      // 获取Riverpod容器，读取登录用例
      final container = ProviderScope.containerOf(context, listen: false);
      final loginUseCase = container.read(loginProvider);

      // 重置密码
      final IResetPwdResModel resp = await loginUseCase.resetPwdApi(
        IResetPwdReqModel(
          phone: phone,
          smscode: smsCode,
          sendtoken: sendToken,
          password: password,
        ),
      );

      if (resp.success && resp.msg == 'success') {
        // 修改成功后，保存密码到本地
        GetStorage().write(StorageKeys.pwd, password);

        Navigator.of(context).pop();
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => SuccessResultPage(
              buttonText: 'Login',
              title: 'Password reset successful',
              assetIconPath: 'assets/images/success.webp',
              onButtonPressed: () {
                final box = GetStorage();
                box.remove(StorageKeys.token);
                box.remove(StorageKeys.userInfo);
                box.remove(StorageKeys.reward);
                box.remove(StorageKeys.customerServiceLink);
                box.remove(StorageKeys.usdtExchangerate);
                box.remove(StorageKeys.ctTypes);
                box.remove(StorageKeys.newbieDialogShow);

                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                  (route) => false,
                );
              },
            ),
          ),
        );
      } else {
        AppToast.error(context, resp.msg ?? 'Modify password failed.');
      }
    } catch (e) {
      AppToast.error(context, 'Modify password exception: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// 弹出短信弹窗并防止重复点击
  Future<void> handleOpenModify(BuildContext context) async {
    if (!canSubmit) {
      AppToast.warning(context, "Please fill in all fields correctly.");
      return;
    }
    if (_isLoading) return;
    _setLoading(true);
    try {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => OtpVerificationDialog(
          phone: phone,
          onSendOtp: (phone) => sendCode(context),
          onVerified: (code) async {
            await modifyPwd(
              context,
              sendToken: _sendToken ?? '',
              smsCode: code,
            );
          },
        ),
      );
    } finally {
      _setLoading(false);
    }
  }
}
