import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kumar_pay/presentation/pages/buy_page/buy_usdt_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kumar_pay/presentation/widgets/common_widgets.dart';
import 'package:kumar_pay/presentation/viewmodels/buy_viewmodel/buy_viewmodel.dart';
import 'package:kumar_pay/presentation/pages/buy_page/buy_inr_page.dart';
import 'package:kumar_pay/presentation/widgets/hx_inkwell_button.dart';
import 'package:kumar_pay/presentation/widgets/hx_input.dart';

class BuyPage extends ConsumerWidget {
  const BuyPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(buyViewModelProvider);
    final vm = ref.read(buyViewModelProvider.notifier);
    final theme = Theme.of(context);

    return Stack(
      children: [
        AppPageScaffold(
          title: 'Buy',
          appBarBackgroundColor: theme.primaryColor,
          appBarForegroundColor: theme.colorScheme.onPrimary,
          systemOverlayStyle: SystemUiOverlayStyle.light,
          automaticallyImplyLeading: false,
          body: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFE8E9F1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: CustomScrollView(
              slivers: [
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _HeaderDelegate(
                    minHeight: state.tabIndex != 2 ? 95 : 43,
                    maxHeight: state.tabIndex != 2 ? 95 : 43,
                    child: Column(
                      children: [
                        _Tabs(index: state.tabIndex, onChanged: vm.onTabChange),
                        if (state.tabIndex != 2)
                          _Search(
                            vm: vm,
                            ascending: state.ascending,
                            minAmount: state.minAmount,
                            maxAmount: state.maxAmount,
                          ),
                      ],
                    ),
                  ),
                ),
                if (state.tabIndex != 2)
                  BuyInrSliver(theme: theme, topInset: 0)
                else
                  BuyUsdtSliver(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Search extends ConsumerStatefulWidget {
  const _Search({
    required this.vm,
    required this.ascending,
    required this.minAmount,
    required this.maxAmount,
  });

  final BuyViewModel vm;
  final bool ascending;
  final int minAmount;
  final int maxAmount;

  @override
  ConsumerState<_Search> createState() => _SearchState();
}

class _SearchState extends ConsumerState<_Search> {
  late final TextEditingController _minController;
  late final TextEditingController _maxController;
  late final FocusNode _minFocus;
  late final FocusNode _maxFocus;

  @override
  void initState() {
    super.initState();
    _minController = TextEditingController(text: widget.minAmount.toString());
    _maxController = TextEditingController(text: widget.maxAmount.toString());
    _minFocus = FocusNode();
    _maxFocus = FocusNode();
    _minFocus.addListener(_handleMinFocus);
    _maxFocus.addListener(_handleMaxFocus);
  }

  @override
  void didUpdateWidget(covariant _Search oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.minAmount != widget.minAmount &&
        _minController.text != widget.minAmount.toString()) {
      _minController.text = widget.minAmount.toString();
    }
    if (oldWidget.maxAmount != widget.maxAmount &&
        _maxController.text != widget.maxAmount.toString()) {
      _maxController.text = widget.maxAmount.toString();
    }
  }

  @override
  void dispose() {
    _minFocus.removeListener(_handleMinFocus);
    _maxFocus.removeListener(_handleMaxFocus);
    _minFocus.dispose();
    _maxFocus.dispose();
    _minController.dispose();
    _maxController.dispose();
    super.dispose();
  }

  void _handleMinFocus() {
    if (_minFocus.hasFocus) return;
    final text = _minController.text.trim();
    final state = ref.read(buyViewModelProvider);
    if (text.isEmpty) {
      _minController.text = state.minAmount.toString();
      return;
    }
    final parsed = int.tryParse(text);
    final min = 100;
    final max = state.maxAmount;
    final normalized = (parsed ?? state.minAmount).clamp(min, max);
    widget.vm.updateMinAmount(normalized.toString());
    _minController.text = normalized.toString();
  }

  void _handleMaxFocus() {
    if (_maxFocus.hasFocus) return;
    final text = _maxController.text.trim();
    final state = ref.read(buyViewModelProvider);
    if (text.isEmpty) {
      _maxController.text = state.maxAmount.toString();
      return;
    }
    final parsed = int.tryParse(text);
    final min = state.minAmount;
    final max = 100000;
    final normalized = (parsed ?? state.maxAmount).clamp(min, max);
    widget.vm.updateMaxAmount(normalized.toString());
    _maxController.text = normalized.toString();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(color: Color(0xFFE8E9F1)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                HxInkWellButton(
                  onButtonPressed: () => widget.vm.handleClickSort(true),
                  child: Icon(
                    Icons.arrow_upward,
                    size: 18,
                    color: widget.ascending
                        ? theme.primaryColor
                        : const Color(0xFF8F9098),
                  ),
                ),

                HxInkWellButton(
                  onButtonPressed: () => widget.vm.handleClickSort(false),
                  child: Icon(
                    Icons.arrow_downward,
                    size: 18,
                    color: !widget.ascending
                        ? theme.primaryColor
                        : const Color(0xFF8F9098),
                  ),
                ),

                const SizedBox(width: 8),
                _InputBox(
                  hint: 'Min',
                  controller: _minController,
                  focusNode: _minFocus,
                  onChanged: widget.vm.updateMinAmount,
                ),
                const SizedBox(width: 8),
                _InputBox(
                  hint: 'Max',
                  controller: _maxController,
                  focusNode: _maxFocus,
                  onChanged: widget.vm.updateMaxAmount,
                ),
              ],
            ),

            HxInkWellButton(
              onButtonPressed: widget.vm.handleSearchRefresh,
              child: const Icon(Icons.search, size: 18),
            ),
          ],
        ),
      ),
    );
  }
}

