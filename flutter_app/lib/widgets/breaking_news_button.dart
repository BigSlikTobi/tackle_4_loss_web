import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models.dart';
import '../services/notification_service.dart';
import '../screens/breaking_news_overview.dart';
import '../design_tokens.dart'; // Import for colors

class BreakingNewsButton extends StatefulWidget {
  final String languageCode;
  final Function(String id) onNavigateToDetail;

  const BreakingNewsButton({
    super.key,
    required this.languageCode,
    required this.onNavigateToDetail,
  });

  @override
  State<BreakingNewsButton> createState() => _BreakingNewsButtonState();
}

class _BreakingNewsButtonState extends State<BreakingNewsButton> {
  static const String _storageKeyLastViewed = 'breaking_news_last_viewed';
  
  List<BreakingNews> _news = [];
  bool _hasUnread = false;

  @override
  void initState() {
    super.initState();
    _fetchNews();
    _setupRealtime();
    NotificationService().init();
  }

  Future<void> _fetchNews() async {
    try {
      final response = await Supabase.instance.client.functions.invoke(
        'get-breaking-news',
        body: {'language_code': widget.languageCode},
      );

      final List<dynamic> data = response.data ?? [];
      final List<BreakingNews> news = data.map((e) => BreakingNews.fromJson(e)).toList();

      if (mounted) {
        setState(() {
          _news = news;
        });
        _checkUnreadStatus();
      }
    } catch (e) {
      debugPrint('Error fetching breaking news: $e');
    }
  }

  void _setupRealtime() {
    Supabase.instance.client
        .channel('breaking-news-flutter')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'content',
          table: 'breaking_news',
          callback: (payload) {
            _fetchNews();
            
            // Trigger Notification
            final newItem = BreakingNews.fromJson(payload.newRecord);
            NotificationService().showNotification(
              'Breaking News! 🚨',
              newItem.xPost ?? newItem.headline,
            );
          },
        )
        .subscribe();
  }

  Future<void> _checkUnreadStatus() async {
    if (_news.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    final lastViewedStr = prefs.getString(_storageKeyLastViewed);
    
    if (lastViewedStr == null) {
      if (mounted) setState(() => _hasUnread = true);
      return;
    }

    final lastViewed = DateTime.parse(lastViewedStr);
    final latest = _news.first.createdAt;

    if (mounted) {
      setState(() {
        _hasUnread = latest.isAfter(lastViewed);
      });
    }
  }

  Future<void> _markAsRead() async {
    if (_news.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_storageKeyLastViewed, _news.first.createdAt.toIso8601String());
      if (mounted) setState(() => _hasUnread = false);
    }
  }

  void _showOverview() {
    _markAsRead();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        builder: (context, scrollController) => BreakingNewsOverview(
          news: _news,
          languageCode: widget.languageCode,
          onNavigateToDetail: widget.onNavigateToDetail,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Return empty if no news, OR maybe show disabled? 
    // Requirement implies it should be there. Let's keep it visible but maybe disabled if no news?
    // Or just always visible as an access point.
    
    return GestureDetector(
      onTap: _showOverview,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0xFF0F3D2E).withOpacity(0.35),
            width: 1.5
          ),
          boxShadow: [
             BoxShadow(
              color: const Color(0xFF0F3D2E).withOpacity(0.12),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
             BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ]
        ),
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            const Text(
              'B',
              style: TextStyle(
                color: Color(0xFF0F3D2E), // Brand Green
                fontSize: 18,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
                fontFamily: 'Inter', // Ensure font matches
              ),
            ),
            if (_hasUnread)
              Positioned(
                top: -2,
                right: -2,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.red[500],
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                     boxShadow: [
                      BoxShadow(
                        color: Colors.red.withOpacity(0.4),
                        blurRadius: 4,
                        spreadRadius: 1,
                      )
                    ]
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
