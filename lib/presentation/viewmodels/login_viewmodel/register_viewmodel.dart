import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';
import 'package:kumar_pay/app/config/base_config.dart';
import 'package:kumar_pay/app/config/storage_keys.dart';
import 'package:kumar_pay/app/toast/app_toast.dart';
import 'package:kumar_pay/core/di/providers.dart';
import 'package:kumar_pay/core/utils/base.dart';
import 'package:kumar_pay/core/network/dio_client.dart';
import 'package:kumar_pay/data/models/login/login_request_model.dart';
import 'package:kumar_pay/data/models/login/login_response_model.dart';
import 'package:kumar_pay/presentation/widgets/otp_verification_dialog.dart';
import 'package:kumar_pay/store/actiions/home/home_actions.dart';
import 'package:kumar_pay/store/request/home/home_api.dart';

class _CustomerServiceLaunchConfig {
  final String url;
  final int type;

  const _CustomerServiceLaunchConfig({required this.url, required this.type});
}

class RegisterViewModel extends ChangeNotifier {
  RegisterViewModel({String initialInviterCode = ''}) {
    final normalized = _normalizeInviterCode(initialInviterCode);
    if (normalized.isNotEmpty) {
      _inviterCode = normalized;
      _persistInviterCode(normalized);
    } else {
      final cached = _normalizeInviterCode(_readCachedInviterCode());
      if (cached.isNotEmpty) {
        _inviterCode = cached;
      } else if (!kIsWeb) {
        final fallback = _normalizeInviterCode(
          KumarBaseConfig.defaultInviterCode,
        );
        if (fallback.isNotEmpty) {
          _inviterCode = fallback;
          _persistInviterCode(fallback);
        }
      }
    }
    inviterController.text = _inviterCode;
    inviterController.addListener(_handleInviterControllerChanged);
  }
  String _phone = '';
  String _password = '';
  String _confirm = '';
  String _inviterCode = '';
  final TextEditingController inviterController = TextEditingController();
  bool _obscure = true;
  bool _obscureConfirm = false;
  String? _sendToken;
  bool _isLoading = false;
  String _customerServiceUrl = '';
  int _customerServiceType = 0;
  bool _showCustomerService = false;

  String get phone => _phone;
  String get password => _password;
  String get confirm => _confirm;
  String get inviterCode => _inviterCode;
  bool get obscure => _obscure;

  bool get canSubmit =>
      phoneValid &&
      passwordValid &&
      confirm.isNotEmpty &&
      !confirmMismatch &&
      _inviterCode.isNotEmpty;
  bool get confirmMismatch =>
      password.isNotEmpty && confirm.isNotEmpty && password != confirm;
  bool get phoneValid => isValidIndianPhone(phone);
  bool get phoneInvalid => phone.isNotEmpty && !phoneValid;
  bool get passwordValid => isValidPassword(password);
  bool get obscureConfirm => _obscureConfirm;
  String? get sendToken => _sendToken;
  bool get isLoading => _isLoading;
  String get customerServiceUrl => _customerServiceUrl;
  int get customerServiceType => _customerServiceType;
  bool get showCustomerService => _showCustomerService;
  bool get isStoredPhoneMatched {
    if (_phone.isEmpty) {
      return false;
    }
    final storedPhone = GetStorage().read<String>(StorageKeys.phone)?.trim();
    if (storedPhone == null || storedPhone.isEmpty) {
      return false;
    }
    return storedPhone == _phone;
  }

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

  void setConfirm(String value) {
    _confirm = value;
    notifyListeners();
  }

  void setInviterCode(String value) {
    _inviterCode = value;
    _persistInviterCode(value.trim());
    notifyListeners();
  }

  void _handleInviterControllerChanged() {
    final value = _normalizeInviterCode(inviterController.text);
    if (value == _inviterCode) return;
    _inviterCode = value;
    _persistInviterCode(value);
    notifyListeners();
  }

  String _readCachedInviterCode() {
    final cached = GetStorage().read(StorageKeys.inviterCode);
    if (cached is String) return cached.trim();
    return '';
  }

  void _persistInviterCode(String value) {
    final normalized = _normalizeInviterCode(value);
    final box = GetStorage();
    if (normalized.isEmpty) {
      box.remove(StorageKeys.inviterCode);
    } else {
      box.write(StorageKeys.inviterCode, normalized);
    }
  }

