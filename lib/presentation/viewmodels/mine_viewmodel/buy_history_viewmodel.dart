import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kumar_pay/app/toast/app_toast.dart';
import 'package:kumar_pay/core/di/buy_providers.dart';
import 'package:kumar_pay/store/models/buy/buy_req_model.dart';
import 'package:kumar_pay/store/models/buy/buy_res_model.dart';
import 'package:url_launcher/url_launcher.dart';

enum BuyHistoryTab { inr, inrCancel, usdt }

class _TabData {
  final List<BuyHistoryItem> items;
  final bool loading;
  final bool noMore;
  final int page;

  const _TabData({
    this.items = const [],
    this.loading = false,
    this.noMore = false,
    this.page = 1,
  });

  _TabData copyWith({
    List<BuyHistoryItem>? items,
    bool? loading,
    bool? noMore,
    int? page,
  }) => _TabData(
    items: items ?? this.items,
    loading: loading ?? this.loading,
    noMore: noMore ?? this.noMore,
    page: page ?? this.page,
  );
}

class BuyHistoryState {
  final int tabIndex;
  final Map<BuyHistoryTab, _TabData> tabs;

  const BuyHistoryState({
    this.tabIndex = 0,
    this.tabs = const {
      BuyHistoryTab.inr: _TabData(),
      BuyHistoryTab.inrCancel: _TabData(),
      BuyHistoryTab.usdt: _TabData(),
    },
  });

  _TabData dataOf(BuyHistoryTab tab) => tabs[tab] ?? const _TabData();

  BuyHistoryState copyWith({
    int? tabIndex,
    Map<BuyHistoryTab, _TabData>? tabs,
  }) => BuyHistoryState(
    tabIndex: tabIndex ?? this.tabIndex,
    tabs: tabs ?? this.tabs,
  );
}

class BuyHistoryViewModel extends StateNotifier<BuyHistoryState> {
  final Ref ref;
  static const int _limit = 10;
  static const Duration _usdtPollInterval = Duration(seconds: 10);
  Timer? _usdtTimer;

  BuyHistoryViewModel(this.ref) : super(const BuyHistoryState()) {}

  void onTabChange(int index) {
    state = state.copyWith(tabIndex: index);
    final tab = BuyHistoryTab.values[index];
    final data = state.dataOf(tab);
    if (!data.loading) {
      refresh(tab);
    }
    if (tab == BuyHistoryTab.usdt) {
      startUsdtPolling();
    }
  }

  void resetTabIndex() {
    if (state.tabIndex == 0) return;
    state = state.copyWith(tabIndex: 0);
  }

  void startUsdtPolling() {
    if (_usdtTimer != null) return;
    _usdtTimer = Timer.periodic(_usdtPollInterval, (_) async {
      try {
        final actions = ref.read(buyActionsProvider);
        await actions.buyUsdtNotifyApi();
      } catch (_) {}
    });
  }

  void stopUsdtPolling() {
    _usdtTimer?.cancel();
    _usdtTimer = null;
  }

  @override
  void dispose() {
    stopUsdtPolling();
    super.dispose();
  }

  Future<void> refresh(BuyHistoryTab tab) async {
    final map = Map<BuyHistoryTab, _TabData>.from(state.tabs);
    map[tab] = map[tab]!.copyWith(
      items: [],
      page: 1,
      noMore: false,
      loading: true,
    );
    state = state.copyWith(tabs: map);
    final newItems = await _fetch(page: 1, tab: tab);
    map[tab] = map[tab]!.copyWith(
      items: newItems,
      page: 2,
      loading: false,
      noMore: newItems.length < _limit,
    );
    state = state.copyWith(tabs: map);
  }

  Future<void> loadMore(BuyHistoryTab tab) async {
    final map = Map<BuyHistoryTab, _TabData>.from(state.tabs);
    final data = map[tab]!;
    if (data.loading || data.noMore) return;
    map[tab] = data.copyWith(loading: true);
    state = state.copyWith(tabs: map);

    final newItems = await _fetch(page: data.page, tab: tab);
    map[tab] = data.copyWith(
      items: [...data.items, ...newItems],
      page: data.page + 1,
      loading: false,
      noMore: newItems.length < _limit,
    );
    state = state.copyWith(tabs: map);
  }

  Future<List<BuyHistoryItem>> _fetch({
    required int page,
    required BuyHistoryTab tab,
  }) async {
    try {
      final currency = _currencyByTab(tab);
      final actions = ref.read(buyActionsProvider);
      final res = await actions.getBuyHistoryApi(
        IGetBuyHistoryReqModel(page: page, limit: _limit, currency: currency),
      );

      final items = res.data?.list ?? const <BuyHistoryItem>[];

      // if (tab == BuyHistoryTab.inrCancel) {
      //   return items.where((e) => e.orderState == 3).toList();
      // }

      return items;
    } catch (_) {
      return [];
    }
  }

  String _currencyByTab(BuyHistoryTab tab) {
    return switch (tab) {
      BuyHistoryTab.usdt => 'usdt',
      BuyHistoryTab.inrCancel => 'inr_cancel',
      _ => 'inr',
    };
  }

  Future<void> confirmPaid(
    BuildContext context, {
    required String orderId,
    required String process,
  }) async {
    try {
      final actions = ref.read(buyActionsProvider);
      final res = await actions.confirmPaidApi(
        IConfirmPaidReqModel(orderId: orderId, process: process),
      );
      if (!res.success) {
        AppToast.show(
          context,
          message: res.msg ?? 'Request failed: confirmPaidApi',
          type: AppToastType.error,
        );
        return;
      }

      AppToast.show(
        context,
        message: 'Payment confirmed',
        type: AppToastType.success,
      );
    } catch (_) {
      AppToast.show(
        context,
        message: 'Payment confirmation failed, please try again later',
        type: AppToastType.error,
      );
    }
  }

  Future<bool> cancelOrder(
    BuildContext context, {
    required String orderId,
    required String process,
    String? cancelRemark,
    required BuyHistoryTab tab,
  }) async {
    try {
      final actions = ref.read(buyActionsProvider);
      final res = await actions.processpaymentslipsApi(
        orderId: orderId,
        process: process,
        cancelRemark: cancelRemark,
      );
      if (!res.success) {
        AppToast.show(
          context,
          message: res.msg ?? 'Request failed: processpaymentslipsApi',
          type: AppToastType.error,
        );
        return false;
      }

      AppToast.show(
        context,
        message: 'Cancel success',
        type: AppToastType.success,
      );
      await refresh(tab);
      return true;
    } catch (_) {
      AppToast.show(
        context,
        message: 'Cancel failed, please try again later',
        type: AppToastType.error,
      );
      return false;
    }
  }

  Future<void> launchWalletDomain(
    BuildContext context, {
    required String walletDomain,
  }) async {
    if (walletDomain.trim().isEmpty) {
      AppToast.show(
        context,
        message: 'Invalid wallet link',
        type: AppToastType.error,
      );
      return;
    }
    final uri = Uri.tryParse(walletDomain);
    if (uri == null) {
      AppToast.show(
        context,
        message: 'Invalid wallet link',
        type: AppToastType.error,
      );
      return;
    }
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

final buyHistoryViewModelProvider =
    StateNotifierProvider.autoDispose<BuyHistoryViewModel, BuyHistoryState>((
      ref,
    ) {
      return BuyHistoryViewModel(ref);
    });
