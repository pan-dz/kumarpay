import 'package:flutter/material.dart';

enum HxButtonType { small, medium, large }

class HxButton extends StatefulWidget {
  final String text;
  final double width;
  final double height;
  final Color color;
  final Color fontColor;
  final VoidCallback onButtonPressed;
  final bool disabled;
  final bool outlined;
  final bool loading;
  final Widget? leading;
  final double leadingGap;
  final double borderRadius;
  final HxButtonType type;
  final bool debounce;
  final Duration debounceDuration;

  const HxButton({
    super.key,
    required this.text,
    required this.color,
    required this.fontColor,
    required this.onButtonPressed,
    this.disabled = false,
    this.outlined = false,
    this.width = double.infinity,
    this.height = 48,
    this.loading = false,
    this.leading,
    this.leadingGap = 8,
    this.borderRadius = 6,
    this.type = HxButtonType.large,
    this.debounce = true,
    this.debounceDuration = const Duration(milliseconds: 800),
  });

  @override
  State<HxButton> createState() => _HxButtonState();
}

class _HxButtonState extends State<HxButton> {
  int _lastPressedMs = 0;

  void _handlePressed() {
    if (widget.loading || widget.disabled) return;
    if (widget.debounce) {
      final now = DateTime.now().millisecondsSinceEpoch;
      if (now - _lastPressedMs < widget.debounceDuration.inMilliseconds) {
        return;
      }
      _lastPressedMs = now;
    }
    widget.onButtonPressed();
  }

  @override
  Widget build(BuildContext context) {
    final disabledBackgroundColor = widget.outlined
        ? Colors.transparent
        : widget.color.withOpacity(0.45);
    final disabledForegroundColor = widget.fontColor.withOpacity(0.75);
    final baseStyle = ElevatedButton.styleFrom(
      elevation: 0,
      backgroundColor: widget.outlined ? Colors.transparent : widget.color,
      foregroundColor: widget.fontColor,
      disabledBackgroundColor: disabledBackgroundColor,
      disabledForegroundColor: disabledForegroundColor,
      shadowColor: Colors.transparent,
      // 垂直内边距由外部 height 控制，避免小高度按钮文字被裁剪
      padding: const EdgeInsets.symmetric(horizontal: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(widget.borderRadius),
      ),
      side: widget.outlined
          ? BorderSide(color: widget.color, width: 0.5)
          : BorderSide.none,
    );

    final style = baseStyle.copyWith(
      // 提供轻微的按压反馈（线框模式下）
      overlayColor: widget.outlined
          ? MaterialStatePropertyAll(widget.color.withOpacity(0.05))
          : null,
    );

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: ElevatedButton(
        onPressed: widget.disabled ? null : _handlePressed,
        style: style,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.leading != null) widget.leading!,
            if (widget.leading != null) SizedBox(width: widget.leadingGap),

            if (widget.loading) ...[
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  color: widget.fontColor,
                  strokeWidth: 2,
                ),
              ),
              const SizedBox(width: 12),
            ],
            // 根据类型设置字体大小
            Builder(
              builder: (_) {
                double fontSize;
                FontWeight fontWeight;
                switch (widget.type) {
                  case HxButtonType.small:
                    fontSize = 14;
                    fontWeight = FontWeight.w500;
                    break;
                  case HxButtonType.medium:
                    fontSize = 16;
                    fontWeight = FontWeight.w600;
                    break;
                  case HxButtonType.large:
                    fontSize = 20;
                    fontWeight = FontWeight.w700;
                    break;
                }
                return Text(
                  widget.text,
                  style: TextStyle(
                    fontSize: fontSize,
                    color: widget.fontColor,
                    fontWeight: fontWeight,
                    height: 1,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
