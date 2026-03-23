import 'package:flutter/material.dart';
import 'package:kumar_pay/presentation/widgets/hx_button.dart';

/// 弹窗位置枚举
enum DialogPosition {
  center, // 居中显示
  bottom, // 底部显示
}

/// 弹窗配置类
class PopupDialogConfig {
  final DialogPosition position;
  final String? title;
  final bool showCloseButton;
  final Widget? customContent;
  final bool showFooterButtons;
  final bool showDoubleButtons;
  final String? primaryButtonText;
  final String? secondaryButtonText;
  final bool closeOnConfirm;
  final bool closeOnCancel;
  final Color? primaryButtonColor;
  final Color? secondaryButtonColor;
  final HxButtonType? buttonType;
  final EdgeInsets? contentPadding;
  final double? borderRadius;
  final double? minHeight;
  final bool barrierDismissible;
  final Color? barrierColor;
  final Duration? animationDuration;
  final Curve? animationCurve;

  PopupDialogConfig({
    this.position = DialogPosition.center,
    this.title,
    this.showCloseButton = true,
    this.customContent,
    this.showFooterButtons = true,
    this.showDoubleButtons = true,
    this.primaryButtonText = 'Confirm',
    this.secondaryButtonText = 'Cancel',
    this.closeOnConfirm = true,
    this.closeOnCancel = true,
    this.primaryButtonColor,
    this.secondaryButtonColor,
    this.buttonType,
    this.contentPadding,
    this.borderRadius = 12.0,
    this.minHeight = 640,
    this.barrierDismissible = true,
    this.barrierColor,
    this.animationDuration,
    this.animationCurve,
  });
}

/// 弹窗组件
class PopupDialog extends StatefulWidget {
  final Widget child;
  final PopupDialogConfig config;
  final VoidCallback? onClose;
  final VoidCallback? onCancel;
  final VoidCallback? onConfirm;
  final Function(BuildContext)? builder;

  PopupDialog({
    super.key,
    required this.child,
    PopupDialogConfig? config,
    this.onClose,
    this.onCancel,
    this.onConfirm,
    this.builder,
  }) : config = config ?? PopupDialogConfig();

  @override
  // ignore: library_private_types_in_public_api
  _PopupDialogState createState() => _PopupDialogState();

  /// 显示弹窗的静态方法
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    PopupDialogConfig? config,
    VoidCallback? onClose,
    VoidCallback? onCancel,
    VoidCallback? onConfirm,
    Function(BuildContext)? builder,
  }) {
    final dialogConfig = config ?? PopupDialogConfig();
    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: dialogConfig.barrierDismissible,
      barrierColor: dialogConfig.barrierColor ?? Colors.black54,
      barrierLabel: '',
      transitionDuration:
          dialogConfig.animationDuration ?? const Duration(milliseconds: 300),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curve = dialogConfig.animationCurve ?? Curves.easeOut;
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: curve,
        );

        if (dialogConfig.position == DialogPosition.bottom) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(curvedAnimation),
            child: child,
          );
        } else {
          return ScaleTransition(
            scale: curvedAnimation,
            child: FadeTransition(opacity: curvedAnimation, child: child),
          );
        }
      },
      pageBuilder: (context, animation, secondaryAnimation) {
        return PopupDialog(
          config: dialogConfig,
          onClose: onClose,
          onCancel: onCancel,
          onConfirm: onConfirm,
          builder: builder,
          child: child,
        );
      },
    );
  }
}

