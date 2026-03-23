import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kumar_pay/app/toast/app_toast.dart';
import 'package:kumar_pay/core/di/upi_providers.dart';
import 'package:kumar_pay/core/utils/enum.dart';
import 'package:kumar_pay/core/utils/base.dart';
import 'package:get_storage/get_storage.dart';
import 'package:kumar_pay/app/config/storage_keys.dart';
import 'package:kumar_pay/presentation/viewmodels/upi_viewmodel/upi_viewmodel.dart';
import 'package:kumar_pay/store/actiions/upi/upi_actions.dart';
import 'package:kumar_pay/store/models/upi/upi_req_model.dart';
import 'package:kumar_pay/store/models/upi/upi_res_model.dart';

class AddUpiProviderInfo {
  final int ctType;
  final String name;
  final String desc;
  final Color color;
  final IconData icon;
  final String iconAsset;
  final bool enabled;
  const AddUpiProviderInfo(
    this.ctType,
    this.name,
    this.desc,
    this.color,
    this.icon,
    this.iconAsset,
    this.enabled,
  );
}

class AddUpiState {
  static const Object _unset = Object();

  final List<AddUpiProviderInfo> providers;
  final AddUpiProviderInfo? selectedProvider;
  final String? name;
  final String? upiNo;
  final List<String> backupUpiOptions;
  final String? selectedBackupUpi;
  final bool showBackupUpiSelect;
  final bool isSubmitting;
  final String? monitorflowCheckId;
  final bool showCaptchaDialog;
  final String? monitorflowPk;
  final String? monitorflowCtType;
  final String? monitorflowAccount;
  final String? otpErrorMessage;
  final int? systemBusyUntilMs;
  final String? busyLoadingMessage;
  final bool autoStartOtpCountdown;

  const AddUpiState({
    this.providers = const [],
    this.selectedProvider,
    this.name,
    this.upiNo,
    this.backupUpiOptions = const [],
    this.selectedBackupUpi,
    this.showBackupUpiSelect = false,
    this.isSubmitting = false,
    this.monitorflowCheckId,
    this.showCaptchaDialog = false,
    this.monitorflowPk,
    this.monitorflowCtType,
    this.monitorflowAccount,
    this.otpErrorMessage,
    this.systemBusyUntilMs,
    this.busyLoadingMessage,
    this.autoStartOtpCountdown = false,
  });

  AddUpiState copyWith({
    List<AddUpiProviderInfo>? providers,
    Object? selectedProvider = _unset,
    Object? name = _unset,
    Object? upiNo = _unset,
    List<String>? backupUpiOptions,
    Object? selectedBackupUpi = _unset,
    bool? showBackupUpiSelect,
    bool? isSubmitting,
    Object? monitorflowCheckId = _unset,
    bool? showCaptchaDialog,
    Object? monitorflowPk = _unset,
    Object? monitorflowCtType = _unset,
    Object? monitorflowAccount = _unset,
    Object? otpErrorMessage = _unset,
    Object? systemBusyUntilMs = _unset,
    Object? busyLoadingMessage = _unset,
    bool? autoStartOtpCountdown,
  }) {
    return AddUpiState(
      providers: providers ?? this.providers,
      selectedProvider: selectedProvider == _unset
          ? this.selectedProvider
          : selectedProvider as AddUpiProviderInfo?,
      name: name == _unset ? this.name : name as String?,
      upiNo: upiNo == _unset ? this.upiNo : upiNo as String?,
      backupUpiOptions: backupUpiOptions ?? this.backupUpiOptions,
      selectedBackupUpi: selectedBackupUpi == _unset
          ? this.selectedBackupUpi
          : selectedBackupUpi as String?,
      showBackupUpiSelect: showBackupUpiSelect ?? this.showBackupUpiSelect,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      monitorflowCheckId: monitorflowCheckId == _unset
          ? this.monitorflowCheckId
          : monitorflowCheckId as String?,
      showCaptchaDialog: showCaptchaDialog ?? this.showCaptchaDialog,
      monitorflowPk: monitorflowPk == _unset
          ? this.monitorflowPk
          : monitorflowPk as String?,
      monitorflowCtType: monitorflowCtType == _unset
          ? this.monitorflowCtType
          : monitorflowCtType as String?,
      monitorflowAccount: monitorflowAccount == _unset
          ? this.monitorflowAccount
          : monitorflowAccount as String?,
      otpErrorMessage: otpErrorMessage == _unset
          ? this.otpErrorMessage
          : otpErrorMessage as String?,
      systemBusyUntilMs: systemBusyUntilMs == _unset
          ? this.systemBusyUntilMs
          : systemBusyUntilMs as int?,
      busyLoadingMessage: busyLoadingMessage == _unset
          ? this.busyLoadingMessage
          : busyLoadingMessage as String?,
      autoStartOtpCountdown:
          autoStartOtpCountdown ?? this.autoStartOtpCountdown,
    );
  }
}

