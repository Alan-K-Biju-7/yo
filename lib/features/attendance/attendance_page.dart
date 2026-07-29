import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/screen_shell.dart';
import 'data/attendance_reference_repository.dart';

class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  String _classCode = AttendanceReferenceRepository.classCodes.first;

  List<AttendanceRecord> get _currentRows =>
      AttendanceReferenceRepository.recordsByClass[_classCode] ??
      const <AttendanceRecord>[];

  @override
  Widget build(BuildContext context) {
    return ScreenShell(
      title: 'Attendance Details',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: DropdownButtonFormField<String>(
              initialValue: _classCode,
              icon: const Icon(Icons.arrow_drop_down, size: 30),
              style: const TextStyle(color: AppColors.ink, fontSize: 20),
              decoration: InputDecoration(
                labelText: 'Select Class Code',
                labelStyle: const TextStyle(
                  color: AppColors.purple,
                  fontSize: 17,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 18,
                ),
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
              items: [
                for (final code in AttendanceReferenceRepository.classCodes)
                  DropdownMenuItem(value: code, child: Text(code)),
              ],
              onChanged: (value) {
                if (value != null) setState(() => _classCode = value);
              },
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(top: 4),
              child: SizedBox(
                width: 870,
                child: Column(
                  children: [
                    Row(
                      children: [
                        const _TableHeader(width: 100, label: 'Date'),
                        for (var i = 1; i <= 7; i++)
                          _TableHeader(width: 110, label: 'Period $i'),
                      ],
                    ),
                    const SizedBox(height: 4),
                    for (final row in _currentRows) ...[
                      Row(
                        children: [
                          SizedBox(
                            width: 100,
                            height: 41,
                            child: Center(
                              child: Text(
                                row.date,
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                          for (final value in row.periods)
                            _AttendanceCell(value: value),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TableHeader extends StatelessWidget {
  const _TableHeader({required this.width, required this.label});

  final double width;
  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: 36,
      child: Center(
        child: Text(
          label,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class _AttendanceCell extends StatelessWidget {
  const _AttendanceCell({required this.value});

  final String value;

  @override
  Widget build(BuildContext context) {
    final empty = value.isEmpty;
    return Container(
      width: 104,
      height: 41,
      margin: const EdgeInsets.symmetric(horizontal: 3),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: empty ? const Color(0xFFF3F3F3) : const Color(0xFF269BE3),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: empty ? const Color(0xFFD4D4D4) : const Color(0xFF258AC6),
        ),
      ),
      child: Text(
        value,
        style: TextStyle(
          color: empty ? AppColors.ink : Colors.white,
          fontSize: 13,
        ),
      ),
    );
  }
}
