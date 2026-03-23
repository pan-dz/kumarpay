import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kumar_pay/presentation/viewmodels/mine_viewmodel/transfer_history_viewmodel.dart';
import 'package:kumar_pay/presentation/widgets/nav_app_bar.dart';
import 'package:kumar_pay/presentation/widgets/refresh_load_list_view.dart';

const _pageBgColor = Color(0xFFE8E9F1);
const _cardSubBgColor = Color(0xFFF8F9FE);
const _textPrimaryColor = Color(0xFF1F2024);
const _textSecondaryColor = Color(0xFF8F9098);

const _valueTextStyle = TextStyle(
  color: _textPrimaryColor,
  fontSize: 12,
  fontWeight: FontWeight.w500,
  height: 1.2,
);

class TransferHistoryPage extends ConsumerStatefulWidget {
  const TransferHistoryPage({super.key});

  @override
  ConsumerState<TransferHistoryPage> createState() =>
      _TransferHistoryPageState();
}

class _TransferHistoryPageState extends ConsumerState<TransferHistoryPage> {
  bool _requestedOnEnter = false;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(transferHistoryViewModelProvider);
    final vm = ref.read(transferHistoryViewModelProvider.notifier);

    if (!_requestedOnEnter) {
      _requestedOnEnter = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        vm.refresh();
      });
    }

    return DefaultTabController(
      length: 1,
      child: Scaffold(
        appBar: const NavAppBar(title: 'Transfer IToken History'),
        body: ColoredBox(
          color: _pageBgColor,
          child: Column(
            children: [
              _TopTabs(onChanged: (_) {}),
              Expanded(
                child: RefreshLoadListView<TransferHistoryItem>(
                  items: state.items,
                  onRefresh: vm.refresh,
                  onLoadMore: vm.loadMore,
                  isLoading: state.isLoading,
                  noMore: state.noMore,
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
                  emptyText: 'No data',
                  bottom: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Center(
                      child: Text(
                        state.noMore
                            ? 'no more data'
                            : (state.isLoading ? 'loading...' : ''),
                        style: const TextStyle(
                          color: Color(0xFF8E9199),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  itemBuilder: (context, item, index) =>
                      _TransferCard(item: item),
                ),
              ),
            ],
          ),
        ),
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
        tabs: const [Tab(text: 'Transfer In')],
      ),
    );
  }
}

class _TransferCard extends StatelessWidget {
  final TransferHistoryItem item;

  const _TransferCard({required this.item});

  String _statusText(int orderState) {
    switch (orderState) {
      case 1:
        return 'Pending';
      case 2:
        return 'Processing';
      case 3:
        return 'Success';
      case 4:
        return 'Failed';
      default:
        return 'Unknown';
    }
  }

  DateTime _dateFromTimestamp(int timestamp) {
    if (timestamp <= 0) return DateTime.fromMillisecondsSinceEpoch(0);
    final isSecond = timestamp < 1000000000000;
    return DateTime.fromMillisecondsSinceEpoch(
      isSecond ? timestamp * 1000 : timestamp,
    );
  }

  String _formatDateTime(DateTime dt) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${dt.year}-${two(dt.month)}-${two(dt.day)} '
        '${two(dt.hour)}:${two(dt.minute)}:${two(dt.second)}';
  }

  Widget _row({
    required String label,
    required Widget value,
    bool compactTop = false,
    bool emphasizeLabel = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(top: compactTop ? 4 : 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 64,
            child: Text(
              label,
              style: TextStyle(
                color: emphasizeLabel ? _textPrimaryColor : _textSecondaryColor,
                fontSize: 12,
                fontWeight: emphasizeLabel ? FontWeight.w600 : FontWeight.w500,
                height: 1.2,
              ),
            ),
          ),
          Expanded(
            child: Align(alignment: Alignment.centerRight, child: value),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      margin: const EdgeInsets.only(right: 5),
                      decoration: const BoxDecoration(
                        color: Color(0xFF21C069),
                        shape: BoxShape.circle,
                      ),
                    ),
                    Text(
                      _statusText(item.orderState),
                      style: const TextStyle(
                        color: _textPrimaryColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Divider(height: 0.5, color: Color(0xFFD3D5DD)),
                const SizedBox(height: 8),
                _row(
                  label: 'Token:',
                  value: Text(
                    '${item.transferType == 1 ? '-' : '+'}${item.itoken.toStringAsFixed(2)}',
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      color: Color(0xFF07C160),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      height: 1,
                    ),
                  ),
                  compactTop: true,
                  emphasizeLabel: true,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.only(
              top: 4,
              left: 10,
              right: 10,
              bottom: 10,
            ),
            decoration: const BoxDecoration(
              color: _cardSubBgColor,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
            ),
            child: Column(
              children: [
                _row(
                  label: 'seq no:',
                  value: Text(
                    item.id.toString(),
                    textAlign: TextAlign.right,
                    style: _valueTextStyle,
                  ),
                  compactTop: true,
                ),
                _row(
                  label: 'time:',
                  value: Text(
                    _formatDateTime(_dateFromTimestamp(item.crtDate)),
                    textAlign: TextAlign.right,
                    style: _valueTextStyle,
                  ),
                  compactTop: true,
                ),
                _row(
                  label: 'Note:',
                  value: Text(
                    item.showNote,
                    textAlign: TextAlign.right,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: _valueTextStyle.copyWith(height: 1.25),
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
