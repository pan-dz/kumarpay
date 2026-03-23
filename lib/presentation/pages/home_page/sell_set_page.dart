import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kumar_pay/presentation/pages/layout_page.dart';
import 'package:kumar_pay/presentation/pages/mine_page/customer_service.dart';
import 'package:kumar_pay/presentation/pages/mine_page/sell_history_page.dart';
import 'package:kumar_pay/presentation/viewmodels/home_viewmodel/sell_set_viewmodel.dart';
import 'package:kumar_pay/presentation/widgets/customer_service.dart';
import 'package:kumar_pay/presentation/widgets/hx_button.dart';
import 'package:kumar_pay/presentation/widgets/nav_app_bar.dart';

class SellSetPage extends ConsumerStatefulWidget {
  const SellSetPage({super.key});

  @override
  ConsumerState<SellSetPage> createState() => _SellSetPageState();
}

class _SellSetPageState extends ConsumerState<SellSetPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(sellSetViewModelProvider.notifier).refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(sellSetViewModelProvider);
    final vm = ref.read(sellSetViewModelProvider.notifier);

    return CustomerServiceRouteScope(
      pageId: 'sell_set',
      child: Stack(
        children: [
          Scaffold(
            appBar: const NavAppBar(title: 'Sell'),
            body: Container(
              width: double.infinity,
              height: double.infinity,
              color: const Color(0xFFE8E9F1),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _BalanceHeader(balance: state.itokenBalance),
                    const SizedBox(height: 12),
                    // _StatsSection(title: 'BUY', stats: state.buyStats),
                    // const SizedBox(height: 12),
                    _StatsSection(title: 'SELL', stats: state.sellStats),
                    const SizedBox(height: 12),
                    _MenuSection(
                      inSell: state.inSell,
                      activeUpiCount: state.activeUpiCount,
                      onToggle: vm.toggleInSell,
                    ),
                    const SizedBox(height: 16),
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

class _BalanceHeader extends StatelessWidget {
  final double balance;
  const _BalanceHeader({required this.balance});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: Text('🇮🇳', style: TextStyle(fontSize: 22)),
          ),
          const SizedBox(width: 4),
          const Text(
            'IToken',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2024),
            ),
          ),
          const Spacer(),
          Text(
            (balance <= 0 ? 0 : balance).toStringAsFixed(2),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1F2024),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsSection extends StatelessWidget {
  final String title;
  final TradeStats stats;
  const _StatsSection({required this.title, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1F2024),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  title: 'In transaction',
                  value: stats.inTransaction,
                  gradient: const LinearGradient(
                    begin: Alignment(0.00, 0.00),
                    end: Alignment(1.05, 1.08),
                    colors: [Color(0xFFFFBF00), Color(0xFFFFA502)],
                  ),
                  iconAsset: 'assets/images/home_sell_icon1.webp',
                  width: 68,
                  height: 50,
                  right: 0,
                  bottom: -5,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  title: 'Today Deal',
                  value: stats.todayDeal,
                  gradient: const LinearGradient(
                    begin: Alignment(0.26, 0.26),
                    end: Alignment(1.05, 1.08),
                    colors: [Color(0xFF8BAAFF), Color(0xFF5D98FF)],
                  ),
                  iconAsset: 'assets/images/home_sell_icon2.webp',
                  width: 60,
                  height: 45,

                  right: 0,
                  bottom: -5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  title: 'Today times',
                  value: stats.todayTimes,
                  gradient: const LinearGradient(
                    begin: Alignment(0.26, 0.26),
                    end: Alignment(1.05, 1.08),
                    colors: [Color(0xFF11CA5E), Color(0xFF09AC4D)],
                  ),
                  iconAsset: 'assets/images/home_sell_icon3.webp',
                  width: 60,
                  height: 56,

                  right: 0,
                  bottom: -6,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  title: 'Today Success',
                  value: stats.todaySuccess,
                  gradient: const LinearGradient(
                    begin: Alignment(0.26, 0.26),
                    end: Alignment(1.05, 1.08),
                    colors: [Color(0xFFFF8E00), Color(0xFFFF6E00)],
                  ),
                  iconAsset: 'assets/images/home_sell_icon4.webp',
                  width: 58,
                  height: 55,

                  right: 0,
                  bottom: -8,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final int value;
  final Gradient gradient;
  final String iconAsset;
  final double width;
  final double height;
  final double right;
  final double bottom;
  const _StatCard({
    required this.title,
    required this.value,
    required this.gradient,
    required this.iconAsset,
    required this.width,
    required this.height,
    required this.right,
    required this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Container(
        height: 52,
        // padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(gradient: gradient),
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            Positioned(
              right: right,
              bottom: bottom,
              child: Opacity(
                opacity: 1,
                child: Image.asset(iconAsset, width: 68, height: 50),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 0, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '$value',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      height: 1,
                    ),
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

class _MenuSection extends StatelessWidget {
  final bool inSell;
  final int activeUpiCount;
  final ValueChanged<bool> onToggle;
  const _MenuSection({
    required this.inSell,
    required this.activeUpiCount,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                const Text(
                  'In Sell',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1F2024),
                  ),
                ),
                const Spacer(),
                Transform.scale(
                  scale: 0.8,
                  child: Switch(
                    value: activeUpiCount > 0,
                    onChanged: activeUpiCount > 0 ? onToggle : null,
                    activeColor: Theme.of(context).primaryColor,
                    inactiveThumbColor: const Color(0xFFBFC3CC),
                    inactiveTrackColor: const Color(0xFFE1E4EA),
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: Color(0xFFE5E7EE), height: 0.5),

          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (_) => const LayoutPage(initialIndex: 2),
                  ),
                  (route) => false,
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'In Active: $activeUpiCount',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1F2024),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Active UPI',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF8F9098),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    HxButton(
                      color: Theme.of(context).primaryColor,
                      fontColor: Colors.white,
                      text: 'Manage UPI',
                      loading: false,
                      width: 120,
                      height: 36,
                      type: HxButtonType.small,
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
                ),
              ),
            ),
          ),
          const Divider(color: Color(0xFFE5E7EE), height: 0.5),

          _MenuItem(
            icon: Icons.shopping_bag_outlined,
            label: 'Buy IToken',
            onTap: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (_) => const LayoutPage(initialIndex: 1),
                ),
                (route) => false,
              );
            },
          ),
          _MenuItem(
            icon: Icons.history,
            label: 'Sell History',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SellHistoryPage()),
              );
            },
          ),
          _MenuItem(
            icon: Icons.support_agent,
            label: 'Official Service',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CustomerServicePage()),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Color(0xFFE5E7EE), width: 0.5),
          ),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 2,
          ),
          leading: Icon(icon, color: const Color(0xFF1F2024)),
          title: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2024),
            ),
          ),
          trailing: const Icon(Icons.chevron_right, color: Colors.black26),
          onTap: onTap,
        ),
      ),
    );
  }
}
