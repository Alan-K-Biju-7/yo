import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rset_student_app/app.dart';
import 'package:rset_student_app/core/session/session_store.dart';
import 'package:rset_student_app/data/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('login persists until logout', (tester) async {
    final sessionStore = await SessionStore.load();
    await tester.pumpWidget(RsetStudentApp(sessionStore: sessionStore));

    expect(find.text('Username'), findsOneWidget);
    await sessionStore.signIn(
      accessToken: 'test-token',
      studentId: 'student',
    );
    final restoredSession = await SessionStore.load();
    await tester.pumpWidget(RsetStudentApp(sessionStore: restoredSession));
    await tester.pump();

    expect(find.text('Home'), findsWidgets);
    expect(restoredSession.isSignedIn, isTrue);

    await tester.tap(find.byTooltip('Logout'));
    await tester.pumpAndSettle();

    expect(find.text('Username'), findsOneWidget);
    expect((await SessionStore.load()).isSignedIn, isFalse);
  });

  testWidgets('approved account signs in locally without a server wait', (
    tester,
  ) async {
    final sessionStore = await SessionStore.load();
    await tester.pumpWidget(RsetStudentApp(sessionStore: sessionStore));

    final fields = find.byType(EditableText);
    await tester.enterText(fields.at(0), 'U2503208');
    await tester.enterText(fields.at(1), '08032007');
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsWidgets);
    expect(sessionStore.accessToken, ApiService.offlineAccessToken);
    expect(find.textContaining('TimeoutException'), findsNothing);
    await sessionStore.signOut();
  });
}
