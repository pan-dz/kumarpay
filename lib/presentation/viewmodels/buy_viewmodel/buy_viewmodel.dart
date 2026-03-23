import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kumar_pay/app/toast/app_toast.dart';
import 'package:kumar_pay/core/di/buy_providers.dart';
import 'package:kumar_pay/core/di/upi_providers.dart';
import 'package:kumar_pay/store/models/buy/buy_req_model.dart';
import 'package:kumar_pay/store/models/buy/buy_res_model.dart';
import 'package:kumar_pay/store/models/upi/upi_res_model.dart';
import 'package:kumar_pay/presentation/widgets/popup_dialog.dart';
import 'package:kumar_pay/presentation/pages/mine_page/buy_history_page.dart';
import 'package:url_launcher/url_launcher.dart';

class BuyState {
  final int tabIndex;
  final bool ascending;
  final List<BuyOrderListItem> items;
  final bool isLoading;
  final bool isBuyLoading;
  final bool noMore;
  final int page;
  final int total;
  final int limit;
  final int minAmount;
  final int maxAmount;

  const BuyState({
    this.tabIndex = 0,
    this.ascending = true,
    this.items = const [],
    this.isLoading = false,
    this.isBuyLoading = false,
    this.noMore = false,
    this.page = 1,
    this.total = 0,
    this.limit = 50,
    this.minAmount = 100,
    this.maxAmount = 100000,
  });

  BuyState copyWith({
    int? tabIndex,
    bool? ascending,
    List<BuyOrderListItem>? items,
    bool? isLoading,
    bool? isBuyLoading,
    bool? noMore,
    int? page,
    int? total,
    int? limit,
    int? minAmount,
    int? maxAmount,
  }) {
    return BuyState(
      tabIndex: tabIndex ?? this.tabIndex,
      ascending: ascending ?? this.ascending,
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      isBuyLoading: isBuyLoading ?? this.isBuyLoading,
      noMore: noMore ?? this.noMore,
      page: page ?? this.page,
      total: total ?? this.total,
      limit: limit ?? this.limit,
      minAmount: minAmount ?? this.minAmount,
      maxAmount: maxAmount ?? this.maxAmount,
    );
  }
}

class BuyViewModel extends StateNotifier<BuyState> {
  final Ref ref;
  BuyViewModel(this.ref) : super(const BuyState()) {
    Future.microtask(handleSearchRefresh);
  }

  void onTabChange(int index) {
    state = state.copyWith(tabIndex: index);
    if (index == 0 || index == 1) {
      handleSearchRefresh();
    } else if (index == 2) {}
  }

  void handleClickSort(bool asc) {
    if (state.ascending == asc) return;
    final sorted = [...state.items];
    sorted.sort(
      (a, b) =>
          asc ? a.amount.compareTo(b.amount) : b.amount.compareTo(a.amount),
    );
    state = state.copyWith(ascending: asc, items: sorted);
  }

  void updateMinAmount(String value) {
    final text = value.trim();
    if (text.isEmpty) return;
    final parsed = int.tryParse(text);
    final min = parsed == null || text.isEmpty ? 100 : parsed;
    final clamped = min.clamp(100, 100000);
    state = state.copyWith(minAmount: clamped);
  }

  void updateMaxAmount(String value) {
    final text = value.trim();
    if (text.isEmpty) return;
    final parsed = int.tryParse(text);
    final max = parsed == null || text.isEmpty ? 100000 : parsed;
    final clamped = max.clamp(100, 100000);
    state = state.copyWith(maxAmount: clamped);
  }

  Future<void> handleSearchRefresh() async {
    state = state.copyWith(isLoading: true, page: 1, noMore: false);
    final data = await _fetchBuyOrderList(page: 1);
    final items = data.list;
    final total = data.total;
    state = state.copyWith(
      items: items,
      total: total,
      isLoading: false,
      noMore: items.length >= total && total > 0,
    );
  }

  Future<void> loadMore() async {
    if (state.isLoading || state.noMore) return;
    final nextPage = state.page + 1;
    state = state.copyWith(isLoading: true, page: nextPage);
    final data = await _fetchBuyOrderList(page: nextPage);
    final newItems = data.list;
    final merged = [...state.items, ...newItems];
    final total = data.total;
    state = state.copyWith(
      items: merged,
      total: total,
      isLoading: false,
      noMore: merged.length >= total || newItems.isEmpty,
    );
  }

