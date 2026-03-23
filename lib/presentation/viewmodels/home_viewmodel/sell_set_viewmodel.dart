import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kumar_pay/core/di/providers.dart';
import 'package:kumar_pay/store/actiions/home/sell_actions.dart';
import 'package:kumar_pay/store/request/home/sell_api.dart';
import 'package:kumar_pay/store/models/home/sell_res_model.dart';

class TradeStats {
  final int inTransaction;
  final int todayDeal;
  final int todayTimes;
  final int todaySuccess;

  const TradeStats({
    this.inTransaction = 0,
    this.todayDeal = 0,
    this.todayTimes = 0,
    this.todaySuccess = 0,
  });

  TradeStats copyWith({
    int? inTransaction,
    int? todayDeal,
    int? todayTimes,
    int? todaySuccess,
  }) {
    return TradeStats(
      inTransaction: inTransaction ?? this.inTransaction,
      todayDeal: todayDeal ?? this.todayDeal,
      todayTimes: todayTimes ?? this.todayTimes,
      todaySuccess: todaySuccess ?? this.todaySuccess,
    );
  }
}

class SellSetState {
  final double itokenBalance;
  final bool inSell;
  final int activeUpiCount;
  final TradeStats buyStats;
  final TradeStats sellStats;

  const SellSetState({
    this.itokenBalance = 140.43,
    this.inSell = true,
    this.activeUpiCount = 1,
    this.buyStats = const TradeStats(),
    this.sellStats = const TradeStats(),
  });

  SellSetState copyWith({
    double? itokenBalance,
    bool? inSell,
    int? activeUpiCount,
    TradeStats? buyStats,
    TradeStats? sellStats,
  }) {
    return SellSetState(
      itokenBalance: itokenBalance ?? this.itokenBalance,
      inSell: inSell ?? this.inSell,
      activeUpiCount: activeUpiCount ?? this.activeUpiCount,
      buyStats: buyStats ?? this.buyStats,
      sellStats: sellStats ?? this.sellStats,
    );
  }
}

class SellSetViewModel extends StateNotifier<SellSetState> {
  final Ref ref;
  SellSetViewModel(this.ref) : super(const SellSetState());

  void toggleInSell(bool value) {
    state = state.copyWith(inSell: value);
  }

  Future<void> refresh() async {
    try {
      final dio = ref.read(dioClientProvider);
      final actions = SellActions(SellStoreApi(dio));
      final res = await actions.userinfoAndAvailableCtApi();
      if (!res.success || res.data == null) {
        return;
      }

      final info = res.data!;
      final receive = info.receiveToday;
      final stats = _mapStats(receive);

      final activeUpiCount = info.kycpartnerVOList
          .where((e) => e.userIsActive)
          .length;
      final inSell = info.kycpartnerVOList.any((e) => e.inSell);

      state = state.copyWith(
        itokenBalance: info.itoken.toDouble(),
        activeUpiCount: activeUpiCount,
        inSell: inSell,
        buyStats: stats,
        sellStats: stats,
      );
    } catch (_) {}
  }

  TradeStats _mapStats(ReceiveTodayModel? receive) {
    if (receive == null) return const TradeStats();
    return TradeStats(
      inTransaction: receive.inTransation,
      todayDeal: receive.todayDeal,
      todayTimes: receive.todayTimes,
      todaySuccess: receive.todaySuccess,
    );
  }
}

final sellSetViewModelProvider =
    StateNotifierProvider<SellSetViewModel, SellSetState>((ref) {
      return SellSetViewModel(ref);
    });
