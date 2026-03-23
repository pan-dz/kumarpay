import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodels/home_viewmodel/home_viewmodel.dart';
import 'bottom_nav.dart';

class AppBottomNav extends ConsumerWidget {
  const AppBottomNav({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(homeViewModelProvider).currentIndex;
    return BottomNav(
      currentIndex: currentIndex,
      onTap: (index) {
        ref.read(homeViewModelProvider.notifier).onTabChange(index);
        if (index == 0) {
          Navigator.of(context).pushReplacementNamed('/');
        } else if (index == 1) {
          Navigator.of(context).pushReplacementNamed('/buy');
        }
      },
    );
  }
}
