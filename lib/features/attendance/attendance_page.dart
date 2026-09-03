import 'package:flutter/material.dart';

import '../../core/session/session_store.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/screen_shell.dart';
import '../../data/api_service.dart';
import '../../data/websocket_service.dart';
import 'data/attendance_reference_repository.dart';

class AttendancePage extends StatefulWidget {
  const AttendancePage({required this.sessionStore, super.key});

  final SessionStore sessionStore;

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class AttendanceRow {
  const AttendanceRow(this.date, this.periods);

  final String date;
  final List<String> periods;
}

class _AttendancePageState extends State<AttendancePage> {
  static const _classCodes = ['2026S3CS-C', '2026S2CS-C', '2025S1CS-C'];

  String _classCode = _classCodes.first;
  List<AttendanceRow> _currentRows = [];
  bool _isLoading = true;
  String? _errorMessage;

  late WebSocketService _wsService;

  @override
  void initState() {
    super.initState();
    _wsService = WebSocketService();
    widget.sessionStore.addListener(_handleSessionUpgrade);
    _setupWebSocket();
    _loadAttendance();
  }

  void _handleSessionUpgrade() {
    final token = widget.sessionStore.accessToken;
    if (token != null && !ApiService.isOfflineToken(token)) {
      _setupWebSocket();
      _loadAttendance();
    }
  }

  void _setupWebSocket() {
    _wsService.onMessageReceived = (message) {
      if (message['type'] == 'attendance_updated') {
        // Reload attendance data when update is received
        _loadAttendance();
      }
    };

    _wsService.connect(widget.sessionStore.accessToken!);
    _wsService.subscribe('attendance');
  }

  Future<void> _loadAttendance() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final attendanceData = await ApiService.getAttendanceByClass(
        _classCode,
        widget.sessionStore.accessToken!,
      );

      final rowsByDate = <String, List<String>>{
        for (final record
            in AttendanceReferenceRepository.recordsByClass[_classCode] ??
                const <AttendanceRecord>[])
          record.date: List<String>.from(record.periods),
      };

      // Keep the supplied reference timetable as the base and overlay live
      // admin changes from the server period-by-period.
      attendanceData.forEach((date, records) {
        final periods = rowsByDate.putIfAbsent(
          date,
          () => <String>['', '', '', '', '', '', ''],
        );

        for (final record in records) {
          final periodIndex = (record['period'] as int) - 1;
          if (periodIndex >= 0 && periodIndex < periods.length) {
            periods[periodIndex] = record['subject_code'].toString();
          }
        }
      });

      final rows = rowsByDate.entries
          .map((entry) => AttendanceRow(entry.key, entry.value))
          .toList();

      // Sort chronologically even though the display format is MM/DD/YYYY.
      rows.sort((a, b) => _dateSortKey(a.date).compareTo(_dateSortKey(b.date)));

      setState(() {
        _currentRows = rows;
        _isLoading = false;
      });
    } catch (e) {
      final referenceRows =
          AttendanceReferenceRepository.recordsByClass[_classCode] ??
              const <AttendanceRecord>[];
      setState(() {
        _currentRows = referenceRows
            .map((record) => AttendanceRow(
                  record.date,
                  List<String>.from(record.periods),
                ))
            .toList();
        _errorMessage = _currentRows.isEmpty
            ? 'Failed to load attendance: ${e.toString()}'
            : null;
        _isLoading = false;
      });
    }
  }

  int _dateSortKey(String value) {
    final parts = value.split('/');
    if (parts.length != 3) return 0;
    final month = int.tryParse(parts[0]) ?? 0;
    final day = int.tryParse(parts[1]) ?? 0;
    final year = int.tryParse(parts[2]) ?? 0;
    return year * 10000 + month * 100 + day;
  }

  @override
  void dispose() {
    widget.sessionStore.removeListener(_handleSessionUpgrade);
    _wsService.disconnect();
    super.dispose();
  }

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
                for (final code in _classCodes)
                  DropdownMenuItem(value: code, child: Text(code)),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => _classCode = value);
                  _loadAttendance();
                }
              },
            ),
          ),
          if (_isLoading)
            const Expanded(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_errorMessage != null)
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error, size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(_errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadAttendance,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else if (_currentRows.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.info, size: 48, color: Colors.blue),
                    const SizedBox(height: 16),
                    const Text('No absence records found'),
                  ],
                ),
              ),
            )
          else
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
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.clip,
      ),
    );
  }
}
