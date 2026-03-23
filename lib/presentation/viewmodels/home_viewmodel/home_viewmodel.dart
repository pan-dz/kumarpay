import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';
import 'package:kumar_pay/app/config/storage_keys.dart';
import 'package:kumar_pay/core/di/home_providers.dart';
import 'package:kumar_pay/core/di/providers.dart';
import 'package:kumar_pay/app/config/api.dart';
import 'package:kumar_pay/core/utils/base.dart';
import 'package:kumar_pay/store/actiions/home/home_actions.dart';
import 'package:kumar_pay/store/request/home/home_api.dart';

class HomeState {
  final int currentIndex;
  final int bannerIndex;
  final List<String> bannerImages;
  final List<Map<String, String>> messages;
  final List<Map<String, String>> news;
  final double unreadCount;
  final String tgChannelLink;
  final String usdtExchangerate;
  final String reward;

  const HomeState({
    this.currentIndex = 0,
    this.bannerIndex = 0,
    this.bannerImages = const [],
    this.messages = const [],
    this.news = const [],
    this.unreadCount = 0.0,
    this.tgChannelLink = '',
    this.usdtExchangerate = '',
    this.reward = '',
  });

  HomeState copyWith({
    int? currentIndex,
    int? bannerIndex,
    List<String>? bannerImages,
    List<Map<String, String>>? messages,
    List<Map<String, String>>? news,
    double? unreadCount,
    String? tgChannelLink,
    String? usdtExchangerate,
    String? reward,
  }) {
    return HomeState(
      currentIndex: currentIndex ?? this.currentIndex,
      bannerIndex: bannerIndex ?? this.bannerIndex,
      bannerImages: bannerImages ?? this.bannerImages,
      messages: messages ?? this.messages,
      news: news ?? this.news,
      unreadCount: unreadCount ?? this.unreadCount,
      tgChannelLink: tgChannelLink ?? this.tgChannelLink,
      usdtExchangerate: usdtExchangerate ?? this.usdtExchangerate,
      reward: reward ?? this.reward,
    );
  }
}

class HomeViewModel extends StateNotifier<HomeState> {
  final Ref ref;
  final HomeActions actions;
  Future<void>? _customerServiceTask;

  static bool shouldShowCustomerServiceOnTab(int index) {
    return index == 0 || index == 1 || index == 2 || index == 4;
  }

  HomeViewModel(this.ref, this.actions)
    : super(
        HomeState(
          tgChannelLink:
              GetStorage().read<String>(StorageKeys.customerServiceLink) ?? '',
        ),
      );

  void init() {
    _loadHomeData();
  }

  void onTabChange(int index) {
    state = state.copyWith(currentIndex: index);
  }

  void onBannerPageChanged(int index) {
    state = state.copyWith(bannerIndex: index);
  }

  // 对外暴露的刷新方法，供页面切换时调用
  Future<void> refreshomeConfig() async {
    await _fetchHomeConfig();
  }

  // 对外暴露的刷新方法，供页面切换时调用
  Future<void> refreshCustomerService() async {
    await _fetchCustomerService(force: true);
  }

  Future<void> refreshCustomerServiceForTab(int index) async {
    if (!shouldShowCustomerServiceOnTab(index)) {
      return;
    }

    await refreshCustomerService();
  }

  Future<void> _loadHomeData() async {
    await Future.wait([_fetchHomeConfig(), ensureCustomerServiceLoaded()]);
  }

  Future<void> ensureCustomerServiceLoaded() async {
    if (state.tgChannelLink.isNotEmpty) {
      return;
    }

    final cached = GetStorage().read<String>(StorageKeys.customerServiceLink);
    if (cached != null && cached.isNotEmpty) {
      state = state.copyWith(tgChannelLink: cached);
      return;
    }

    await _fetchCustomerService();
  }

  // Future<void> _fetchUnreadCount() async {
  //   try {
  //     final res = await actions.unReadCountApi();
  //     if (res.success && res.data != null) {
  //       state = state.copyWith(unreadCount: res.data!);
  //     }
  //   } catch (e) {
  //     debugPrint('fetch unReadCount failed: $e');
  //   }
  // }

