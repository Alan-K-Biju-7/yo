import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/screen_shell.dart';
import '../../data/reference_data.dart';

class NoticeListPage extends StatefulWidget {
  const NoticeListPage({this.examNotices = false, super.key});

  final bool examNotices;

  @override
  State<NoticeListPage> createState() => _NoticeListPageState();
}

class _NoticeListPageState extends State<NoticeListPage> {
  int _page = 1;

  @override
  Widget build(BuildContext context) {
    final records =
        widget.examNotices ? ReferenceData.examNotices : ReferenceData.notices;
    return ScreenShell(
      title: widget.examNotices ? 'Exam Notices' : 'Notices',
      child: Stack(
        children: [
          ListView.separated(
            key: PageStorageKey<String>(
              widget.examNotices ? 'exam-notices' : 'notices',
            ),
            padding: const EdgeInsets.fromLTRB(15, 26, 15, 95),
            itemCount: records.length,
            separatorBuilder: (context, index) => const SizedBox(height: 19),
            itemBuilder: (context, index) =>
                _NoticeCard(record: records[index]),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: DecoratedBox(
              decoration: const BoxDecoration(color: AppColors.page),
              child: SafeArea(
                top: false,
                child: SizedBox(
                  height: 72,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed:
                            _page == 1 ? null : () => setState(() => _page--),
                        icon: const Icon(Icons.chevron_left, size: 34),
                      ),
                      _PageButton(
                        number: 1,
                        selected: _page == 1,
                        onTap: () => setState(() => _page = 1),
                      ),
                      _PageButton(
                        number: 2,
                        selected: _page == 2,
                        onTap: () => setState(() => _page = 2),
                      ),
                      IconButton(
                        color: AppColors.purple,
                        onPressed:
                            _page == 2 ? null : () => setState(() => _page++),
                        icon: const Icon(Icons.chevron_right, size: 34),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NoticeCard extends StatelessWidget {
  const _NoticeCard({required this.record});

  final NoticeRecord record;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 4,
      shadowColor: Colors.black38,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(17, 14, 17, 14),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    record.title,
                    style: const TextStyle(fontSize: 20, height: 1.35),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    record.date,
                    style: const TextStyle(
                      fontSize: 17,
                      color: Color(0xFF57535A),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            const Icon(
              Icons.notifications_active,
              color: AppColors.primary,
              size: 30,
            ),
          ],
        ),
      ),
    );
  }
}

class _PageButton extends StatelessWidget {
  const _PageButton({
    required this.number,
    required this.selected,
    required this.onTap,
  });

  final int number;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 48,
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF70687A) : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Text(
          '$number',
          style: TextStyle(
            fontSize: 18,
            color: selected ? Colors.white : AppColors.purple,
          ),
        ),
      ),
    );
  }
}
