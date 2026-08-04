import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rset_student_app/core/session/session_store.dart';
import 'package:rset_student_app/core/theme/app_theme.dart';
import 'package:rset_student_app/features/auth/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('login screen matches the supplied 360x800 reference layout',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(360, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    SharedPreferences.setMockInitialValues({});
    final sessionStore = await SessionStore.load();

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: LoginPage(sessionStore: sessionStore),
      ),
    );
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(LoginPage),
      matchesGoldenFile('goldens/login_360x800.png'),
    );
  });
}
