import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:kumar_pay/app/config/storage_keys.dart';
import 'package:kumar_pay/app/services/app_update_service.dart';
import 'package:kumar_pay/app/toast/app_toast.dart';
import 'package:kumar_pay/presentation/pages/active_page/newbie_reward.dart';
import 'package:kumar_pay/presentation/widgets/hx_button.dart';
import 'package:kumar_pay/presentation/widgets/popup_dialog.dart';
import 'package:kumar_pay/presentation/widgets/common_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kumar_pay/core/utils/base.dart';
import 'package:kumar_pay/presentation/viewmodels/mine_viewmodel/mine_viewmodel.dart';
import 'package:kumar_pay/presentation/widgets/hx_input.dart';
import 'package:kumar_pay/presentation/pages/mine_page/buy_history_page.dart';
import 'package:kumar_pay/presentation/pages/mine_page/sell_history_page.dart';
import 'package:kumar_pay/presentation/pages/mine_page/transfer_history_page.dart';
import 'package:kumar_pay/presentation/pages/login_page/modify_pwd_page.dart';
import 'package:kumar_pay/presentation/pages/login_page/login_page.dart';
import 'package:kumar_pay/presentation/pages/mine_page/customer_service.dart';

class MinePage extends ConsumerWidget {
  const MinePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(mineViewModelProvider);

    return Stack(
      children: [
        CustomScrollView(
          slivers: [
            SliverPersistentHeader(
              pinned: true,
              delegate: _MineHeaderDelegate(state),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 12)),

            SliverToBoxAdapter(
              child: _StatsCard(ref: ref, state: state),
            ),

            if (state.minSellIToken == 1)
              SliverToBoxAdapter(
                child: _SetOrderSize(ref: ref, state: state),
              ),

            SliverToBoxAdapter(
              child: _MenuSection(state: state, ref: ref),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 12)),

            SliverToBoxAdapter(child: _SignOutButton(ref: ref)),
            const SliverToBoxAdapter(child: SizedBox(height: 44)),
          ],
        ),
        if (state.isTodayProfitLoading ||
            state.isUserInfoLoading ||
            state.isOrderSizeLoading)
          const Positioned.fill(child: CommonLoadingView()),
      ],
    );
  }
}

class _HeaderSection extends StatefulWidget {
  final MineState state;
  const _HeaderSection({required this.state});

  @override
  State<_HeaderSection> createState() => _HeaderSectionState();
}

class _HeaderSectionState extends State<_HeaderSection> {
  bool _showUserName = false;

