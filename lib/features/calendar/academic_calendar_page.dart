import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/session/session_store.dart';
import '../../core/widgets/screen_shell.dart';
import '../../data/api_service.dart';
import '../../data/websocket_service.dart';

class AcademicCalendarPage extends StatefulWidget {
  const AcademicCalendarPage({required this.sessionStore, super.key});

  final SessionStore sessionStore;

  @override
  State<AcademicCalendarPage> createState() => _AcademicCalendarPageState();
}

class EventRecord {
  final String id;
  final String title;
  final String date;
  final String? description;

  EventRecord({
    required this.id,
    required this.title,
    required this.date,
    this.description,
  });

  factory EventRecord.fromJson(Map<String, dynamic> json) {
    return EventRecord(
      id: json['_id'],
      title: json['title'],
      date: json['date'],
      description: json['description'],
    );
  }
}

class _AcademicCalendarPageState extends State<AcademicCalendarPage> {
  static const _monthNames = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  static const _weekdays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

  DateTime _month = DateTime(2026, 7);
  DateTime _selected = DateTime(2026, 7, 28);
  List<EventRecord> _allEvents = [];
  Set<String> _datesWithEvents = {};
  bool _isLoading = true;
  late WebSocketService _wsService;

  @override
  void initState() {
    super.initState();
    _wsService = WebSocketService();
    _setupWebSocket();
    _loadEvents();
  }

  void _setupWebSocket() {
    _wsService.onMessageReceived = (message) {
      if (message['type'] == 'event_added') {
        // Reload events when new event is added
        _loadEvents();
      }
    };

    _wsService.connect(widget.sessionStore.accessToken!);
    _wsService.subscribe('events');
  }

  Future<void> _loadEvents() async {
    try {
      final eventsList = await ApiService.getAllEvents(
        widget.sessionStore.accessToken!,
      );

      final events =
          eventsList.map((json) => EventRecord.fromJson(json)).toList();

      final dates = <String>{};
      for (final event in events) {
        dates.add(event.date);
      }

      setState(() {
        _allEvents = events;
        _datesWithEvents = dates;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Failed to load events: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _changeMonth(int amount) {
    setState(() => _month = DateTime(_month.year, _month.month + amount));
  }

  List<EventRecord> _getEventsForDate(DateTime date) {
    final dateStr =
        '${(date.month).toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}/${date.year}';
    return _allEvents.where((event) => event.date == dateStr).toList();
  }

  @override
  void dispose() {
    _wsService.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenShell(
      title: 'Academic Calendar',
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(8, 17, 8, 30),
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => _changeMonth(-1),
                  icon: const Icon(Icons.chevron_left, size: 30),
                ),
                Expanded(
                  child: Text(
                    '${_monthNames[_month.month - 1]} ${_month.year}',
                    style: const TextStyle(fontSize: 21),
                  ),
                ),
                OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.ink,
                    side: const BorderSide(color: AppColors.ink),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 13,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                  ),
                  child: const Text('2 weeks', style: TextStyle(fontSize: 17)),
                ),
                IconButton(
                  onPressed: () => _changeMonth(1),
                  icon: const Icon(Icons.chevron_right, size: 30),
                ),
              ],
            ),
            const SizedBox(height: 13),
            Row(
              children: [
                for (final day in _weekdays)
                  Expanded(
                    child: Text(
                      day,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 17,
                        color: Color(0xFF5C575E),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 2),
            _isLoading
                ? const SizedBox(
                    height: 300,
                    child: Center(child: CircularProgressIndicator()),
                  )
                : _MonthGrid(
                    month: _month,
                    selected: _selected,
                    onSelected: (date) => setState(() => _selected = date),
                    datesWithEvents: _datesWithEvents,
                  ),
            const SizedBox(height: 24),
            if (_getEventsForDate(_selected).isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 16, bottom: 12),
                    child: Text(
                      'Events for ${_selected.day}/${_selected.month}/${_selected.year}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  for (final event in _getEventsForDate(_selected))
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                event.title,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (event.description != null &&
                                  event.description!.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    event.description!,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF5C575E),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _MonthGrid extends StatelessWidget {
  const _MonthGrid({
    required this.month,
    required this.selected,
    required this.onSelected,
    required this.datesWithEvents,
  });

  final DateTime month;
  final DateTime selected;
  final ValueChanged<DateTime> onSelected;
  final Set<String> datesWithEvents;

  String _formatDate(DateTime date) {
    return '${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final first = DateTime(month.year, month.month);
    final gridStart = first.subtract(Duration(days: first.weekday % 7));
    final days = List.generate(42, (index) {
      return gridStart.add(Duration(days: index));
    });
    final lastRelevantRow = days.lastIndexWhere(
          (date) => date.month == month.month,
        ) ~/
        7;
    final visibleDays = days.take((lastRelevantRow + 1) * 7).toList();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: visibleDays.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: .86,
      ),
      itemBuilder: (context, index) {
        final date = visibleDays[index];
        final inMonth = date.month == month.month;
        final isSelected = date.year == selected.year &&
            date.month == selected.month &&
            date.day == selected.day;
        final specialBlue = inMonth &&
            (date.weekday == DateTime.sunday ||
                (date.year == 2026 &&
                    date.month == 7 &&
                    {3, 20}.contains(date.day)));
        final hasDot = datesWithEvents.contains(_formatDate(date));

        return InkWell(
          onTap: () => onSelected(date),
          borderRadius: BorderRadius.circular(7),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF438EF5) : null,
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Text(
                  '${date.day}',
                  style: TextStyle(
                    fontSize: 17,
                    color: isSelected
                        ? Colors.white
                        : !inMonth
                            ? const Color(0xFFB3AFB3)
                            : specialBlue
                                ? AppColors.primary
                                : AppColors.ink,
                  ),
                ),
              ),
              SizedBox(
                height: 10,
                child: hasDot && !isSelected
                    ? const Center(
                        child: CircleAvatar(
                          radius: 4,
                          backgroundColor: Color(0xFF252A2D),
                        ),
                      )
                    : null,
              ),
            ],
          ),
        );
      },
    );
  }
}
