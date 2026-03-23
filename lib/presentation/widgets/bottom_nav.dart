import 'package:flutter/material.dart';

class BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<BottomNavigationBarItem>? items;
  final Map<int, int>? badgeCounts; // index -> count

  const BottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.items,
    this.badgeCounts,
  });

  @override
  Widget build(BuildContext context) {
    final defaultItems = [
      _itemWithBadge(
        context,
        icon: Icons.home,
        activeIcon: Icons.home,
        label: 'Home',
        index: 0,
      ),
      _itemWithBadge(
        context,
        icon: Icons.shopping_cart_outlined,
        activeIcon: Icons.shopping_cart_outlined,
        label: 'Buy',
        index: 1,
      ),
      _itemWithBadge(
        context,
        icon: Icons.article_outlined,
        activeIcon: Icons.article_outlined,
        label: 'UPI',
        index: 2,
      ),
      _itemWithBadge(
        context,
        icon: Icons.article_outlined,
        activeIcon: Icons.article_outlined,
        label: 'Team',
        index: 3,
      ),
      _itemWithBadge(
        context,
        icon: Icons.account_circle_outlined,
        activeIcon: Icons.account_circle_outlined,
        label: 'Mine',
        index: 4,
      ),
    ];

    return Container(
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
        currentIndex: currentIndex,
        onTap: onTap,
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
        items: items ?? defaultItems,
      ),
    );
  }

  BottomNavigationBarItem _itemWithBadge(
    BuildContext context, {
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
  }) {
    final count = badgeCounts?[index] ?? 0;
    Widget buildIcon(IconData data) {
      final base = Container(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Icon(data),
      );
      if (count <= 0) return base;
      return Stack(
        clipBehavior: Clip.none,
        children: [
          base,
          Positioned(
            right: -2,
            top: -2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
              ),
              constraints: const BoxConstraints(minWidth: 18),
              child: Text(
                count > 99 ? '99+' : '$count',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      );
    }

    return BottomNavigationBarItem(
      icon: buildIcon(icon),
      activeIcon: buildIcon(activeIcon),
      label: label,
    );
  }
}
