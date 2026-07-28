import 'package:flutter/material.dart';

class ReferenceAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ReferenceAppBar({
    required this.title,
    this.onBack,
    this.action,
    super.key,
  });

  final String title;
  final VoidCallback? onBack;
  final Widget? action;

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      leadingWidth: onBack == null ? 16 : 72,
      leading: onBack == null
          ? null
          : IconButton(
              padding: const EdgeInsets.only(left: 16),
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back),
            ),
      titleSpacing: onBack == null ? 16 : 0,
      title: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: Text(title),
      ),
      actions: action == null
          ? null
          : [
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Center(child: action),
              ),
            ],
    );
  }
}
