import 'package:flutter/material.dart';

/// A reusable list widget that supports pull-to-refresh and
/// infinite scroll (load-more) with a simple bottom status.
///
/// Parent manages data and passes in [items], [isLoading] and [noMore].
/// Provide [onRefresh] to reload data and [onLoadMore] to fetch next page.
class RefreshLoadListView<T> extends StatefulWidget {
  final List<T> items;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final Future<void> Function() onRefresh;
  final Future<void> Function()? onLoadMore;
  final bool isLoading;
  final bool noMore;
  final EdgeInsetsGeometry? padding;
  final ScrollController? controller;
  final double loadMoreOffset;
  final Widget? bottom;
  final Widget? empty;
  final String emptyText;
  final EmptyStateConfig? emptyConfig;

  const RefreshLoadListView({
    super.key,
    required this.items,
    required this.itemBuilder,
    required this.onRefresh,
    this.onLoadMore,
    required this.isLoading,
    required this.noMore,
    this.padding,
    this.controller,
    this.loadMoreOffset = 100,
    this.bottom,
    this.empty,
    this.emptyText = 'No data',
    this.emptyConfig,
  });

  @override
  State<RefreshLoadListView<T>> createState() => _RefreshLoadListViewState<T>();
}

class _RefreshLoadListViewState<T> extends State<RefreshLoadListView<T>> {
  late final ScrollController _controller;
  ScrollController get _effectiveController => widget.controller ?? _controller;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
    _effectiveController.addListener(_onScroll);
  }

  @override
  void didUpdateWidget(covariant RefreshLoadListView<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(_onScroll);
      _effectiveController.addListener(_onScroll);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (widget.onLoadMore == null) return;
    if (widget.noMore || widget.isLoading) return;
    if (widget.items.isEmpty) return;
    final position = _effectiveController.position;
    if (!position.hasPixels || !position.hasContentDimensions) return;
    if (position.pixels >= position.maxScrollExtent - widget.loadMoreOffset) {
      widget.onLoadMore!.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: widget.onRefresh,
      child: ListView.builder(
        controller: _effectiveController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: widget.padding,
        itemCount: widget.items.length + 1,
        itemBuilder: (context, index) {
          if (index < widget.items.length) {
            final item = widget.items[index];
            return widget.itemBuilder(context, item, index);
          }
          if (widget.items.isEmpty && !widget.isLoading) {
            if (widget.empty != null) return widget.empty!;
            if (widget.emptyConfig != null) {
              return _EmptyState(config: widget.emptyConfig!);
            }
            return _DefaultEmpty(text: widget.emptyText);
          }
          return widget.bottom ??
              _DefaultBottom(
                isLoading: widget.isLoading,
                noMore: widget.noMore,
              );
        },
      ),
    );
  }
}

class _DefaultBottom extends StatelessWidget {
  final bool isLoading;
  final bool noMore;
  const _DefaultBottom({required this.isLoading, required this.noMore});

  @override
  Widget build(BuildContext context) {
    final text = noMore ? 'No more data' : (isLoading ? 'Loading...' : '');
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(color: Color(0xFF8E9199), fontSize: 12),
        ),
      ),
    );
  }
}

/// Config for a standard image + text empty state with optional button
class EmptyStateConfig {
  final Widget? image;
  final String title;
  final String? subtitle;
  final bool showButton;
  final String buttonText;
  final VoidCallback? onButtonPressed;
  final EdgeInsets padding;
  final double spacing;

  const EmptyStateConfig({
    this.image,
    required this.title,
    this.subtitle,
    this.showButton = false,
    this.buttonText = '',
    this.onButtonPressed,
    this.padding = const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
    this.spacing = 12,
  });
}

class _EmptyState extends StatelessWidget {
  final EmptyStateConfig config;
  const _EmptyState({required this.config});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: config.padding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 24),
          if (config.image != null)
            SizedBox(height: 100, child: Center(child: config.image))
          else
            SizedBox(
              height: 100,
              child: Center(
                child: Image.asset(
                  'assets/images/no_data.webp',
                  width: 100,
                  height: 100,
                ),
              ),
            ),

          SizedBox(height: config.spacing),
          Text(
            config.title,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF71727A),
              fontSize: 14,
              fontWeight: FontWeight.w500,
              height: 1.2,
            ),
          ),
          if (config.subtitle != null && config.subtitle!.isNotEmpty) ...[
            SizedBox(height: config.spacing / 2),
            Text(
              config.subtitle!,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF8E9199),
                fontSize: 14,
              ),
            ),
          ],
          if (config.showButton) ...[
            const SizedBox(height: 140),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: config.onButtonPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  elevation: 0,
                ),

                child: Text(
                  config.buttonText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    height: 1,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DefaultEmpty extends StatelessWidget {
  final String text;
  const _DefaultEmpty({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 70),
      child: SizedBox(
        height: 200,
        child: Column(
          children: [
            SizedBox(
              height: 150,
              child: Center(
                child: Image.asset(
                  'assets/images/no_data.webp',
                  width: 140,
                  fit: BoxFit.contain,
                ),
              ),
            ),

            Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(color: const Color(0xFF8E9199), fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
