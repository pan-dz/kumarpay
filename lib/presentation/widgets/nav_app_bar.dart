import 'package:flutter/material.dart';

class NavAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool centerTitle;
  final double elevation;
  final bool showBottomBorder;
  final VoidCallback? onBack;
  final List<Widget>? actions;
  final Widget? leading;

  const NavAppBar({
    super.key,
    required this.title,
    this.centerTitle = true,
    this.elevation = 0,
    this.showBottomBorder = true,
    this.onBack,
    this.actions,
    this.leading,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF1F2024),
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      elevation: elevation,
      shape: showBottomBorder
          ? const Border(
              bottom: BorderSide(color: Color(0xFFEEEEEE), width: 0.5),
            )
          : null,
      centerTitle: centerTitle,
      leading:
          leading ??
          IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_rounded,
              size: 20,
              color: Color(0xFF1F2024),
            ),
            onPressed: onBack ?? () => Navigator.of(context).pop(),
          ),
      actions: actions,
    );
  }
}
