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

  const EventRecord({
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

const _referenceEvents = <EventRecord>[
  EventRecord(id: 'ref-0731', title: 'Techkshetra 2026', date: '07/31/2026'),
  EventRecord(
      id: 'ref-0808',
      title: 'Open House and Honours/Minor Internal Examination',
      date: '08/08/2026'),
  EventRecord(
      id: 'ref-0812',
      title: 'Karkkidaka Vavu',
      date: '08/12/2026',
      description: 'Holiday'),
  EventRecord(
      id: 'ref-0815',
      title: 'Independence Day',
      date: '08/15/2026',
      description: 'Holiday'),
  EventRecord(id: 'ref-0821', title: 'Onam Celebration', date: '08/21/2026'),
  EventRecord(
      id: 'ref-0824',
      title: 'Onam Holidays',
      date: '08/24/2026',
      description: 'Holiday'),
  EventRecord(
      id: 'ref-0825',
      title: 'ഒന്നാം ഓണം',
      date: '08/25/2026',
      description: 'Holiday'),
  EventRecord(
      id: 'ref-0826',
      title: 'തിരുവോണം',
      date: '08/26/2026',
      description: 'Holiday'),
  EventRecord(
      id: 'ref-0827',
      title: 'മൂന്നാം ഓണം',
      date: '08/27/2026',
      description: 'Holiday'),
  EventRecord(
      id: 'ref-0828',
      title: 'ശ്രീ നാരായണ ഗുരു ജയന്തി',
      date: '08/28/2026',
      description: 'Holiday'),
  EventRecord(
      id: 'ref-0829',
      title: 'Onam Holidays',
      date: '08/29/2026',
      description: 'Holiday'),
  EventRecord(id: 'ref-0902', title: 'Confluence 3.0', date: '09/02/2026'),
  EventRecord(
      id: 'ref-0904',
      title: 'Sri Krishna Jayanthi',
      date: '09/04/2026',
      description: 'Holiday'),
  EventRecord(
      id: 'ref-0921',
      title: 'Sree Narayanaguru Samadhi',
      date: '09/21/2026',
      description: 'Holiday'),
  EventRecord(
      id: 'ref-0930', title: 'Semester ends for S3/S5/S7', date: '09/30/2026'),
  EventRecord(
      id: 'ref-1002',
      title: 'Gandhi Jayanthi',
      date: '10/02/2026',
      description: 'Holiday'),
  EventRecord(id: 'ref-1012', title: 'ESE-Theory', date: '10/12/2026'),
  EventRecord(
      id: 'ref-1020',
      title: 'Maha Navami',
      date: '10/20/2026',
      description: 'Holiday'),
  EventRecord(
      id: 'ref-1021',
      title: 'Vijaya Dasami',
      date: '10/21/2026',
      description: 'Holiday'),
];

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

  DateTime _month = DateTime(2026, 8);
  DateTime _selected = DateTime(2026, 7, 31);
  List<EventRecord> _allEvents = List.of(_referenceEvents);
  Set<String> _datesWithEvents =
      _referenceEvents.map((event) => event.date).toSet();
  bool _isLoading = true;
  late WebSocketService _wsService;

  @override
  void initState() {
    super.initState();
    _wsService = WebSocketService();
    widget.sessionStore.addListener(_handleSessionUpgrade);
    _setupWebSocket();
    _loadEvents();
  }

  void _handleSessionUpgrade() {
    final token = widget.sessionStore.accessToken;
    if (token != null && !ApiService.isOfflineToken(token)) {
      _setupWebSocket();
      _loadEvents();
    }
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

      final remoteEvents =
          eventsList.map((json) => EventRecord.fromJson(json)).toList();
      final events = <EventRecord>[..._referenceEvents];
      for (final remote in remoteEvents) {
        final duplicate = events.any(
          (event) => event.date == remote.date && event.title == remote.title,
        );
        if (!duplicate) events.add(remote);
      }

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
    widget.sessionStore.removeListener(_handleSessionUpgrade);
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
                    today: DateTime.now(),
                    onSelected: (date) => setState(() => _selected = date),
                    datesWithEvents: _datesWithEvents,
                  ),
            const SizedBox(height: 24),
            if (_getEventsForDate(_selected).isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final event in _getEventsForDate(_selected))
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        padding: const EdgeInsets.fromLTRB(20, 20, 18, 20),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF8FF),
                          border:
                              Border.all(color: AppColors.primary, width: 2),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x33000000),
                              blurRadius: 6,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    event.title,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  if (event.description != null &&
                                      event.description!.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(
                                        event.description!,
                                        style: const TextStyle(
                                          fontSize: 17,
                                          fontStyle: FontStyle.italic,
                                          color: Color(0xFF438EF5),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.calendar_month_outlined,
                              color: AppColors.primary,
                              size: 30,
                            ),
                          ],
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
    required this.today,
    required this.onSelected,
    required this.datesWithEvents,
  });

  final DateTime month;
  final DateTime selected;
  final DateTime today;
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
        final isToday = date.year == today.year &&
            date.month == today.month &&
            date.day == today.day;
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
                  color: isSelected
                      ? const Color(0xFF1455AD)
                      : isToday
                          ? const Color(0xFF438EF5)
                          : null,
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Text(
                  '${date.day}',
                  style: TextStyle(
                    fontSize: 17,
                    color: isSelected || isToday
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