  String get _displayUserName {
    if (_showUserName) return widget.state.userName;
    return maskMiddle(widget.state.userName, prefix: 2, suffix: 2);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 220,
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0, 2),
              radius: 1.3,
              focalRadius: 20,
              colors: [Color(0xFFC4FFCC), Color(0xFF00BC48)],
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 32),
                Text(
                  'Mine',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 16),

                CircleAvatar(
                  radius: 22,
                  backgroundColor: Colors.white,
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: const Color(0xFF1ABC9C),
                    child: Text(
                      'U',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _TagChip(
                      label: 'Name:$_displayUserName',
                      onTap: () async {
                        await Clipboard.setData(
                          ClipboardData(text: widget.state.userName),
                        );
                        if (!context.mounted) return;
                        AppToast.success(context, 'Name copied');
                      },
                      trailingIcon: _showUserName
                          ? Icons.visibility_off
                          : Icons.visibility,
                      onTrailingTap: () {
                        setState(() {
                          _showUserName = !_showUserName;
                        });
                      },
                    ),
                    const SizedBox(width: 4),
                    _TagChip(
                      label:
                          'Reward: ${GetStorage().read(StorageKeys.reward) ?? ''}',
                    ),

                    const SizedBox(width: 4),
                    _TagChip(
                      label: 'ID:${widget.state.teamWorkId}',
                      showArrow: true,
                      onTap: () async {
                        await Clipboard.setData(
                          ClipboardData(text: widget.state.teamWorkId),
                        );
                        if (!context.mounted) return;
                        AppToast.success(context, 'ID copied');
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _MineHeaderDelegate extends SliverPersistentHeaderDelegate {
  final MineState state;
  _MineHeaderDelegate(this.state);

  @override
  double get minExtent => 220;

  @override
  double get maxExtent => 220;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return _HeaderSection(state: state);
  }

  @override
  bool shouldRebuild(covariant _MineHeaderDelegate oldDelegate) {
    return oldDelegate.state != state;
  }
}

class _StatsCard extends StatelessWidget {
  final WidgetRef ref;
  final MineState state;

  const _StatsCard({required this.ref, required this.state});

  @override
  Widget build(BuildContext context) {
    final textStyleSub = Theme.of(
      context,
    ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]);
    final iTokenParsed = num.tryParse(state.iToken.toString());
    final iTokenText = (iTokenParsed != null && iTokenParsed < 0)
        ? '0'
        : state.iToken.toString();

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: Color(0xFFD3D5DD)),
      ),
      elevation: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _StatColumn(
            icon: SizedBox(
              width: 20,
              child: Text('🇮🇳', style: TextStyle(fontSize: 14)),
            ),
            title: iTokenText,
            subtitle: 'IToken',
            subStyle: textStyleSub,
            onTap: () => PopupDialog.show(
              context: context,
              config: PopupDialogConfig(
                position: DialogPosition.center,
                title: 'IToken Detail',
                primaryButtonText: 'Close',
                showCloseButton: false,
                showFooterButtons: true,
                showDoubleButtons: false,
                minHeight: 200,
              ),
              child: _ColumnSpaceBetween(
                items: [
                  _LabelValue(label: 'Available:', value: iTokenText),
                  _LabelValue(label: 'In Sell:', value: state.frozenItoken),
                ],
              ),
            ),
          ),
          _DividerV(),
          _StatColumn(
            icon: const Icon(
              Icons.card_giftcard,
              color: Color(0xFF1F2024),
              size: 16,
            ),
            title: state.todayProfit.toString(),
            subtitle: 'Today Profit',
            subStyle: textStyleSub,
            onTap: () async {
              if (ref.read(mineViewModelProvider).isTodayProfitLoading) {
                return;
              }
              await ref
                  .read(mineViewModelProvider.notifier)
                  .fetchTodayProfit(context);

              // 读取最新状态后再弹出详情弹窗
              final s = ref.read(mineViewModelProvider);
              PopupDialog.show(
                context: context,
                config: PopupDialogConfig(
                  position: DialogPosition.center,
                  title: 'Today Profit Detail',
                  primaryButtonText: 'Close',
                  showCloseButton: false,
                  showFooterButtons: true,
                  showDoubleButtons: false,
                  minHeight: 200,
                ),
                child: _ColumnSpaceBetween(
                  items: [
                    _LabelValue(
                      label: 'Trade Profit (INR):',
                      value: s.tradeProfit,
                    ),
                    _LabelValue(label: 'Team Profit:', value: s.teamProfit),
                    _LabelValue(label: 'Event Reward:', value: s.eventProfit),
                  ],
                ),
              );
            },
          ),
          _DividerV(),
          _StatColumn(
            icon: const Icon(
              Icons.receipt_long,
              color: Color(0xFF1F2024),
              size: 16,
            ),
            title: 'UPI',
            subtitle: 'Sell History',
            subStyle: textStyleSub,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SellHistoryPage(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _MenuSection extends StatefulWidget {
  final MineState state;
  final WidgetRef ref;
  const _MenuSection({required this.state, required this.ref});

  @override
  State<_MenuSection> createState() => _MenuSectionState();
}

class _MenuSectionState extends State<_MenuSection> {
  String _versionText = '';

  @override
  void initState() {
    super.initState();
    _loadVersionText();
  }

  Future<void> _loadVersionText() async {
    if (kIsWeb) {
      return;
    }

    try {
      final versionText = await AppUpdateService.getDisplayVersionText();
      if (!mounted) return;
      setState(() {
        _versionText = versionText;
      });
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: Color(0xFFD3D5DD)),
      ),
      elevation: 0,
      child: Column(
        children: [
          _MenuTile(
            icon: Icons.shopping_bag_outlined,
            title: 'Buy History',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BuyHistoryPage()),
              );
            },
          ),
          _MenuTileDivider(),

          _MenuTile(
            icon: Icons.event,
            title: 'Event Center',
            onTap: () => PopupDialog.show(
              context: context,
              config: PopupDialogConfig(
                position: DialogPosition.center,
                title: 'Event List',
                primaryButtonText: 'Cancel',
                showCloseButton: false,
                showFooterButtons: true,
                showDoubleButtons: false,
                minHeight: MediaQuery.of(context).size.height - 400,
              ),
              child: SizedBox(
                height: MediaQuery.of(context).size.height - 560,
                // height: MediaQuery.of(context).size.height - 570,
                child: Column(
                  children: [
                    HxButton(
                      width: double.infinity,
                      height: 48,
                      color: Color.fromARGB(255, 175, 175, 175),
                      fontColor: Color(0xFF1F2024),
                      text: 'Newbie Reward',
                      outlined: true,
                      type: HxButtonType.medium,
                      onButtonPressed: () {
                        Navigator.of(context).pop();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const NewbieRewardPage(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          _MenuTileDivider(),

          _MenuTile(
            icon: Icons.history,
            title: 'Transfer IToken History',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TransferHistoryPage(),
                ),
              );
            },
          ),
          _MenuTileDivider(),

          _MenuTile(
            icon: Icons.school_outlined,
            title: 'Tutorial',
            onTap: () => widget.ref
                .read(mineViewModelProvider.notifier)
                .handleClickVideo(),
          ),
          _MenuTileDivider(),

          _MenuTile(
            icon: Icons.support_agent,
            title: 'Official Service',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CustomerServicePage(),
                ),
              );
            },
          ),
          _MenuTileDivider(),

          _MenuTile(
            icon: Icons.lock_outline,
            title: 'Modify Password',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ModifyPwdPage(
                    phone: widget.state.phone,
                    type: 'mine modify',
                  ),
                ),
              );
            },
          ),
          if (!kIsWeb) ...[
            _MenuTileDivider(),
            _MenuTile(
              icon: Icons.track_changes,
              title: 'Regarding KumarPay',
              trailingText: _versionText,
              trailingTextColor: const Color(0xFF8F9098),
              showChevron: false,
              onTap: () {},
            ),
          ],
        ],
      ),
    );
  }
}

