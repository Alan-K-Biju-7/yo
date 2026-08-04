import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/session/session_store.dart';
import '../../core/widgets/screen_shell.dart';
import '../../data/api_service.dart';
import '../../data/reference_data.dart';
import '../../data/websocket_service.dart';

class InternalMarkPage extends StatefulWidget {
  const InternalMarkPage({required this.sessionStore, super.key});

  final SessionStore sessionStore;

  @override
  State<InternalMarkPage> createState() => _InternalMarkPageState();
}

class _InternalMarkPageState extends State<InternalMarkPage> {
  static const _classCodes = ['2026S3CS-C', '2026S2CS-C', '2025S1CS-C'];
  static const _liveExamType = 'Internal Exam 1';

  static const _subjectNames = {
    '102906/PH900A': 'Engineering Physics A',
    '102908/MA100B': 'Calculus and Linear Algebra',
    '102903/CO100F': 'Introduction to Electrical and Electronics Engineering',
    '102908/EN900G': 'English for Engineers',
  };

  static List<String> get _filteredExamTypes {
    // Include all exam types except explicit exclusions. The design requires
    // that only 'Attendance' and 'Project/report from module 6' be excluded.
    return ReferenceData.examTypes.where((type) {
      final lower = type.toLowerCase();
      if (lower == 'attendance') return false;
      if (lower == 'project/report from module 6') return false;
      return true;
    }).toList();
  }

  List<String> get _availableExamTypes {
    final values = _dataByClassAndExam[_classCode]?.keys.toList() ??
        List<String>.from(_filteredExamTypes);
    if (_liveData != null && !values.contains(_liveExamType)) {
      values.insert(0, _liveExamType);
    }
    return values;
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
          _SubjectDetail('102903/CO100F',
              'Introduction to Electrical and Electronics Engineering'),
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
          _SubjectDetail('102903/CO100F',
              'Introduction to Electrical and Electronics Engineering'),
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
          _SubjectDetail('102906/CO100E',
              'Introduction to Electrical and Electronics Engineering'),
          _SubjectDetail('102908/EN900G', 'English for Engineers'),
        ],
      ),
      'Assignment-1/Assignment Test/...': _InternalMarkData(
        marks: [
          _MarkRow('102906/CO100E', '6.5'),
        ],
        subjects: [
          _SubjectDetail('102906/CO100E',
              'Introduction to Electrical and Electronics Engineering'),
        ],
      ),
    },
  };

  String _classCode = _classCodes.first;
  String? _examType;
  _InternalMarkData? _liveData;
  bool _loading = true;
  String? _loadError;
  late final WebSocketService _wsService;

  @override
  void initState() {
    super.initState();
    _wsService = WebSocketService();
    _wsService.onMessageReceived = (message) {
      if (message['type'] == 'marks_updated') _loadMarks();
    };
    _wsService.connect(widget.sessionStore.accessToken!);
    _wsService.subscribe('marks');
    _loadMarks();
  }

  Future<void> _loadMarks() async {
    if (mounted) setState(() => _loading = true);
    try {
      final response = await ApiService.getMarks(
        widget.sessionStore.studentId!,
        _classCode,
        widget.sessionStore.accessToken!,
      );
      final items = (response['marks'] as List<dynamic>? ?? const []);
      final marks = items
          .map((item) => _MarkRow(
                item['subject_code'].toString(),
                item['mark'].toString(),
              ))
          .toList();
      if (!mounted) return;
      setState(() {
        _liveData = marks.isEmpty
            ? null
            : _InternalMarkData(
                marks: marks,
                subjects: marks
                    .map((mark) => _SubjectDetail(
                          mark.subjectCode,
                          _subjectNames[mark.subjectCode] ?? mark.subjectCode,
                        ))
                    .toList(),
              );
        if (_liveData != null) _examType = _liveExamType;
        _loadError = null;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loadError = error.toString().replaceFirst('Exception: ', '');
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _wsService.disconnect();
    super.dispose();
  }

  _InternalMarkData? get _selectedData {
    if (_examType == null) return null;
    if (_examType == _liveExamType && _liveData != null) return _liveData;
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
              _loadMarks();
            },
          ),
          if (_loading) const LinearProgressIndicator(),
          if (_loadError != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child:
                  Text(_loadError!, style: const TextStyle(color: Colors.red)),
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
    return LayoutBuilder(builder: (context, constraints) {
      final double markColumnWidth =
          (constraints.maxWidth * 0.28).clamp(60.0, 140.0);

      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Column(
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Subject Code',
                      style:
                          TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                    ),
                  ),
                  SizedBox(
                      width: markColumnWidth,
                      child: const Text('Mark 1',
                          textAlign: TextAlign.right,
                          style: TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 16))),
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
                    SizedBox(
                        width: markColumnWidth,
                        child: Text(mark.mark,
                            textAlign: TextAlign.right,
                            style: const TextStyle(fontSize: 16))),
                  ],
                ),
                const Divider(
                    height: 18, thickness: 1, color: Color(0xFFE1E1E1)),
              ],
            ],
          ),
        ),
      );
    });
  }
}

class _SubjectDetailsTable extends StatelessWidget {
  const _SubjectDetailsTable({required this.data});

  final _InternalMarkData data;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      const tableWidth = 820.0;
      const codeColumnWidth = 215.0;
      const gap = 28.0;

      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: constraints.maxWidth > tableWidth
              ? constraints.maxWidth
              : tableWidth,
          child: Card(
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              child: Column(
                children: [
                  Row(
                    children: [
                      const SizedBox(
                        width: codeColumnWidth,
                        child: Text(
                          'Subject Code',
                          style: TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 16),
                        ),
                      ),
                      SizedBox(width: gap),
                      const Expanded(
                        child: Text(
                          'Subject Name',
                          style: TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 22, thickness: 1.2),
                  for (final subject in data.subjects) ...[
                    Row(
                      children: [
                        SizedBox(
                          width: codeColumnWidth,
                          child: Text(
                            subject.subjectCode,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                        SizedBox(width: gap),
                        Expanded(
                          child: Text(
                            subject.subjectName,
                            maxLines: 1,
                            overflow: TextOverflow.visible,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                    const Divider(
                        height: 18, thickness: 1, color: Color(0xFFE1E1E1)),
                  ],
                ],
              ),
            ),
          ),
        ),
      );
    });
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
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
                softWrap: true,
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