class AddUpiViewModel extends StateNotifier<AddUpiState> {
  final Ref ref;
  Timer? _checkTimer;
  Timer? _systemBusyTimer;
  bool _isSubmitting = false;
  static const bool _otpLimitEnabled = false;
  static const int _otpLimitCount = 3;
  static const Duration _otpLimitWindow = Duration(hours: 1);

  AddUpiViewModel(this.ref) : super(const AddUpiState());

  void loadProviders() {
    final raw = GetStorage().read(StorageKeys.ctTypes);
    final allowed = <int>{};
    if (raw is List) {
      for (final v in raw) {
        final parsed = int.tryParse(v.toString());
        if (parsed != null) allowed.add(parsed);
      }
    }
    state = state.copyWith(
      providers: UpiProviderType.values
          .where((p) => p != UpiProviderType.unknown)
          .map(
            (p) => AddUpiProviderInfo(
              p.ctType,
              p.label,
              p.desc,
              p.brandColor,
              p.icon,
              p.iconAsset,
              allowed.isEmpty ? true : allowed.contains(p.ctType),
            ),
          )
          .toList(),
    );
  }

  void selectProvider(AddUpiProviderInfo provider) {
    state = state.copyWith(
      selectedProvider: provider,
      showBackupUpiSelect: false,
      backupUpiOptions: const [],
      selectedBackupUpi: null,
      monitorflowCheckId: null,
      showCaptchaDialog: false,
      otpErrorMessage: null,
      autoStartOtpCountdown: false,
    );
  }

  void setName(String value) {
    state = state.copyWith(name: value);
  }

  void setUpiNo(String value) {
    state = state.copyWith(upiNo: value);
  }

  void _triggerOtpDialog({required bool autoStartCountdown}) {
    if (state.showCaptchaDialog) {
      state = state.copyWith(
        showCaptchaDialog: false,
        autoStartOtpCountdown: false,
      );
    }
    state = state.copyWith(
      showCaptchaDialog: true,
      otpErrorMessage: null,
      autoStartOtpCountdown: autoStartCountdown,
    );
  }

  void hideOtpDialog() {
    state = state.copyWith(
      showCaptchaDialog: false,
      otpErrorMessage: null,
      autoStartOtpCountdown: false,
    );
  }

  void resetForm() {
    _stopMonitorflowCheckPolling();
    _systemBusyTimer?.cancel();
    _isSubmitting = false;
    state = state.copyWith(
      name: null,
      upiNo: null,
      selectedProvider: null,
      backupUpiOptions: const [],
      selectedBackupUpi: null,
      showBackupUpiSelect: false,
      isSubmitting: false,
      monitorflowCheckId: null,
      showCaptchaDialog: false,
      monitorflowPk: null,
      monitorflowCtType: null,
      monitorflowAccount: null,
      otpErrorMessage: null,
      systemBusyUntilMs: null,
      busyLoadingMessage: null,
      autoStartOtpCountdown: false,
    );
  }

  void _setSystemBusyCooldown({int seconds = 5, String? message}) {
    final busyUntil = DateTime.now().millisecondsSinceEpoch + (seconds * 1000);
    _systemBusyTimer?.cancel();
    state = state.copyWith(
      systemBusyUntilMs: busyUntil,
      busyLoadingMessage: message,
    );
    _systemBusyTimer = Timer(Duration(seconds: seconds), () {
      if (!mounted) return;
      state = state.copyWith(systemBusyUntilMs: null, busyLoadingMessage: null);
    });
  }

