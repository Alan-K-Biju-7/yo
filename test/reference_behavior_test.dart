import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rset_student_app/core/session/session_store.dart';
import 'package:rset_student_app/core/theme/app_theme.dart';
import 'package:rset_student_app/data/reference_data.dart';
import 'package:rset_student_app/features/attendance/attendance_page.dart';
import 'package:rset_student_app/features/calendar/academic_calendar_page.dart';
import 'package:rset_student_app/features/documents/academic_documents_page.dart';
import 'package:rset_student_app/features/home/home_page.dart';
import 'package:rset_student_app/features/late_arrivals/late_arrivals_page.dart';
import 'package:rset_student_app/features/marks/internal_mark_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> pumpScreen(WidgetTester tester, Widget screen) async {
    await tester.pumpWidget(MaterialApp(theme: AppTheme.light, home: screen));
    await tester.pumpAndSettle();
  }

  testWidgets('Home accordions are exclusive and Profile returns to Home', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({'signed_in': true});
    final sessionStore = await SessionStore.load();
    await pumpScreen(tester, HomePage(sessionStore: sessionStore));

    await tester.tap(find.text('RSET Vision'));
    await tester.pumpAndSettle();
    expect(find.text(ReferenceData.vision), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('RSET Mission'),
      220,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('RSET Mission'));
    await tester.pumpAndSettle();
    expect(find.text(ReferenceData.vision), findsNothing);
    expect(find.text(ReferenceData.mission), findsOneWidget);

    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    expect(find.text('My Profile'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back).first);
    await tester.pumpAndSettle();
    expect(find.text('Home'), findsWidgets);
  });

  testWidgets('Home Notices shortcut opens the supplied notice list', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({'signed_in': true});
    final sessionStore = await SessionStore.load();
    await pumpScreen(tester, HomePage(sessionStore: sessionStore));

    final notices = find.text('Notices');
    await tester.scrollUntilVisible(
      notices,
      260,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.drag(
      find.byType(CustomScrollView),
      const Offset(0, -220),
    );
    await tester.pumpAndSettle();
    await tester.tap(notices);
    await tester.pumpAndSettle();

    expect(find.text('Merit Award Winners'), findsOneWidget);
    expect(find.text('28/07/2026'), findsOneWidget);
  });

  testWidgets('Attendance exposes every supplied class code', (tester) async {
    await pumpScreen(tester, const AttendancePage());

    await tester.tap(find.text('2026S3CS-C'));
    await tester.pumpAndSettle();

    expect(find.text('2026S2CS-C'), findsOneWidget);
    expect(find.text('2025S1CS-C'), findsOneWidget);
  });

  testWidgets('Internal Mark exposes the supplied exam types', (tester) async {
    await pumpScreen(tester, const InternalMarkPage());

    await tester.tap(find.text('Select Exam Type'));
    await tester.pumpAndSettle();

    expect(find.text('Internal Exam 1'), findsOneWidget);
    expect(find.text('Internal Exam 2'), findsOneWidget);
    expect(find.text('Attendance'), findsOneWidget);
  });

  testWidgets('Academic Calendar moves between months', (tester) async {
    await pumpScreen(tester, const AcademicCalendarPage());
    expect(find.text('July 2026'), findsOneWidget);

    final rightArrows = find.byIcon(Icons.chevron_right);
    await tester.tap(rightArrows.first);
    await tester.pumpAndSettle();
    expect(find.text('August 2026'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.chevron_left).first);
    await tester.pumpAndSettle();
    expect(find.text('July 2026'), findsOneWidget);
  });

  testWidgets('Document and late-arrival reference content is present', (
    tester,
  ) async {
    await pumpScreen(tester, const AcademicDocumentsPage());
    expect(find.text('Academic Handbook 2025-26'), findsOneWidget);
    expect(find.byIcon(Icons.picture_as_pdf), findsNWidgets(6));

    await pumpScreen(tester, const LateArrivalsPage());
    expect(find.text('No late coming records found'), findsOneWidget);
    expect(find.byIcon(Icons.refresh), findsOneWidget);
  });
}
