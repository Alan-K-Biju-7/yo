import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/screen_shell.dart';

class AcademicCalendarPage extends StatefulWidget {
  const AcademicCalendarPage({super.key});

  @override
  State<AcademicCalendarPage> createState() => _AcademicCalendarPageState();
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

  void _changeMonth(int amount) {
    setState(() => _month = DateTime(_month.year, _month.month + amount));
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
            _MonthGrid(
              month: _month,
              selected: _selected,
              onSelected: (date) => setState(() => _selected = date),
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
  });

  final DateTime month;
  final DateTime selected;
  final ValueChanged<DateTime> onSelected;

  static const _dotDates = {
    '2026-06-29',
    '2026-07-03',
    '2026-07-20',
    '2026-07-21',
    '2026-07-22',
    '2026-07-23',
    '2026-07-24',
    '2026-07-25',
    '2026-07-31',
  };

  String _key(DateTime date) => '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

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
        final hasDot = _dotDates.contains(_key(date));

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
