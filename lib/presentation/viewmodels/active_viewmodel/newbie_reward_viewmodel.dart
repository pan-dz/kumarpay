import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kumar_pay/core/di/active_providers.dart';
import 'package:kumar_pay/presentation/pages/layout_page.dart';
import 'package:kumar_pay/store/models/active/active_res_model.dart';
import 'package:url_launcher/url_launcher.dart';

enum NewbieRewardCardType { telegram, vip }

class NewbieRewardCard {
  final String title;
  final String actionText;
  final NewbieRewardCardType type;

  const NewbieRewardCard({
    required this.title,
    required this.actionText,
    required this.type,
  });
}

enum NewbieRewardTaskStatus { todo, done }

class NewbieRewardTask {
  final String rewardRule;
  final String activityCode;
  final String title;
  final int startDate;
  final int endDate;
  final int status;
  final int crtDate;
  final String remark;
  final String frontUrl;
  final int? condition;
  final num rewardAmt;
  final int sort;
  final String iconAsset;
  final NewbieRewardTaskStatus uiStatus;
  final String actionText;

  const NewbieRewardTask({
    required this.rewardRule,
    required this.activityCode,
    required this.title,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.crtDate,
    required this.remark,
    required this.frontUrl,
    required this.condition,
    required this.rewardAmt,
    required this.sort,
    required this.iconAsset,
    required this.uiStatus,
    required this.actionText,
  });

