import 'package:flutter/material.dart';

import 'core/session/session_store.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/login_page.dart';
import 'features/home/home_page.dart';

class RsetStudentApp extends StatelessWidget {
  const RsetStudentApp({required this.sessionStore, super.key});

  final SessionStore sessionStore;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'RSET',
      theme: AppTheme.light,
      home: sessionStore.isSignedIn
          ? HomePage(sessionStore: sessionStore)
          : LoginPage(sessionStore: sessionStore),
    );
  }
}
