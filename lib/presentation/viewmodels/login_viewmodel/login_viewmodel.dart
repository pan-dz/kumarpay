import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:dio/dio.dart';
import 'package:kumar_pay/app/toast/app_toast.dart';
import 'dart:io';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';
import 'package:kumar_pay/app/config/storage_keys.dart';
import 'package:kumar_pay/presentation/pages/layout_page.dart';
import 'package:kumar_pay/presentation/pages/login_page/modify_pwd_page.dart';
import 'package:kumar_pay/core/di/providers.dart';
import 'package:kumar_pay/core/di/user_providers.dart';
import 'package:kumar_pay/data/models/login/login_request_model.dart';
import 'package:kumar_pay/data/models/login/login_response_model.dart';
import 'package:kumar_pay/presentation/viewmodels/home_viewmodel/home_viewmodel.dart';
import 'package:kumar_pay/presentation/widgets/otp_verification_dialog.dart';
import 'package:kumar_pay/store/models/user/user_req_model.dart';
import 'package:kumar_pay/app/analytics/adjust_tracker.dart';

class LoginViewModel extends ChangeNotifier {
  String _phone = '';
  String _password = '';
  bool _obscure = true;
  bool _savePassword = false;
  String? _sendToken;
  bool _isLoading = false;
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  LoginViewModel() {
    _loadCachedCredentials();
  }

  String get phone => _phone;
  String get password => _password;
  bool get obscure => _obscure;
  bool get savePassword => _savePassword;
  String? get sendToken => _sendToken;
  bool get isLoading => _isLoading;

  void _setLoading(bool value) {
    if (_isLoading == value) return;
    _isLoading = value;
    notifyListeners();
  }

  void setPhone(String value) {
    _phone = value.trim();
    notifyListeners();
  }

  void setPassword(String value) {
    _password = value;
    notifyListeners();
  }

  void toggleObscure() {
    _obscure = !_obscure;
    notifyListeners();
  }

  void toggleSavePassword() {
    _savePassword = !_savePassword;
    notifyListeners();
  }

  void _loadCachedCredentials() {
    try {
      final box = GetStorage();
      final cachedPhone = box.read<String>(StorageKeys.phone);
      final cachedPwd = box.read<String>(StorageKeys.pwd);
      if (cachedPhone != null && cachedPhone.isNotEmpty) {
        _phone = cachedPhone;
        phoneController.text = cachedPhone;
      }
      if (cachedPwd != null && cachedPwd.isNotEmpty) {
        _password = cachedPwd;
        _savePassword = true; // 已缓存密码，默认视为选中
        passwordController.text = cachedPwd;
      }

      // 加载后通知界面刷新
      notifyListeners();
    } catch (_) {}
  }

