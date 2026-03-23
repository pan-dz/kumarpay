import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:kumar_pay/app/toast/app_toast.dart';
import 'package:kumar_pay/presentation/pages/active_page/team/my_team_page.dart';
import 'package:kumar_pay/presentation/widgets/hx_inkwell_button.dart';
import 'package:kumar_pay/presentation/widgets/popup_dialog.dart';
import 'package:kumar_pay/presentation/widgets/common_widgets.dart';
import 'package:kumar_pay/presentation/pages/active_page/team/invite_friend.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kumar_pay/presentation/viewmodels/active_viewmodel/team/team_viewmodel.dart';
import 'package:qr_flutter/qr_flutter.dart';

class TeamPage extends ConsumerWidget {
  const TeamPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(teamViewModelProvider);
    final paddingTop = MediaQuery.of(context).padding.top;

    return Scaffold(
      // backgroundColor: const Color(0xFFF2F3F7),
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: Stack(
        children: [
          Positioned(top: 0, left: 0, right: 0, child: _Header(state: state)),

          Positioned(
            top: 60 + paddingTop,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 50),
                    _SummaryCard(state: state),
                    const SizedBox(height: 12),
                    _InvitationCard(state: state),
                    _CommissionList(state: state),
                  ],
                ),
              ),
            ),
          ),

          Positioned(
            top: 24 + paddingTop,
            left: 12,
            child: _buildHeaderInfo(context, state),
          ),

          Positioned(
            right: 0,
            top: 6 + paddingTop,
            child: Container(
              width: 75,
              height: 75,
              decoration: BoxDecoration(
                image: const DecorationImage(
                  image: AssetImage('assets/images/km_team_jinbi.webp'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          if (state.isLoading)
            const Positioned.fill(child: CommonLoadingView()),
        ],
      ),
    );
  }

  Widget _buildHeaderInfo(BuildContext context, TeamState state) {
    final primary = Theme.of(context).primaryColor;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const CircleAvatar(
          radius: 34,
          backgroundColor: Color(0xFFEAF7F3),
          child: CircleAvatar(
            radius: 32,
            backgroundColor: Color(0xFF1ABC9C),
            child: Icon(Icons.person, color: Colors.white, size: 42),
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ID: ${state.userId}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                height: 1,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Text(
                  'Reward：',
                  style: TextStyle(
                    color: primary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  state.rewardText,
                  style: TextStyle(
                    color: primary,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    height: 1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  final TeamState state;
  const _Header({required this.state});

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;
    return Container(
      height: 100 + topInset,
      decoration: BoxDecoration(
        image: const DecorationImage(
          image: AssetImage('assets/images/km_team_bg.webp'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

class _SummaryCard extends ConsumerWidget {
  final TeamState state;
  const _SummaryCard({required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: const DecorationImage(
                image: AssetImage('assets/images/team_bg.webp'),
                fit: BoxFit.cover,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 6, top: 6, bottom: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const Text(
                          'Total Commission:',
                          style: TextStyle(
                            color: Color(0xFF1F2024),
                            fontWeight: FontWeight.w600,
                            height: 1,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          state.totalCommission.toStringAsFixed(2),
                          style: const TextStyle(
                            color: Color(0xFF1F2024),
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            height: 1,
                          ),
                        ),
                      ],
                    ),
                  ),

                  GridView(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 8,
                          crossAxisSpacing: 8,
                          childAspectRatio: 2.4,
                        ),
                    children: [
                      _Tile(
                        topTitle: 'View',
                        title: 'Invite Friends Reward',
                        value: state.viewAmount.toStringAsFixed(2),
                        leading: Icons.visibility,
                        trailingArrow: true,
                        lineHeight: 1,
                        bgImage: 'assets/images/km_team_k1.webp',
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const InviteFriendPage(),
                            ),
                          );
                        },
                      ),
                      _Tile(
                        topTitle: state.myTotalProfit.toStringAsFixed(2),
                        title: 'My Total Profit',
                        value: state.myTotalProfit.toStringAsFixed(2),
                        leading: Icons.visibility,
                        trailingArrow: true,
                        lineHeight: 1,
                        bgImage: 'assets/images/km_team_k2.webp',
                        onTap: () => _handleDailyProfitTap(context, ref),
                      ),
                      _Tile(
                        topTitle: state.teamCount.toString(),
                        title: 'Team Count',
                        value: state.viewAmount.toStringAsFixed(2),
                        leading: Icons.visibility,
                        trailingArrow: true,
                        lineHeight: 2,
                        bgImage: 'assets/images/km_team_k3.webp',
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const MyTeamPage(),
                            ),
                          );
                        },
                      ),
                      _Tile(
                        topTitle: state.yesterdayTeamCommission.toStringAsFixed(
                          2,
                        ),
                        title: 'Yesterday Team \nCommission',
                        value: state.viewAmount.toStringAsFixed(2),
                        leading: Icons.visibility,
                        trailingArrow: false,
                        lineHeight: 1,
                        bgImage: 'assets/images/km_team_k4.webp',
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Today Team Commission:',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF1F2024),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          state.todayTeamCommission.toDouble().toStringAsFixed(
                            2,
                          ),
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFFFE6600),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  _CommissionProgress(
                    todayTeamCommission: state.todayTeamCommission,
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          right: 35,
          top: -20,
          child: Container(
            width: 88,
            height: 60,
            decoration: BoxDecoration(
              image: const DecorationImage(
                image: AssetImage('assets/images/team_img1.webp'),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleDailyProfitTap(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final navigator = Navigator.of(context, rootNavigator: true);
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const CommonLoadingView(),
    );

    try {
      await ref
          .read(teamViewModelProvider.notifier)
          .fetchTeamDailyDataForYesterday();
    } finally {
      if (context.mounted && navigator.canPop()) {
        navigator.pop();
      }
    }

    if (!context.mounted) return;

    DateTime selectedDate = DateTime.now().subtract(const Duration(days: 1));
    PopupDialog.show(
      context: context,
      config: PopupDialogConfig(
        position: DialogPosition.center,
        title: 'Daily Profit',
        primaryButtonText: 'Close',
        showCloseButton: false,
        showFooterButtons: true,
        showDoubleButtons: false,
        minHeight: 200,
      ),
      child: Consumer(
        builder: (context, ref, _) {
          final dailyState = ref.watch(teamViewModelProvider);
          return StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 12),
                  _InfoRow(
                    label: 'Profit Date',
                    value: _formatDate(selectedDate),
                    valueColor: const Color(0xFF1F2024),
                    trailingIcon: Icons.arrow_forward_ios,
                    onTap: () async {
                      final picked = await _pickDateCupertinoNumeric(
                        context,
                        initialDate: selectedDate,
                        minYear: 2020,
                        maxYear: 2040,
                      );
                      if (picked != null) {
                        setState(() => selectedDate = picked);

                        final navigator = Navigator.of(
                          context,
                          rootNavigator: true,
                        );
                        showDialog<void>(
                          context: context,
                          barrierDismissible: false,
                          builder: (_) => const CommonLoadingView(),
                        );

                        try {
                          await ref
                              .read(teamViewModelProvider.notifier)
                              .fetchTeamDailyDataForYesterday();
                        } finally {
                          if (context.mounted && navigator.canPop()) {
                            navigator.pop();
                          }
                        }
                      }
                    },
                  ),
                  _InfoRow(
                    label: 'Buy Times (INR)',
                    value: dailyState.dailyBuyTimes.toString(),
                  ),
                  _InfoRow(
                    label: 'Buy IToken (INR)',
                    value: dailyState.dailyBuyAmount.toStringAsFixed(2),
                  ),
                  _InfoRow(
                    label: 'Trade Profit (INR)',
                    value: dailyState.dailyTradeProfit.toStringAsFixed(2),
                  ),
                  _InfoRow(
                    label: 'Team Profit',
                    value: dailyState.dailyTeamProfit.toStringAsFixed(2),
                  ),
                  _InfoRow(
                    label: 'Event Reward',
                    value: dailyState.dailyEventReward.toStringAsFixed(2),
                  ),
                  _InfoRow(
                    label: 'Sell IToken',
                    value: dailyState.dailySellAmount.toStringAsFixed(2),
                  ),
                  _InfoRow(
                    label: 'Sell Times',
                    value: dailyState.dailySellTimes.toString(),
                  ),
                  _InfoRow(
                    label: 'Total Profit',
                    value: dailyState.dailyTotalProfit.toStringAsFixed(2),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _CommissionProgress extends StatelessWidget {
  final double todayTeamCommission;

  const _CommissionProgress({required this.todayTeamCommission});

  @override
  Widget build(BuildContext context) {
    const double targetValue = 500;
    final progress = (todayTeamCommission / targetValue).clamp(0.0, 1.0);
    final progressPercent = (progress * 100).toStringAsFixed(2);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: SizedBox(
              height: 15,
              child: Stack(
                children: [
                  Container(
                    height: 15,
                    // color: const Color(0xFFE5E5E5),
                    decoration: ShapeDecoration(
                      color: const Color(0xFFFDFFFD),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      shadows: [
                        BoxShadow(
                          color: Color(0x19000000),
                          blurRadius: 2.10,
                          offset: Offset(0, 3),
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: progress,
                    child: Container(
                      decoration: ShapeDecoration(
                        gradient: LinearGradient(
                          begin: Alignment(1.00, 0.50),
                          end: Alignment(0.00, 0.50),
                          colors: [
                            const Color(0xFFEC711E),
                            const Color(0xFFF1B614),
                          ],
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Text(
                        '$progressPercent%',
                        style: const TextStyle(
                          color: Color(0xFF2F3036),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          height: 1,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '0',
                style: TextStyle(
                  color: Color(0xFF7F7F9A),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                'DailyCommission Tasks $progressPercent%',
                style: const TextStyle(
                  color: Color(0xFF8F9098),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Text(
                '500',
                style: TextStyle(
                  color: Color(0xFF7F7F9A),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  final String title;
  final String value;
  final IconData leading;
  final bool trailingArrow;
  final String? topTitle;
  final String? bgImage;
  final double? lineHeight;
  final VoidCallback? onTap;
  const _Tile({
    required this.title,
    required this.value,
    required this.leading,
    this.trailingArrow = false,
    this.topTitle,
    this.bgImage,
    this.lineHeight,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final headerText = topTitle ?? title;
    return SizedBox(
      height: 118,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: trailingArrow ? onTap : null,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.asset(bgImage!, height: 240, fit: BoxFit.cover),
                ),
                Positioned(
                  left: 12,
                  top: 12,
                  child: Text(
                    headerText,
                    style: const TextStyle(
                      color: Color(0xFF1F2024),
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      height: 1,
                    ),
                  ),
                ),
                Positioned(
                  left: 10,
                  right: 0,
                  bottom: trailingArrow ? 2 : 3,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                          height: lineHeight,
                        ),
                      ),
                      if (trailingArrow)
                        const Icon(
                          Icons.chevron_right,
                          color: Color(0xFFA3EBC0),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InvitationCard extends ConsumerWidget {
  final TeamState state;
  const _InvitationCard({required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 8, 6, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.person, color: Color(0xFF00BC48)),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Invitation Link',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF1F2024),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  _SquareIconButton(
                    icon: Icons.qr_code,
                    onTap: () => _showInviteQrDialog(context, state),
                  ),
                ],
              ),

              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 36),
                    child: Text(
                      state.invitationLink,
                      style: const TextStyle(
                        color: Color(0xFF4E5969),
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 6),
                  HxInkWellButton(
                    child: const Icon(
                      Icons.copy,
                      size: 16,
                      color: Color(0xFF8F9098),
                    ),
                    onButtonPressed: () async {
                      Clipboard.setData(
                        ClipboardData(text: state.invitationLink),
                      );
                      AppToast.success(context, 'Copied to clipboard');
                    },
                  ),
                ],
              ),
            ],
          ),
        ),

        const Divider(
          height: 0.5,
          thickness: 0.5,
          indent: 52,
          endIndent: 12,
          color: Color(0xFFD3D5DD),
        ),
      ],
    );
  }
}

class _SquareIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _SquareIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return HxInkWellButton(
      child: Container(
        width: 34,
        height: 28,
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFD3D5DD)),
          borderRadius: BorderRadius.circular(6),
        ),
        alignment: Alignment.center,
        child: Icon(icon, size: 18, color: const Color(0xFF1F2024)),
      ),

      onButtonPressed: () => onTap(),
    );
  }
}

void _showInviteQrDialog(BuildContext context, TeamState state) {
  PopupDialog.show(
    context: context,
    config: PopupDialogConfig(
      position: DialogPosition.center,
      title: state.inviteCode,
      primaryButtonText: 'Close',
      showCloseButton: false,
      showFooterButtons: true,
      showDoubleButtons: false,
      minHeight: 240,
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        QrImageView(
          data: '${state.invitationLink}${state.inviteCode}',
          size: 180,
          backgroundColor: Colors.white,
          errorCorrectionLevel: QrErrorCorrectLevel.Q,
        ),
      ],
    ),
  );
}

class _CommissionList extends StatelessWidget {
  final TeamState state;
  const _CommissionList({required this.state});

  @override
  Widget build(BuildContext context) {
    final items = [
      ('level 1 Commission = Buy * ', state.level1Percent),
      ('level 2 Commission = Buy * ', state.level2Percent),
      ('level 3 Commission = Buy * ', state.level3Percent),
    ];
    return Column(
      children: List.generate(items.length, (i) {
        final (label, pct) = items[i];
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  const Icon(Icons.groups, color: Color(0xFF00BC48)),
                  const SizedBox(width: 12),
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF2F3036),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '${pct.toStringAsFixed(1)}%',
                    style: const TextStyle(
                      color: Color(0xFFFF2E2E),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(
              height: 0.5,
              thickness: 0.5,
              indent: 52,
              endIndent: 12,
              color: Color(0xFFD3D5DD),
            ),
          ],
        );
      }),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;
  final VoidCallback? onTap;
  final IconData? trailingIcon;
  const _InfoRow({
    required this.label,
    required this.value,
    this.valueColor = const Color(0xFFFFA300),
    this.onTap,
    this.trailingIcon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: EdgeInsets.only(bottom: 10),
        child: Row(
          children: [
            SizedBox(
              width: 150,
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF8F9098),
                  fontWeight: FontWeight.w500,
                  height: 1,
                ),
              ),
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Flexible(
                    child: Text(
                      value,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 14,
                        color: valueColor,
                        fontWeight: FontWeight.w500,
                        height: 1,
                      ),
                    ),
                  ),
                  if (trailingIcon != null) const SizedBox(width: 6),
                  if (trailingIcon != null)
                    Icon(
                      trailingIcon,
                      size: 16,
                      color: const Color(0xFF8F9098),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatDate(DateTime d) {
  final month = d.month.toString().padLeft(2, '0');
  final day = d.day.toString().padLeft(2, '0');
  final year = d.year.toString();
  return '$month/$day/$year';
}

Future<DateTime?> _pickDateCupertinoNumeric(
  BuildContext context, {
  DateTime? initialDate,
  int minYear = 2020,
  int maxYear = 2030,
}) async {
  final init = initialDate ?? DateTime.now();
  int year = init.year;
  int month = init.month;
  int day = init.day;

  final years = List<int>.generate(maxYear - minYear + 1, (i) => minYear + i);
  final months = List<int>.generate(12, (i) => i + 1);
  int daysCount = _daysInMonth(year, month);
  List<int> days = List<int>.generate(daysCount, (i) => i + 1);

  final yearCtrl = FixedExtentScrollController(initialItem: year - minYear);
  final monthCtrl = FixedExtentScrollController(initialItem: month - 1);
  final dayCtrl = FixedExtentScrollController(initialItem: day - 1);

  return showCupertinoModalPopup<DateTime>(
    context: context,
    builder: (_) => Container(
      height: 320,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: StatefulBuilder(
        builder: (context, setState) {
          return Column(
            children: [
              SizedBox(
                height: 70,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: 120,
                      child: CupertinoButton(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: const Text(
                          'Cancel',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            color: Color(0xFF8F9098),
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            height: 1,
                          ),
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),

                    Expanded(
                      child: const Text(
                        'Date',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF1F2024),
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),

                    SizedBox(
                      width: 120,
                      child: CupertinoButton(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: const Text(
                          'OK',
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            color: Color(0xFF27AE60),
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            height: 1,
                          ),
                        ),
                        onPressed: () => Navigator.of(
                          context,
                        ).pop(DateTime(year, month, day)),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Expanded(
                      child: CupertinoPicker(
                        scrollController: monthCtrl,
                        itemExtent: 42,
                        magnification: 1.1,
                        useMagnifier: true,
                        onSelectedItemChanged: (index) {
                          month = months[index];
                          final newCount = _daysInMonth(year, month);
                          if (newCount != daysCount) {
                            daysCount = newCount;
                            days = List<int>.generate(daysCount, (i) => i + 1);
                            if (day > daysCount) {
                              day = daysCount;
                              dayCtrl.jumpToItem(day - 1);
                            }
                            setState(() {});
                          }
                        },
                        children: months
                            .map((m) => Center(child: Text('$m')))
                            .toList(),
                      ),
                    ),
                    Expanded(
                      child: CupertinoPicker(
                        scrollController: dayCtrl,
                        itemExtent: 42,
                        magnification: 1.1,
                        useMagnifier: true,
                        onSelectedItemChanged: (index) {
                          day = days[index];
                        },
                        children: days
                            .map((d) => Center(child: Text('$d')))
                            .toList(),
                      ),
                    ),
                    Expanded(
                      child: CupertinoPicker(
                        scrollController: yearCtrl,
                        itemExtent: 42,
                        magnification: 1.1,
                        useMagnifier: true,
                        onSelectedItemChanged: (index) {
                          year = years[index];
                          final newCount = _daysInMonth(year, month);
                          if (newCount != daysCount) {
                            daysCount = newCount;
                            days = List<int>.generate(daysCount, (i) => i + 1);
                            if (day > daysCount) {
                              day = daysCount;
                              dayCtrl.jumpToItem(day - 1);
                            }
                            setState(() {});
                          }
                        },
                        children: years
                            .map((y) => Center(child: Text('$y')))
                            .toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    ),
  );
}

int _daysInMonth(int year, int month) {
  return DateTime(year, month + 1, 0).day;
}
