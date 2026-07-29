import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/screen_shell.dart';
import '../../data/reference_data.dart';

class InternalMarkPage extends StatefulWidget {
  const InternalMarkPage({super.key});

  @override
  State<InternalMarkPage> createState() => _InternalMarkPageState();
}

class _InternalMarkPageState extends State<InternalMarkPage> {
  static const _classCodes = ['2026S3CS-C', '2026S2CS-C', '2025S1CS-C'];

  static List<String> get _filteredExamTypes {
    return ReferenceData.examTypes.where((type) {
      final lower = type.toLowerCase();
      if (lower.contains('re-test') || lower.contains('attendance')) {
        return false;
      }
      if (lower.contains('module 6') || lower.contains('course project')) {
        return false;
      }
      return true;
    }).toList();
  }

  List<String> get _availableExamTypes {
    return _dataByClassAndExam[_classCode]?.keys.toList() ?? _filteredExamTypes;
  }

  static const _dataByClassAndExam = {
    '2026S2CS-C': {
      'Internal Exam 1': _InternalMarkData(
        marks: [
          _MarkRow('102923/CS200A', '22'),
          _MarkRow('102921/MA200B', '24.5'),
          _MarkRow('102922/PH200D', '26'),
          _MarkRow('102924/EE200C', '30.5'),
        ],
        subjects: [
          _SubjectDetail('102923/CS200A', 'Data Structures and Algorithms'),
          _SubjectDetail('102921/MA200B', 'Discrete Mathematics'),
          _SubjectDetail('102922/PH200D', 'Physics for Computer Science'),
          _SubjectDetail('102924/EE200C', 'Circuit Theory'),
        ],
      ),
      'Internal Exam 2': _InternalMarkData(
        marks: [
          _MarkRow('102923/CS200A', '28'),
          _MarkRow('102921/MA200B', '23.5'),
          _MarkRow('102922/PH200D', '29'),
          _MarkRow('102924/EE200C', '31.5'),
        ],
        subjects: [
          _SubjectDetail('102923/CS200A', 'Data Structures and Algorithms'),
          _SubjectDetail('102921/MA200B', 'Discrete Mathematics'),
          _SubjectDetail('102922/PH200D', 'Physics for Computer Science'),
          _SubjectDetail('102924/EE200C', 'Circuit Theory'),
        ],
      ),
      'Assignment/ Assignment Test/ S...': _InternalMarkData(
        marks: [
          _MarkRow('102923/CS200A', '12'),
          _MarkRow('102921/MA200B', '13'),
          _MarkRow('102924/EE200C', '14'),
        ],
        subjects: [
          _SubjectDetail('102923/CS200A', 'Data Structures and Algorithms'),
          _SubjectDetail('102921/MA200B', 'Discrete Mathematics'),
          _SubjectDetail('102924/EE200C', 'Circuit Theory'),
        ],
      ),
      'Assignment-1/Assignment Test/...': _InternalMarkData(
        marks: [
          _MarkRow('102922/PH200D', '8.5'),
        ],
        subjects: [
          _SubjectDetail('102922/PH200D', 'Physics for Computer Science'),
        ],
      ),
    },
    '2025S1CS-C': {
      'Internal Exam 1': _InternalMarkData(
        marks: [
          _MarkRow('102906/PH900A', '34'),
          _MarkRow('102908/MA100B', '35'),
          _MarkRow('102903/CO100F', '47.5'),
          _MarkRow('102908/EN900G', '39'),
        ],
        subjects: [
          _SubjectDetail('102906/PH900A', 'Engineering Physics A'),
          _SubjectDetail('102908/MA100B', 'Calculus and Linear Algebra'),
          _SubjectDetail('102903/CO100F', 'Introduction to Electrical and Electronics Engineering'),
          _SubjectDetail('102908/EN900G', 'English for Engineers'),
        ],
      ),
      'Internal Exam 2': _InternalMarkData(
        marks: [
          _MarkRow('102906/PH900A', '41'),
          _MarkRow('102908/MA100B', '35.5'),
          _MarkRow('102903/CO100F', '38.5'),
          _MarkRow('102908/EN900G', '37.5'),
        ],
        subjects: [
          _SubjectDetail('102906/PH900A', 'Engineering Physics A'),
          _SubjectDetail('102908/MA100B', 'Calculus and Linear Algebra'),
          _SubjectDetail('102903/CO100F', 'Introduction to Electrical and Electronics Engineering'),
          _SubjectDetail('102908/EN900G', 'English for Engineers'),
        ],
      ),
      'Assignment/ Assignment Test/ S...': _InternalMarkData(
        marks: [
          _MarkRow('102908/MA100B', '15'),
          _MarkRow('102906/CO100E', '7'),
          _MarkRow('102908/EN900G', '26.5'),
        ],
        subjects: [
          _SubjectDetail('102908/MA100B', 'Calculus and Linear Algebra'),
          _SubjectDetail('102906/CO100E', 'Introduction to Electrical and Electronics Engineering'),
          _SubjectDetail('102908/EN900G', 'English for Engineers'),
        ],
      ),
      'Assignment-1/Assignment Test/...': _InternalMarkData(
        marks: [
          _MarkRow('102906/CO100E', '6.5'),
        ],
        subjects: [
          _SubjectDetail('102906/CO100E', 'Introduction to Electrical and Electronics Engineering'),
        ],
      ),
    },
  };

