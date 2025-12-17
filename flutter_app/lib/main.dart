import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'design_tokens.dart';
import 'models.dart';
import 'widgets/header.dart';
import 'widgets/article_feed.dart';
import 'widgets/breaking_news_button.dart'; // Import Button
import 'widgets/mini_audio_player.dart';
import 'screens/article_viewer.dart';
import 'services/breaking_news_service.dart';

import 'services/global.dart';
import 'services/audio_handler.dart';
import 'package:audio_service/audio_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await initializeDateFormatting();
  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  audioHandler = await AudioService.init(
    builder: () => AudioPlayerHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.tackle4loss.channel.audio',
      androidNotificationChannelName: 'Detail Deep Dive',
      androidNotificationOngoing: true,
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tackle4Loss',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.brandBase,
          primary: AppColors.brandBase,
          secondary: AppColors.brandLight,
          surface: AppColors.neutralSoft,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.neutralSoft,
        textTheme: GoogleFonts.interTextTheme(),
      ),
      home: const HomeScreen(),
      builder: (context, child) {
        return Stack(
          children: [
            if (child != null) child,
            const Positioned(
              left: 0,
              right: 0,
              bottom: 24, // Floats above bottom content
              child: SafeArea(child: MiniAudioPlayer()),
            ),
          ],
        );
      },
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedLanguage = 'de';
  List<Article> _articles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchArticles();
  }

  Future<void> _fetchArticles() async {
    try {
      debugPrint('Fetching latest deepdive from Supabase Edge Function...');
      
      final response = await Supabase.instance.client.functions.invoke(
        'get-latest-deepdive',
        body: {'language_code': _selectedLanguage},
      );

      final data = response.data;
      
      List<Article> articles = [];
      if (data != null) {
        try {
          articles = [Article.fromSupabase(data)];
        } catch (e) {
          debugPrint('Error parsing article: $e');
        }
      }

      if (mounted) {
        setState(() {
          _articles = articles;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching articles: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Future<void> _selectArticle(BuildContext context, Article article, List<Article> allArticles) async {
    // Fetch full article details including sections
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final response = await Supabase.instance.client.functions.invoke(
        'get-article-viewer-data',
        body: {'article_id': article.id},
      );
      
      if (mounted) {
          Navigator.pop(context); // Hide loader

          final fullArticle = Article.fromSupabase(response.data);
          
          // Find current index
          final currentIndex = allArticles.indexWhere((a) => a.id == article.id);
          final Article? nextArticle = (currentIndex != -1 && currentIndex < allArticles.length - 1)
            ? allArticles[currentIndex + 1]
            : null;
          final Article? previousArticle = (currentIndex > 0)
            ? allArticles[currentIndex - 1]
            : null;

          void navigateToArticle(String id) {
            // Pop current viewer
            Navigator.pop(context);
            
            // Find new article summary
            final newArticle = allArticles.firstWhere((a) => a.id == id, orElse: () => Article.empty());
            if (newArticle.id.isEmpty) return;

            // Trigger selection logic again
            _selectArticle(context, newArticle, allArticles);
          }

          Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ArticleViewerScreen(
              article: fullArticle,
              nextArticle: nextArticle,
              previousArticle: previousArticle,
              onNavigate: navigateToArticle,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Hide loader
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading article: $e')),
        );
      }
    }
  }

  // Navigate to Detail from Chip
  Future<void> _handleBreakingNewsNavigation(String id) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final article = await BreakingNewsService().fetchBreakingNewsAsArticle(id, _selectedLanguage);

      if (mounted) {
        Navigator.pop(context); // Hide loader
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ArticleViewerScreen(
              article: article,
              nextArticle: null,
              previousArticle: null,
              onNavigate: (id) {},
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Hide loader
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to load breaking news. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      debugPrint("Error loading breaking news: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    // Filtering is now done on server side via the edge function parameter
    final filteredArticles = _articles; 
    
    return Scaffold(
      body: Stack(
        children: [
          // Main Scroll View
          CustomScrollView(
            slivers: [
              AppHeader(
                selectedLanguage: _selectedLanguage,
                onLanguageChanged: (lang) {
                  setState(() {
                    _selectedLanguage = lang;
                    _isLoading = true;
                    _articles = []; 
                  });
                  _fetchArticles(); 
                },
              ),
              if (_isLoading)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              else
                ArticleFeed(
                  articles: filteredArticles,
                  onSelect: (article) => _selectArticle(context, article, filteredArticles),
                ),
                
              // Add padding at bottom for MiniPlayer + Bottom Bar
              const SliverToBoxAdapter(
                 child: SizedBox(height: 120),
              ),
            ],
          ),

          // Global Mini Player - Moved up slightly if needed, or placed above bottom bar
          // Positioned(bottom: 80, left: 0, right: 0, child: const MiniAudioPlayer()), 
          // Actually MiniAudioPlayer handles its own specific position usually or is just at bottom.
          // Let's align it above the footer manually if it's fixed, OR integrate into footer?
          // For now, let's keep it fixed at bottom of screen, but elevate it.
          // Assuming MiniAudioPlayer has its own positioning logic or is a simple widget.
          // The previous code had it in a Stack. Let's wrap it in Positioned.
        ],
      ),
      bottomNavigationBar: Container(
        height: 80,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey[200]!)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            )
          ]
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Left: Copyright or Home Icon?
            Text(
              'T4L',
              style: GoogleFonts.blackOpsOne(
                color: AppColors.brandBase,
                fontSize: 24,
              ),
            ),
            
            // Right: Breaking News Button
            BreakingNewsButton(
              languageCode: _selectedLanguage,
              onNavigateToDetail: _handleBreakingNewsNavigation,
            ),
          ],
        ),
      ),
    );
  }
}
