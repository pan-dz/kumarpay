import 'dart:async';
import 'package:flutter/material.dart';
import 'package:kumar_pay/presentation/pages/home_page/sell_set_page.dart';
import 'package:kumar_pay/presentation/viewmodels/mine_viewmodel/sell_history_viewmodel.dart';
import 'package:kumar_pay/presentation/widgets/hx_inkwell_button.dart';
import 'package:kumar_pay/presentation/widgets/popup_dialog.dart';
import 'package:kumar_pay/presentation/widgets/refresh_load_list_view.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kumar_pay/presentation/widgets/customer_service.dart';
import 'package:kumar_pay/presentation/widgets/nav_app_bar.dart';
import 'package:kumar_pay/store/models/mine/sell_history_res_model.dart';
import 'package:kumar_pay/core/utils/enum.dart';
import 'package:kumar_pay/core/utils/base.dart';

class SellHistoryPage extends ConsumerStatefulWidget {
  const SellHistoryPage({super.key});

  @override
  ConsumerState<SellHistoryPage> createState() => _SellHistoryPageState();
}

class _SellHistoryPageState extends ConsumerState<SellHistoryPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(sellHistoryViewModelProvider.notifier).resetTabIndex();
      final state = ref.read(sellHistoryViewModelProvider);
      final vm = ref.read(sellHistoryViewModelProvider.notifier);
      final tab = SellHistoryTab.values[state.tabIndex];
      vm.refresh(tab);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(sellHistoryViewModelProvider);
    final vm = ref.read(sellHistoryViewModelProvider.notifier);
    return CustomerServiceRouteScope(
      pageId: 'sell_history',
      child: Stack(
        children: [
          DefaultTabController(
            key: ValueKey(state.tabIndex),
            initialIndex: state.tabIndex,
            length: 3,
            child: Scaffold(
              appBar: const NavAppBar(title: 'Sell History'),
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
                          const _HistoryTab(tab: SellHistoryTab.paying),
                          const _HistoryTab(tab: SellHistoryTab.success),
                          const _HistoryTab(tab: SellHistoryTab.all),
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
          Tab(text: 'Paying'),
          Tab(text: 'Success'),
          Tab(text: 'All'),
        ],
      ),
    );
  }
}

class _HistoryTab extends ConsumerWidget {
  final SellHistoryTab tab;
  const _HistoryTab({required this.tab});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(sellHistoryViewModelProvider);
    final vm = ref.read(sellHistoryViewModelProvider.notifier);
    final data = state.dataOf(tab);

