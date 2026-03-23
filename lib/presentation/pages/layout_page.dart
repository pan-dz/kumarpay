import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kumar_pay/app/router/app_router.dart';
import 'package:kumar_pay/presentation/pages/home_page/home_page.dart';
import 'package:kumar_pay/presentation/pages/buy_page/buy_page.dart';
import 'package:kumar_pay/presentation/pages/upi_page/upi_page.dart';
import 'package:kumar_pay/presentation/pages/mine_page/mine_page.dart';
import 'package:kumar_pay/presentation/pages/active_page/team/team_page.dart';
import 'package:kumar_pay/presentation/viewmodels/buy_viewmodel/buy_viewmodel.dart';
import 'package:kumar_pay/presentation/viewmodels/buy_viewmodel/buy_usdt_viewmodel.dart';
import 'package:kumar_pay/presentation/viewmodels/home_viewmodel/home_viewmodel.dart';
import 'package:kumar_pay/presentation/viewmodels/mine_viewmodel/mine_viewmodel.dart';
import 'package:kumar_pay/presentation/viewmodels/upi_viewmodel/upi_viewmodel.dart';
import 'package:kumar_pay/presentation/viewmodels/active_viewmodel/team/team_viewmodel.dart';
import 'package:kumar_pay/presentation/widgets/customer_service.dart';

class LayoutPage extends ConsumerStatefulWidget {
  final int initialIndex;
  const LayoutPage({super.key, this.initialIndex = 0});

  @override
  ConsumerState<LayoutPage> createState() => _LayoutPageState();
}

class _LayoutPageState extends ConsumerState<LayoutPage> with RouteAware {
  late int _currentIndex = widget.initialIndex;
  late final List<Widget?> _pageCache;
  PageRoute<dynamic>? _route;
  bool _isCurrentRoute = false;
  late final String _visibilityKey = 'layout_${identityHashCode(this)}';

  @override
  void initState() {
    super.initState();
    _pageCache = List<Widget?>.filled(5, null, growable: false);
    _pageCache[_currentIndex] = _buildPage(_currentIndex);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is! PageRoute<dynamic> || identical(route, _route)) {
      return;
    }

    if (_route != null) {
      AppRouter.routeObserver.unsubscribe(this);
    }

    _route = route;
    AppRouter.routeObserver.subscribe(this, route);
  }

  @override
  void dispose() {
    AppRouter.routeObserver.unsubscribe(this);
    _setCustomerServiceVisible(false);
    super.dispose();
  }

  Widget _buildPage(int index) {
    switch (index) {
      case 0:
        return const HomePage();
      case 1:
        return const BuyPage();
      case 2:
        return const UpiPage();
      case 3:
        return const TeamPage();
      case 4:
        return const MinePage();
      default:
        return const SizedBox.shrink();
    }
  }

  bool get _shouldShowCustomerServiceOnTab {
    return HomeViewModel.shouldShowCustomerServiceOnTab(_currentIndex);
  }

  void _setCustomerServiceVisible(bool visible) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      final notifier = ref.read(customerServiceVisibilityProvider.notifier);
      if (visible) {
        notifier.activate(_visibilityKey);
      } else {
        notifier.deactivate(_visibilityKey);
      }
    });
  }

  void _syncCustomerServiceVisibility() {
    _setCustomerServiceVisible(
      _isCurrentRoute && _shouldShowCustomerServiceOnTab,
    );
  }

  @override
  void didPush() {
    _isCurrentRoute = true;
    _syncCustomerServiceVisibility();
  }

  @override
  void didPopNext() {
    _isCurrentRoute = true;
    _syncCustomerServiceVisibility();
  }

  @override
  void didPushNext() {
    _isCurrentRoute = false;
    _setCustomerServiceVisible(false);
  }

  @override
  void didPop() {
    _isCurrentRoute = false;
    _setCustomerServiceVisible(false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: List.generate(
          5,
          (i) => _pageCache[i] ?? const SizedBox.shrink(),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
              _pageCache[index] ??= _buildPage(index);
            });
            _syncCustomerServiceVisibility();

            unawaited(
              ref
                  .read(homeViewModelProvider.notifier)
                  .refreshCustomerServiceForTab(index),
            );

            if (index == 0) {
              ref.read(homeViewModelProvider.notifier).refreshomeConfig();
              ref.read(mineViewModelProvider.notifier).refreshUserInfo(context);
              ref.read(buyUsdtViewModelProvider.notifier).refreshUsdtRecords();
            } else if (index == 1) {
              ref.read(buyViewModelProvider.notifier).handleSearchRefresh();
              ref.read(buyUsdtViewModelProvider.notifier).refreshUsdtRecords();
            } else if (index == 2) {
              ref.read(upiViewModelProvider.notifier).getUpiList();
            } else if (index == 3) {
              ref.read(teamViewModelProvider.notifier).fetchTeamInfo();
            } else if (index == 4) {
              ref.read(mineViewModelProvider.notifier).refreshUserInfo(context);
              ref.read(buyUsdtViewModelProvider.notifier).refreshUsdtRecords();
            }
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: Theme.of(context).primaryColor,
          unselectedItemColor: Colors.grey[600],
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
          items: [
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: const Icon(Icons.home_outlined),
              ),
              activeIcon: Container(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: const Icon(Icons.home),
              ),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: const Icon(Icons.shopping_cart_outlined),
              ),
              activeIcon: Container(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: const Icon(Icons.shopping_cart),
              ),
              label: 'Buy',
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: const Icon(Icons.folder_shared_outlined),
              ),
              activeIcon: Container(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: const Icon(Icons.folder_shared),
              ),
              label: 'UPI',
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: const Icon(Icons.chat_bubble_outline),
              ),
              activeIcon: Container(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: const Icon(Icons.chat_bubble),
              ),
              label: 'Team',
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: const Icon(Icons.account_circle_outlined),
              ),
              activeIcon: Container(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: const Icon(Icons.account_circle),
              ),
              label: 'Mine',
            ),
          ],
        ),
      ),
    );
  }
}
