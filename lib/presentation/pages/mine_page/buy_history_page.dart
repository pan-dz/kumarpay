import 'package:flutter/material.dart';
import 'package:kumar_pay/app/toast/app_toast.dart';
import 'package:kumar_pay/core/utils/base.dart';
import 'package:kumar_pay/core/utils/enum.dart';
import 'package:kumar_pay/presentation/widgets/hx_inkwell_button.dart';
import 'package:kumar_pay/presentation/widgets/popup_dialog.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kumar_pay/presentation/pages/layout_page.dart';
import 'package:kumar_pay/presentation/widgets/nav_app_bar.dart';
import 'package:kumar_pay/presentation/widgets/refresh_load_list_view.dart';
import 'package:kumar_pay/presentation/viewmodels/mine_viewmodel/buy_history_viewmodel.dart';
import 'package:kumar_pay/presentation/widgets/customer_service.dart';
import 'package:kumar_pay/presentation/widgets/hx_button.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:kumar_pay/store/models/buy/buy_res_model.dart';
import 'package:kumar_pay/presentation/pages/upi_page/freecharge_page.dart';

class BuyHistoryPage extends ConsumerStatefulWidget {
  const BuyHistoryPage({super.key});

  @override
  ConsumerState<BuyHistoryPage> createState() => _BuyHistoryPageState();
}

