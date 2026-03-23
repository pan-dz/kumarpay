import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kumar_pay/core/di/active_providers.dart';
import 'package:kumar_pay/store/models/active/active_res_model.dart';

enum InviteFriendStatus { done, pending }

enum InviteRewardStatus { pending, ready, claimed }

class InviteFriendState {
  final bool isLoading;
  final double totalBonus;
  final double receivedBonus;
  final int doneCount;
  final int totalCount;
  final bool showFriends;
  final bool hasClaimed;
  final String rewardRule;
  final String activityCode;
  final double rewardPerFriend;
  final String tipText;
  final List<ActivityRecord> items;

  const InviteFriendState({
    this.isLoading = false,
    this.totalBonus = 0,
    this.receivedBonus = 0,
    this.doneCount = 0,
    this.totalCount = 0,
    this.showFriends = true,
    this.hasClaimed = false,
    this.rewardRule = '',
    this.activityCode = '',
    this.rewardPerFriend = 0,
    this.tipText =
        'You need to remind your friends to complete the newbie tasks\n'
        'and receive rewards',
    this.items = const [],
  });

  InviteFriendState copyWith({
    bool? isLoading,
    double? totalBonus,
    double? receivedBonus,
    int? doneCount,
    int? totalCount,
    bool? showFriends,
    bool? hasClaimed,
    String? rewardRule,
    String? activityCode,
    double? rewardPerFriend,
    String? tipText,
    List<ActivityRecord>? items,
  }) {
    return InviteFriendState(
      isLoading: isLoading ?? this.isLoading,
      totalBonus: totalBonus ?? this.totalBonus,
      receivedBonus: receivedBonus ?? this.receivedBonus,
      doneCount: doneCount ?? this.doneCount,
      totalCount: totalCount ?? this.totalCount,
      showFriends: showFriends ?? this.showFriends,
      hasClaimed: hasClaimed ?? this.hasClaimed,
      rewardRule: rewardRule ?? this.rewardRule,
      activityCode: activityCode ?? this.activityCode,
      rewardPerFriend: rewardPerFriend ?? this.rewardPerFriend,
      tipText: tipText ?? this.tipText,
      items: items ?? this.items,
    );
  }

  InviteRewardStatus get rewardStatus {
    if (doneCount >= totalCount && totalCount > 0) {
      return hasClaimed ? InviteRewardStatus.claimed : InviteRewardStatus.ready;
    }
    return InviteRewardStatus.pending;
  }
}

class InviteFriendViewModel extends StateNotifier<InviteFriendState> {
  final Ref ref;
  InviteFriendViewModel(this.ref) : super(const InviteFriendState());

  Future<void> refresh() async {
    try {
      state = state.copyWith(isLoading: true);
      InviteFriendsModel? data;

      // const mockJson = {
      //   "activityRecord": {
      //     "id": 1934,
      //     "username": "8942838381",
      //     "rewardRule": "old_rpt_new_reward",
      //     "activityCode": "old_rpt_new_reward",
      //     "rewardAmt": 50,
      //     "condition": 1,
      //     "conditionAmt": 30,
      //     "settleAmt": 30,
      //     "done": 0,
      //     "uptDate": 1765083998,
      //     "params": "{\"9476332654\": \"0\", \"9883390509\": \"1\"}",
      //     "crtDate": 1764305970,
      //   },
      //   "oldRptNewReward": {
      //     "name": "old_rpt_new_reward",
      //     "fixed": 30,
      //     "ratio": 0,
      //     "minCondi": 1,
      //     "ruleActive": 1,
      //     "rule": "{}",
      //   },
      // };
      // data = InviteFriendsModel.fromJson(mockJson);

      final actions = ref.read(activeActionsProvider);
      final response = await actions.inviteFriendsApi();
      if (!response.success || response.data == null) {
        state = state.copyWith(isLoading: false);
        return;
      }
      data = response.data!;

      final record = data.activityRecord;
      final reward = data.oldRptNewReward;
      final fixed = (reward?.fixed ?? 0).toDouble();
      final hasClaimed = (record?.done ?? 0) == 1;
      final items = _parseFriendItems(record, fixed);
      final totalCount = items.length;
      final doneCount = items.where((item) => item.done == 1).length;
      final receivedBonus = fixed * doneCount;
      final totalBonus = items.length * (record?.settleAmt ?? 0).toDouble();

      state = state.copyWith(
        isLoading: false,
        totalBonus: totalBonus,
        receivedBonus: receivedBonus,
        doneCount: doneCount,
        totalCount: totalCount,
        hasClaimed: hasClaimed,
        rewardRule: reward?.name ?? '',
        activityCode: record?.activityCode ?? '',
        rewardPerFriend: fixed,
        items: items,
      );
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  List<ActivityRecord> _parseFriendItems(
    ActivityRecord? record,
    double rewardPerFriend,
  ) {
    if (record == null || record.params.isEmpty) return const [];
    try {
      final raw = jsonDecode(record.params);
      if (raw is! Map) return const [];
      return raw.entries
          .map((entry) {
            final username = entry.key?.toString() ?? '';
            final doneValue = int.tryParse(entry.value.toString()) ?? 0;

            return ActivityRecord(
              id: 0,
              username: username,
              rewardRule: record.rewardRule,
              activityCode: record.activityCode,
              rewardAmt: rewardPerFriend,
              condition: 0,
              conditionAmt: record.conditionAmt,
              settleAmt: record.rewardAmt,
              done: doneValue,
              uptDate: 0,
              params: '',
              crtDate: 0,
            );
          })
          .where((item) => item.username.isNotEmpty)
          .toList();
    } catch (_) {
      return const [];
    }
  }

  void toggleShowFriends() {
    state = state.copyWith(showFriends: !state.showFriends);
  }

  Future<void> receiveRewards() async {
    if (state.rewardStatus != InviteRewardStatus.ready) return;
    if (state.activityCode.isEmpty) return;
    try {
      state = state.copyWith(isLoading: true);
      final actions = ref.read(activeActionsProvider);
      final response = await actions.inviteFriendsRewardApi(
        activityCode: state.activityCode,
      );
      if (!response.success) {
        state = state.copyWith(isLoading: false);
        return;
      }
      state = state.copyWith(isLoading: false, hasClaimed: true);
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  void inviteFriends() {}
}

final inviteFriendViewModelProvider =
    StateNotifierProvider.autoDispose<InviteFriendViewModel, InviteFriendState>(
      (ref) {
        return InviteFriendViewModel(ref);
      },
    );
