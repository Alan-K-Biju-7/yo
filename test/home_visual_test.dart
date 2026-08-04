import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rset_student_app/core/session/session_store.dart';
import 'package:rset_student_app/core/theme/app_theme.dart';
import 'package:rset_student_app/features/home/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('home screen matches the supplied 360x800 reference layout',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(360, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    SharedPreferences.setMockInitialValues({
      'signed_in': true,
      'access_token': 'visual-test-token',
      'student_id': 'u2503208',
    });
    final sessionStore = await SessionStore.load();

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: HomePage(sessionStore: sessionStore, enableRealtime: false),
      ),
    );
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(HomePage),
      matchesGoldenFile('goldens/home_360x800.png'),
    );
  });
}
