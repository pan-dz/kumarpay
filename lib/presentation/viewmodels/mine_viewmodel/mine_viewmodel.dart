import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kumar_pay/app/config/base_config.dart';
import 'package:kumar_pay/core/di/user_providers.dart';
import 'package:kumar_pay/presentation/pages/active_page/newbie_reward.dart';
import 'package:kumar_pay/presentation/widgets/popup_dialog.dart';
import 'package:kumar_pay/store/actiions/user/user_actions.dart';
import 'package:kumar_pay/store/models/user/user_req_model.dart';
import 'package:kumar_pay/store/request/user/user_api.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:get_storage/get_storage.dart';
import 'package:kumar_pay/app/config/storage_keys.dart';

class MineState {
  final String userName;
  final String teamWorkId;
  final String rewardText;
  final String iToken;
  final String phone;
  final int minSellIToken;
  final String frozenItoken;
  final String userSellToken;

  final String todayProfit;
  final String tradeProfit;
  final String teamProfit;
  final String eventProfit;

  final String orderSizeRange;
  final int? minSize;
  final int? maxSize;
  final bool isTodayProfitLoading;
  final bool isUserInfoLoading;
  final bool isOrderSizeLoading;

  const MineState({
    this.userName = '',
    this.teamWorkId = '',
    this.rewardText = '0',
    this.iToken = '0.0',
    this.phone = '',
    this.minSellIToken = 0,
    this.frozenItoken = '0.0',
    this.userSellToken = '',

    this.todayProfit = '0.0',
    this.tradeProfit = '0.0',
    this.teamProfit = '0.0',
    this.eventProfit = '0.0',

    this.orderSizeRange = '',
    this.minSize,
    this.maxSize,
    this.isTodayProfitLoading = false,
    this.isUserInfoLoading = false,
    this.isOrderSizeLoading = false,
  });

  MineState copyWith({
    String? userName,
    String? teamWorkId,
    String? rewardText,
    String? iToken,
    String? phone,
    int? minSellIToken,
    String? frozenItoken,
    String? userSellToken,
    String? todayProfit,
    String? tradeProfit,
    String? teamProfit,
    String? eventProfit,
    String? orderSizeRange,
    int? minSize,
    int? maxSize,
    bool? isTodayProfitLoading,
    bool? isUserInfoLoading,
    bool? isOrderSizeLoading,
  }) {
    return MineState(
      userName: userName ?? this.userName,
      teamWorkId: teamWorkId ?? this.teamWorkId,
      rewardText: rewardText ?? this.rewardText,
      iToken: iToken ?? this.iToken,
      phone: phone ?? this.phone,
      minSellIToken: minSellIToken ?? this.minSellIToken,
      frozenItoken: frozenItoken ?? this.frozenItoken,
      userSellToken: userSellToken ?? this.userSellToken,

      orderSizeRange: orderSizeRange ?? this.orderSizeRange,
      minSize: minSize ?? this.minSize,
      maxSize: maxSize ?? this.maxSize,

      isTodayProfitLoading: isTodayProfitLoading ?? this.isTodayProfitLoading,
      isUserInfoLoading: isUserInfoLoading ?? this.isUserInfoLoading,
      isOrderSizeLoading: isOrderSizeLoading ?? this.isOrderSizeLoading,

      todayProfit: todayProfit ?? this.todayProfit,
      tradeProfit: tradeProfit ?? this.tradeProfit,
      teamProfit: teamProfit ?? this.teamProfit,
      eventProfit: eventProfit ?? this.eventProfit,
    );
  }
}

class MineViewModel extends StateNotifier<MineState> {
  final UserActions actions;
  bool _newbieDialogOpen = false;
  MineViewModel(this.actions) : super(const MineState());

  void init() {
    // _fetchUserInfo();
    _loadCachedUserInfo();
    _loadRewardText();
  }

  void _loadRewardText() {
    final reward = GetStorage().read<String>(StorageKeys.reward);
    if (reward != null) {
      state = state.copyWith(rewardText: reward);
    }
  }

  void _loadCachedUserInfo() {
    try {
      final box = GetStorage();
      final raw = box.read(StorageKeys.userInfo);
      if (raw is Map) {
        final map = raw.cast<String, dynamic>();
        final itoken = map['itoken'];
        state = state.copyWith(phone: map['mobile'].toString());

        final minSellIToken = map['minSellIToken'];
        if (minSellIToken != null) {
          final parsed = int.tryParse(minSellIToken.toString());
          state = state.copyWith(minSellIToken: parsed ?? 0);
        }

        final userSellToken = map['userSellToken'];
        if (userSellToken != null) {
          final tokenText = userSellToken.toString();
          state = state.copyWith(userSellToken: tokenText, orderSizeRange: '');
        }

        if (itoken is num) {
          state = state.copyWith(iToken: itoken.toString());
        } else if (itoken != null) {
          final parsed = num.tryParse(itoken.toString());
          state = state.copyWith(iToken: (parsed ?? itoken).toString());
        }
      }
    } catch (_) {}
  }

  Future<bool> updateOrderSizeRange(String range) async {
    state = state.copyWith(orderSizeRange: range);

    final parts = range.contains('~') ? range.split('~') : range.split(',');
    if (parts.length < 2) return false;
    final min = int.tryParse(parts[0].trim());
    final max = int.tryParse(parts[1].trim());
    if (min == null || max == null) return false;
    if (min < 100) return false;

    try {
      state = state.copyWith(isOrderSizeLoading: true);
      final result = await actions.minSellITokenApi(min: min, max: max);
      if (result.success) {
        state = state.copyWith(userSellToken: '$min,$max');
      }
      return result.success;
    } catch (_) {
      return false;
    } finally {
      state = state.copyWith(isOrderSizeLoading: false);
    }
  }

