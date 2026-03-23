import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kumar_pay/presentation/viewmodels/active_viewmodel/team/my_team_viewmodel.dart';
import 'package:kumar_pay/presentation/widgets/nav_app_bar.dart';
import 'package:kumar_pay/presentation/widgets/refresh_load_list_view.dart';
import 'package:kumar_pay/store/models/active/active_res_model.dart';

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

class MyTeamPage extends ConsumerStatefulWidget {
  const MyTeamPage({super.key});

  @override
  ConsumerState<MyTeamPage> createState() => _MyTeamPageState();
}

class _MyTeamPageState extends ConsumerState<MyTeamPage> {
  bool _requestedOnEnter = false;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(myTeamViewModelProvider);
    final vm = ref.read(myTeamViewModelProvider.notifier);

    if (!_requestedOnEnter) {
      _requestedOnEnter = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        vm.refresh();
      });
    }

    return Scaffold(
      appBar: const NavAppBar(title: 'My Team'),
      body: ColoredBox(
        color: _pageBgColor,
        child: RefreshLoadListView<MyTeamItemModel>(
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
                style: const TextStyle(color: Color(0xFF8E9199), fontSize: 12),
              ),
            ),
          ),
          itemBuilder: (context, item, index) => _MyTeamCard(item: item),
        ),
      ),
    );
  }
}

class _MyTeamCard extends StatelessWidget {
  final MyTeamItemModel item;

  const _MyTeamCard({required this.item});

  String _formatDateTime(DateTime dt) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${dt.year}-${two(dt.month)}-${two(dt.day)} '
        '${two(dt.hour)}:${two(dt.minute)}:${two(dt.second)}';
  }

  String _formatServerTime(String value) {
    final raw = value.trim();
    if (raw.isEmpty) return '-';

    final timestamp = int.tryParse(raw);
    if (timestamp != null) {
      if (timestamp <= 0) return '-';
      final isSeconds = timestamp < 1000000000000;
      final dt = DateTime.fromMillisecondsSinceEpoch(
        isSeconds ? timestamp * 1000 : timestamp,
      );
      return _formatDateTime(dt);
    }

    final parsed = DateTime.tryParse(raw);
    if (parsed != null) {
      return _formatDateTime(parsed);
    }

    return raw;
  }

  Widget _row({
    required String label,
    required Widget value,
    bool compactTop = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(top: compactTop ? 4 : 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                color: _textSecondaryColor,
                fontSize: 12,
                fontWeight: FontWeight.w500,
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
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    item.username.isEmpty ? '-' : item.username,
                    style: const TextStyle(
                      color: _textPrimaryColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),

                const SizedBox(height: 4),
                _row(
                  label: 'Team size:',
                  value: Text(
                    item.teamCount.toString(),
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: _textPrimaryColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                    ),
                  ),
                  compactTop: true,
                ),
                const SizedBox(height: 4),
                _row(
                  label: 'Team performance:',
                  value: Text(
                    '₹${item.performance.toStringAsFixed(2)}',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: _textPrimaryColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                    ),
                  ),
                  compactTop: true,
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
                  label: 'Uid:',
                  value: Text(
                    item.teamWorkId.toString(),
                    textAlign: TextAlign.right,
                    style: _valueTextStyle,
                  ),
                  compactTop: true,
                ),
                _row(
                  label: 'Last Login:',
                  value: Text(
                    _formatServerTime(item.lgTime.toString()),
                    textAlign: TextAlign.right,
                    style: _valueTextStyle,
                  ),
                  compactTop: true,
                ),
                _row(
                  label: 'Dividend:',
                  value: Text(
                    item.dividend.toStringAsFixed(2),
                    textAlign: TextAlign.right,
                    style: _valueTextStyle,
                  ),
                  compactTop: true,
                ),
                _row(
                  label: 'Last Expire:',
                  value: Text(
                    _formatServerTime(item.lgExpiredTime.toString()),
                    textAlign: TextAlign.right,
                    style: _valueTextStyle,
                  ),
                  compactTop: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
