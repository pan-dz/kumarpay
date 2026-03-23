import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kumar_pay/core/di/active_providers.dart';
import 'package:kumar_pay/store/models/active/active_req_model.dart';
import 'package:kumar_pay/store/models/active/active_res_model.dart';

class MyTeamState {
  final List<MyTeamItemModel> items;
  final bool isLoading;
  final bool noMore;
  final int page;
  final int total;

  const MyTeamState({
    this.items = const [],
    this.isLoading = false,
    this.noMore = false,
    this.page = 1,
    this.total = 0,
  });

  MyTeamState copyWith({
    List<MyTeamItemModel>? items,
    bool? isLoading,
    bool? noMore,
    int? page,
    int? total,
  }) {
    return MyTeamState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      noMore: noMore ?? this.noMore,
      page: page ?? this.page,
      total: total ?? this.total,
    );
  }
}

class _MyTeamFetchResult {
  final int total;
  final List<MyTeamItemModel> items;

  const _MyTeamFetchResult({required this.total, required this.items});
}

class MyTeamViewModel extends StateNotifier<MyTeamState> {
  final Ref ref;
  static const int _limit = 10;

  MyTeamViewModel(this.ref) : super(const MyTeamState());

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

  Future<_MyTeamFetchResult> _fetch({required int page}) async {
    try {
      final actions = ref.read(activeActionsProvider);
      final res = await actions.myTeamListApi(
        IMyTeamListReqModel(page: page, limit: _limit),
      );

      final list = res.data?.list ?? const <MyTeamItemModel>[];
      return _MyTeamFetchResult(total: res.data?.total ?? 0, items: list);
    } catch (_) {
      return const _MyTeamFetchResult(total: 0, items: []);
    }
  }
}

final myTeamViewModelProvider =
    StateNotifierProvider.autoDispose<MyTeamViewModel, MyTeamState>((ref) {
      return MyTeamViewModel(ref);
    });