class _BuyHistoryPageState extends ConsumerState<BuyHistoryPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(buyHistoryViewModelProvider.notifier).resetTabIndex();
      final state = ref.read(buyHistoryViewModelProvider);
      final vm = ref.read(buyHistoryViewModelProvider.notifier);
      final tab = BuyHistoryTab.values[state.tabIndex];
      vm.refresh(tab);
    });
  }

  @override
  void deactivate() {
    ref.read(buyHistoryViewModelProvider.notifier).stopUsdtPolling();
    super.deactivate();
  }

  @override
  void dispose() {
    ref.read(buyHistoryViewModelProvider.notifier).stopUsdtPolling();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(buyHistoryViewModelProvider);
    final vm = ref.read(buyHistoryViewModelProvider.notifier);
    return CustomerServiceRouteScope(
      pageId: 'buy_history',
      child: Stack(
        children: [
          DefaultTabController(
            key: ValueKey(state.tabIndex),
            initialIndex: state.tabIndex,
            length: 3,
            child: Scaffold(
              appBar: const NavAppBar(title: 'Buy History'),
              body: Container(
                width: double.infinity,
                height: double.infinity,
                decoration: const BoxDecoration(color: Color(0xFFE8E9F1)),
                child: Column(
                  children: [
                    _TopTabs(onChanged: vm.onTabChange),
                    const SizedBox(height: 8),
                    Expanded(
                      child: TabBarView(
                        children: [
                          const _HistoryTab(tab: BuyHistoryTab.inr),
                          _HistoryTab(
                            tab: BuyHistoryTab.inrCancel,
                            emptyConfig: EmptyStateConfig(
                              title:
                                  'No UPI partners have been linked yet\nPlease Link your UPI to proceed',
                              subtitle: '',
                              showButton: true,
                              buttonText: 'To buy',
                              onButtonPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const LayoutPage(initialIndex: 1),
                                  ),
                                );
                              },
                            ),
                          ),
                          const _HistoryTab(tab: BuyHistoryTab.usdt),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopTabs extends StatelessWidget {
  final ValueChanged<int>? onChanged;
  const _TopTabs({this.onChanged});
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: TabBar(
        onTap: onChanged,
        labelColor: const Color(0xFF1F2024),
        unselectedLabelColor: const Color(0xFF8E9199),
        labelStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        unselectedLabelStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        indicatorColor: const Color(0xFF1F2024),
        indicatorSize: TabBarIndicatorSize.label,
        tabs: const [
          Tab(text: 'INR'),
          Tab(text: 'INR(Cancel)'),
          Tab(text: 'USDT'),
        ],
      ),
    );
  }
}

class _HistoryTab extends ConsumerWidget {
  final BuyHistoryTab tab;
  final EmptyStateConfig? emptyConfig;
  const _HistoryTab({required this.tab, this.emptyConfig});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(buyHistoryViewModelProvider);
    final vm = ref.read(buyHistoryViewModelProvider.notifier);
    final data = state.dataOf(tab);

    return RefreshLoadListView<BuyHistoryItem>(
      items: data.items,
      onRefresh: () => vm.refresh(tab),
      onLoadMore: () => vm.loadMore(tab),
      isLoading: data.loading,
      noMore: data.noMore,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      emptyConfig: emptyConfig,
      itemBuilder: (context, item, index) => _OrderCard(
        item: item,
        tab: tab,
        onConfirmPaid: () =>
            vm.confirmPaid(context, orderId: item.rptNo, process: 'finish'),
        onCancel: () => {},
        onCancelPaid: () =>
            _showCancelReasonDialog(context, vm, item: item, tab: tab),
        onGoToPay: () =>
            vm.launchWalletDomain(context, walletDomain: item.walletDomain),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final BuyHistoryItem item;
  final BuyHistoryTab tab;
  final Future<void> Function() onConfirmPaid;
  final VoidCallback onCancel;
  final VoidCallback onCancelPaid;
  final VoidCallback onGoToPay;
  const _OrderCard({
    required this.item,
    required this.tab,
    required this.onConfirmPaid,
    required this.onCancel,
    required this.onCancelPaid,
    required this.onGoToPay,
  });

  double get _reward => (item.reward ?? 0).toDouble();
  double get _amount => item.amount.toDouble();
  double get _tokenAmount => tab == BuyHistoryTab.usdt
      ? (item.itoken ?? 0).toDouble()
      : _amount + _reward;
  String get _timeString => _formatTs(item.uptDate ?? item.crtDate);

  OrderStatus get _status => _mapStatus(item.orderState);

  Color get _dotColor => switch (_status) {
    OrderStatus.paying => const Color(0xFFFFA629),
    OrderStatus.success => const Color(0xFF21C069),
    OrderStatus.init => const Color(0xFF8E9199),
    OrderStatus.pending => const Color(0xFFFFA629),
    OrderStatus.close => const Color(0xFFDC3545),
    OrderStatus.fail => const Color(0xFFDC3545),
  };

  String get _statusText => switch (_status) {
    OrderStatus.init => 'Init',
    OrderStatus.pending => 'Pending',
    OrderStatus.paying => 'Paying',
    OrderStatus.success => 'Success',
    OrderStatus.close => 'Cancel',
    OrderStatus.fail => 'Fail',
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(right: 4),
                  decoration: BoxDecoration(
                    color: _dotColor,
                    shape: BoxShape.circle,
                  ),
                ),
                Text(
                  _statusText,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF1F2024),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),

                HxInkWellButton(
                  onButtonPressed: () => PopupDialog.show(
                    context: context,
                    config: PopupDialogConfig(
                      position: DialogPosition.center,
                      title: item.rptNo,
                      showCloseButton: false,
                      showFooterButtons: true,
                      showDoubleButtons: false,
                      primaryButtonText: 'Cancel',
                      closeOnConfirm: true,
                      minHeight: tab != BuyHistoryTab.usdt ? 400 : 140,
                    ),
                    child: _OrderDetails(item: item, tab: tab),
                  ),
                  child: Row(
                    children: const [
                      Text(
                        'Detail',
                        style: TextStyle(
                          color: Color(0xFF1F2024),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(
                        Icons.visibility,
                        color: Color(0xFF1F2024),
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(
            color: Color(0xFFD3D5DD),
            height: 0.5,
            indent: 8,
            endIndent: 8,
          ),

          InkWell(
            onTap: item.orderState == 1 || item.orderState == 2
                ? () {
                    if (item.payType == 3) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => FreechargePage(
                            id: item.rptNo,
                            ctime: item.crtDate,
                            upiName: item.payAccount,
                            ctType: item.payType,
                            walletAddress: item.ctAccount,
                            entrySource: FreechargeEntrySource.buyHistory,
                          ),
                        ),
                      );
                      return;
                    }

                    _showPaymentNotice(
                      context,
                      item.walletDomain,
                      onConfirmPaid,
                      onCancelPaid,
                      onGoToPay,
                    );
                  }
                : () => {},
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 16, 12, 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'IToken:',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF1F2024),
                          fontWeight: FontWeight.w500,
                          height: 1,
                        ),
                      ),

                      Text(
                        _tokenAmount.toStringAsFixed(2),
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF1F2024),
                          fontWeight: FontWeight.w700,
                          height: 1,
                        ),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 6, 12, 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Buy:',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF1F2024),
                          fontWeight: FontWeight.w500,
                          height: 1,
                        ),
                      ),

                      Text(
                        tab == BuyHistoryTab.usdt
                            ? '${item.amount} USDT'
                            : '₹ ${_amount.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF1F2024),
                          fontWeight: FontWeight.w700,
                          height: 1,
                        ),
                      ),
                    ],
                  ),
                ),

                Container(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF8F9FE),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(8),
                      bottomRight: Radius.circular(8),
                    ),
                  ),
                  child: Column(
                    children: [
                      _InfoRow(
                        label: 'Reward:',
                        value: _reward.toStringAsFixed(2),
                      ),
                      _InfoRow(label: 'OrderNo:', value: item.rptNo),
                      _InfoRow(label: 'Time:', value: _timeString),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderDetails extends StatelessWidget {
  final BuyHistoryItem item;
  final BuyHistoryTab tab;

  const _OrderDetails({required this.item, required this.tab});

  String get kycPartner => UpiProviderType.fromCtType(item.payType).label;
  String get _statusText => switch (_mapStatus(item.orderState)) {
    OrderStatus.init => 'Init',
    OrderStatus.pending => 'Pending',
    OrderStatus.paying => 'Paying',
    OrderStatus.success => 'Success',
    OrderStatus.close => 'Close',
    OrderStatus.fail => 'Fail',
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (tab != BuyHistoryTab.usdt) ...[
          _InfoRow(
            label: 'UPI ID',
            value: maskMiddle(item.payAccount),
            labelWidth: 100,
          ),
          const SizedBox(height: 6),
          _InfoRow(label: 'kyc Partner', value: kycPartner, labelWidth: 100),
          const SizedBox(height: 6),
          _InfoRow(label: 'IFSC', value: item.acctCode, labelWidth: 100),
          const SizedBox(height: 6),
          _InfoRow(label: 'Name', value: item.acctName, labelWidth: 100),
          const SizedBox(height: 6),
          _InfoRow(label: 'account', value: item.acctNo, labelWidth: 100),
          const SizedBox(height: 6),
        ],
        _InfoRow(
          label: 'Debit time',
          value: _formatTs(item.crtDate),
          labelWidth: 100,
        ),
        const SizedBox(height: 6),

        _InfoRow(
          label: 'Deal time',
          value: _formatTs(item.uptDate ?? 0),
          labelWidth: 100,
        ),
        const SizedBox(height: 6),

        _InfoRow(label: 'Utr', value: item.utr, labelWidth: 100),
        const SizedBox(height: 6),

        _InfoRow(label: 'Order status', value: _statusText, labelWidth: 100),
        const SizedBox(height: 6),

        if (tab != BuyHistoryTab.usdt) ...[
          _InfoRow(
            label: 'Finish time',
            value: _formatTs(item.fnsDate),
            labelWidth: 100,
          ),
        ],
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final double? labelWidth;
  const _InfoRow({required this.label, required this.value, this.labelWidth});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: labelWidth ?? 70,
          child: Text(
            label,
            style: const TextStyle(fontSize: 14, color: Color(0xFF8F9098)),
          ),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(fontSize: 14, color: Color(0xFF1F2024)),
          ),
        ),
      ],
    );
  }
}