class _SignOutButton extends StatelessWidget {
  final WidgetRef ref;
  const _SignOutButton({required this.ref});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: HxButton(
        width: double.infinity,
        height: 48,
        color: Color(0xFFD3D5DD),
        fontColor: Color(0xFF1F2024),
        text: 'Sign Out',
        outlined: true,
        type: HxButtonType.medium,
        leading: const Icon(Icons.logout),
        onButtonPressed: () => _showSignOutDialog(context),
      ),
    );
  }

  void _showSignOutDialog(BuildContext context) {
    PopupDialog.show(
      context: context,
      config: PopupDialogConfig(
        position: DialogPosition.center,
        title: 'Confirm Exit',
        showCloseButton: false,
        showFooterButtons: true,
        minHeight: 130,
      ),
      child: const Text(
        'Confirm to log out?',
        style: TextStyle(
          color: Color(0xFF8F9098),
          fontSize: 14,
          fontWeight: FontWeight.w500,
          height: 1.2,
        ),
      ),
      onCancel: () => {},
      onConfirm: () {
        ref.read(mineViewModelProvider.notifier).signOut();
        final navigator = Navigator.of(context, rootNavigator: true);
        if (navigator.canPop()) {
          navigator.pop();
        }
        Future.microtask(() {
          navigator.pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const LoginPage()),
            (route) => false,
          );
        });
      },
    );
  }
}

class _TagChip extends StatelessWidget {
  final String label;
  final bool showArrow;
  final VoidCallback? onTap;
  final IconData? trailingIcon;
  final VoidCallback? onTrailingTap;

  const _TagChip({
    required this.label,
    this.showArrow = false,
    this.onTap,
    this.trailingIcon,
    this.onTrailingTap,
  });

