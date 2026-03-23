import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';
import 'package:kumar_pay/app/config/storage_keys.dart';
import 'package:kumar_pay/core/utils/base.dart';
import 'package:kumar_pay/core/utils/enum.dart';
import 'package:kumar_pay/presentation/pages/upi_page/freecharge_page.dart';
import 'package:kumar_pay/presentation/viewmodels/buy_viewmodel/buy_viewmodel.dart';
import 'package:kumar_pay/presentation/widgets/common_widgets.dart';
import 'package:kumar_pay/presentation/widgets/hx_button.dart';
import 'package:kumar_pay/presentation/widgets/hx_inkwell_button.dart';
import 'package:kumar_pay/presentation/widgets/popup_dialog.dart';
import 'package:kumar_pay/presentation/widgets/refresh_load_list_view.dart';
import 'package:kumar_pay/presentation/pages/layout_page.dart';
import 'package:kumar_pay/store/models/buy/buy_res_model.dart';
import 'package:kumar_pay/store/models/upi/upi_res_model.dart';

class BuyInrSliver extends ConsumerWidget {
  const BuyInrSliver({super.key, required this.theme, this.topInset = 0});
  final ThemeData theme;
  final double topInset;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(buyViewModelProvider);
    final vm = ref.read(buyViewModelProvider.notifier);

    Future<void> handleBuyTap(BuyOrderListItem order) async {
      final options = await vm.getBuyUpiList(context);

      final selected = await PopupDialog.show<UpiInfoModel>(
        context: context,
        config: PopupDialogConfig(
          position: DialogPosition.bottom,
          title: 'Pay using the following \n payment UPIs: ',
          showCloseButton: false,
          showFooterButtons: false,
          barrierDismissible: true,
          minHeight: MediaQuery.of(context).size.height - 255,
        ),
        child: _BuyUpiListPopupDialog(options: options),
      );

      if (selected == null) return;
      if (!context.mounted) return;

      final ok = await vm.buyIToken(
        context,
        orderId: order.rptNo,
        ctId: selected.id,
        ctType: selected.ctType,
      );
      if (!ok || !context.mounted) return;

      if (selected.ctType == 3) {
        // freecharge 点击显示提示弹窗，并跳转到freecharge信息页面
        await PopupDialog.show(
          context: context,
          config: PopupDialogConfig(
            position: DialogPosition.center,
            title: 'Tips',
            primaryButtonText: 'OK',
            showCloseButton: false,
            showFooterButtons: true,
            showDoubleButtons: false,
            minHeight: 240,
            closeOnConfirm: false,
          ),
          onConfirm: () {
            final rootNavigator = Navigator.of(context, rootNavigator: true);
            if (!rootNavigator.mounted) {
              return;
            }
            if (rootNavigator.canPop()) {
              rootNavigator.pop();
            }

            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => FreechargePage(
                  id: order.rptNo,
                  ctime: order.crtDate,
                  upiName: selected.upi,
                  ctType: selected.ctType,
                  walletAddress: selected.account,
                  entrySource: FreechargeEntrySource.buyList,
                ),
              ),
            );
          },
          child: Text(
            'The pre-order is successful, please use the selected payment tool to complete the payment within the specified time, otherwise the purchase will not be,completed, and the order will be,returned after the order processing timeout',
          ),
        );
      }
    }

    return SliverFillRemaining(
      child: Stack(
        children: [
          RefreshLoadListView<BuyOrderListItem>(
            items: state.items,
            onRefresh: vm.handleSearchRefresh,
            onLoadMore: vm.loadMore,
            isLoading: state.isLoading,
            noMore: state.noMore,
            padding: EdgeInsets.fromLTRB(0, topInset, 0, 0),
            emptyText: 'No Data',
            itemBuilder: (context, item, index) {
              BorderRadius borderRadius = BorderRadius.zero;
              if (index == 0) {
                borderRadius = const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                );
              }
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: borderRadius,
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: _BuyListItem(
                    item: item,
                    theme: theme,
                    tabIndex: state.tabIndex,
                    onBuyPressed: (order) => handleBuyTap(order),
                  ),
                ),
              );
            },
          ),

          if (state.isLoading || state.isBuyLoading)
            Positioned.fill(
              child: Container(
                clipBehavior: Clip.antiAlias,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: const CommonLoadingView(),
              ),
            ),
        ],
      ),
    );
  }
}

