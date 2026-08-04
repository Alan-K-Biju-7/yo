import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rset_student_app/core/session/session_store.dart';
import 'package:rset_student_app/core/theme/app_theme.dart';
import 'package:rset_student_app/features/attendance/attendance_page.dart';
import 'package:rset_student_app/features/calendar/academic_calendar_page.dart';
import 'package:rset_student_app/features/documents/academic_documents_page.dart';
import 'package:rset_student_app/features/home/home_page.dart';
import 'package:rset_student_app/features/late_arrivals/late_arrivals_page.dart';
import 'package:rset_student_app/features/marks/internal_mark_page.dart';
import 'package:rset_student_app/features/notices/notice_list_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> pumpScreen(WidgetTester tester, Widget screen) async {
    await tester.pumpWidget(MaterialApp(theme: AppTheme.light, home: screen));
    await tester.pumpAndSettle();
  }

  testWidgets('Home reference content and Profile returns to Home', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'signed_in': true,
      'access_token': 'test-token',
      'student_id': 'test-student',
    });
    final sessionStore = await SessionStore.load();
    await pumpScreen(
      tester,
      HomePage(sessionStore: sessionStore, enableRealtime: false),
    );

    expect(find.text('Latest Exam Notice'), findsOneWidget);
    expect(find.text('Exam Notices'), findsOneWidget);
    expect(find.text('Upcoming Events'), findsOneWidget);

    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    expect(find.text('My Profile'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back).first);
    await tester.pumpAndSettle();
    expect(find.text('Home'), findsWidgets);
  });

  testWidgets('Notice list accepts an authenticated session', (tester) async {
    SharedPreferences.setMockInitialValues({
      'signed_in': true,
      'access_token': 'test-token',
      'student_id': 'test-student',
    });
    final sessionStore = await SessionStore.load();
    await pumpScreen(
      tester,
      NoticeListPage(
        sessionStore: sessionStore,
        enableRealtime: false,
      ),
    );

    expect(find.byType(NoticeListPage), findsOneWidget);
    expect(find.text('Notices'), findsOneWidget);
  });

  testWidgets('Attendance exposes every supplied class code', (tester) async {
    SharedPreferences.setMockInitialValues({
      'signed_in': true,
      'access_token': 'test-token',
      'student_id': 'test-student',
    });
    final sessionStore = await SessionStore.load();
    await pumpScreen(tester, AttendancePage(sessionStore: sessionStore));

    await tester.tap(find.text('2026S3CS-C'));
    await tester.pumpAndSettle();

    expect(find.text('2026S2CS-C'), findsOneWidget);
    expect(find.text('2025S1CS-C'), findsOneWidget);
  });

  testWidgets('Internal Mark exposes the supplied exam types', (tester) async {
    SharedPreferences.setMockInitialValues({
      'signed_in': true,
      'access_token': 'test-token',
      'student_id': 'test-student',
    });
    final sessionStore = await SessionStore.load();
    await pumpScreen(tester, InternalMarkPage(sessionStore: sessionStore));

    await tester.tap(find.text('Select Exam Type'));
    await tester.pumpAndSettle();

    expect(find.text('Internal Exam 1'), findsOneWidget);
    expect(find.text('Internal Exam 2'), findsOneWidget);
    expect(find.text('Assignment/ Assignment Test/ S...'), findsOneWidget);
    expect(find.text('Assignment-1/Assignment Test/...'), findsOneWidget);
    expect(find.text('Re-Test 1'), findsOneWidget);
    expect(find.text('Re-Test 2'), findsOneWidget);
    expect(find.text('Attendance'), findsNothing);
  });

  testWidgets('Academic Calendar moves between months', (tester) async {
    SharedPreferences.setMockInitialValues({
      'signed_in': true,
      'access_token': 'test-token',
      'student_id': 'test-student',
    });
    final sessionStore = await SessionStore.load();
    await pumpScreen(tester, AcademicCalendarPage(sessionStore: sessionStore));
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