  @override
  Widget build(BuildContext context) {
    final content = Container(
      padding: EdgeInsets.only(
        left: 6,
        right: (showArrow || trailingIcon != null) ? 0 : 6,
        top: 6,
        bottom: 6,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF33CC6B),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
          if (trailingIcon != null) ...[
            InkWell(
              borderRadius: BorderRadius.circular(4),
              onTap: onTrailingTap,
              child: Padding(
                padding: const EdgeInsets.only(left: 2, right: 4),
                child: Icon(trailingIcon, size: 16, color: Colors.white),
              ),
            ),
          ] else if (showArrow) ...[
            const Icon(Icons.arrow_right, size: 18, color: Colors.white),
          ],
        ],
      ),
    );

    if (onTap == null) return content;

    return InkWell(
      borderRadius: BorderRadius.circular(4),
      onTap: onTap,
      child: content,
    );
  }
}

class _StatColumn extends StatelessWidget {
  final Widget icon;
  final String title;
  final String subtitle;
  final TextStyle? subStyle;
  final VoidCallback? onTap;

  const _StatColumn({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.subStyle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(6),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF1F2024),
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                icon,
                Text(subtitle, style: subStyle),
                const Icon(
                  Icons.arrow_right,
                  color: Color(0xFF1F2024),
                  size: 20,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DividerV extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(height: 40, width: 0.5, color: const Color(0xFFD3D5DD));
  }
}

class _MenuTileDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(
      color: Color(0xFFD3D5DD),
      height: 0.5,
      indent: 12,
      endIndent: 12,
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? trailingText;
  final Color? trailingTextColor;
  final bool showChevron;
  final VoidCallback? onTap;
  const _MenuTile({
    required this.icon,
    required this.title,
    this.trailingText,
    this.trailingTextColor,
    this.showChevron = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final trailingStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
      color: trailingTextColor ?? const Color(0xFFFFA300),
      fontSize: 14,
      fontWeight: FontWeight.w500,
    );
    return ListTile(
      dense: true,
      minLeadingWidth: 0,
      tileColor: Colors.transparent,
      selectedTileColor: Colors.transparent,
      splashColor: Colors.transparent,
      hoverColor: Colors.transparent,
      focusColor: Colors.transparent,
      horizontalTitleGap: 8,
      leading: Icon(icon, color: const Color(0xFF1F2024)),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          color: Color(0xFF1F2024),
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailingText != null)
            Padding(
              padding: const EdgeInsets.only(right: 0.0),
              child: Text(trailingText!, style: trailingStyle),
            ),
          if (showChevron)
            const Icon(Icons.chevron_right, color: Color(0xFF8F9098), size: 24),
        ],
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
    );
  }
}

class _LabelValue {
  final String label;
  final String value;

  const _LabelValue({required this.label, required this.value});
}

class _ColumnSpaceBetween extends StatelessWidget {
  final List<_LabelValue> items;

  const _ColumnSpaceBetween({required this.items});

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var i = 0; i < items.length; i++) {
      final item = items[i];
      rows.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              item.label,
              style: TextStyle(
                color: const Color(0xFF8F9098),
                fontSize: 14,
                fontWeight: FontWeight.w500,
                height: 1,
              ),
            ),
            Text(
              item.value,
              style: TextStyle(
                color: const Color(0xFF1F2024),
                fontSize: 14,
                fontWeight: FontWeight.w500,
                height: 1,
              ),
            ),
          ],
        ),
      );
      if (i < items.length - 1) rows.add(const SizedBox(height: 12));
    }
    return Column(mainAxisAlignment: MainAxisAlignment.start, children: rows);
  }
}

class _SetOrderSize extends StatelessWidget {
  final MineState state;
  final WidgetRef ref;
  const _SetOrderSize({required this.state, required this.ref});