    return RefreshLoadListView<SellHistoryItem>(
      items: data.items,
      onRefresh: () => vm.refresh(tab),
      onLoadMore: () => vm.loadMore(tab),
      isLoading: data.loading,
      noMore: data.noMore,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      emptyConfig: EmptyStateConfig(
        title:
            'There are no sales orders at the moment. If you have enabled consignment, please check the authorization of the key partner and whether the kyc partner can receive payment normally or contact customer service in time.',
        subtitle: '',
        showButton: true,
        buttonText: 'Check Sell state',
        onButtonPressed: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const SellSetPage()));
        },
      ),
      itemBuilder: (context, item, index) =>
          _OrderCard(item: item, onCountdownFinished: () => vm.refresh(tab)),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final SellHistoryItem item;
  final VoidCallback? onCountdownFinished;
  const _OrderCard({required this.item, this.onCountdownFinished});

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
    OrderStatus.close => 'Close',
    OrderStatus.fail => 'Pay Failed',
  };

  String get _timeString => _formatTs(item.uptDate!);

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
                if (_status == OrderStatus.paying && item.secLimit > 0)
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: _CountdownText(
                      seconds: item.secLimit,
                      onFinished: onCountdownFinished,
                    ),
                  ),
                const Spacer(),
                HxInkWellButton(
                  onButtonPressed: () {
                    _showOrderDetailDialog(context, item);
                  },
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

          Column(
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
                      'Selling price:',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF1F2024),
                        fontWeight: FontWeight.w500,
                        height: 1,
                      ),
                    ),

                    Text(
                      '₹ ${item.realAmount.toStringAsFixed(2)}',
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
                      'Quantity:',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF1F2024),
                        fontWeight: FontWeight.w500,
                        height: 1,
                      ),
                    ),

                    Text(
                      '${item.realAmount.toStringAsFixed(0)} IToken',
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
                    _InfoRow(label: 'RptNo:', value: item.rptNo),
                    const SizedBox(height: 4),
                    _InfoRow(label: 'Deal Date:', value: _timeString),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

void _showOrderDetailDialog(BuildContext context, SellHistoryItem item) {
  final rawUpiId = item.receiveAccount.isNotEmpty
      ? item.receiveAccount
      : (item.payAccount.isNotEmpty ? item.payAccount : '-');
  final upiId = maskMiddle(rawUpiId);
  final kycPartner = UpiProviderType.fromCtType(item.ctType).label;
  final debitTime = _formatTs(item.crtDate);
  final dealTime = _formatTs(item.uptDate ?? 0);
  final finishTime = _formatTs(item.fnsDate ?? 0);
  final orderStatus = switch (_mapStatus(item.orderState)) {
    OrderStatus.init => 'Init',
    OrderStatus.pending => 'Pending',
    OrderStatus.paying => 'Paying',
    OrderStatus.success => 'Success',
    OrderStatus.close => 'Close',
    OrderStatus.fail => 'Pay Failed',
  };

  PopupDialog.show(
    context: context,
    config: PopupDialogConfig(
      position: DialogPosition.center,
      title: item.rptNo,
      showCloseButton: false,
      showFooterButtons: true,
      showDoubleButtons: false,
      primaryButtonText: 'Close',
      minHeight: 0,
      contentPadding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _DetailRow(label: 'UPI ID', value: upiId),
        _DetailRow(label: 'Kyc Partner', value: kycPartner),
        _DetailRow(label: 'Debit time', value: debitTime),
        _DetailRow(label: 'Deal time', value: dealTime),
        _DetailRow(label: 'Utr', value: item.utr.isNotEmpty ? item.utr : '-'),
        _DetailRow(label: 'Order status', value: orderStatus),
        _DetailRow(label: 'Finish time', value: finishTime),
      ],
    ),
  );
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF8F9098),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF1F2024),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CountdownText extends StatefulWidget {
  final int seconds;
  final VoidCallback? onFinished;
  const _CountdownText({required this.seconds, this.onFinished});

  @override
  State<_CountdownText> createState() => _CountdownTextState();
}

class _CountdownTextState extends State<_CountdownText> {
  late int _seconds;
  Timer? _timer;
  bool _finishedNotified = false;

  @override
  void initState() {
    super.initState();
    _seconds = widget.seconds;
    _startTimer();
  }

  @override
  void didUpdateWidget(covariant _CountdownText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.seconds != widget.seconds) {
      _seconds = widget.seconds;
      _startTimer();
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _finishedNotified = false;
    if (_seconds <= 0) return;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_seconds <= 1) {
        setState(() => _seconds = 0);
        t.cancel();
        if (!_finishedNotified) {
          _finishedNotified = true;
          widget.onFinished?.call();
        }
      } else {
        setState(() => _seconds -= 1);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_seconds <= 0) return const SizedBox.shrink();
    return Text(
      _formatCountdown(_seconds),
      style: const TextStyle(
        fontSize: 14,
        color: Color(0xFFDC3545),
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 120,
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

String _formatCountdown(int seconds) {
  if (seconds <= 0) return '00:00';
  final m = (seconds ~/ 60).toString().padLeft(2, '0');
  final s = (seconds % 60).toString().padLeft(2, '0');
  return '$m:$s';
}
