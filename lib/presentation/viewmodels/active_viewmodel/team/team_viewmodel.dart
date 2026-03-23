import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';
import 'package:kumar_pay/app/config/storage_keys.dart';
import 'package:kumar_pay/core/di/active_providers.dart';

class TeamState {
  final bool isLoading;
  final String userId;
  final String inviteCode;
  final String rewardText;
  final double totalCommission;
  final double viewAmount; // View
  final double myTotalProfit;
  final int teamCount;
  final double yesterdayTeamCommission;
  final double todayTeamCommission;
  final String invitationLink;
  final double level1Percent;
  final double level2Percent;
  final double level3Percent;
  final int dailyBuyTimes;
  final double dailyBuyAmount;
  final double dailyTradeProfit;
  final double dailyTeamProfit;
  final double dailyEventReward;
  final double dailySellAmount;
  final int dailySellTimes;
  final double dailyTotalProfit;

  const TeamState({
    this.isLoading = false,
    this.userId = '',
    this.inviteCode = '',
    this.rewardText = '',
    this.totalCommission = 0.0,
    this.viewAmount = 0.0,
    this.myTotalProfit = 0.0,
    this.teamCount = 0,
    this.yesterdayTeamCommission = 0.0,
    this.todayTeamCommission = 0.0,
    this.invitationLink = '',
    this.level1Percent = 0.0,
    this.level2Percent = 0.0,
    this.level3Percent = 0.0,
    this.dailyBuyTimes = 0,
    this.dailyBuyAmount = 0.0,
    this.dailyTradeProfit = 0.0,
    this.dailyTeamProfit = 0.0,
    this.dailyEventReward = 0.0,
    this.dailySellAmount = 0.0,
    this.dailySellTimes = 0,
    this.dailyTotalProfit = 0.0,
  });

  TeamState copyWith({
    bool? isLoading,
    String? userId,
    String? inviteCode,
    String? rewardText,
    double? totalCommission,
    double? viewAmount,
    double? myTotalProfit,
    int? teamCount,
    double? yesterdayTeamCommission,
    double? todayTeamCommission,
    String? invitationLink,
    double? level1Percent,
    double? level2Percent,
    double? level3Percent,
    int? dailyBuyTimes,
    double? dailyBuyAmount,
    double? dailyTradeProfit,
    double? dailyTeamProfit,
    double? dailyEventReward,
    double? dailySellAmount,
    int? dailySellTimes,
    double? dailyTotalProfit,
  }) {
    return TeamState(
      isLoading: isLoading ?? this.isLoading,
      userId: userId ?? this.userId,
      inviteCode: inviteCode ?? this.inviteCode,
      rewardText: rewardText ?? this.rewardText,
      totalCommission: totalCommission ?? this.totalCommission,
      viewAmount: viewAmount ?? this.viewAmount,
      myTotalProfit: myTotalProfit ?? this.myTotalProfit,
      teamCount: teamCount ?? this.teamCount,
      yesterdayTeamCommission:
          yesterdayTeamCommission ?? this.yesterdayTeamCommission,
      todayTeamCommission: todayTeamCommission ?? this.todayTeamCommission,
      invitationLink: invitationLink ?? this.invitationLink,
      level1Percent: level1Percent ?? this.level1Percent,
      level2Percent: level2Percent ?? this.level2Percent,
      level3Percent: level3Percent ?? this.level3Percent,
      dailyBuyTimes: dailyBuyTimes ?? this.dailyBuyTimes,
      dailyBuyAmount: dailyBuyAmount ?? this.dailyBuyAmount,
      dailyTradeProfit: dailyTradeProfit ?? this.dailyTradeProfit,
      dailyTeamProfit: dailyTeamProfit ?? this.dailyTeamProfit,
      dailyEventReward: dailyEventReward ?? this.dailyEventReward,
      dailySellAmount: dailySellAmount ?? this.dailySellAmount,
      dailySellTimes: dailySellTimes ?? this.dailySellTimes,
      dailyTotalProfit: dailyTotalProfit ?? this.dailyTotalProfit,
    );
  }
}

class TeamViewModel extends StateNotifier<TeamState> {
  final Ref ref;
  TeamViewModel(this.ref) : super(const TeamState());