  Future<List<UpiInfoModel>> getBuyUpiList(BuildContext context) async {
    if (state.isBuyLoading) return const <UpiInfoModel>[];
    state = state.copyWith(isBuyLoading: true);
    try {
      final actions = ref.read(upiActionsProvider);

      // 点击buy获取可用upi列表，显示弹窗
      final res = await actions.getBuyUpiListApi();
      if (!res.success) {
        AppToast.show(
          context,
          message: res.msg ?? 'Request failed: getBuyUpiListApi',
          type: AppToastType.error,
        );
        return const <UpiInfoModel>[];
      }

      final options = res.data ?? const <UpiInfoModel>[];
      return options;
    } catch (_) {
      AppToast.show(
        context,
        message: 'Failed to fetch UPI list, please try again later',
        type: AppToastType.error,
      );
      return const <UpiInfoModel>[];
    } finally {
      state = state.copyWith(isBuyLoading: false);
    }
  }

  Future<bool> buyIToken(
    BuildContext context, {
    required String orderId,
    required int ctId,
    required int ctType,
  }) async {
    if (state.isBuyLoading) return false;
    state = state.copyWith(isBuyLoading: true);
    try {
      final actions = ref.read(buyActionsProvider);
      final res = await actions.buyITokenApi(
        IBuyITokenReqModel(orderId: orderId, ctId: ctId, ctType: ctType),
      );

      if (!res.success &&
          res.msg == 'UPI is being used, please finish payment.') {
        PopupDialog.show(
          context: context,
          config: PopupDialogConfig(
            position: DialogPosition.center,
            title: 'Tips',
            showCloseButton: false,
            showFooterButtons: true,
            showDoubleButtons: true,
            primaryButtonText: 'View History',
            secondaryButtonText: 'Stay',
            minHeight: 140,
            closeOnConfirm: false,
          ),
          child: Text(
            res.msg ?? 'UPI is being used, please finish payment.',
            style: const TextStyle(
              color: Color(0xFF8F9098),
              fontSize: 14,
              fontWeight: FontWeight.w500,
              height: 1.2,
            ),
          ),
          onConfirm: () {
            Navigator.of(context).pop();
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const BuyHistoryPage()));
          },
        );
        return false;
      } else if (!res.success) {
        AppToast.show(
          context,
          message: res.msg ?? 'Request failed: buyITokenApi',
          type: AppToastType.error,
        );
        return false;
      }

      if (ctType == 3) {
        AppToast.show(
          context,
          message: 'Pre-order success',
          type: AppToastType.success,
        );
        await handleSearchRefresh();
        return true;
      }

      final data = res.data;
      final walletDomain = data?.walletDomain ?? '';
      if (walletDomain.isEmpty) {
        AppToast.show(
          context,
          message: 'Purchase succeeded, but wallet link is empty',
          type: AppToastType.warning,
        );
        return false;
      }

      final uri = Uri.tryParse(walletDomain);
      if (uri == null) {
        AppToast.show(
          context,
          message: 'Invalid wallet link',
          type: AppToastType.error,
        );
        return false;
      }

      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      AppToast.show(
        context,
        message: launched ? 'Purchase succeeded' : 'Failed to open wallet app',
        type: launched ? AppToastType.success : AppToastType.warning,
      );

      await handleSearchRefresh();
      return true;
    } catch (_) {
      AppToast.show(
        context,
        message: 'Purchase failed, please try again later',
        type: AppToastType.error,
      );
      return false;
    } finally {
      state = state.copyWith(isBuyLoading: false);
    }
  }

  Future<BuyOrderListData> _fetchBuyOrderList({required int page}) async {
    try {
      final actions = ref.read(buyActionsProvider);
      final request = IGetBuyOrderListReqModel(
        page: page,
        limit: state.limit,
        minAmount: state.minAmount,
        maxAmount: state.maxAmount,
        ifAsc: state.ascending,
        method: state.tabIndex,
      );
      final response = await actions.getBuyOrderListApi(request);
      return response.data ?? const BuyOrderListData(total: 0, list: []);
    } catch (_) {
      return const BuyOrderListData(total: 0, list: []);
    }
  }
}

final buyViewModelProvider = StateNotifierProvider<BuyViewModel, BuyState>(
  (ref) => BuyViewModel(ref),
);