  Future<void> _fetchHomeConfig() async {
    try {
      final res = await actions.getHomeConfigApi();
      if (res.success && res.data != null) {
        final info = res.data!;
        final banners = info.bannerSrcs
            .map((e) => _withUploadPrefix(e))
            .where((e) => e.isNotEmpty)
            .toList();
        final List<Map<String, String>> newsMaps =
            ((info.newsList.where((n) => n.type == 2).toList())
                  ..sort((a, b) => a.sort.compareTo(b.sort)))
                .map<Map<String, String>>(
                  (n) => {
                    'title': (n.name.isNotEmpty ? n.name : n.content),
                    'subtitle': _formatDate(n.crtDate),
                    'content': (n.content.isNotEmpty ? n.content : ''),
                  },
                )
                .toList();

        final List<Map<String, String>> messageMaps =
            ((info.newsList.where((n) => n.type == 1).toList())
                  ..sort((a, b) => a.sort.compareTo(b.sort)))
                .map<Map<String, String>>(
                  (n) => {
                    'title': (n.name.isNotEmpty ? n.name : n.content),
                    'subtitle': _formatDate(n.crtDate),
                    'content': (n.content.isNotEmpty ? n.content : ''),
                  },
                )
                .toList();

        final reward = _computeInrBuyReward(info.rewardRules);

        state = state.copyWith(
          bannerImages: banners.isNotEmpty ? banners : state.bannerImages,
          news: newsMaps.isNotEmpty ? newsMaps : state.news,
          messages: messageMaps.isNotEmpty ? messageMaps : state.messages,
          // tgChannelLink: state.tgChannelLink.isNotEmpty
          //     ? state.tgChannelLink
          //     : info.tgChannelLink,
          usdtExchangerate: info.usdtExchangerate,
          reward: reward,
        );

        ref.read(usdtExchangerateProvider.notifier).state =
            info.usdtExchangerate;
        ref.read(currencyProvider.notifier).state = info.currency;

        GetStorage().write(StorageKeys.usdtExchangerate, info.usdtExchangerate);
        GetStorage().write(StorageKeys.ctTypes, info.ctTypes);
      }
    } catch (e) {
      debugPrint('fetch home config failed: $e');
    }
  }

  Future<void> _fetchCustomerService({bool force = false}) async {
    if (!force) {
      if (state.tgChannelLink.isNotEmpty) {
        return;
      }

      final cached = GetStorage().read<String>(StorageKeys.customerServiceLink);
      if (cached != null && cached.isNotEmpty) {
        state = state.copyWith(tgChannelLink: cached);
        return;
      }
    }

    final inflightTask = _customerServiceTask;
    if (inflightTask != null) {
      await inflightTask;
      return;
    }

    final task = _loadCustomerServiceFromApi();
    _customerServiceTask = task;

    try {
      await task;
    } finally {
      if (identical(_customerServiceTask, task)) {
        _customerServiceTask = null;
      }
    }
  }

  Future<void> _loadCustomerServiceFromApi() async {
    try {
      final res = await actions.getCustomerServiceApi();
      final link = buildCustomerServiceLink(res.data);
      if (res.success) {
        state = state.copyWith(tgChannelLink: link);
        if (link.isNotEmpty) {
          GetStorage().write(StorageKeys.customerServiceLink, link);
        } else {
          GetStorage().remove(StorageKeys.customerServiceLink);
        }
      }
    } catch (e) {
      debugPrint('fetch customer service failed: $e');
    }
  }

  String _computeInrBuyReward(Map<String, dynamic> rules) {
    try {
      // 高优订单 奖励公式
      final bigReward = _formatRewardRuleByName(rules, 'inr_buy_reward_0');
      // 普通订单 奖励公式
      final normalReward = _formatRewardRuleByName(rules, 'inr_buy_reward_1');

      if (normalReward.isNotEmpty) {
        GetStorage().write(StorageKeys.reward, normalReward);
      }
      if (bigReward.isNotEmpty) {
        GetStorage().write(StorageKeys.rewardBig, bigReward);
      }
      return normalReward.isNotEmpty ? normalReward : state.reward;
    } catch (_) {
      return state.reward;
    }
  }

