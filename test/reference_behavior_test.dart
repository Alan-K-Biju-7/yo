import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rset_student_app/core/session/session_store.dart';
import 'package:rset_student_app/core/theme/app_theme.dart';
import 'package:rset_student_app/data/reference_data.dart';
import 'package:rset_student_app/features/attendance/attendance_page.dart';
import 'package:rset_student_app/features/attendance/data/attendance_reference_repository.dart';
import 'package:rset_student_app/features/calendar/academic_calendar_page.dart';
import 'package:rset_student_app/features/comments/comments_remarks_page.dart';
import 'package:rset_student_app/features/documents/academic_documents_page.dart';
import 'package:rset_student_app/features/home/home_page.dart';
import 'package:rset_student_app/features/late_arrivals/late_arrivals_page.dart';
import 'package:rset_student_app/features/marks/internal_mark_page.dart';
import 'package:rset_student_app/features/notices/notice_list_page.dart';
import 'package:rset_student_app/features/rewards/reward_details_page.dart';
import 'package:rset_student_app/features/semester/semester_mark_page.dart';
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
    expect(find.text('Latest Notice'), findsOneWidget);
    expect(
      find.text('Holiday on 7 September 2026'),
      findsOneWidget,
    );
    expect(find.text('NEHA MATHEWS -'), findsOneWidget);
    expect(find.text('U2503208'), findsOneWidget);
    expect(find.text('RSET Vision'), findsOneWidget);
    expect(find.text('RSET Mission'), findsOneWidget);

    await tester.tap(find.text('RSET Vision'));
    await tester.pumpAndSettle();
    expect(find.text(ReferenceData.vision), findsOneWidget);

    await tester.tap(find.text('RSET Vision'));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Exam Notices'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Exam Notices'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Upcoming Events'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Upcoming Events'), findsOneWidget);

    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    expect(find.text('My Profile'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back).first);
    await tester.pumpAndSettle();
    expect(find.text('Home'), findsWidgets);
  });

  testWidgets('Comments and Remarks opens a clean blank page', (tester) async {
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

    await tester.scrollUntilVisible(
      find.text('Comments/\nRemarks'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.drag(
      find.byType(CustomScrollView),
      const Offset(0, -100),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Comments/\nRemarks'));
    await tester.pumpAndSettle();

    expect(find.byType(CommentsRemarksPage), findsOneWidget);
    expect(find.text('Comments/Remarks'), findsOneWidget);
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
    expect(
      find.text('Holiday on 7 September 2026'),
      findsOneWidget,
    );
    expect(find.text('03/09/2026'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Introduction to Web Development Using Javascript- An ACE '
          'Domain Skills Orientation Session by the Department of CSE'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(
      find.text('Introduction to Web Development Using Javascript- An ACE '
          'Domain Skills Orientation Session by the Department of CSE'),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.notifications_active), findsWidgets);

    await tester.tap(find.text('2'));
    await tester.pumpAndSettle();
    expect(
      find.text('Call for Proposals for RSET Research SEED Money 2026-27'),
      findsOneWidget,
    );
  });

  testWidgets('Exam Notices keeps its supplied entries and pagination', (
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
      NoticeListPage(
        sessionStore: sessionStore,
        examNotices: true,
        enableRealtime: false,
      ),
    );

    expect(find.text('Exam Notices'), findsOneWidget);
    expect(
      find.text(
        'B.Tech. Second, Fourth, Sixth and Eighth Semesters (2021and 2022 '
        'Admissions) Supplementary Examinations – Registration.',
      ),
      findsOneWidget,
    );
    expect(find.text('20/08/2026'), findsNWidgets(3));
    expect(find.text('1'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(find.byIcon(Icons.notifications_active), findsWidgets);
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

  test('S3 attendance matches the supplied seven-period row', () {
    final records = AttendanceReferenceRepository.recordsByClass['2026S3CS-C']!;

    expect(records, hasLength(1));
    expect(records.single.date, '07/01/2026');
    expect(records.single.periods, const [
      '102802/C0300A',
      '102903/C0300B',
      '102902/C0300D',
      '102903/C0322S',
      '102903/C0322S',
      '102903/C0322S',
      '',
    ]);
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
    expect(find.text('Attendance'), findsOneWidget);
    expect(find.text('Practical Evaluation'), findsOneWidget);
    expect(find.text('Lab Internal Examination'), findsOneWidget);
  });

  testWidgets('S3 Internal Exam 1 marks remain available offline', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final sessionStore = await SessionStore.load();
    await sessionStore.signIn(
      accessToken: 'rset-parent-offline-session',
      studentId: 'U2503208',
    );
    await pumpScreen(tester, InternalMarkPage(sessionStore: sessionStore));

    expect(find.text('102802/CO300A'), findsOneWidget);
    expect(find.text('35'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Environmental Science and Sustainable Engineering'),
      400,
      scrollable: find.byType(Scrollable).first,
    );
    expect(
      find.text('Environmental Science and Sustainable Engineering'),
      findsOneWidget,
    );
  });

  testWidgets('Semester Mark exposes S1 grade details', (tester) async {
    await pumpScreen(tester, const SemesterMarkPage());

    expect(find.text('Semester Mark'), findsOneWidget);
    expect(find.text('S1'), findsOneWidget);
    expect(find.text('Grade Point'), findsOneWidget);
    expect(find.text('90% and above'), findsOneWidget);
    expect(find.text('Malpractice'), findsOneWidget);
  });

  testWidgets('Reward Details is a clean blank page', (tester) async {
    await pumpScreen(tester, const RewardDetailsPage());

    expect(find.text('Reward Details'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('Academic Calendar moves between months', (tester) async {
    SharedPreferences.setMockInitialValues({
      'signed_in': true,
      'access_token': 'test-token',
      'student_id': 'test-student',
    });
    final sessionStore = await SessionStore.load();
    await pumpScreen(tester, AcademicCalendarPage(sessionStore: sessionStore));
    expect(find.text('August 2026'), findsOneWidget);

    final rightArrows = find.byIcon(Icons.chevron_right);
    await tester.tap(rightArrows.first);
    await tester.pumpAndSettle();
    expect(find.text('September 2026'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.chevron_left).first);
    await tester.pumpAndSettle();
    expect(find.text('August 2026'), findsOneWidget);

    await tester.tap(rightArrows.first);
    await tester.pumpAndSettle();
    await tester.tap(rightArrows.first);
    await tester.pumpAndSettle();
    expect(find.text('October 2026'), findsOneWidget);

    await tester.tap(find.text('12'));
    await tester.pumpAndSettle();
    expect(find.text('ESE-Theory'), findsOneWidget);
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