  String _otpHistoryKey(String account) {
    return '${StorageKeys.otpRequestHistory}_$account';
  }

  List<int> _readOtpHistory(String account) {
    final raw = GetStorage().read(_otpHistoryKey(account));
    if (raw is List) {
      return raw
          .map((e) => int.tryParse(e.toString()))
          .whereType<int>()
          .toList();
    }
    return <int>[];
  }

  void _writeOtpHistory(String account, List<int> history) {
    GetStorage().write(_otpHistoryKey(account), history);
  }

  bool _recordOtpRequest(BuildContext context, String account) {
    if (!_otpLimitEnabled) return true;
    final now = DateTime.now().millisecondsSinceEpoch;
    final windowMs = _otpLimitWindow.inMilliseconds;
    final history = _readOtpHistory(
      account,
    ).where((t) => now - t < windowMs).toList()..sort();

    final remainSeconds = _getOtpRemainingSeconds(account);
    if (remainSeconds > 0) {
      final message =
          'OTP request limit reached. Try again in ${_formatRemainingTime(remainSeconds)} (max $_otpLimitCount per hour).';
      state = state.copyWith(otpErrorMessage: message);
      AppToast.show(context, message: message, type: AppToastType.warning);
      return false;
    }

    history.add(now);
    _writeOtpHistory(account, history);
    return true;
  }

  void selectBackupUpi(String value) {
    state = state.copyWith(selectedBackupUpi: value);
  }

  void prefillFromUpiInfo(UpiInfoModel info) {
    if (state.providers.isEmpty) {
      loadProviders();
    }

    AddUpiProviderInfo? provider;
    if (state.providers.isNotEmpty) {
      provider = state.providers.firstWhere(
        (p) => p.ctType == info.ctType,
        orElse: () => state.providers.first,
      );
    }
    state = state.copyWith(
      selectedProvider: provider,
      name: info.pnname,
      upiNo: info.account,
      showBackupUpiSelect: false,
      backupUpiOptions: const [],
      selectedBackupUpi: null,
    );
  }

  void _startMonitorflowCheckPolling({
    required String ctType,
    required String account,
    required String ctId,
  }) {
    _checkTimer?.cancel();
    final actions = ref.read(upiActionsProvider);

    Future<void> runOnce() async {
      await _runMonitorflowCheckOnce(
        actions: actions,
        ctType: ctType,
        account: account,
        ctId: ctId,
      );
    }

    runOnce();
    _checkTimer = Timer.periodic(const Duration(seconds: 4), (_) => runOnce());
  }

  Future<bool> _runMonitorflowCheckOnce({
    required UpiActions actions,
    required String ctType,
    required String account,
    required String ctId,
    bool allowOtpDialog = true,
  }) async {
    try {
      final res = await actions.getMonitorflowCheckApi(
        IGetMonitorflowTCheckReqModel(
          ctType: ctType,
          account: account,
          ctId: ctId,
        ),
      );
      if (res.success) {
        final backupUpi = (res.data?.backupUpi ?? const <String>[])
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
        final id = res.data?.id ?? '';
        final hasPayload = backupUpi.isNotEmpty || id.isNotEmpty;
        if (hasPayload && backupUpi.isEmpty && allowOtpDialog) {
          _triggerOtpDialog(autoStartCountdown: false);
        }
        if (backupUpi.isNotEmpty) {
          // 如果轮训接口查询到存在upi绑定选项，则展示选择框
          state = state.copyWith(
            showCaptchaDialog: false, // 隐藏发送otp
            showBackupUpiSelect: true, // 显示选择备选upi
            backupUpiOptions: backupUpi,
            monitorflowCheckId: id.isEmpty ? state.monitorflowCheckId : id,
            otpErrorMessage: null,
          );
        }
        if (backupUpi.isNotEmpty && id.isNotEmpty) {
          _stopMonitorflowCheckPolling();
        }
      }
    } catch (_) {
      // Polling failures should not block the main flow.
    }
    return state.showBackupUpiSelect;
  }

