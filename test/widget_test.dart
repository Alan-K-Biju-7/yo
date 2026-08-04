import 'package:flutter_test/flutter_test.dart';
import 'package:rset_student_app/app.dart';
import 'package:rset_student_app/core/session/session_store.dart';
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
}