OrderStatus _mapStatus(int orderState) {
  return switch (orderState) {
    0 => OrderStatus.init,
    1 => OrderStatus.paying,
    2 => OrderStatus.pending,
    3 => OrderStatus.success,
    4 => OrderStatus.close,
    5 => OrderStatus.fail,
    _ => OrderStatus.paying,
  };
}

String _formatTs(int ts) {
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

Future<void> _showPaymentNotice(
  BuildContext context,
  String walletDomain,
  Future<void> Function() onConfirmPaid,
  VoidCallback onCancelPaid,
  VoidCallback onGoToPay,
) {
  return PopupDialog.show(
    context: context,
    config: PopupDialogConfig(
      position: DialogPosition.center,
      title: 'Payment Notice',
      showCloseButton: true,
      showFooterButtons: false,
      showDoubleButtons: false,
      primaryButtonText: 'Go Pay',
      secondaryButtonText: 'Cancel',
      minHeight: 400,
    ),
    onConfirm: () async {
      if (walletDomain.trim().isEmpty) return;
      final uri = Uri.tryParse(walletDomain);
      if (uri == null) {
        AppToast.show(
          context,
          message: 'Invalid wallet link',
          type: AppToastType.error,
        );
        return;
      }
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    },
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 170,
          child: const Text(
            'Warning: If your payment was successful, please do not pay again. If not, click "Go Pay" below to complete the payment.\nTips: Please make sure Mobikwik is installed before clicking "Go Pay".',
            style: TextStyle(
              color: Color(0xFFFF2E2E),
              fontSize: 16,
              fontWeight: FontWeight.w500,
              height: 1.35,
            ),
          ),
        ),
        const SizedBox(height: 16),
        HxButton(
          color: const Color(0xFF2F7CF0),
          fontColor: Colors.white,
          text: 'I confirm I have paid',
          onButtonPressed: () async {
            await onConfirmPaid();
          },
        ),
        const SizedBox(height: 32),

        Row(
          children: [
            Expanded(
              child: HxButton(
                outlined: true,
                color: Color(0xFF1F2024),
                fontColor: Color(0xFF1F2024),
                text: 'Cancel',
                onButtonPressed: onCancelPaid,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: HxButton(
                color: Theme.of(context).primaryColor,
                fontColor: Colors.white,
                text: 'Go Pay',
                onButtonPressed: onGoToPay,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

Future<void> _showCancelReasonDialog(
  BuildContext context,
  BuyHistoryViewModel vm, {
  required BuyHistoryItem item,
  required BuyHistoryTab tab,
}) async {
  final rootContext = Navigator.of(context, rootNavigator: true).context;
  final reasons = [
    'Incorrect bank account information',
    "Don't want to buy",
    'Payment Fail',
    'Other',
  ];
  String? selectedReason;
  String otherReason = '';
  final controller = TextEditingController();

  await PopupDialog.show(
    context: rootContext,
    config: PopupDialogConfig(
      position: DialogPosition.center,
      title: 'why cancel',
      showCloseButton: true,
      showFooterButtons: true,
      showDoubleButtons: false,
      primaryButtonText: 'Confirm',
      minHeight: 520,
    ),
    onConfirm: () async {
      final reason = selectedReason == 'Other'
          ? otherReason.trim()
          : (selectedReason ?? '');
      if (reason.isEmpty) {
        AppToast.show(
          context,
          message: 'Please select a reason',
          type: AppToastType.warning,
        );
        return;
      }

      final ok = await vm.cancelOrder(
        context,
        orderId: item.rptNo,
        // orderId: item.orderNo,
        process: 'Cancel',
        cancelRemark: reason,
        tab: tab,
      );
      if (ok) {
        final rootNavigator = Navigator.of(context, rootNavigator: true);
        if (rootNavigator.canPop()) {
          rootNavigator.pop();
        }
        if (rootNavigator.canPop()) {
          rootNavigator.pop();
        }
      }
    },
    child: StatefulBuilder(
      builder: (context, setState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 360,
              child: Column(
                children: [
                  const Text(
                    'Warning: If you click Cancel after payment is completed, you will lose the purchased tokens!',
                    style: TextStyle(
                      color: Color(0xFFFF2E2E),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),

                  ...reasons.map(
                    (r) => Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: Material(
                        color: selectedReason == r
                            ? const Color(0xFFEFF4FF)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(6),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(6),
                          onTap: () {
                            setState(() {
                              selectedReason = r;
                            });
                          },
                          child: Ink(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: selectedReason == r
                                    ? const Color(0xFF2F7CF0)
                                    : const Color(0xFFD3D5DD),
                                width: 0.5,
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 12,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  selectedReason == r
                                      ? Icons.radio_button_checked
                                      : Icons.radio_button_off,
                                  color: selectedReason == r
                                      ? const Color(0xFF2F7CF0)
                                      : const Color(0xFF8F9098),
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    r,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: selectedReason == r
                                          ? const Color(0xFF2F7CF0)
                                          : const Color(0xFF1F2024),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (selectedReason == 'Other')
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: TextField(
                        controller: controller,
                        maxLength: 100,
                        minLines: 4,
                        maxLines: 8,
                        onChanged: (v) => otherReason = v,
                        decoration: const InputDecoration(
                          hintText: 'Please enter a reason',
                          counterText: '',
                          filled: true,
                          fillColor: Color(0xFFF5F6FA),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 10,
                          ),

                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(6)),
                            borderSide: BorderSide(
                              color: Color(0xFFD3D5DD),
                              width: 0.5,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(6)),
                            borderSide: BorderSide(
                              color: Color(0xFFD3D5DD),
                              width: 0.5,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(6)),
                            borderSide: BorderSide(
                              color: Color(0xFF2F7CF0),
                              width: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    ),
  );

  controller.dispose();
}
