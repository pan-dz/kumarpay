import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kumar_pay/core/di/mine_providers.dart';
import 'package:kumar_pay/store/models/mine/sell_history_req_model.dart';
import 'package:kumar_pay/store/models/mine/sell_history_res_model.dart';

// Tabs for Buy History
enum SellHistoryTab { paying, success, all }

class _TabData {
  final List<SellHistoryItem> items;
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
    List<SellHistoryItem>? items,
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

class SellHistoryState {
  final int tabIndex;
  final Map<SellHistoryTab, _TabData> tabs;

  const SellHistoryState({
    this.tabIndex = 0,
    this.tabs = const {
      SellHistoryTab.paying: _TabData(),
      SellHistoryTab.success: _TabData(),
      SellHistoryTab.all: _TabData(),
    },
  });

  _TabData dataOf(SellHistoryTab tab) => tabs[tab] ?? const _TabData();

  SellHistoryState copyWith({
    int? tabIndex,
    Map<SellHistoryTab, _TabData>? tabs,
  }) => SellHistoryState(
    tabIndex: tabIndex ?? this.tabIndex,
    tabs: tabs ?? this.tabs,
  );
}

class SellHistoryViewModel extends StateNotifier<SellHistoryState> {
  final Ref ref;
  static const int _limit = 10;

  SellHistoryViewModel(this.ref) : super(const SellHistoryState()) {}

  void onTabChange(int index) {
    state = state.copyWith(tabIndex: index);
    final tab = SellHistoryTab.values[index];
    final data = state.dataOf(tab);
    if (data.items.isEmpty && !data.loading) {
      refresh(tab);
    }
  }

  void resetTabIndex() {
    if (state.tabIndex == 0) return;
    state = state.copyWith(tabIndex: 0);
  }

  Future<void> refresh(SellHistoryTab tab) async {
    final map = Map<SellHistoryTab, _TabData>.from(state.tabs);
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

  Future<void> loadMore(SellHistoryTab tab) async {
    final map = Map<SellHistoryTab, _TabData>.from(state.tabs);
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

  Future<List<SellHistoryItem>> _fetch({
    required int page,
    required SellHistoryTab tab,
  }) async {
    try {
      final actions = ref.read(sellHistoryActionsProvider);
      final res = await actions.getSellHistoryApi(
        IGetSellHistoryReqModel(
          page: page,
          limit: _limit,
          status: _statusByTab(tab),
        ),
      );

      return res.data?.list ?? const <SellHistoryItem>[];
    } catch (_) {
      return const <SellHistoryItem>[];
    }
  }

  int _statusByTab(SellHistoryTab tab) {
    return switch (tab) {
      SellHistoryTab.paying => 1,
      SellHistoryTab.success => 3,
      SellHistoryTab.all => 5,
    };
  }
}

final sellHistoryViewModelProvider =
    StateNotifierProvider<SellHistoryViewModel, SellHistoryState>((ref) {
      return SellHistoryViewModel(ref);
    });
