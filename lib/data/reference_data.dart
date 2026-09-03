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
    AcademicEvent('Semester ends for S3/S5/\nS7', '30/9/2026'),
    AcademicEvent('ESE-Theory', '12/10/2026'),
    AcademicEvent('ESE-Theory', '13/10/2026'),
  ];

  static const notices = [
    NoticeRecord('Holiday on 7 September 2026', '03/09/2026'),
    NoticeRecord('Confluence 3.0 Day 2', '31/08/2026'),
    NoticeRecord(
      'Silver Jubilee Celebrations - Instructions to Students',
      '31/08/2026',
    ),
    NoticeRecord(
      'RSET Front Gate will be Blocked from 11.00 am to 2.00pm on 31st '
          'August 2026',
      '30/08/2026',
    ),
    NoticeRecord(
      'Discipline Committee - Silver Jubilee Celebrations & Inauguration '
          'of Confluence 3.0',
      '30/08/2026',
    ),
    NoticeRecord(
      'Minute to Minute Programme of Silver Jubilee Celebrations Meeting & '
          'Inauguration of Confluence 3.0',
      '29/08/2026',
    ),
    NoticeRecord(
      'Onam Holidays and Resumption of Classes on 31/08/26',
      '21/08/2026',
    ),
    NoticeRecord('ASME Industry Interaction Session', '20/08/2026'),
    NoticeRecord(
      'Introduction to Web Development Using Javascript- An ACE Domain '
          'Skills Orientation Session by the Department of CSE',
      '19/08/2026',
    ),
    NoticeRecord(
      'Call for Proposals for RSET Research SEED Money 2026-27',
      '30/07/2026',
    ),
    NoticeRecord(
      'RSET Film Society Presents "LATVERIA – MCU Quiz"',
      '30/07/2026',
    ),
    NoticeRecord(
      'Inauguration of SOUL - The social Service Cell of the Department of '
          'Electronics And Communication Engineering',
      '30/07/2026',
    ),
    NoticeRecord(
      'Pitch Perfect With AI',
      '30/07/2026',
    ),
    NoticeRecord(
      'Techkshetra 2026 – Logo Launch',
      '30/07/2026',
    ),
    NoticeRecord('Merit Award Winners', '28/07/2026'),
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
      'B.Tech. Second, Fourth, Sixth and Eighth Semesters (2021and 2022 '
          'Admissions) Supplementary Examinations – Registration.',
      '20/08/2026',
    ),
    NoticeRecord(
      'B.Tech. Second, Fourth, Sixth and Eighth Semesters (2020 Admission) '
          'Supplementary Examinations – Registration.',
      '20/08/2026',
    ),
    NoticeRecord(
      'B.Tech. First, Second, Third, Fourth, Fifth and Sixth Semesters '
          '(2023, 2024, 2025 Admissions) Supplementary Examinations – '
          'Registration.',
      '20/08/2026',
    ),
    NoticeRecord('Special Exam Notification', '14/08/2026'),
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
    'Practical Evaluation',
    'Lab Internal Examination',
    'Lab work/ Record/Viva-voce',
    'Classwork/ Assessment/Viva Vo...',
    'Lab Attendance',
    'Re-Test1 Marks for Ineligible Stu...',
    'Re-Test2 Marks for Ineligible Stu...',
    'Assignment/Quiz/Course Project',
    'Project/report from module 6',
    'Assignment-2/ Assignment Test/...',
  ];
}
