import 'package:flutter/material.dart';
import 'package:another_flushbar/flushbar.dart';

enum AppToastType { success, info, warning, error }

class AppToastTheme {
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon;
  final Color? iconColor;
  final BorderRadius? borderRadius;
  final EdgeInsets? margin;
  final EdgeInsets? padding;
  final Duration? duration;
  final bool? shouldIconPulse;
  final FlushbarPosition? position;
  final double? elevation;
  final TextStyle? messageStyle;
  final TextStyle? titleStyle;

  const AppToastTheme({
    this.backgroundColor,
    this.textColor,
    this.icon,
    this.iconColor,
    this.borderRadius,
    this.margin,
    this.padding,
    this.duration,
    this.shouldIconPulse,
    this.position,
    this.elevation,
    this.messageStyle,
    this.titleStyle,
  });

  AppToastTheme copyWith({
    Color? backgroundColor,
    Color? textColor,
    IconData? icon,
    Color? iconColor,
    Color? leftBarIndicatorColor,
    BorderRadius? borderRadius,
    EdgeInsets? margin,
    EdgeInsets? padding,
    Duration? duration,
    bool? shouldIconPulse,
    FlushbarPosition? position,
    double? elevation,
    TextStyle? messageStyle,
    TextStyle? titleStyle,
  }) {
    return AppToastTheme(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      textColor: textColor ?? this.textColor,
      icon: icon ?? this.icon,
      iconColor: iconColor ?? this.iconColor,
      borderRadius: borderRadius ?? this.borderRadius,
      margin: margin ?? this.margin,
      padding: padding ?? this.padding,
      duration: duration ?? this.duration,
      shouldIconPulse: shouldIconPulse ?? this.shouldIconPulse,
      position: position ?? this.position,
      elevation: elevation ?? this.elevation,
      messageStyle: messageStyle ?? this.messageStyle,
      titleStyle: titleStyle ?? this.titleStyle,
    );
  }
}

class AppToast {
  static AppToastTheme _defaults(BuildContext context, AppToastType type) {
    final theme = Theme.of(context);

    switch (type) {
      case AppToastType.success:
        return AppToastTheme(
          backgroundColor: const Color(0xFF2E7D32), // Green 800
          textColor: Colors.white,
          icon: Icons.check_circle,
          iconColor: Colors.white,
          borderRadius: BorderRadius.circular(8),
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          duration: const Duration(seconds: 2),
          shouldIconPulse: true,
          position: FlushbarPosition.TOP,
          elevation: 6,
          messageStyle: theme.textTheme.bodyMedium?.copyWith(
            color: Colors.white,
          ),
        );
      case AppToastType.info:
        return AppToastTheme(
          backgroundColor: const Color(0xFF10A37F), // GPT-like teal/green
          textColor: Colors.white,
          icon: Icons.info,
          iconColor: Colors.white,
          borderRadius: BorderRadius.circular(8),
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          duration: const Duration(milliseconds: 2000),
          shouldIconPulse: true,
          position: FlushbarPosition.TOP,
          elevation: 6,
          messageStyle: theme.textTheme.bodyMedium?.copyWith(
            color: Colors.white,
          ),
        );
      case AppToastType.warning:
        return AppToastTheme(
          backgroundColor: const Color(0xFFF59E0B), // GPT-like amber
          textColor: Colors.white,
          icon: Icons.warning_amber_rounded,
          iconColor: Colors.white,
          borderRadius: BorderRadius.circular(8),
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          duration: const Duration(milliseconds: 2000),
          shouldIconPulse: true,
          position: FlushbarPosition.TOP,
          elevation: 6,
          messageStyle: theme.textTheme.bodyMedium?.copyWith(
            color: Colors.white,
          ),
        );
      case AppToastType.error:
        return AppToastTheme(
          backgroundColor: const Color(0xFFC62828), // Red 800
          textColor: Colors.white,
          icon: Icons.error,
          iconColor: Colors.white,
          borderRadius: BorderRadius.circular(8),
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          duration: const Duration(milliseconds: 2000),
          shouldIconPulse: true,
          position: FlushbarPosition.TOP,
          elevation: 6,
          messageStyle: theme.textTheme.bodyMedium?.copyWith(
            color: Colors.white,
          ),
        );
    }
  }

  static void show(
    BuildContext context, {
    required String message,
    AppToastType type = AppToastType.info,
    AppToastTheme? theme,
    String? title,
    String? actionText,
    VoidCallback? onAction,
    FlushbarDismissDirection dismissDirection =
        FlushbarDismissDirection.HORIZONTAL,
  }) {
    final base = _defaults(context, type);
    final t = base.copyWith(
      backgroundColor: theme?.backgroundColor,
      textColor: theme?.textColor,
      icon: theme?.icon,
      iconColor: theme?.iconColor,
      borderRadius: theme?.borderRadius,
      margin: theme?.margin,
      padding: theme?.padding,
      duration: theme?.duration,
      shouldIconPulse: theme?.shouldIconPulse,
      position: theme?.position,
      elevation: theme?.elevation,
      messageStyle: theme?.messageStyle,
      titleStyle: theme?.titleStyle,
    );

    final textStyle =
        t.messageStyle ??
        TextStyle(color: t.textColor ?? Colors.white, fontSize: 14);

    final rootOverlayContext =
        Navigator.of(context, rootNavigator: true).overlay?.context ?? context;

    Flushbar(
      titleText: title == null
          ? null
          : Text(
              title,
              style:
                  t.titleStyle ??
                  textStyle.copyWith(fontWeight: FontWeight.w600),
            ),
      messageText: Text(message, style: textStyle),
      duration: t.duration ?? const Duration(milliseconds: 3000),
      // duration: const Duration(milliseconds: 4000),
      backgroundColor: t.backgroundColor ?? Colors.black87,
      borderRadius: t.borderRadius ?? BorderRadius.circular(8),
      margin: t.margin ?? const EdgeInsets.all(16),
      padding: t.padding ?? const EdgeInsets.all(16),
      flushbarPosition: t.position ?? FlushbarPosition.TOP,
      icon: (t.icon == null)
          ? null
          : Icon(t.icon, color: t.iconColor ?? t.textColor ?? Colors.white),
      shouldIconPulse: t.shouldIconPulse ?? false,
      dismissDirection: dismissDirection,
      isDismissible: true,
      mainButton: (actionText != null && onAction != null)
          ? TextButton(
              onPressed: onAction,
              child: Text(
                actionText,
                style: TextStyle(
                  color: (t.textColor ?? Colors.white).withOpacity(0.9),
                ),
              ),
            )
          : null,
    ).show(rootOverlayContext);
  }

  static void success(BuildContext context, String message) {
    show(context, message: message, type: AppToastType.success);
  }

  static void info(BuildContext context, String message) {
    show(context, message: message, type: AppToastType.info);
  }

  static void warning(BuildContext context, String message) {
    show(context, message: message, type: AppToastType.warning);
  }

  static void error(
    BuildContext context,
    String message, {
    String? actionText,
    VoidCallback? onAction,
  }) {
    show(
      context,
      message: message,
      type: AppToastType.error,
      actionText: actionText,
      onAction: onAction,
    );
  }
}
