import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kumar_pay/core/di/user_providers.dart';
import 'package:kumar_pay/store/models/user/user_req_model.dart';
import 'package:kumar_pay/store/models/user/user_res_model.dart';

class TransferHistoryItem {
  final int id;
  final String transferIn;
  final String transferOut;
  final num itoken;
  final int transferType;
  final int orderState;
  final int crtDate;
  final String showNote;
  final int userShow;

  const TransferHistoryItem({
    required this.id,
    required this.transferIn,
    required this.transferOut,
    required this.itoken,
    required this.transferType,
    required this.orderState,
    required this.crtDate,
    required this.showNote,
    required this.userShow,
  });

  factory TransferHistoryItem.fromModel(TransferTokenHistoryItemModel model) {
    return TransferHistoryItem(
      id: model.id,
      transferIn: model.transferIn,
      transferOut: model.transferOut,
      itoken: model.itoken,
      transferType: model.transferType,
      orderState: model.orderState,
      crtDate: model.crtDate,
      showNote: model.showNote,
      userShow: model.userShow,
    );
  }
}

class TransferHistoryState {
  final List<TransferHistoryItem> items;
  final bool isLoading;
  final bool noMore;
  final int page;
  final int total;

  const TransferHistoryState({
    this.items = const [],
    this.isLoading = false,
    this.noMore = false,
    this.page = 1,
    this.total = 0,
  });

  TransferHistoryState copyWith({
    List<TransferHistoryItem>? items,
    bool? isLoading,
    bool? noMore,
    int? page,
    int? total,
  }) {
    return TransferHistoryState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      noMore: noMore ?? this.noMore,
      page: page ?? this.page,
      total: total ?? this.total,
    );
  }
}

class _TransferFetchResult {
  final int total;
  final List<TransferHistoryItem> items;

  const _TransferFetchResult({required this.total, required this.items});
}

class TransferHistoryViewModel extends StateNotifier<TransferHistoryState> {
  final Ref ref;
  static const int _limit = 10;

  TransferHistoryViewModel(this.ref) : super(const TransferHistoryState());

  Future<void> refresh() async {
    state = state.copyWith(
      items: [],
      page: 1,
      noMore: false,
      total: 0,
      isLoading: true,
    );
    final result = await _fetch(page: 1);
    final newItems = result.items;
    state = state.copyWith(
      items: newItems,
      page: 2,
      total: result.total,
      isLoading: false,
      noMore: newItems.isEmpty || newItems.length >= result.total,
    );
  }

  Future<void> loadMore() async {
    if (state.isLoading || state.noMore) return;

    state = state.copyWith(isLoading: true);
    final result = await _fetch(page: state.page);
    final merged = [...state.items, ...result.items];
    state = state.copyWith(
      items: merged,
      page: state.page + 1,
      total: result.total,
      isLoading: false,
      noMore: result.items.isEmpty || merged.length >= result.total,
    );
  }

  Future<_TransferFetchResult> _fetch({required int page}) async {
    try {
      final actions = ref.read(userActionsProvider);
      final res = await actions.transferTokenHistoryApi(
        ITransferTokenHistoryReqModel(page: page, limit: _limit),
      );

      final list = res.data?.list ?? const <TransferTokenHistoryItemModel>[];
      return _TransferFetchResult(
        total: res.data?.total ?? 0,
        items: list.map(TransferHistoryItem.fromModel).toList(),
      );
    } catch (_) {
      return const _TransferFetchResult(total: 0, items: []);
    }
  }
}

final transferHistoryViewModelProvider =
    StateNotifierProvider.autoDispose<
      TransferHistoryViewModel,
      TransferHistoryState
    >((ref) {
      return TransferHistoryViewModel(ref);
    });
