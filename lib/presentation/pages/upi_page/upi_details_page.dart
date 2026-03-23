import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kumar_pay/core/utils/base.dart';
import 'package:kumar_pay/presentation/widgets/nav_app_bar.dart';
import 'package:kumar_pay/presentation/widgets/common_widgets.dart';
import 'package:kumar_pay/presentation/widgets/customer_service.dart';
import 'package:kumar_pay/presentation/viewmodels/upi_viewmodel/upi_details_viewmodel.dart';
import 'package:kumar_pay/core/utils/enum.dart';

class UpiDetailsPage extends ConsumerWidget {
  final String upiName;
  final UpiProviderType provider;

  const UpiDetailsPage({
    super.key,
    required this.upiName,
    required this.provider,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(upiDetailsViewModelProvider(upiName));
    final vm = ref.read(upiDetailsViewModelProvider(upiName).notifier);

    return CustomerServiceRouteScope(
      pageId: 'upi_details',
      child: Stack(
        children: [
          Scaffold(
            appBar: NavAppBar(title: provider.label),
            body: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: const BoxDecoration(color: Color(0xFFE8E9F1)),
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  color: Colors.white,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (state.error != null && state.error!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Text(
                            state.error!,
                            style: const TextStyle(
                              color: Color(0xFFFF2E2E),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 0,
                          vertical: 14,
                        ),
                        child: Row(
                          children: [
                            Image.asset(
                              provider.iconAsset,
                              width: 28,
                              height: 28,
                              fit: BoxFit.contain,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                provider.label,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1F2024),
                                ),
                              ),
                            ),
                            Text(
                              maskMiddle(state.upiId),
                              style: const TextStyle(
                                color: Color(0xFFFFA300),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(color: Color(0xFFD3D5DD), height: 0.5),
                      _OrdersSection(vm: vm, state: state),
                      const Divider(color: Color(0xFFD3D5DD), height: 0.5),
                      _ListRow(
                        title: 'Allocation Quota',
                        trailing: Text(state.allocationQuota),
                      ),
                      const Divider(color: Color(0xFFD3D5DD), height: 0.5),
                      _ListRow(
                        title: 'Min Single Transaction',
                        trailing: Text('Min Single Transaction'),
                      ),
                      const Divider(color: Color(0xFFD3D5DD), height: 0.5),
                      _ListRow(
                        title: 'In Sell',
                        trailing: state.inSellOk
                            ? const _GreenStatusIcon()
                            : const _RedStatusIcon(),
                      ),
                      const Divider(color: Color(0xFFD3D5DD), height: 0.5),
                      _ListRow(
                        title: 'Lock Time',
                        trailing: state.lockTimeOk
                            ? const _GreenStatusIcon()
                            : const _RedStatusIcon(),
                      ),
                      const Divider(color: Color(0xFFD3D5DD), height: 0.5),
                      _ListRow(
                        title: 'Online',
                        inlineNote: state.onlineWarning,
                        trailing: state.onlineOk
                            ? const _GreenStatusIcon()
                            : const _RedStatusIcon(),
                      ),
                    ],
                  ),
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
}

class _ListRow extends StatelessWidget {
  const _ListRow({
    required this.title,
    required this.trailing,
    this.inlineNote,
  });

  final String title;
  final Widget trailing;
  final String? inlineNote;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: ListTile(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 3),
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF1F2024),
                fontWeight: FontWeight.w500,
              ),
            ),
            if (inlineNote != null) ...[
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  inlineNote!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFFFF2E2E),
                    fontWeight: FontWeight.w500,
                    height: 1,
                  ),
                ),
              ),
            ],
          ],
        ),
        trailing: trailing,
      ),
    );
  }
}

class _RedStatusIcon extends StatelessWidget {
  const _RedStatusIcon();

  @override
  Widget build(BuildContext context) {
    return const CircleAvatar(
      radius: 10,
      backgroundColor: Color(0xFFFF2E2E),
      child: Icon(
        Icons.close,
        color: Colors.white,
        fontWeight: FontWeight.w700,
        size: 16,
      ),
    );
  }
}

class _GreenStatusIcon extends StatelessWidget {
  const _GreenStatusIcon();

  @override
  Widget build(BuildContext context) {
    return const CircleAvatar(
      radius: 10,
      backgroundColor: Color(0xFF07C160),
      child: Icon(
        Icons.check,
        color: Colors.white,
        fontWeight: FontWeight.w700,
        size: 16,
      ),
    );
  }
}

class _OrdersSection extends ConsumerWidget {
  final UpiDetailsViewModel vm;
  final UpiDetailsState state;
  const _OrdersSection({required this.vm, required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        initiallyExpanded: state.ordersExpanded,
        onExpansionChanged: (v) => vm.toggleOrdersExpanded(v),
        tilePadding: const EdgeInsets.symmetric(horizontal: 0),
        childrenPadding: const EdgeInsets.only(bottom: 12),
        title: const Text(
          'Last 10 trading orders',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF1F2024),
            fontWeight: FontWeight.w500,
          ),
        ),
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 0),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F2F6),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Column(
              children: [
                // 表头
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE6E8EE),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(6),
                      topRight: Radius.circular(6),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Expanded(
                        flex: 6,
                        child: Text(
                          'Order No',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF1F2024),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 4,
                        child: Text(
                          'Order State',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF1F2024),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 4,
                        child: Text(
                          'Deal Date',
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF1F2024),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // 数据行
                for (final o in state.orders) _OrderRow(order: o),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderRow extends StatelessWidget {
  const _OrderRow({required this.order});
  final UpiOrderRecord order;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFE0E3EA), width: 0.5)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 6,
            child: Text(
              order.orderNo,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF1F2024),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: _StatusDotLabel(
              color: order.stateColor,
              text: order.stateText,
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(
              order.dealDate,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF1F2024),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusDotLabel extends StatelessWidget {
  const _StatusDotLabel({required this.color, required this.text});
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 3),
        Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF1F2024),
            fontWeight: FontWeight.w500,
            height: 1,
          ),
        ),
      ],
    );
  }
}