  /// 校验是否需要显示登陆验证码
  Future<void> checkNeedVerificationCode(BuildContext context) async {
    if (_isLoading) return;

    if (_phone.isEmpty || _password.isEmpty) {
      AppToast.warning(
        context,
        "Please enter your mobile phone number and password.",
      );
      return;
    }

    try {
      _setLoading(true);
      // 获取Riverpod容器，读取登录用例
      final container = ProviderScope.containerOf(context, listen: false);
      final loginUseCase = container.read(loginProvider);

      // 生成/读取持久化的clientId
      final box = GetStorage();
      final clientId = _getOrCreateClientId(box);

      // 获取是否需要校验验证码
      final checkSmsNewResult = await loginUseCase.checkSmsNewApi(
        ICheckSmsNewReqModel(phone: _phone, password: _password),
      );

      if (checkSmsNewResult.success) {
        // 获取发送验证码token
        final getSendTokenRes = await loginUseCase.getSendTokenApi(
          IGetSendTokenReqModel(clientId: clientId, phone: _phone, token: '1'),
        );

        // 存在token 现在弹窗发送验证码
        if (getSendTokenRes.success && getSendTokenRes.data != null) {
          _sendToken = getSendTokenRes.data;
          try {
            await showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) => OtpVerificationDialog(
                phone: phone,
                onSendOtp: (phone) => sendCode(context),
                onVerified: (code) async {
                  await login(context, sendToken: sendToken, smsCode: code);
                },
              ),
            );
          } finally {
            _setLoading(false);
          }
        } else {
          // 不需要验证码，直接登录
          await login(context, sendToken: sendToken, smsCode: '');
        }
      } else {
        _setLoading(false);
        AppToast.error(
          context,
          checkSmsNewResult.msg ?? 'Failed to verify login method.',
        );
      }
    } catch (e) {
      _setLoading(false);
      AppToast.error(context, 'Login exception: $e');
    }
  }

  /// 发送验证码
  Future<bool> sendCode(BuildContext context) async {
    try {
      if (_sendToken == null || _sendToken!.isEmpty) {
        AppToast.error(context, 'Verification token is missing.');
        return false;
      }
      // 获取Riverpod容器，读取登录用例
      final container = ProviderScope.containerOf(context, listen: false);
      final loginUseCase = container.read(loginProvider);

      // 生成/读取持久化的clientId
      final box = GetStorage();
      final clientId = _getOrCreateClientId(box);

      await loginUseCase.sendLoginSmsApi(
        ISendLoginSmsReqModel(
          phone: _phone,
          password: _password,
          clientId: clientId,
          sendtoken: _sendToken!,
        ),
      );
      return true;
    } catch (e) {
      AppToast.error(context, 'Login exception: $e');
    }
    return false;
  }

  Future<void> login(
    BuildContext context, {
    String? sendToken,
    String? smsCode,
  }) async {
    try {
      // 获取Riverpod容器，读取登录用例
      final container = ProviderScope.containerOf(context, listen: false);
      final loginUseCase = container.read(loginProvider);

      // 生成/读取持久化的clientId
      final box = GetStorage();
      final clientId = _getOrCreateClientId(box);
      final ip = await _getLocalIp();

      final request = LoginReqModel(
        phone: _phone,
        password: _password,
        ip: ip ?? '',
        clientId: clientId,
        sendToken: sendToken,
        smsCode: smsCode,
      );

      // 登陆接口
      final LoginResModel resp = await loginUseCase.loginApi(request);
      if (resp.success && (resp.data?.isNotEmpty ?? false)) {
        // 保存token、手机号、密码
        box.write(StorageKeys.token, resp.data);
        box.write(StorageKeys.phone, _phone);
        if (_savePassword) {
          box.write(StorageKeys.pwd, _password);
        } else {
          box.remove(StorageKeys.pwd);
        }
        // 登录成功后拉取用户信息并缓存（不阻塞后续导航）
        try {
          final actions = container.read(userActionsProvider);
          final userRes = await actions.userInfoApi(IUserInfoReqModel());
          if (userRes.success && userRes.data != null) {
            box.write(StorageKeys.userInfo, userRes.data!.toJson());
          }
        } catch (_) {}

        container.read(homeViewModelProvider.notifier).refreshomeConfig();
        container.read(homeViewModelProvider.notifier).refreshCustomerService();
        Future.microtask(() async {
          try {
            await AdjustTracker.reportAdjustIds().timeout(
              const Duration(seconds: 3),
            );
          } catch (_) {}
        });

        // 先关闭弹窗，再提示成功，最后导航
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }

        AppToast.success(context, "Login successful.");

        await Future.delayed(const Duration(milliseconds: 1200));
        if (context.mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const LayoutPage()),
            (route) => false,
          );
        }
      } else {
        AppToast.error(context, resp.msg ?? 'Login failed with unknown error.');
      }
    } catch (e) {
      AppToast.error(context, 'Login exception: $e');
    } finally {
      _setLoading(false);
    }
  }

  String _getOrCreateClientId(GetStorage box) {
    final cached = box.read<String>(StorageKeys.clientId);
    if (cached != null && cached.isNotEmpty) return cached;
    final id = _generateSimpleUuid();
    box.write(StorageKeys.clientId, id);
    return id;
  }

  String _generateSimpleUuid() {
    const chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    const length = 40;
    Random rng;
    try {
      rng = Random.secure();
    } catch (_) {
      rng = Random();
    }
    final sb = StringBuffer();
    for (var i = 0; i < length; i++) {
      sb.write(chars[rng.nextInt(chars.length)]);
    }
    return sb.toString();
  }

  Future<String?> _getLocalIp() async {
    try {
      if (kIsWeb) {
        // web环境无法读取本地网卡，尝试通过公网服务获取外网IP
        final dio = Dio(
          BaseOptions(
            connectTimeout: const Duration(seconds: 3),
            receiveTimeout: const Duration(seconds: 3),
          ),
        );
        final resp = await dio.get(
          'https://api.ipify.org',
          queryParameters: {'format': 'json'},
        );
        final data = resp.data;
        if (data is Map &&
            data['ip'] is String &&
            (data['ip'] as String).isNotEmpty) {
          return data['ip'] as String;
        }
        return null;
      } else {
        final interfaces = await NetworkInterface.list(
          type: InternetAddressType.IPv4,
        );
        for (final itf in interfaces) {
          for (final addr in itf.addresses) {
            if (!addr.isLoopback) return addr.address;
          }
        }
      }
    } catch (_) {}
    return null;
  }

  void resetPassword(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => ModifyPwdPage(phone: _phone)));
  }

  @override
  void dispose() {
    phoneController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
