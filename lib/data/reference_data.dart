import 'package:flutter/material.dart';

class NoticeRecord {
  const NoticeRecord(this.title, this.date);

  final String title;
  final String date;
}

class AcademicEvent {
  const AcademicEvent(this.title, this.date);

  final String title;
  final String date;
}

class FeatureItem {
  const FeatureItem(this.label, this.icon);

  final String label;
  final IconData icon;
}

abstract final class ReferenceData {
  static const vision =
      'To evolve into a premier technological and research institution, '
      'moulding eminent professionals with creative minds, innovative ideas '
      'and sound practical skill, and to shape a future where technology works '
      'for the enrichment of mankind.';

  static const mission =
      'To impart state-of-the-art knowledge to individuals in various '
      'technological disciplines and to inculcate in them a high degree of '
      'social consciousness and human values, thereby enabling them to face '
      'the challenges of life with courage and conviction.';

  static const features = [
    FeatureItem('Notices', Icons.mail),
    FeatureItem('Exam Notices', Icons.mail),
    FeatureItem('Internal Mark', Icons.star),
    FeatureItem('Semester', Icons.school),
    FeatureItem('Attendance', Icons.check_circle),
    FeatureItem('Academic\nCalendar', Icons.calendar_month),
    FeatureItem('Late arrivals', Icons.ads_click),
    FeatureItem('Academic/\nSemester', Icons.picture_as_pdf),
    FeatureItem('Comments/\nRemarks', Icons.auto_awesome),
  ];

  static const upcomingEvents = [
    AcademicEvent('Techkshetra 2026', '31/7/2026'),
    AcademicEvent(
      'Open House and\nHonours/Minor Internal\nExamination',
      '8/8/2026',
    ),
  ];

  static const notices = [
    NoticeRecord('Merit Award Winners', '28/07/2026'),
    NoticeRecord(
      'The Future of Work: Building the Digital Workforce with Agentic AI',
      '27/07/2026',
    ),
    NoticeRecord(
      'B.Tech. Second Semester Regular (2025 admission) and Supplementary '
          '(2023 and 2024 admissions) Examinations, April 2026 – Revaluation '
          'results published',
      '25/07/2026',
    ),
    NoticeRecord(
      'Ph.D. Open Defence and Viva-Voce: Ms.Selvy.R (DMA)',
      '25/07/2026',
    ),
    NoticeRecord(
      'Number Ninjas: FIFA Math Bingo & Sudoku Showdown – Winners',
      '25/07/2026',
    ),
    NoticeRecord(
      'Debate Club Executive Committee 2026 -2027',
      '25/07/2026',
    ),
    NoticeRecord(
      'Technical Session for the Final-Year AI&DS Students.',
      '24/07/2026',
    ),
    NoticeRecord(
      'Alumni-Assisted Placement Preparation Series',
      '23/07/2026',
    ),
    NoticeRecord(
      'Blessing Ceremony of the "Wheels with Nature" and "Feel Nature" '
          'Projects at Sanjoe Hostels',
      '23/07/2026',
    ),
    NoticeRecord(
      'Tomorrow (23/07/2026) is a Regular Working Day.',
      '22/07/2026',
    ),
  ];

  static const examNotices = [
    NoticeRecord(
      'B.Tech. Second Semester Regular (2025 admission) and Supplementary '
          '(2023 and 2024 admissions) Examinations, April 2026 – Revaluation '
          'results published',
      '25/07/2026',
    ),
    NoticeRecord(
      'Announcing B.Tech. Second, Fourth and Sixth Semesters (2023 Scheme, '
          '2023/2024/2025 Admissions) Special Supplementary Examinations.',
      '24/07/2026',
    ),
    NoticeRecord(
      'B.Tech. Third Semester Minor (2025 Admission) and Fifth Semester '
          'Honors (2024 Admission) First Internal Examination:',
      '18/07/2026',
    ),
    NoticeRecord(
      'B.Tech. Degree First Internal Examination, July 2026 Seventh Semester '
          '(2023 Admission) – Timetable',
      '13/07/2026',
    ),
    NoticeRecord(
      'B.Tech. Degree First Internal Examination, July 2026 Fifth Semester '
          '(2024 Admission) – Timetable',
      '10/07/2026',
    ),
    NoticeRecord(
      'B.Tech. Degree First Internal Examination, July 2026 Third Semester '
          '(2025 Admission) – Timetable',
      '10/07/2026',
    ),
    NoticeRecord(
      'Publication of the Results of B.Tech. Degree Sixth Semester '
          '(2023 admission) Regular Examination, April 2026.',
      '20/06/2026',
    ),
    NoticeRecord(
      'Publication of the results of B.Tech. Degree Fourth Semester '
          '(2024 admission) Regular Examination, April 2026.',
      '18/06/2026',
    ),
    NoticeRecord(
      'Publication of the results of B.Tech. Degree Second Semester '
          '(2025 admission) Regular Examination, April 2026',
      '12/06/2026',
    ),
  ];

  static const documents = [
    'Anti-Drug\nAffidavit',
    'S1 M.Tech. Academic Calendar\n2025-26 Odd',
    'S3 M.Tech. Academic Calendar\n2025-26 Odd',
    'Academic Calendar B.Tech\n2025-26 Even',
    'Academic Handbook 2025-26',
    'Semester Plan -S2 S4 S6\nS8_2025-26 Even',
  ];

  static const examTypes = [
    'Internal Exam 1',
    'Internal Exam 2',
    'Assignment/ Assignment Test/ S...',
    'Assignment-1/Assignment Test/...',
    'Re-Test 1',
    'Re-Test 2',
    'Attendance',
    'Re-Test1 Marks for Ineligible Stu...',
    'Re-Test2 Marks for Ineligible Stu...',
    'Assignment/Quiz/Course Project',
    'Project/report from module 6',
    'Assignment-2/ Assignment Test/...',
  ];
}
