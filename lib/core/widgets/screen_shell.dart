import 'package:flutter/material.dart';

import 'reference_app_bar.dart';

class ScreenShell extends StatelessWidget {
  const ScreenShell({
    required this.title,
    required this.child,
    this.onBack,
    this.floatingActionButton,
    super.key,
  });

  final String title;
  final Widget child;
  final VoidCallback? onBack;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ReferenceAppBar(
        title: title,
        onBack: onBack ?? () => Navigator.of(context).pop(),
      ),
      body: SafeArea(
        top: false,
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: child,
          ),
        ),
      ),
      floatingActionButton: floatingActionButton,
    );
  }
}