  Future<void> fetchTeamInfo() async {
    try {
      state = state.copyWith(isLoading: true);
      final actions = ref.read(activeActionsProvider);
      final response = await actions.getTeamInfoApi();
      if (!response.success || response.data == null) {
        state = state.copyWith(isLoading: false);
        return;
      }

      final data = response.data!;
      final team = data.teaminfo;
      final today = data.today;
      final dividendMap = _parseDividend(data.inrBuyDividend);
      final level1 = dividendMap[1] ?? 0.0;
      final level2 = dividendMap[2] ?? 0.0;
      final level3 = dividendMap[3] ?? 0.0;

      state = state.copyWith(
        isLoading: false,
        userId: team.teamWorkId.toString(),
        inviteCode: data.inviteCode,
        rewardText: GetStorage().read(StorageKeys.reward)?.toString() ?? '',
        totalCommission: team.commission.toDouble(),
        viewAmount: team.reward.toDouble(),
        myTotalProfit: team.performance.toDouble(),
        teamCount: team.count,
        yesterdayTeamCommission: team.parentCommission.toDouble(),
        todayTeamCommission: today.dividend.toDouble(),
        invitationLink: _buildInviteLink(data.rsUrl, data.inviteCode),
        // invitationLink: _buildInviteLink('', data.inviteCode),
        level1Percent: level1 * 100,
        level2Percent: level2 * 100,
        level3Percent: level3 * 100,
      );
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> fetchTeamDailyDataForYesterday() async {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    await fetchTeamDailyData(_ymd(yesterday));
  }

  Future<void> fetchTeamDailyData(int day) async {
    try {
      final actions = ref.read(activeActionsProvider);
      final response = await actions.getTeamDailyDataApi(day: day);
      if (!response.success || response.data == null) {
        return;
      }

      final data = response.data!;
      final totalProfit = _calcDailyTotal(
        data.commission,
        data.performance,
        data.reward,
        data.dividend,
        data.bonus,
      );

      state = state.copyWith(
        dailyBuyTimes: data.times,
        dailyBuyAmount: data.recharge.toDouble(),
        dailyTradeProfit: data.commission.toDouble(),
        dailyTeamProfit: data.performance.toDouble(),
        dailyEventReward: data.reward.toDouble(),
        dailySellAmount: data.urecharge.toDouble(),
        dailySellTimes: data.utimes,
        dailyTotalProfit: totalProfit,
      );
    } catch (_) {}
  }

  Map<int, double> _parseDividend(Object? raw) {
    if (raw == null) return const {};
    if (raw is Map) {
      return _mapToDividend(raw);
    }

    final text = raw.toString().trim();
    if (text.isEmpty) return const {};

    try {
      final decoded = json.decode(text);
      if (decoded is Map) return _mapToDividend(decoded);
      return const {};
    } catch (_) {
      try {
        final normalized = _normalizeDividendJson(text);
        final decoded = json.decode(normalized);
        if (decoded is Map) return _mapToDividend(decoded);
        return const {};
      } catch (_) {
        return const {};
      }
    }
  }

  Map<int, double> _mapToDividend(Map<dynamic, dynamic> map) {
    final result = <int, double>{};
    for (final entry in map.entries) {
      final key = int.tryParse(entry.key.toString());
      if (key == null) continue;
      final value = entry.value;
      if (value is num) {
        result[key] = value.toDouble();
      } else {
        result[key] = double.tryParse(value.toString()) ?? 0.0;
      }
    }
    return result;
  }

  String _normalizeDividendJson(String raw) {
    // 将 {1: 0.003, 2: 0.002} 规范为 {"1": 0.003, "2": 0.002}
    return raw.replaceAllMapped(RegExp(r'(\b\d+\b)\s*:'), (m) => '"${m[1]}":');
  }

  String _buildInviteLink(String rsUrl, String inviteCode) {
    if (rsUrl.isEmpty) return inviteCode;
    if (inviteCode.isEmpty) return rsUrl;
    return rsUrl.endsWith('/') ? '$rsUrl$inviteCode' : '$rsUrl$inviteCode';
  }

  int _ymd(DateTime date) {
    final y = date.year.toString();
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return int.parse('$y$m$d');
  }

  double _calcDailyTotal(
    num commission,
    num performance,
    num reward,
    num dividend,
    num bonus,
  ) {
    return (commission + performance + reward + dividend + bonus).toDouble();
  }
}

final teamViewModelProvider = StateNotifierProvider<TeamViewModel, TeamState>((
  ref,
) {
  return TeamViewModel(ref);
});