class _InputBox extends StatelessWidget {
  final String hint;
  final TextEditingController controller;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  const _InputBox({
    required this.hint,
    required this.controller,
    this.focusNode,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 36,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFD8DAE0),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        // crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(width: 8),
          Text(
            hint,
            style: const TextStyle(
              color: Color(0xFF8F9098),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: HxInput(
              controller: controller,
              focusNode: focusNode,
              onChanged: onChanged,
            ),
          ),
          const SizedBox(width: 6),
        ],
      ),
    );
  }
}

class _Tabs extends StatelessWidget {
  final int index;
  final ValueChanged<int> onChanged;
  const _Tabs({required this.index, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final labels = const ['INR + More', 'INR', 'USDT'];
    return Container(
      decoration: BoxDecoration(color: theme.primaryColor),
      child: SizedBox(
        height: 43,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final double segWidth = constraints.maxWidth / labels.length;
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: List.generate(labels.length, (i) {
                      final selected = index == i;
                      return SizedBox(
                        width: segWidth,
                        height: 40,
                        child: InkWell(
                          onTap: () => onChanged(i),
                          child: Center(
                            child: Text(
                              labels[i],
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: selected
                                    ? FontWeight.w700
                                    : FontWeight.w600,
                                color: selected
                                    ? theme.colorScheme.onPrimary
                                    : Color(0xFFA3EBC0),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                  SizedBox(
                    height: 3,
                    child: Stack(
                      children: [
                        Container(
                          decoration: ShapeDecoration(
                            color: theme.primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(999),
                                topRight: Radius.circular(999),
                              ),
                            ),
                          ),
                        ),
                        AnimatedPositioned(
                          duration: const Duration(milliseconds: 220),
                          curve: Curves.easeOutCubic,
                          left: index * segWidth + segWidth / 6.5,
                          width: segWidth / 1.5,
                          child: Container(
                            height: 3,
                            // color: theme.colorScheme.onPrimary,
                            decoration: ShapeDecoration(
                              color: theme.colorScheme.onPrimary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  topRight: Radius.circular(10),
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
        ),
      ),
    );
  }
}

class _HeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double minHeight;
  final double maxHeight;

  _HeaderDelegate({
    required this.child,
    required this.minHeight,
    required this.maxHeight,
  });

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      elevation: overlapsContent ? 2 : 0,
      child: child,
    );
  }

  @override
  bool shouldRebuild(covariant _HeaderDelegate oldDelegate) {
    return oldDelegate.child != child ||
        oldDelegate.minHeight != minHeight ||
        oldDelegate.maxHeight != maxHeight;
  }
}
