import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/screen_shell.dart';

class LateArrivalsPage extends StatefulWidget {
  const LateArrivalsPage({super.key});

  @override
  State<LateArrivalsPage> createState() => _LateArrivalsPageState();
}

class _LateArrivalsPageState extends State<LateArrivalsPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    await _controller.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return ScreenShell(
      title: 'Late Coming Details',
      floatingActionButton: FloatingActionButton(
        onPressed: _refresh,
        backgroundColor: const Color(0xFF62B5EB),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: RotationTransition(
          turns: _controller,
          child: const Icon(Icons.refresh, size: 30),
        ),
      ),
      child: const Align(
        alignment: Alignment.topLeft,
        child: Padding(
          padding: EdgeInsets.fromLTRB(13, 25, 13, 0),
          child: Text(
            'No late coming records found',
            style: TextStyle(color: AppColors.danger, fontSize: 20),
          ),
        ),
      ),
    );
  }
}