class _PopupDialogState extends State<PopupDialog>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async {
        widget.onClose?.call();
        return true;
      },
      child: widget.config.position == DialogPosition.bottom
          ? _buildBottomDialog()
          : _buildCenterDialog(),
    );
  }

  /// 构建底部弹窗
  Widget _buildBottomDialog() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        // 外层容器用于布局和约束，具体材质由内部 Material 提供
        constraints: BoxConstraints(minHeight: widget.config.minHeight ?? 0),
        child: Material(
          color: Theme.of(context).dialogBackgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(widget.config.borderRadius ?? 12),
              topRight: Radius.circular(widget.config.borderRadius ?? 12),
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: _buildDialogContent(),
        ),
      ),
    );
  }

  /// 构建居中弹窗
  Widget _buildCenterDialog() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.config.borderRadius ?? 12),
          boxShadow: [
            BoxShadow(
              // ignore: deprecated_member_use
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        constraints: BoxConstraints(
          // maxWidth: 500,
          minHeight: widget.config.minHeight ?? 0,
        ),
        width: double.infinity,

        child: Material(
          color: Theme.of(context).dialogBackgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              widget.config.borderRadius ?? 12,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: _buildDialogContent(),
        ),
      ),
    );
  }

  /// 构建弹窗内容
  Widget _buildDialogContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 标题栏
        if (widget.config.title != null || widget.config.showCloseButton)
          _buildHeader(),
        // 自定义内容（如果有）
        if (widget.config.customContent != null) widget.config.customContent!,

        // 主体内容
        DefaultTextStyle.merge(
          style: const TextStyle(
            color: Colors.black,
            fontSize: 14,
            fontWeight: FontWeight.w500,
            decoration: TextDecoration.none,
          ),
          child: Padding(
            padding:
                widget.config.contentPadding ??
                const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: widget.builder != null
                ? widget.builder!(context)
                : widget.child,
          ),
        ),

        // 底部按钮
        if (widget.config.showFooterButtons) _buildFooter(),
      ],
    );
  }

  /// 构建标题栏
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 10, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Center(
              child: Text(
                widget.config.title ?? '',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          if (widget.config.showCloseButton)
            GestureDetector(
              child: Container(
                padding: const EdgeInsets.all(4),
                child: SizedBox(
                  width: 28,
                  height: 28,
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(28),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(28),
                      onTap: () {
                        Navigator.of(context).pop();
                        widget.onClose?.call();
                      },
                      child: Icon(
                        Icons.close,
                        size: 24,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// 构建底部按钮
  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(widget.config.borderRadius ?? 12),
          bottomRight: Radius.circular(widget.config.borderRadius ?? 12),
        ),
      ),
      child: Row(
        children: widget.config.showDoubleButtons
            ? _buildDoubleButtons()
            : _buildSingleButton(),
      ),
    );
  }

  /// 构建双按钮
  List<Widget> _buildDoubleButtons() {
    return [
      Expanded(
        child: HxButton(
          outlined: true,
          color: Color(0xFF1F2024),
          fontColor: Color(0xFF1F2024),
          text: widget.config.secondaryButtonText ?? 'Cancel',
          type: widget.config.buttonType ?? HxButtonType.large,
          onButtonPressed: () {
            widget.onCancel?.call();
            if (widget.config.closeOnCancel) {
              Navigator.of(context).pop();
            }
          },
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: HxButton(
          color:
              widget.config.primaryButtonColor ??
              Theme.of(context).primaryColor,
          fontColor: Colors.white,
          text: widget.config.primaryButtonText ?? 'Confirm',
          type: widget.config.buttonType ?? HxButtonType.large,
          onButtonPressed: () {
            widget.onConfirm?.call();
            if (widget.config.closeOnConfirm) {
              Navigator.of(context).pop();
            }
          },
        ),
      ),
    ];
  }

  /// 构建单按钮
  List<Widget> _buildSingleButton() {
    return [
      Expanded(
        child: HxButton(
          color:
              widget.config.primaryButtonColor ??
              Theme.of(context).primaryColor,
          fontColor: Colors.white,
          text: widget.config.primaryButtonText ?? 'Confirm',
          type: widget.config.buttonType ?? HxButtonType.medium,
          onButtonPressed: () {
            widget.onConfirm?.call();
            if (widget.config.closeOnConfirm) {
              Navigator.of(context).pop();
            }
          },
        ),
      ),
    ];
  }
}
