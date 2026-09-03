import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/screen_shell.dart';

class SemesterMarkPage extends StatefulWidget {
  const SemesterMarkPage({super.key});

  @override
  State<SemesterMarkPage> createState() => _SemesterMarkPageState();
}

class _SemesterMarkPageState extends State<SemesterMarkPage> {
  String _semester = 'S1';

  static const _grades = [
    ('S', '10', '90% and above'),
    ('A+', '9.0', '85% and above but less than 90%'),
    ('A', '8.5', '80% and above but less than 85%'),
    ('B+', '8.0', '75% and above but less than 80%'),
    ('B', '7.5', '70% and above but less than 75%'),
    ('C+', '7.0', '65% and above but less than 70%'),
    ('C', '6.5', '60% and above but less than 65%'),
    ('D', '6.0', '55% and above but less than 60%'),
    ('P', '5.5', '50% and above but less than 55%'),
    ('F', '0', 'Below 50% (CIE+ESE)'),
    ('I', '0', 'Absent'),
    ('M', '0', 'Malpractice'),
    ('FE', '0', 'Failed due to lack of attendance'),
  ];

  @override
  Widget build(BuildContext context) {
    return ScreenShell(
      title: 'Semester Mark',
      child: ListView(
        padding: const EdgeInsets.fromLTRB(14, 16, 14, 28),
        children: [
          DropdownButtonFormField<String>(
            initialValue: _semester,
            isExpanded: true,
            icon: const Icon(Icons.arrow_drop_down, size: 30),
            style: const TextStyle(
              color: AppColors.ink,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
            decoration: InputDecoration(
              labelText: 'Select Semester',
              labelStyle: const TextStyle(
                color: AppColors.purple,
                fontSize: 17,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: AppColors.purple,
                  width: 1.8,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: AppColors.purple,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            items: const [
              DropdownMenuItem(value: 'S1', child: Text('S1')),
            ],
            onChanged: (value) {
              if (value != null) setState(() => _semester = value);
            },
          ),
          const SizedBox(height: 28),
          const _CourseHeaderTable(),
          const SizedBox(height: 16),
          const _GradeTable(grades: _grades),
        ],
      ),
    );
  }
}

class _CourseHeaderTable extends StatelessWidget {
  const _CourseHeaderTable();

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: 760,
        child: ColoredBox(
          color: Color(0xFFECECEC),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 22),
            child: Row(
              children: [
                SizedBox(width: 80, child: _HeaderText('Sl No')),
                SizedBox(width: 210, child: _HeaderText('Course Name')),
                SizedBox(width: 110, child: _HeaderText('Credit')),
                SizedBox(width: 180, child: _HeaderText('Course Code')),
                SizedBox(width: 140, child: _HeaderText('Grade')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GradeTable extends StatelessWidget {
  const _GradeTable({required this.grades});

  final List<(String, String, String)> grades;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: 760,
        child: Column(
          children: [
            const ColoredBox(
              color: Color(0xFFECECEC),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 22, vertical: 21),
                child: Row(
                  children: [
                    SizedBox(width: 110, child: _HeaderText('Grade')),
                    SizedBox(width: 190, child: _HeaderText('Grade Point')),
                    Expanded(child: _HeaderText('Percentage of Total Marks')),
                  ],
                ),
              ),
            ),
            for (final grade in grades)
              Container(
                height: 58,
                padding: const EdgeInsets.symmetric(horizontal: 22),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Color(0xFFD3CDD3)),
                  ),
                ),
                child: Row(
                  children: [
                    SizedBox(width: 110, child: Text(grade.$1)),
                    SizedBox(width: 190, child: Text(grade.$2)),
                    Expanded(child: Text(grade.$3)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _HeaderText extends StatelessWidget {
  const _HeaderText(this.value);

  final String value;

  @override
  Widget build(BuildContext context) {
    return Text(
      value,
      maxLines: 1,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
    );
  }
}