  void _stopMonitorflowCheckPolling() {
    _checkTimer?.cancel();
    _checkTimer = null;
  }

  int _getOtpRemainingSeconds(String account) {
    if (!_otpLimitEnabled) return 0;
    final now = DateTime.now().millisecondsSinceEpoch;
    final windowMs = _otpLimitWindow.inMilliseconds;
    final history = _readOtpHistory(
      account,
    ).where((t) => now - t < windowMs).toList()..sort();
    if (history.length < _otpLimitCount) return 0;
    final earliest = history.first;
    final waitMs = (earliest + windowMs) - now;
    if (waitMs <= 0) return 0;
    return (waitMs / 1000).ceil();
  }

  String _formatRemainingTime(int seconds) {
    final minutes = (seconds / 60).floor();
    final secs = seconds % 60;
    if (minutes <= 0) return '${secs}s';
    return '${minutes}m ${secs}s';
  }

  void _showOtpLimitToast(BuildContext context, String account) {
    final remain = _getOtpRemainingSeconds(account);
    if (remain <= 0) return;
    AppToast.show(
      context,
      message:
          'OTP request limit reached. Try again in ${_formatRemainingTime(remain)} (max $_otpLimitCount per hour).',
      type: AppToastType.warning,
    );
  }

  Future<void> handleMonitorFlow(BuildContext context) async {
    if (_isSubmitting) return;

    final provider = state.selectedProvider;
    final name = (state.name ?? '').trim();
    final upiNo = (state.upiNo ?? '').trim();

    if (provider == null) {
      AppToast.show(
        context,
        message: 'Please select a UPI provider',
        type: AppToastType.warning,
      );
      return;
    }

    if (name.isEmpty || upiNo.isEmpty) {
      AppToast.show(
        context,
        message: 'Please enter name and UPI account',
        type: AppToastType.warning,
      );
      return;
    }

    if (!isValidIndianPhone(upiNo)) {
      AppToast.show(
        context,
        message: 'Please enter a valid Indian phone number',
        type: AppToastType.warning,
      );
      return;
    }

    _isSubmitting = true;
    state = state.copyWith(isSubmitting: true);
    var requestFailed = false;

    final ctType = provider.ctType.toString();
    final account = upiNo;
    final pnname = name;

    const ctId = '';
    const pin = '';
    const deviceId = 'web';

    final remainSeconds = _getOtpRemainingSeconds(account);
    if (remainSeconds > 0) {
      final stopFurther = await _runMonitorflowCheckOnce(
        actions: ref.read(upiActionsProvider),
        ctType: ctType,
        account: account,
        ctId: ctId,
        allowOtpDialog: false,
      );
      _isSubmitting = false;
      state = state.copyWith(isSubmitting: false);
      if (!stopFurther) {
        _showOtpLimitToast(context, account);
      }
      return;
    }

    // 轮询接口如果存在 UPI 绑定选项，则阻止请求后续接口
    final stopFurther = await _runMonitorflowCheckOnce(
      actions: ref.read(upiActionsProvider),
      ctType: ctType,
      account: account,
      ctId: ctId,
      allowOtpDialog: true,
    );
    if (stopFurther) {
      _isSubmitting = false;
      state = state.copyWith(isSubmitting: false);
      _startMonitorflowCheckPolling(
        ctType: ctType,
        account: account,
        ctId: ctId,
      );
      return;
    }

    _startMonitorflowCheckPolling(ctType: ctType, account: account, ctId: ctId);

    try {
      final actions = ref.read(upiActionsProvider);
      final oneRes = await actions.getMonitorflowOneApi(
        IGetMonitorflowOneReqModel(
          ctType: ctType,
          account: account,
          pnname: pnname,
          pin: pin,
          ctId: ctId,
          deviceId: deviceId,
        ),
      );

      if (!oneRes.success) {
        AppToast.show(
          context,
          message: oneRes.msg ?? 'Request fail: getMonitorflowOneApi',
          type: AppToastType.error,
        );
        requestFailed = true;
        return;
      }

      final pk = oneRes.data?.pk ?? '';
      if (pk.isEmpty) {
        AppToast.show(
          context,
          message: 'Monitor step 1 returned an empty pk',
          type: AppToastType.error,
        );
        requestFailed = true;
        return;
      }

      state = state.copyWith(
        monitorflowPk: pk,
        monitorflowCtType: ctType,
        monitorflowAccount: account,
      );

      final twoRes = await actions.getMonitorflowTwoApi(
        IGetMonitorflowTwoReqModel(ctType: ctType, pk: pk, deviceId: deviceId),
      );

      if (!twoRes.success) {
        AppToast.show(
          context,
          message: twoRes.msg ?? 'Request fail: getMonitorflowTwoApi',
          type: AppToastType.error,
        );
        requestFailed = true;
        return;
      }

      // 校验用户手机号是否正常
      state = state.copyWith(isSubmitting: true);
      final checkRes = await actions.getCheckResultApi(
        IGetCheckResultReqModel(
          ctType: ctType,
          account: account,
          ctId: ctId,
          pk: pk,
        ),
      );

      // 用户未绑定过upi，显示发送otp弹窗（现在只有mobi才会提示）
      if (ctType == '2' &&
          checkRes.code == 3020 &&
          checkRes.msg == 'Account Need Request Otp') {
        state = state.copyWith(isSubmitting: false);
        _triggerOtpDialog(autoStartCountdown: true);
        requestFailed = true;
        return;
      }
      // 账号异常提示，建议更换账号继续绑定
      else if (!checkRes.success &&
          checkRes.msg == 'Blocked due to suspected fraud') {
        AppToast.show(
          context,
          message: 'Please change to another wallet to complete UPI binding.',
          type: AppToastType.error,
        );
        requestFailed = true;
        return;
      }
      // 系统繁忙提示 限制按钮5秒内无法再次点击
      else if (!checkRes.success && checkRes.msg == 'System is busy!') {
        state = state.copyWith(isSubmitting: false);
        _setSystemBusyCooldown(seconds: 5, message: 'send otp...');
        requestFailed = true;
        return;
      }
      // 错误提示
      else if (!checkRes.success && checkRes.msg != 'System is busy!') {
        AppToast.show(
          context,
          message: checkRes.msg ?? 'Request fail: getCheckResultApi',
          type: AppToastType.error,
        );
        requestFailed = true;
        return;
      }
      // 成功显示发送otp弹窗
      else if (checkRes.success) {
        state = state.copyWith(isSubmitting: false);
        _triggerOtpDialog(autoStartCountdown: true);
        requestFailed = true;
        return;
      }
    } catch (e) {
      requestFailed = true;
      AppToast.show(
        context,
        message: 'Monitoring failed, please try again later',
        type: AppToastType.error,
      );
    } finally {
      if (requestFailed) {
        _stopMonitorflowCheckPolling();
      }
      _isSubmitting = false;
      state = state.copyWith(isSubmitting: false);
    }
  }

