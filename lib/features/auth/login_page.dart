import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/session/session_store.dart';
import '../../core/theme/app_theme.dart';
import '../../data/api_service.dart';
import '../home/home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({required this.sessionStore, super.key});

  final SessionStore sessionStore;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController(text: 'U2503208');
  final _passwordController = TextEditingController(text: '08032007');
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
    try {
      final username = _usernameController.text.trim();
      final result = await ApiService.login(username, _passwordController.text);
      await widget.sessionStore.signIn(
        accessToken: result['access_token'] as String,
        studentId: username,
      );
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(
          builder: (_) => HomePage(sessionStore: widget.sessionStore),
        ),
        (_) => false,
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(error.toString().replaceFirst('Exception: ', ''))),
      );
      setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: AppColors.primary,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.black,
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
                  horizontal: landscape ? 48 : 16,
                  vertical: 0,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: Column(
                      children: [
                        SizedBox(height: landscape ? 4 : 88),
                        RsetBrandMark(compact: landscape),
                        SizedBox(height: landscape ? 20 : 42),
                        _LoginField(
                          controller: _usernameController,
                          hint: 'Username',
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 20),
                        _LoginField(
                          controller: _passwordController,
                          hint: 'Password',
                          obscureText: true,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _login(),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          height: 58,
                          child: FilledButton(
                            onPressed: _submitting ? null : _login,
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.white,
                              disabledBackgroundColor: Colors.white70,
                              foregroundColor: AppColors.accent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(9),
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
      height: 58,
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        textInputAction: textInputAction,
        onSubmitted: onSubmitted,
        cursorColor: Colors.white,
        style: const TextStyle(
          color: Colors.white,
          fontFamily: 'Roboto',
          fontSize: 20,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
            color: Colors.white,
            fontFamily: 'Roboto',
            fontSize: 20,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.white, width: 1.2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
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
        width: 114 * scale,
        height: 168 * scale,
        child: Image.asset(
          'assets/images/rset_official_logo_vertical.png',
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