  String _normalizeInviterCode(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return '';

    final length = trimmed.length;
    for (var unitLen = 1; unitLen <= length ~/ 2; unitLen++) {
      if (length % unitLen != 0) continue;
      final unit = trimmed.substring(0, unitLen);
      var repeated = true;
      for (var i = 0; i < length; i += unitLen) {
        if (trimmed.substring(i, i + unitLen) != unit) {
          repeated = false;
          break;
        }
      }
      if (repeated) return unit;
    }
    return trimmed;
  }

  @override
  void dispose() {
    inviterController.removeListener(_handleInviterControllerChanged);
    inviterController.dispose();
    super.dispose();
  }

  void toggleObscure() {
    _obscure = !_obscure;
    notifyListeners();
  }

  void toggleObscureConfirm() {
    _obscureConfirm = !_obscureConfirm;
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
    } else if (!phoneValid) {
      AppToast.warning(context, "Please enter a valid phone number.");
      return false;
    } else if (!passwordValid) {
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
            purpose: 'register',
            sendtoken: _sendToken!,
          ),
        );

        if (codeResult.success) {
          return true;
        } else {
          _setLoading(false);
          Navigator.of(context).pop();
          await Future.delayed(const Duration(milliseconds: 200));
          AppToast.error(context, codeResult.msg ?? 'Failed to send SMS code.');
        }
      }
    } catch (e) {
      _setLoading(false);
      AppToast.error(context, 'Register exception: $e');
      return false;
    }
    return false;
  }

  /// 提交注册
  Future<void> register(
    BuildContext context, {
    required String sendToken,
    required String smsCode,
  }) async {
    try {
      // 获取Riverpod容器，读取登录用例
      final container = ProviderScope.containerOf(context, listen: false);
      final loginUseCase = container.read(loginProvider);

      final request = IRegisterReqModel(
        phone: _phone,
        password: _password,
        referral_code: _inviterCode,
        sendtoken: sendToken,
        smscode: smsCode,
        channel: KumarBaseConfig.channelId,
      );

      final IRegisterResModel resp = await loginUseCase.registerApi(request);
      if (resp.success && (resp.msg == 'success')) {
        if (context.mounted) {
          // 保存 手机号、密码
          final box = GetStorage();
          box.write(StorageKeys.phone, _phone);
          box.write(StorageKeys.pwd, _password);

          final registerUsername = resp.data?.username.trim().isNotEmpty == true
              ? resp.data!.username.trim()
              : _phone;
          final customerServiceConfig = await _loadCustomerServiceUrl(
            registerUsername,
          );

          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }

          _customerServiceUrl = customerServiceConfig.url;
          _customerServiceType = customerServiceConfig.type;
          _showCustomerService = true;
          notifyListeners();
          AppToast.success(context, 'Registration successful');
        }
      } else {
        AppToast.error(
          context,
          resp.msg ?? 'Register failed with unknown error.',
        );
      }
    } catch (e) {
      AppToast.error(context, 'Register exception: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// 弹出短信弹窗并防止重复点击
  Future<void> handleOpenOtpPopup(BuildContext context) async {
    if (isStoredPhoneMatched) {
      return;
    }

    if (phone.isEmpty || password.isEmpty) {
      AppToast.warning(
        context,
        "Please enter your mobile phone number and password.",
      );
      return;
    } else if (!phoneValid) {
      AppToast.warning(context, "Please enter a valid phone number.");
      return;
    } else if (!passwordValid) {
      AppToast.warning(
        context,
        "Passwords must be 6-30 characters long and can contain numbers or letters.",
      );
      return;
    } else if (_inviterCode.isEmpty) {
      AppToast.warning(context, "Please enter a valid inviter code.");
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
            await register(context, sendToken: _sendToken!, smsCode: code);
          },
        ),
      );
    } finally {
      _setLoading(false);
    }
  }

  Future<_CustomerServiceLaunchConfig> _loadCustomerServiceUrl(
    String username,
  ) async {
    try {
      final response = await HomeActions(
        HomeStoreApi(DioClient()),
      ).getCustomerByUserNameApi(username);

      final link = buildCustomerServiceLink(response.data);
      if (response.success) {
        if (link.isNotEmpty) {
          GetStorage().write(StorageKeys.customerServiceLink, link);
        } else {
          GetStorage().remove(StorageKeys.customerServiceLink);
        }
        return _CustomerServiceLaunchConfig(
          url: link,
          type: response.data?.type ?? 0,
        );
      }
    } catch (_) {}

    final cached = GetStorage().read<String>(StorageKeys.customerServiceLink);
    if (cached != null && cached.isNotEmpty) {
      return _CustomerServiceLaunchConfig(url: cached, type: 0);
    }
    return const _CustomerServiceLaunchConfig(url: '', type: 0);
  }
}
