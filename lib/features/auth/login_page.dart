import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/session/session_store.dart';
import '../../core/theme/app_theme.dart';
import '../home/home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({required this.sessionStore, super.key});

  final SessionStore sessionStore;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_submitting) return;
    if (_usernameController.text.trim().isEmpty ||
        _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter username and password')),
      );
      return;
    }

    setState(() => _submitting = true);
    await widget.sessionStore.signIn();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(
        builder: (_) => HomePage(sessionStore: widget.sessionStore),
      ),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: AppColors.primary,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: AppColors.primary,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: AppColors.primary,
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final landscape = constraints.maxWidth > constraints.maxHeight;
              return SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: landscape ? 48 : 18,
                  vertical: landscape ? 20 : 28,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: Column(
                      children: [
                        SizedBox(height: landscape ? 4 : 42),
                        RsetBrandMark(compact: landscape),
                        SizedBox(height: landscape ? 24 : 42),
                        _LoginField(
                          controller: _usernameController,
                          hint: 'Username',
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 22),
                        _LoginField(
                          controller: _passwordController,
                          hint: 'Password',
                          obscureText: true,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _login(),
                        ),
                        const SizedBox(height: 23),
                        SizedBox(
                          width: double.infinity,
                          height: 68,
                          child: FilledButton(
                            onPressed: _submitting ? null : _login,
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.white,
                              disabledBackgroundColor: Colors.white70,
                              foregroundColor: AppColors.accent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: _submitting
                                ? const SizedBox.square(
                                    dimension: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : const Text(
                                    'Login',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _LoginField extends StatelessWidget {
  const _LoginField({
    required this.controller,
    required this.hint,
    required this.textInputAction,
    this.obscureText = false,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String hint;
  final TextInputAction textInputAction;
  final bool obscureText;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 68,
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        textInputAction: textInputAction,
        onSubmitted: onSubmitted,
        cursorColor: Colors.white,
        style: const TextStyle(
          color: Colors.white,
          fontFamily: 'Roboto',
          fontSize: 22,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
            color: Colors.white,
            fontFamily: 'Roboto',
            fontSize: 22,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.white, width: 1.2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.white, width: 1.7),
          ),
        ),
      ),
    );
  }
}

class RsetBrandMark extends StatelessWidget {
  const RsetBrandMark({this.compact = false, super.key});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final scale = compact ? .72 : 1.0;
    return Semantics(
      label: 'RSET, Rajagiri School of Engineering and Technology',
      child: SizedBox(
        width: 170 * scale,
        height: 210 * scale,
        child: FittedBox(
          fit: BoxFit.contain,
          child: const SizedBox(
            width: 170,
            height: 210,
            child: Column(
              children: [
                _OfficialLogoCrop(
                  width: 105,
                  height: 105,
                  imageWidth: 249,
                  imageHeight: 141,
                  alignment: Alignment.centerLeft,
                ),
                SizedBox(height: 8),
                _OfficialLogoCrop(
                  width: 150,
                  height: 71,
                  imageWidth: 258,
                  imageHeight: 146,
                  alignment: Alignment.centerRight,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OfficialLogoCrop extends StatelessWidget {
  const _OfficialLogoCrop({
    required this.width,
    required this.height,
    required this.imageWidth,
    required this.imageHeight,
    required this.alignment,
  });

  final double width;
  final double height;
  final double imageWidth;
  final double imageHeight;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: SizedBox(
        width: width,
        height: height,
        child: OverflowBox(
          alignment: alignment,
          minWidth: imageWidth,
          maxWidth: imageWidth,
          minHeight: imageHeight,
          maxHeight: imageHeight,
          child: Image.asset(
            'assets/images/rset_official_logo.png',
            width: imageWidth,
            height: imageHeight,
            fit: BoxFit.contain,
            color: Colors.white,
            colorBlendMode: BlendMode.srcIn,
          ),
        ),
      ),
    );
  }
}