  factory NewbieRewardTask.fromJson(
    Map<String, dynamic> json, {
    required String iconAsset,
  }) {
    final status = (json['status'] is num)
        ? (json['status'] as num).toInt()
        : 0;
    final uiStatus = status == 0
        ? NewbieRewardTaskStatus.todo
        : NewbieRewardTaskStatus.done;
    return NewbieRewardTask(
      rewardRule: (json['rewardRule'] ?? '').toString(),
      activityCode: (json['activityCode'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      startDate: (json['startDate'] is num)
          ? (json['startDate'] as num).toInt()
          : 0,
      endDate: (json['endDate'] is num) ? (json['endDate'] as num).toInt() : 0,
      status: status,
      crtDate: (json['crtDate'] is num) ? (json['crtDate'] as num).toInt() : 0,
      remark: (json['remark'] ?? '').toString(),
      frontUrl: (json['frontUrl'] ?? '').toString(),
      condition: (json['condition'] is num)
          ? (json['condition'] as num).toInt()
          : null,
      rewardAmt: (json['rewardAmt'] is num) ? (json['rewardAmt'] as num) : 0,
      sort: (json['sort'] is num) ? (json['sort'] as num).toInt() : 0,
      iconAsset: iconAsset,
      uiStatus: uiStatus,
      actionText: uiStatus == NewbieRewardTaskStatus.done ? 'Done' : 'GO',
    );
  }
}

class NewbieRewardState {
  final int totalBonus;
  final bool isLoading;
  final bool isReceiving;
  final String tgGroup;
  final String buyToken;
  final String allDone;
  final List<NewbieRewardCard> cards;
  final List<NewbieRewardTask> tasks;

  const NewbieRewardState({
    this.totalBonus = 200,
    this.isLoading = false,
    this.isReceiving = false,
    this.tgGroup = '',
    this.allDone = '',
    this.buyToken = '',
    this.cards = const [],
    this.tasks = const [],
  });

  NewbieRewardState copyWith({
    int? totalBonus,
    bool? isLoading,
    bool? isReceiving,
    String? tgGroup,
    String? buyToken,
    String? allDone,
    List<NewbieRewardCard>? cards,
    List<NewbieRewardTask>? tasks,
  }) {
    return NewbieRewardState(
      totalBonus: totalBonus ?? this.totalBonus,
      isLoading: isLoading ?? this.isLoading,
      isReceiving: isReceiving ?? this.isReceiving,
      tgGroup: tgGroup ?? this.tgGroup,
      allDone: allDone ?? this.allDone,
      buyToken: buyToken ?? this.buyToken,
      cards: cards ?? this.cards,
      tasks: tasks ?? this.tasks,
    );
  }
}

class NewbieRewardViewModel extends StateNotifier<NewbieRewardState> {
  final Ref ref;
  NewbieRewardViewModel(this.ref)
    : super(const NewbieRewardState(totalBonus: 200, tasks: []));

  Future<void> refresh() async {
    try {
      state = state.copyWith(isLoading: true);
      final actions = ref.read(activeActionsProvider);
      final response = await actions.newbieGuidesApi();
      if (!response.success || response.data == null) {
        state = state.copyWith(isLoading: false);
        return;
      }

      final data = response.data!;
      final paramsMap = _parseParams(data.activityRecord?.params);
      final rawAllDone = (data.allDone ?? '').toString();
      final allDone = rawAllDone.isNotEmpty
          ? rawAllDone
          : data.activityRecord?.done.toString() ?? '';
      final tasks =
          data.activityRules
              .map(
                (rule) =>
                    _taskFromRule(rule, paramsMap, allDone, data.buyToken),
              )
              .toList()
            ..sort((a, b) => a.sort.compareTo(b.sort));

      state = state.copyWith(
        totalBonus: data.newbieReward.toInt(),
        tgGroup: data.tgGroup,
        buyToken: data.buyToken,
        allDone: allDone,
        tasks: tasks,
        isLoading: false,
        isReceiving: false,
      );
    } catch (_) {
      state = state.copyWith(isLoading: false, isReceiving: false);
    }
  }

  Map<String, dynamic> _parseParams(String? raw) {
    if (raw == null || raw.isEmpty) return <String, dynamic>{};
    try {
      final decoded = json.decode(raw);
      return decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};
    } catch (_) {
      return <String, dynamic>{};
    }
  }

  NewbieRewardTask _taskFromRule(
    ActivityRule rule,
    Map<String, dynamic> params,
    String allDone,
    String buyToken,
  ) {
    int status;
    if (allDone == '1') {
      status = rule.status == 1 ? 1 : 0;
    } else {
      final rawStatus = params[rule.activityCode];
      if (rawStatus == null) {
        status = rule.status;
      } else {
        status = rawStatus is num
            ? rawStatus.toInt()
            : int.tryParse(rawStatus.toString()) ?? 0;
      }
    }
    final done = status == 1;
    final title = rule.activityCode == 'newbie_buyitoken' && buyToken.isNotEmpty
        ? '${rule.title} ($buyToken)'
        : rule.title;
    return NewbieRewardTask(
      rewardRule: rule.rewardRule,
      activityCode: rule.activityCode,
      title: title,
      startDate: rule.startDate,
      endDate: rule.endDate,
      status: status,
      crtDate: rule.crtDate,
      remark: rule.remark,
      frontUrl: rule.frontUrl,
      condition: rule.condition,
      rewardAmt: rule.rewardAmt,
      sort: rule.sort,
      iconAsset: _iconForActivity(rule.activityCode),
      uiStatus: done
          ? NewbieRewardTaskStatus.done
          : NewbieRewardTaskStatus.todo,
      actionText: done ? 'Done' : 'GO',
    );
  }

  String _iconForActivity(String? code) {
    switch (code) {
      case 'newbie_tg_channel':
        return 'assets/images/newbie_1.webp';
      case 'newbie_tg_customer':
        return 'assets/images/newbie_2.webp';
      case 'newbie_watch_video':
        return 'assets/images/newbie_3.webp';
      case 'newbie_newct':
        return 'assets/images/newbie_4.webp';
      case 'newbie_buyitoken':
        return 'assets/images/newbie_5.webp';
      default:
        return 'assets/images/newbie_1.webp';
    }
  }

  void onCardTap(NewbieRewardCard card) {}

  Future<void> onReceiveReward() async {
    final allTasksDone =
        state.tasks.isNotEmpty && state.tasks.every((task) => task.status == 1);
    final canReceive =
        allTasksDone && (state.allDone.isEmpty || state.allDone == '0');
    if (!canReceive) return;

    // 先显示 loading
    state = state.copyWith(isReceiving: true);

    try {
      final actions = ref.read(activeActionsProvider);
      final response = await actions.newbieRewardApi();

      if (!response.success) {
        state = state.copyWith(isReceiving: false);
        return;
      }

      state = state.copyWith(allDone: '1', isReceiving: false);
    } catch (_) {
      state = state.copyWith(isReceiving: false);
    }
  }

  void onTaskTap(BuildContext context, NewbieRewardTask task) async {
    if (task.activityCode == 'newbie_buyitoken') {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LayoutPage(initialIndex: 1)),
        (route) => false,
      );
    } else if (task.activityCode == 'newbie_newct') {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LayoutPage(initialIndex: 2)),
        (route) => false,
      );
    }
    /// 跳转地址
    else if (task.activityCode == 'newbie_tg_channel' ||
        task.activityCode == 'newbie_tg_customer' ||
        task.activityCode == 'newbie_watch_video') {
      // 先跳转
      final uri = Uri.tryParse(task.frontUrl);
      if (uri != null) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }

      // 后台调用 API
      final actions = ref.read(activeActionsProvider);
      await actions.activityCodeDoneApi(activityCode: task.activityCode);

      // 更新任务列表状态
      final updatedTasks = state.tasks.map((t) {
        if (t.activityCode == task.activityCode) {
          return NewbieRewardTask(
            rewardRule: t.rewardRule,
            activityCode: t.activityCode,
            title: t.title,
            startDate: t.startDate,
            endDate: t.endDate,
            status: 1,
            crtDate: t.crtDate,
            remark: t.remark,
            frontUrl: t.frontUrl,
            condition: t.condition,
            rewardAmt: t.rewardAmt,
            sort: t.sort,
            iconAsset: t.iconAsset,
            uiStatus: NewbieRewardTaskStatus.done,
            actionText: 'Done',
          );
        }
        return t;
      }).toList();

      state = state.copyWith(tasks: updatedTasks);
    }
  }
}

final newbieRewardProvider =
    StateNotifierProvider<NewbieRewardViewModel, NewbieRewardState>((ref) {
      return NewbieRewardViewModel(ref);
    });