  String _formatRewardRuleByName(Map<String, dynamic> rules, String name) {
    final item = _findRewardRuleByName(rules, name);
    if (item == null) return '';

    final fixed = _asNum(item['fixed']);
    final ratio = _asNum(item['ratio']);
    if (fixed == null && ratio == null) return '';

    final fixedStr = fixed == null
        ? '0'
        : (fixed % 1 == 0 ? fixed.toStringAsFixed(0) : fixed.toString());
    final ratioStr = ratio == null
        ? '0'
        : (ratio % 1 == 0 ? ratio.toStringAsFixed(0) : ratio.toString());
    return '$ratioStr%+$fixedStr';
  }

  Map<String, dynamic>? _findRewardRuleByName(
    Map<String, dynamic> rules,
    String name,
  ) {
    final direct = rules[name];
    if (direct is Map<String, dynamic>) return direct;

    final listCandidate = rules['list'] ?? rules['rules'] ?? rules['items'];
    if (listCandidate is List) {
      for (final item in listCandidate) {
        if (item is Map<String, dynamic>) {
          final itemName = item['name']?.toString();
          if (itemName == name) return item;
        }
      }
    }
    return null;
  }

  num? _asNum(Object? v) {
    if (v is num) return v;
    if (v is String) return num.tryParse(v);
    return null;
  }

  String _formatDate(int ts) {
    try {
      if (ts <= 0) return '';
      final isMs = ts > 1000000000000;
      final dt = DateTime.fromMillisecondsSinceEpoch(isMs ? ts : ts * 1000);
      String two(int v) => v.toString().padLeft(2, '0');
      return '${dt.year}-${two(dt.month)}-${two(dt.day)} ${two(dt.hour)}:${two(dt.minute)}:${two(dt.second)}';
    } catch (_) {
      return ts.toString();
    }
  }

  String _withUploadPrefix(String path) {
    final raw = path.trim();
    if (raw.isEmpty) return '';
    if (raw.startsWith('http://') || raw.startsWith('https://')) {
      return raw;
    }
    final normalized = raw.startsWith('/') ? raw : '/$raw';
    return '$baseUrl/upload$normalized';
  }
}

final homeViewModelProvider = StateNotifierProvider<HomeViewModel, HomeState>((
  ref,
) {
  // 构建 HomeActions 依赖
  final dio = ref.read(dioClientProvider);
  final actions = HomeActions(HomeStoreApi(dio));
  final vm = HomeViewModel(ref, actions);

  // 自动初始化计时器
  WidgetsBinding.instance.addPostFrameCallback((_) => vm.init());
  return vm;
});

// 垂直消息轮播组件（UI+逻辑）
class VerticalTicker extends StatefulWidget {
  final List<Map<String, String>> messages;
  final ScrollController controller;
  final ValueChanged<int>? onIndexChanged;
  const VerticalTicker({
    super.key,
    required this.messages,
    required this.controller,
    this.onIndexChanged,
  });

  @override
  State<VerticalTicker> createState() => _VerticalTickerState();
}

class _VerticalTickerState extends State<VerticalTicker> {
  int _index = 0;
  late final Timer _timer;

  @override
  void initState() {
    super.initState();
    // 初始回调一次当前索引
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onIndexChanged?.call(_index);
    });
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted) return;
      setState(() {
        _index = (_index + 1) % widget.messages.length;
        widget.onIndexChanged?.call(_index);
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      transitionBuilder: (child, anim) {
        final inAnim = Tween<Offset>(
          begin: const Offset(0, 1),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut));
        return ClipRect(
          child: SlideTransition(position: inAnim, child: child),
        );
      },
      child: Align(
        key: ValueKey(_index),
        alignment: Alignment.centerLeft,
        child: Text(
          widget.messages[_index]['title'] ?? '',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFFFFA300),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
