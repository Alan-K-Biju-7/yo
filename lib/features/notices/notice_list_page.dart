import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/session/session_store.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/screen_shell.dart';
import '../../data/api_service.dart';
import '../../data/websocket_service.dart';

class NoticeListPage extends StatefulWidget {
  const NoticeListPage({
    required this.sessionStore,
    this.examNotices = false,
    this.enableRealtime = true,
    super.key,
  });

  final SessionStore sessionStore;
  final bool examNotices;
  final bool enableRealtime;

  @override
  State<NoticeListPage> createState() => _NoticeListPageState();
}

class NoticeRecord {
  final String id;
  final String title;
  final String date;
  final String fileUrl;

  NoticeRecord({
    required this.id,
    required this.title,
    required this.date,
    required this.fileUrl,
  });

  factory NoticeRecord.fromJson(Map<String, dynamic> json) {
    return NoticeRecord(
      id: json['_id'],
      title: json['title'],
      date: json['upload_date'].toString().split('T')[0],
      fileUrl: json['file_url'],
    );
  }
}

class _NoticeListPageState extends State<NoticeListPage> {
  List<NoticeRecord> _notices = [];
  bool _isLoading = true;
  String? _errorMessage;
  late WebSocketService _wsService;

  @override
  void initState() {
    super.initState();
    _wsService = WebSocketService();
    if (widget.enableRealtime) {
      _setupWebSocket();
      _loadNotices();
    } else {
      _isLoading = false;
    }
  }

  void _setupWebSocket() {
    _wsService.onMessageReceived = (message) {
      if (message['type'] == 'notice_added') {
        // Reload notices when new notice is added
        _loadNotices();
      }
    };

    _wsService.connect(widget.sessionStore.accessToken!);
    _wsService.subscribe('notices');
  }

  Future<void> _loadNotices() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final noticesList = await ApiService.getNotices(
        widget.examNotices,
        widget.sessionStore.accessToken!,
      );

      final records =
          noticesList.map((json) => NoticeRecord.fromJson(json)).toList();

      setState(() {
        _notices = records;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load notices: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _wsService.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenShell(
      title: widget.examNotices ? 'Exam Notices' : 'Notices',
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error, size: 48, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(_errorMessage!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.red)),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadNotices,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : _notices.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.mail, size: 48, color: Colors.grey),
                          SizedBox(height: 16),
                          Text('No notices available'),
                        ],
                      ),
                    )
                  : ListView.separated(
                      key: PageStorageKey<String>(
                        widget.examNotices ? 'exam-notices' : 'notices',
                      ),
                      padding: const EdgeInsets.fromLTRB(15, 26, 15, 95),
                      itemCount: _notices.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 19),
                      itemBuilder: (context, index) =>
                          _NoticeCard(record: _notices[index]),
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
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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
            InkWell(
              onTap: () async {
                final opened = await launchUrl(
                  ApiService.fileUri(record.fileUrl),
                  mode: LaunchMode.externalApplication,
                );
                if (!opened && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Unable to open this PDF')),
                  );
                }
              },
              child: const Icon(
                Icons.picture_as_pdf,
                color: AppColors.primary,
                size: 30,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
