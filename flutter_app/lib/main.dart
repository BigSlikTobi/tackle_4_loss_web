import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'design_tokens.dart';
import 'models.dart';
import 'widgets/header.dart';
import 'widgets/article_feed.dart';
import 'screens/article_viewer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await initializeDateFormatting();

  await Supabase.initialize(
    url: 'https://yqtiuzhedkfacwgormhn.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InlxdGl1emhlZGtmYWN3Z29ybWhuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDE4NzcwMDgsImV4cCI6MjA1NzQ1MzAwOH0.h2FYangQNOdEJWq8ExWBABiphzoLObWcj5B9Z-uIgQc',
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
      debugPrint('Fetching articles from Supabase...');
      final response = await Supabase.instance.client
          .schema('content')
          .from('deepdive_article')
          .select('*')
          .order('published_at', ascending: false);

      debugPrint('Raw response length: ${(response as List).length}');

      final articles = (response as List)
          .map((json) {
            try {
              return Article.fromSupabase(json);
            } catch (e) {
              debugPrint('Error parsing article ${json['id']}: $e');
              rethrow;
            }
          })
          .toList();

      debugPrint('Parsed ${articles.length} articles');

      if (mounted) {
        setState(() {
          _articles = articles;
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Loaded ${articles.length} articles')),
        );
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

  @override
  Widget build(BuildContext context) {
    final filteredArticles = _articles
        .where((a) => a.languageCode == _selectedLanguage)
        .toList();
    
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          AppHeader(
            selectedLanguage: _selectedLanguage,
            onLanguageChanged: (lang) {
              setState(() {
                _selectedLanguage = lang;
              });
            },
          ),
          if (_isLoading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else
            ArticleFeed(
              articles: filteredArticles,
              onSelect: (article) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ArticleViewerScreen(article: article),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