class _BuyListItem extends StatelessWidget {
  final BuyOrderListItem item;
  final ThemeData theme;
  final int tabIndex;
  final ValueChanged<BuyOrderListItem> onBuyPressed;
  const _BuyListItem({
    required this.item,
    required this.theme,
    required this.tabIndex,
    required this.onBuyPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFE8E9F1), width: 0.5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'No. ${item.rptNo}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF8F9098),
                    fontWeight: FontWeight.w600,
                    height: 1,
                  ),
                ),
                Text(
                  'Reward: ${_rewardHeaderText()}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF8F9098),
                    fontWeight: FontWeight.w500,
                    height: 1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 2,
                        child: _LcrBlock(
                          title: 'Price',
                          bottom: '₹${item.amount}',
                          color: const Color(0xFFFF2E2E),
                        ),
                      ),
                      Expanded(child: const _Sign(text: '+')),

                      Expanded(
                        flex: 2,
                        child: _LcrBlock(
                          title: 'Reward',
                          bottom: _formatNum(_rewardAmount()),
                          color: const Color(0xFF1F2024),
                        ),
                      ),
                      Expanded(child: const _Sign(text: '=')),
                      Expanded(
                        flex: 2,
                        child: _LcrBlock(
                          title: 'IToken',
                          bottom: _formatNum(item.amount + _rewardAmount()),
                          color: theme.primaryColor,
                        ),
                      ),
                      SizedBox(width: 20),
                    ],
                  ),
                ),

                HxButton(
                  width: 80,
                  height: 36,
                  color: theme.primaryColor,
                  fontColor: Colors.white,
                  text: 'Buy',
                  type: HxButtonType.medium,
                  onButtonPressed: () => onBuyPressed(item),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _rewardHeaderText() {
    final raw = tabIndex == 0
        ? (GetStorage().read(StorageKeys.rewardBig)?.toString() ?? '')
        : (GetStorage().read(StorageKeys.reward)?.toString() ?? '');
    return raw;
  }

  num _rewardAmount() {
    final reward = item.reward;
    if (reward != null) return reward;
    final rule = tabIndex == 0
        ? (GetStorage().read(StorageKeys.rewardBig)?.toString() ?? '')
        : (GetStorage().read(StorageKeys.reward)?.toString() ?? '');
    return _computeRewardByRule(item.amount, rule);
  }

  num _computeRewardByRule(num amount, String rule) {
    final trimmed = rule.trim();
    if (trimmed.isEmpty) return 0;
    final parts = trimmed.split('+');
    num ratio = 0;
    num fixed = 0;
    if (parts.isNotEmpty) {
      final ratioRaw = parts[0].replaceAll('%', '').trim();
      ratio = num.tryParse(ratioRaw) ?? 0;
    }
    if (parts.length > 1) {
      fixed = num.tryParse(parts[1].trim()) ?? 0;
    }
    return amount * ratio / 100 + fixed;
  }

  String _formatNum(num value) {
    return value.toStringAsFixed(2);
  }
}

class _BuyUpiListPopupDialog extends StatelessWidget {
  final List<UpiInfoModel> options;
  const _BuyUpiListPopupDialog({required this.options});

  @override
  Widget build(BuildContext context) {
    final titleStyle = const TextStyle(
      fontSize: 14,
      color: Color(0xFF1F2024),
      fontWeight: FontWeight.w700,
    );
    final subtitleStyle = const TextStyle(
      fontSize: 12,
      color: Color(0xFF8F9098),
      fontWeight: FontWeight.w500,
    );
    final divider = const Divider(color: Color(0xFFD3D5DD), height: 0.5);

    return SizedBox(
      height: MediaQuery.of(context).size.height - 255,
      child: options.isEmpty
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    'No Payment UPI Available.\nLink a wallet that supports purchases\n (e.g., Freecharge, Mobikwik).',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF8F9098),
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                HxButton(
                  width: 220,
                  height: 44,
                  color: Theme.of(context).primaryColor,
                  fontColor: Colors.white,
                  text: 'Go to link UPI',
                  type: HxButtonType.medium,
                  onButtonPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (_) => const LayoutPage(initialIndex: 2),
                      ),
                      (route) => false,
                    );
                  },
                ),
              ],
            )
          : ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              physics: const BouncingScrollPhysics(),
              itemCount: options.length,
              separatorBuilder: (context, index) => divider,
              itemBuilder: (context, index) {
                final item = options[index];
                final provider = UpiProviderType.fromCtType(item.ctType);
                final maskedAccount = maskMiddle(
                  item.account,
                  prefix: 3,
                  suffix: 4,
                  mask: '****',
                  preserveAfterAt: false,
                );
                return HxInkWellButton(
                  onButtonPressed: () => Navigator.of(context).pop(item),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        provider.iconAsset,
                        width: 28,
                        height: 28,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${provider.label}($maskedAccount)',
                              style: titleStyle,
                            ),
                            Row(
                              children: [
                                Text(item.pnname, style: subtitleStyle),
                                const SizedBox(width: 4),
                                Text(
                                  maskMiddle(item.upi),
                                  style: subtitleStyle,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: Colors.grey),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

class _LcrBlock extends StatelessWidget {
  final String title;
  final String bottom;
  final Color color;

  const _LcrBlock({
    required this.title,
    required this.bottom,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 60),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF8F9098),
              fontWeight: FontWeight.w500,
              height: 1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            bottom,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: color,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _Sign extends StatelessWidget {
  final String text;
  const _Sign({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: Color(0xFF1F2024),
      ),
    );
  }
}
