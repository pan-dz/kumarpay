import 'package:flutter/material.dart';

class HxInkWellButton extends StatelessWidget {
  final Widget child;
  final VoidCallback onButtonPressed;
  final EdgeInsetsGeometry? padding;

  const HxInkWellButton({
    super.key,
    required this.child,
    required this.onButtonPressed,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
        onTap: onButtonPressed,
        child: Padding(
          padding:
              padding ?? const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          child: child,
        ),
      ),
    );
  }
}
