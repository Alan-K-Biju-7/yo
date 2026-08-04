import 'package:flutter/material.dart';

import '../../core/session/session_store.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/reference_app_bar.dart';
import '../../data/reference_data.dart';
import '../attendance/attendance_page.dart';
import '../auth/login_page.dart';
import '../calendar/academic_calendar_page.dart';
import '../documents/academic_documents_page.dart';
import '../late_arrivals/late_arrivals_page.dart';
import '../marks/internal_mark_page.dart';
import '../notices/notice_list_page.dart';
import '../profile/profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    required this.sessionStore,
    this.enableRealtime = true,
    super.key,
  });

  final SessionStore sessionStore;
  final bool enableRealtime;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<void> _logout() async {
    await widget.sessionStore.signOut();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(
        builder: (_) => LoginPage(sessionStore: widget.sessionStore),
      ),
      (_) => false,
    );
  }

  void _open(Widget page) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
  }

  void _openFeature(int index) {
    switch (index) {
      case 0:
        _open(NoticeListPage(
          sessionStore: widget.sessionStore,
          enableRealtime: widget.enableRealtime,
        ));
        return;
      case 1:
        _open(NoticeListPage(
          sessionStore: widget.sessionStore,
          examNotices: true,
          enableRealtime: widget.enableRealtime,
        ));
        return;
      case 2:
        _open(InternalMarkPage(sessionStore: widget.sessionStore));
        return;
      case 4:
        _open(AttendancePage(sessionStore: widget.sessionStore));
        return;
      case 5:
        _open(AcademicCalendarPage(sessionStore: widget.sessionStore));
        return;
      case 6:
        _open(const LateArrivalsPage());
        return;
      case 7:
        _open(const AcademicDocumentsPage());
        return;
      default:
        return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ReferenceAppBar(
        title: 'Home',
        action: IconButton(
          tooltip: 'Logout',
          onPressed: _logout,
          icon: const Icon(Icons.logout, size: 30),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: CustomScrollView(
              key: const PageStorageKey<String>('home-scroll'),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
                  sliver: SliverList.list(
                    children: [
                      const _HomeNoticeCard(
                        heading: 'Latest Exam Notice',
                        title:
                            'Sub: B.Tech. Minor Third Semester\n'
                            '(2025 Admission) Course\n'
                            'Registration:',
                        fullWidth: true,
                      ),
                      const SizedBox(height: 20),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final columns = constraints.maxWidth >= 600 ? 5 : 3;
                          return GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: ReferenceData.features.length,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: columns,
                              mainAxisSpacing: 16,
                              crossAxisSpacing: 16,
                              childAspectRatio: 1,
                            ),
                            itemBuilder: (context, index) {
                              final item = ReferenceData.features[index];
                              final enabled = !{3, 8}.contains(index);
                              return _FeatureTile(
                                item: item,
                                enabled: enabled,
                                onTap: () => _openFeature(index),
                              );
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      const UpcomingEventsCard(),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            return TextStyle(
              color: states.contains(WidgetState.selected)
                  ? AppColors.purple
                  : const Color(0xFF4D494F),
              fontSize: 14,
            );
          }),
        ),
        child: NavigationBar(
          height: 72,
          backgroundColor: AppColors.surface,
          indicatorColor: Colors.transparent,
          selectedIndex: 0,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          onDestinationSelected: (index) {
            if (index == 1) _open(const ProfilePage());
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home, color: AppColors.accent),
              selectedIcon: Icon(Icons.home, color: AppColors.accent),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.person, color: AppColors.accent),
              selectedIcon: Icon(Icons.person, color: AppColors.accent),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

class StudentSummaryCard extends StatelessWidget {
  const StudentSummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 6,
      shadowColor: Colors.black38,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 28,
              backgroundColor: AppColors.lavender,
            ),
            const SizedBox(width: 19),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'NEHA MATHEWS -',
                    style: TextStyle(fontSize: 19, letterSpacing: .4),
                  ),
                  SizedBox(height: 3),
                  Text('U2503208', style: TextStyle(fontSize: 19)),
                  SizedBox(height: 3),
                  Text(
                    '2026S3CS-C',
                    style: TextStyle(fontSize: 16, color: Color(0xFF4D494F)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeExpansionCard extends StatelessWidget {
  const HomeExpansionCard({
    required this.title,
    required this.body,
    required this.expanded,
    required this.onTap,
    super.key,
  });

  final String title;
  final String body;
  final bool expanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 230),
      curve: Curves.easeInOut,
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 5,
        shadowColor: Colors.black26,
        color: AppColors.surface,
        shape: const RoundedRectangleBorder(),
        child: Padding(
          padding:
              EdgeInsets.fromLTRB(8, expanded ? 8 : 0, 8, expanded ? 8 : 0),
          child: Column(
            children: [
              if (expanded) const Divider(height: 1, color: Color(0xFF777477)),
              InkWell(
                onTap: onTap,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 24,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Icon(
                        expanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: expanded ? AppColors.purple : AppColors.ink,
                        size: 30,
                      ),
                    ],
                  ),
                ),
              ),
              if (expanded)
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 0, 8, 10),
                  child: Text(
                    body,
                    textAlign: TextAlign.justify,
                    style: const TextStyle(fontSize: 18, height: 1.4),
                  ),
                ),
              if (expanded) const Divider(height: 1, color: Color(0xFF777477)),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeNoticeCard extends StatelessWidget {
  const _HomeNoticeCard({
    required this.heading,
    required this.title,
    this.fullWidth = false,
  });

  final String heading;
  final String title;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 128,
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 5,
        shadowColor: Colors.black26,
        color: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          width: fullWidth ? double.infinity : null,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                heading,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.topLeft,
                  child: Text(
                    title,
                    maxLines: 3,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.45,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureTile extends StatelessWidget {
  const _FeatureTile({
    required this.item,
    required this.enabled,
    required this.onTap,
  });

  final FeatureItem item;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      elevation: 0,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(item.icon, size: 28, color: AppColors.primary),
              const SizedBox(height: 10),
              Text(
                item.label,
                textAlign: TextAlign.center,
                maxLines: 2,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.3,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class UpcomingEventsCard extends StatelessWidget {
  const UpcomingEventsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 4,
      shadowColor: Colors.black26,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(17, 17, 17, 22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Upcoming Events',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 18),
            for (final event in ReferenceData.upcomingEvents) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 5, left: 18, right: 22),
                    child: Icon(
                      Icons.event,
                      color: AppColors.primary,
                      size: 26,
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event.title,
                          style: const TextStyle(fontSize: 20, height: 1.3),
                        ),
                        Text(
                          event.date,
                          style: const TextStyle(
                            fontSize: 17,
                            color: Color(0xFF5A565C),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (event != ReferenceData.upcomingEvents.last)
                const SizedBox(height: 20),
            ],
          ],
        ),
      ),
    );
  }
}
