import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 页面状态组件
/// 统一处理加载中、错误和空数据状态的显示
class PageStateWidget extends StatelessWidget {
  final bool isLoading;
  final String? error;
  final bool isEmpty;
  final VoidCallback? onRetry;
  final String emptyMessage;
  final String emptyMessage1;
  final String emptyIcon;
  final Widget? child;
  final bool? isShowRetryButton;

  const PageStateWidget({
    super.key,
    required this.isLoading,
    this.error,
    this.isEmpty = false,
    this.onRetry,
    this.emptyMessage = 'No data available.',
    this.emptyMessage1 = '',
    this.emptyIcon = 'inbox',
    this.child,
    this.isShowRetryButton = true,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
            const SizedBox(height: 16),
            Text(
              'An error occurred',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red[400],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error!,
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            if (isShowRetryButton == true)
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
          ],
        ),
      );
    }

    if (isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(_getEmptyDataIcon(), size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 4),
            Text(
              emptyMessage1,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            if (onRetry != null && isShowRetryButton == true)
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh'),
              ),
          ],
        ),
      );
    }

    return child ?? const SizedBox.shrink();
  }

  IconData _getEmptyDataIcon() {
    switch (emptyIcon) {
      case 'people':
        return Icons.people_outline;
      case 'article':
        return Icons.article_outlined;
      case 'comment':
        return Icons.chat_bubble_outline;
      case 'folder_shared':
        return Icons.folder_shared;
      default:
        return Icons.inbox_outlined;
    }
  }
}

/// 通用加载组件
class CommonLoadingView extends StatelessWidget {
  final double? size;
  final Color? barrierColor;
  final bool showBarrier;
  final String? message;
  const CommonLoadingView({
    super.key,
    this.size,
    this.barrierColor,
    this.showBarrier = true,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    final indicator = size == null
        ? const CircularProgressIndicator()
        : SizedBox(
            width: size,
            height: size,
            child: const CircularProgressIndicator(),
          );

    return Container(
      color: showBarrier
          ? (barrierColor ?? const Color.fromARGB(46, 0, 0, 0))
          : Colors.transparent,
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          indicator,
          if (message != null) ...[
            const SizedBox(height: 12),
            Text(
              message!,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white,
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// 信息项组件
/// 用于显示带图标的信息项，如邮箱、电话等
class InfoItemWidget extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final CrossAxisAlignment alignment;

  const InfoItemWidget({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.alignment = CrossAxisAlignment.center,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: alignment,
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          Expanded(
            child: Text(value, style: TextStyle(color: Colors.grey[600])),
          ),
        ],
      ),
    );
  }
}

/// 统计项组件
/// 用于显示统计数据，如浏览量、点赞数等
class StatItemWidget extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const StatItemWidget({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          '$value $label',
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
        ),
      ],
    );
  }
}

/// 操作项组件
/// 用于显示可点击的操作项，如点赞、回复等
class ActionItemWidget extends StatelessWidget {
  final String label;
  final String count;
  final IconData icon;
  final VoidCallback onTap;

  const ActionItemWidget({
    super.key,
    required this.label,
    required this.count,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: Colors.grey[600]),
            if (count.isNotEmpty) ...[
              const SizedBox(width: 4),
              Text(
                count,
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
            ],
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

/// 头像组件
/// 统一的头像显示样式
class AvatarWidget extends StatelessWidget {
  final String? text;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final double? radius;

  const AvatarWidget({
    super.key,
    this.text,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.radius,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? Colors.blue[100];
    final txtColor = textColor ?? Colors.blue[800];
    final size = radius ?? 20;

    return CircleAvatar(
      radius: size,
      backgroundColor: bgColor,
      child: text != null
          ? Text(
              text!.substring(0, 1).toUpperCase(),
              style: TextStyle(color: txtColor, fontWeight: FontWeight.bold),
            )
          : icon != null
          ? Icon(icon, color: txtColor)
          : const Icon(Icons.person, color: Colors.white),
    );
  }
}

/// 应用页面框架组件
/// 统一页面布局，包含AppBar和刷新功能
class AppPageScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final List<Widget>? actions;
  final Future<void> Function()? onRefresh;
  final bool centerTitle;
  final bool automaticallyImplyLeading;
  final bool showRefreshIndicator;
  final bool isCustomContainer;
  final Widget? headBody;
  final Color? appBarBackgroundColor;
  final Color? appBarForegroundColor;
  final SystemUiOverlayStyle? systemOverlayStyle;

  const AppPageScaffold({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.onRefresh,
    this.centerTitle = true,
    this.automaticallyImplyLeading = true,
    this.showRefreshIndicator = true,
    this.isCustomContainer = false,
    this.headBody,
    this.appBarBackgroundColor,
    this.appBarForegroundColor,
    this.systemOverlayStyle,
  });

  @override
  Widget build(BuildContext context) {
    final defaultActions = actions ?? [];

    // 如果没有提供actions但提供了onRefresh，添加默认的刷新按钮
    if (defaultActions.isEmpty && onRefresh != null) {
      defaultActions.add(
        IconButton(icon: const Icon(Icons.refresh), onPressed: onRefresh),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        centerTitle: centerTitle,
        automaticallyImplyLeading: automaticallyImplyLeading,
        actions: defaultActions,
        backgroundColor: appBarBackgroundColor ?? Colors.white,
        foregroundColor: appBarForegroundColor ?? Colors.black,
        titleTextStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
          color: appBarForegroundColor ?? Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
        systemOverlayStyle: systemOverlayStyle ?? SystemUiOverlayStyle.dark,
      ),
      body: showRefreshIndicator && onRefresh != null
          ? isCustomContainer
                ? Container(
                    alignment: Alignment.center,
                    child: Column(
                      children: [
                        if (headBody != null) headBody!,
                        const SizedBox(height: 16),
                        RefreshIndicator(onRefresh: onRefresh!, child: body),
                      ],
                    ),
                  )
                : RefreshIndicator(onRefresh: onRefresh!, child: body)
          : body,
    );
  }
}

/// 列表项卡片组件
/// 统一的列表项卡片样式
class ListItemCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final double? elevation;
  final BorderRadius? borderRadius;

  const ListItemCard({
    super.key,
    required this.child,
    this.margin,
    this.padding,
    this.color,
    this.elevation,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: margin ?? const EdgeInsets.only(bottom: 16),
      elevation: elevation ?? 2,
      color: color,
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius ?? BorderRadius.circular(8),
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(16.0),
        child: child,
      ),
    );
  }
}


/// 