  void signOut() {
    // 清理本地 token
    final box = GetStorage();
    box.remove(StorageKeys.token);
    box.remove(StorageKeys.userInfo);
    box.remove(StorageKeys.reward);
    box.remove(StorageKeys.customerServiceLink);
    box.remove(StorageKeys.usdtExchangerate);
    box.remove(StorageKeys.ctTypes);
    box.remove(StorageKeys.newbieDialogShow);
  }

  void onStatsTap() {}

  void setMinSize(int value) {
    final next = value < 100 ? 100 : value;
    state = state.copyWith(minSize: next);
  }

  void setMaxSize(int value) {
    state = state.copyWith(maxSize: value);
  }

  void resetOrderSizeInputs() {
    final raw = state.userSellToken;
    final trimmed = raw.trim();
    final commaStripped = trimmed.replaceAll(',', '');
    if (trimmed.isEmpty || commaStripped.isEmpty) {
      state = state.copyWith(minSize: 100, maxSize: 100000);
      return;
    }

    int? parsePart(String raw, int index) {
      if (raw.isEmpty) return null;
      final parts = raw.split(',');
      if (parts.length <= index) return null;
      return int.tryParse(parts[index].trim());
    }

    final min =
        parsePart(state.userSellToken, 0) ??
        int.tryParse(state.minSellIToken.toString()) ??
        100;
    final max = parsePart(state.userSellToken, 1) ?? 100000;

    state = state.copyWith(minSize: min, maxSize: max);
  }

  // 对外暴露的刷新方法，供页面切换时调用
  Future<void> refreshUserInfo(BuildContext context) async {
    await _fetchUserInfo(context);
  }

  Future<void> _fetchUserInfo(BuildContext context) async {
    if (state.isUserInfoLoading) return;
    state = state.copyWith(isUserInfoLoading: true);
    try {
      final box = GetStorage();
      final userRes = await actions.userInfoApi(IUserInfoReqModel());
      if (userRes.success && userRes.data != null) {
        box.write(StorageKeys.userInfo, userRes.data!.toJson());

        state = state.copyWith(
          userName: userRes.data?.username,
          teamWorkId: userRes.data!.teamWorkId.toString(),
          iToken: userRes.data!.itoken.toString(),
          frozenItoken: userRes.data!.frozenItoken.toString(),
          minSellIToken: userRes.data!.minSellIToken,
          userSellToken: userRes.data!.userSellToken.toString(),
          orderSizeRange: _formatOrderSizeRange(
            userRes.data!.userSellToken.toString(),
          ),
          todayProfit: userRes.data!.todayProfit.toString(),
        );
        final shown = box.read<bool>(StorageKeys.newbieDialogShow) ?? false;
        if (userRes.data!.ifFinishNewbieActivity == 0 &&
            !shown &&
            context.mounted &&
            !_newbieDialogOpen) {
          _newbieDialogOpen = true;
          box.write(StorageKeys.newbieDialogShow, true);
          PopupDialog.show(
            context: context,
            config: PopupDialogConfig(
              position: DialogPosition.center,
              title: 'Kind tips',
              showCloseButton: false,
              showFooterButtons: true,
              minHeight: 130,
            ),
            child: const Text(
              'Newbie Tutorial reward not completed.',
              style: TextStyle(
                color: Color(0xFF8F9098),
                fontSize: 14,
                fontWeight: FontWeight.w500,
                height: 1.2,
              ),
            ),
            onCancel: () {
              _newbieDialogOpen = false;
            },
            onConfirm: () {
              _newbieDialogOpen = false;
              final navigator = Navigator.of(context, rootNavigator: true);
              if (navigator.canPop()) {
                navigator.pop();
              }
              Future.microtask(() {
                navigator.push(
                  MaterialPageRoute(builder: (_) => const NewbieRewardPage()),
                );
              });
            },
          );
        }
      }
    } catch (e) {
      return;
    } finally {
      state = state.copyWith(isUserInfoLoading: false);
    }
  }

  Future<void> _fetchTodayProfit(BuildContext context) async {
    if (state.isTodayProfitLoading) return;
    state = state.copyWith(isTodayProfitLoading: true);
    try {
      final result = await actions.todayProfitApi();
      if (result.success && result.data != null) {
        state = state.copyWith(
          tradeProfit: result.data!.commission.toString(),
          teamProfit: result.data!.performance.toString(),
          eventProfit: result.data!.reward.toString(),
        );
      }
    } catch (e) {
      return;
    } finally {
      state = state.copyWith(isTodayProfitLoading: false);
    }
  }

  // 公开方法，供页面触发
  Future<void> fetchTodayProfit(BuildContext context) async {
    await _fetchTodayProfit(context);
  }

  Future<void> handleClickVideo() async {
    final uri = Uri.parse(KumarBaseConfig.addUpiVideo);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

String _formatOrderSizeRange(String raw) {
  final trimmed = raw.trim();
  if (trimmed.isEmpty) return '';
  final commaStripped = trimmed.replaceAll(',', '');
  if (commaStripped.isEmpty) return '100~100000';
  final parts = raw
      .split(',')
      .map((part) => part.trim())
      .where((part) => part.isNotEmpty)
      .toList();
  if (parts.length >= 2) return '${parts[0]}~${parts[1]}';
  if (parts.length == 1) return parts[0];
  return '';
}

final mineViewModelProvider = StateNotifierProvider<MineViewModel, MineState>((
  ref,
) {
  final dio = ref.read(dioClientProvider);
  final actions = UserActions(UserStoreApi(dio));
  final vm = MineViewModel(actions);

  // 页面初始化后加载缓存中的用户信息
  WidgetsBinding.instance.addPostFrameCallback((_) => vm.init());
  return vm;
});
