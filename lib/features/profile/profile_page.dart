import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/screen_shell.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenShell(
      title: 'My Profile',
      child: SingleChildScrollView(
        key: const PageStorageKey<String>('profile-scroll'),
        padding: const EdgeInsets.fromLTRB(20, 17, 20, 34),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: AppColors.lavender,
            ),
            const SizedBox(height: 18),
            const Text(
              'NEHA MATHEWS',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            const Text(
              'U2503208',
              style: TextStyle(fontSize: 21, color: AppColors.muted),
            ),
            const SizedBox(height: 20),
            const _AcademicSummaryCard(),
            const SizedBox(height: 21),
            const Text(
              'About',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            const _AboutRow(label: 'Date of Birth', value: '03/08/2007'),
            const SizedBox(height: 9),
            const _AboutRow(label: 'Gender', value: ''),
            const SizedBox(height: 26),
            const FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                'Current / Ongoing Courses',
                style: TextStyle(fontSize: 23, fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(height: 9),
            const _CourseCard(),
          ],
        ),
      ),
    );
  }
}

class _AcademicSummaryCard extends StatelessWidget {
  const _AcademicSummaryCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 6,
      shadowColor: Colors.black38,
      color: AppColors.infoCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
      child: const Padding(
        padding: EdgeInsets.fromLTRB(16, 20, 16, 22),
        child: Column(
          children: [
            _SummaryRow(label: 'Register No:', value: 'RET25CS212'),
            SizedBox(height: 15),
            _SummaryRow(
              label: 'DEPARTMENT:',
              value: 'Computer Science\nEngineering',
            ),
            SizedBox(height: 14),
            _SummaryRow(label: 'SEMESTER:', value: 'S3'),
            SizedBox(height: 14),
            _SummaryRow(label: 'ACADEMIC YEAR:', value: '2025-2029'),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 17, height: 1.3),
          ),
        ),
      ],
    );
  }
}

class _AboutRow extends StatelessWidget {
  const _AboutRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Wrap(
        spacing: 4,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),
          Text(value, style: const TextStyle(fontSize: 17)),
        ],
      ),
    );
  }
}

class _CourseCard extends StatelessWidget {
  const _CourseCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 5,
      shadowColor: Colors.black38,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 24,
                  backgroundColor: Color(0xFF86CFF7),
                  child: Icon(
                    Icons.school,
                    color: AppColors.primary,
                    size: 31,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'B.Tech.',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 23,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 21),
            const Text(
              'Computer Science Engineering',
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 2),
            const Text(
              'Department of Engineering',
              style: TextStyle(fontSize: 17, color: AppColors.muted),
            ),
            const SizedBox(height: 18),
            const Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: AppColors.muted),
                SizedBox(width: 6),
                Text(
                  '2025-2029',
                  style: TextStyle(fontSize: 17, color: AppColors.muted),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              '2029 Passout Batch | RET25CS212',
              style: TextStyle(fontSize: 16, color: AppColors.muted),
            ),
          ],
        ),
      ),
    );
  }
}