  @override
  Widget build(BuildContext context) {
    if (state.minSellIToken != 1) {
      return const SizedBox.shrink();
    }
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: Color(0xFFD3D5DD)),
      ),
      elevation: 0,
      child: _MenuTile(
        icon: Icons.list_alt,
        title: 'Set order size',
        trailingText: state.orderSizeRange,
        onTap: () {
          ref.read(mineViewModelProvider.notifier).resetOrderSizeInputs();
          PopupDialog.show(
            context: context,
            config: PopupDialogConfig(
              position: DialogPosition.center,
              title: 'Order Sell Size Setting',
              showCloseButton: false,
              showFooterButtons: true,
              showDoubleButtons: true,
              minHeight: 430,
              primaryButtonText: 'Confirm',
              secondaryButtonText: 'Cancel',
              closeOnConfirm: false,
            ),
            onClose: () =>
                ref.read(mineViewModelProvider.notifier).resetOrderSizeInputs(),
            onCancel: () =>
                ref.read(mineViewModelProvider.notifier).resetOrderSizeInputs(),
            onConfirm: () async {
              final latest = ref.read(mineViewModelProvider);

              final min = latest.minSize ?? 0;
              final max = latest.maxSize ?? 0;
              if (min >= max) {
                AppToast.warning(context, 'Min must be less than Max.');
                return;
              }
              await ref
                  .read(mineViewModelProvider.notifier)
                  .updateOrderSizeRange('$min~$max');
              ref.read(mineViewModelProvider.notifier).resetOrderSizeInputs();
              if (!context.mounted) return;
              final navigator = Navigator.of(context, rootNavigator: true);
              if (navigator.canPop()) {
                navigator.pop();
              }
            },
            child: Consumer(
              builder: (context, ref, _) {
                final latest = ref.watch(mineViewModelProvider);
                final rawMinValue =
                    latest.minSize ??
                    _parseUserSellToken(latest.userSellToken, 0) ??
                    100;
                final rawMaxValue =
                    latest.maxSize ??
                    _parseUserSellToken(latest.userSellToken, 1) ??
                    100000;
                final minValue = rawMinValue.clamp(100, 10000);
                final maxValue = rawMaxValue.clamp(1000, 100000);
                return Stack(
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.fromLTRB(0, 12, 0, 16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'You should make the right sold size for\nyou token, otherwise the token will not\nbe sold\n',
                                style: TextStyle(
                                  color: Color(0xFF1F2024),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  height: 1.2,
                                ),
                              ),
                              const Text(
                                'Notice:\nmin is between 100 and 10,000,\nand max is between 1000 and 100,000',
                                style: TextStyle(
                                  color: Color(0xFFFF2E2E),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  height: 1.2,
                                ),
                              ),
                              const SizedBox(height: 12),

                              const Text('Min:'),
                              const SizedBox(height: 8),
                              _OrderSizeInput(
                                value: minValue,
                                min: 100,
                                max: 10000,
                                onChanged: (value) => ref
                                    .read(mineViewModelProvider.notifier)
                                    .setMinSize(value),
                              ),

                              const SizedBox(height: 12),
                              const Text('Max:'),
                              const SizedBox(height: 8),
                              _OrderSizeInput(
                                value: maxValue,
                                min: 1000,
                                max: 100000,
                                onChanged: (value) => ref
                                    .read(mineViewModelProvider.notifier)
                                    .setMaxSize(value),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (latest.isOrderSizeLoading)
                      const Positioned.fill(
                        child: CommonLoadingView(showBarrier: false),
                      ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _OrderSizeInput extends StatefulWidget {
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  const _OrderSizeInput({
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  @override
  State<_OrderSizeInput> createState() => _OrderSizeInputState();
}

class _OrderSizeInputState extends State<_OrderSizeInput> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value.toString());
    _focusNode = FocusNode();
  }

  @override
  void didUpdateWidget(covariant _OrderSizeInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    final nextText = widget.value.toString();
    if (_controller.text != nextText) {
      _controller.text = nextText;
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return HxInput(
      controller: _controller,
      focusNode: _focusNode,
      textAlign: TextAlign.start,
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.done,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      minValue: widget.min,
      maxValue: widget.max,
      onValidated: widget.onChanged,
      style: const TextStyle(
        fontSize: 16,
        color: Color(0xFF1F2024),
        fontWeight: FontWeight.w700,
        height: 1.20,
      ),
      decoration: InputDecoration(
        isDense: true,
        border: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFFD3D5DD)),
          borderRadius: BorderRadius.circular(6),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFFD3D5DD)),
          borderRadius: BorderRadius.circular(6),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color.fromARGB(255, 56, 83, 190)),
          borderRadius: BorderRadius.circular(6),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 16),
      ),
    );
  }
}

int? _parseUserSellToken(String raw, int index) {
  if (raw.isEmpty) return null;
  final parts = raw.split(',');
  if (parts.length <= index) return null;
  return int.tryParse(parts[index].trim());
}