  String _classCode = _classCodes.first;
  String? _examType;

  _InternalMarkData? get _selectedData {
    if (_examType == null) return null;
    return _dataByClassAndExam[_classCode]?[_examType!];
  }

  @override
  Widget build(BuildContext context) {
    final selectedData = _selectedData;

    return ScreenShell(
      title: 'Internal Mark',
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          _OutlinedDropdown(
            label: 'Select Class Code',
            value: _classCode,
            options: _classCodes,
            onChanged: (value) {
              setState(() {
                _classCode = value;
                _examType = null;
              });
            },
          ),
          const SizedBox(height: 17),
          _OutlinedDropdown(
            label: 'Select Exam Type',
            value: _examType,
            options: _availableExamTypes,
            onChanged: (value) => setState(() => _examType = value),
          ),
          if (selectedData != null) ...[
            const SizedBox(height: 22),
            const _SectionHeader('Marks Table'),
            const SizedBox(height: 16),
            _MarksTable(data: selectedData),
            const SizedBox(height: 28),
            const _SectionHeader('Subject Details'),
            const SizedBox(height: 16),
            _SubjectDetailsTable(data: selectedData),
          ],
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class _MarkRow {
  const _MarkRow(this.subjectCode, this.mark);

  final String subjectCode;
  final String mark;
}

class _SubjectDetail {
  const _SubjectDetail(this.subjectCode, this.subjectName);

  final String subjectCode;
  final String subjectName;
}

class _InternalMarkData {
  const _InternalMarkData({required this.marks, required this.subjects});

  final List<_MarkRow> marks;
  final List<_SubjectDetail> subjects;
}

class _MarksTable extends StatelessWidget {
  const _MarksTable({required this.data});

  final _InternalMarkData data;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Column(
          children: [
            Row(
              children: const [
                Expanded(
                  child: Text(
                    'Subject Code',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                ),
                SizedBox(width: 80),
                Text(
                  'Mark 1',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                ),
              ],
            ),
            const Divider(height: 22, thickness: 1.2),
            for (final mark in data.marks) ...[
              Row(
                children: [
                  Expanded(
                    child: Text(
                      mark.subjectCode,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  SizedBox(width: 80, child: Text(mark.mark, textAlign: TextAlign.right, style: const TextStyle(fontSize: 16))),
                ],
              ),
              const Divider(height: 18, thickness: 1, color: Color(0xFFE1E1E1)),
            ],
          ],
        ),
      ),
    );
  }
}

class _SubjectDetailsTable extends StatelessWidget {
  const _SubjectDetailsTable({required this.data});

  final _InternalMarkData data;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Column(
          children: [
            Row(
              children: const [
                Expanded(
                  child: Text(
                    'Subject Code',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                ),
                SizedBox(width: 20),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Subject Name',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                ),
              ],
            ),
            const Divider(height: 22, thickness: 1.2),
            for (final subject in data.subjects) ...[
              Row(
                children: [
                  Expanded(
                    child: Text(
                      subject.subjectCode,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    flex: 2,
                    child: Text(
                      subject.subjectName,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
              const Divider(height: 18, thickness: 1, color: Color(0xFFE1E1E1)),
            ],
          ],
        ),
      ),
    );
  }
}

class _OutlinedDropdown extends StatelessWidget {
  const _OutlinedDropdown({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final String label;
  final String? value;
  final List<String> options;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      isExpanded: true,
      menuMaxHeight: MediaQuery.sizeOf(context).height * .78,
      icon: const Icon(Icons.arrow_drop_down, size: 30),
      style: const TextStyle(
        color: AppColors.ink,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.purple, fontSize: 17),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: value == null ? AppColors.purple : const Color(0xFF6F6A70),
            width: value == null ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.purple, width: 2),
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      selectedItemBuilder: (context) => [
        for (final option in options)
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              option,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ],
      items: [
        for (final option in options)
          DropdownMenuItem<String>(
            value: option,
            child: SizedBox(
              width: double.infinity,
              child: Text(
                option,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
      ],
      onChanged: (selected) {
        if (selected != null) onChanged(selected);
      },
    );
  }
}
