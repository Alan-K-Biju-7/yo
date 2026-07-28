import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rset_student_app/core/session/session_store.dart';
import 'package:rset_student_app/core/theme/app_theme.dart';
import 'package:rset_student_app/features/attendance/attendance_page.dart';
import 'package:rset_student_app/features/auth/login_page.dart';
import 'package:rset_student_app/features/calendar/academic_calendar_page.dart';
import 'package:rset_student_app/features/documents/academic_documents_page.dart';
import 'package:rset_student_app/features/home/home_page.dart';
import 'package:rset_student_app/features/late_arrivals/late_arrivals_page.dart';
import 'package:rset_student_app/features/marks/internal_mark_page.dart';
import 'package:rset_student_app/features/notices/notice_list_page.dart';
import 'package:rset_student_app/features/profile/profile_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  for (final size in const [Size(360, 800), Size(800, 360)]) {
    testWidgets('all supplied screens fit at ${size.width}x${size.height}', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(size);
      addTearDown(() => tester.binding.setSurfaceSize(null));
      SharedPreferences.setMockInitialValues({});
      final sessionStore = await SessionStore.load();

      final screens = <Widget>[
        LoginPage(sessionStore: sessionStore),
        HomePage(sessionStore: sessionStore),
        const ProfilePage(),
        const AttendancePage(),
        const NoticeListPage(),
        const NoticeListPage(examNotices: true),
        const InternalMarkPage(),
        const AcademicCalendarPage(),
        const LateArrivalsPage(),
        const AcademicDocumentsPage(),
      ];

      for (final screen in screens) {
        await tester.pumpWidget(
          MaterialApp(theme: AppTheme.light, home: screen),
        );
        await tester.pump();
        expect(
          tester.takeException(),
          isNull,
          reason: '${screen.runtimeType} overflowed at $size',
        );
      }
    });
  }
}