  Future<void> handleAddUpi(BuildContext context) async {
    if (_isSubmitting) return;

    final upi = (state.selectedBackupUpi ?? '').trim();
    final pnname = (state.name ?? '').trim();
    final id = (state.monitorflowCheckId ?? '').trim();

    if (upi.isEmpty) {
      AppToast.show(
        context,
        message: 'Please select a UPI',
        type: AppToastType.warning,
      );
      return;
    }

    if (pnname.isEmpty || id.isEmpty) {
      AppToast.show(
        context,
        message: 'Please complete the monitoring flow first',
        type: AppToastType.warning,
      );
      return;
    }

    _isSubmitting = true;
    state = state.copyWith(isSubmitting: true);

    try {
      final actions = ref.read(upiActionsProvider);
      final res = await actions.addUpiApi(
        IAddUpiReqModel(upi: upi, pnname: pnname, id: id),
      );

      if (!res.success) {
        AppToast.show(
          context,
          message: res.msg ?? 'Request fail: addUpiApi',
          type: AppToastType.error,
        );
        return;
      }

      state = state.copyWith(
        showBackupUpiSelect: false,
        backupUpiOptions: const [],
        selectedBackupUpi: null,
        monitorflowCheckId: null,
        name: null,
        upiNo: null,
        selectedProvider: null,
      );

      // Navigate to the UPI list or refresh it.
      ref.read(upiViewModelProvider.notifier).getUpiList();
      if (context.mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      AppToast.show(
        context,
        message: 'UPI linked successfully',
        type: AppToastType.success,
      );
    } catch (_) {
      AppToast.show(
        context,
        message: 'Link failed, please try again later',
        type: AppToastType.error,
      );
    } finally {
      _isSubmitting = false;
      state = state.copyWith(isSubmitting: false);
    }
  }

  Future<bool> handleVerifyOtp(BuildContext context, String otp) async {
    final code = otp.trim();
    final ctType = (state.monitorflowCtType ?? '').trim();
    final ctTypeInt = int.tryParse(ctType) ?? -1;
    final otpLength = UpiProviderType.fromCtType(ctTypeInt).otpLength;
    if (code.length != otpLength) {
      AppToast.show(
        context,
        message: 'Please enter a $otpLength-digit OTP',
        type: AppToastType.warning,
      );
      return false;
    }
    final account = (state.monitorflowAccount ?? '').trim();
    final pk = (state.monitorflowPk ?? '').trim();
    // if (ctType.isEmpty || account.isEmpty || pk.isEmpty) {
    //   AppToast.show(
    //     context,
    //     message: 'Please restart the monitoring flow',
    //     type: AppToastType.warning,
    //   );
    //   return false;
    // }

    state = state.copyWith(isSubmitting: true, otpErrorMessage: null);

    try {
      final actions = ref.read(upiActionsProvider);
      final res = await actions.getMonitorflowThreeApi(
        IGetMonitorflowThreeReqModel(
          ctType: ctType,
          pk: pk,
          account: account,
          loginParams: {'otp': code},
        ),
      );

      if (!res.success) {
        state = state.copyWith(
          isSubmitting: false,
          otpErrorMessage: res.msg ?? 'OTP verification failed',
          showCaptchaDialog: true,
          autoStartOtpCountdown: false,
        );
        return false;
      }

      // 开启轮训获取upi绑定选项
      state = state.copyWith(
        isSubmitting: false,
        showCaptchaDialog: false,
        otpErrorMessage: null,
      );
      _startMonitorflowCheckPolling(ctType: ctType, account: account, ctId: '');
      return true;
    } catch (_) {
      state = state.copyWith(
        isSubmitting: false,
        otpErrorMessage: 'OTP verification failed, please try again later',
        showCaptchaDialog: true,
        autoStartOtpCountdown: false,
      );
      return false;
    }
  }

  Future<bool> handleResendOtp(BuildContext context) async {
    final ctType = (state.monitorflowCtType ?? '').trim();
    final account = (state.monitorflowAccount ?? '').trim();
    final pk = (state.monitorflowPk ?? '').trim();
    const ctId = '';

    if (account.isEmpty) return false;
    state = state.copyWith(otpErrorMessage: null);

    // if (ctType.isEmpty || account.isEmpty || pk.isEmpty) {
    //   AppToast.show(
    //     context,
    //     message: 'Please restart the monitoring flow',
    //     type: AppToastType.warning,
    //   );
    //   return false;
    // }

    try {
      final actions = ref.read(upiActionsProvider);
      final res = await actions.getCheckResultApi(
        IGetCheckResultReqModel(
          ctType: ctType,
          account: account,
          ctId: ctId,
          pk: pk,
        ),
      );

      if (!res.success) {
        state = state.copyWith(
          otpErrorMessage: res.msg ?? 'OTP request failed',
        );
        return false;
      }

      if (!_recordOtpRequest(context, account)) {
        return false;
      }

      return true;
    } catch (_) {
      state = state.copyWith(
        otpErrorMessage: 'Resend OTP failed, please try again later',
      );
      return false;
    }
  }

  @override
  void dispose() {
    _stopMonitorflowCheckPolling();
    _systemBusyTimer?.cancel();
    super.dispose();
  }
}

final addUpiViewModelProvider =
    StateNotifierProvider.autoDispose<AddUpiViewModel, AddUpiState>((ref) {
      final vm = AddUpiViewModel(ref);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        vm.loadProviders();
      });
      return vm;
    });
