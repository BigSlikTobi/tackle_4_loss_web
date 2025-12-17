import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'design_tokens.dart';
import 'models.dart';
import 'widgets/custom_header.dart';
import 'widgets/hero_section.dart';
import 'widgets/live_on_air_banner.dart';
import 'widgets/picked_for_you_section.dart';
import 'widgets/trending_now_section.dart';
import 'widgets/bottom_navigation.dart';
import 'screens/article_viewer_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await initializeDateFormatting();
  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = GoogleFonts.interTextTheme(Theme.of(context).textTheme);

    final lightTheme = ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.backgroundLight,
      primaryColor: AppColors.primary,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        background: AppColors.backgroundLight,
        surface: AppColors.cardLight,
        onPrimary: Colors.white,
        onSecondary: AppColors.primary,
        onBackground: AppColors.textMainLight,
        onSurface: AppColors.textMainLight,
      ),
      textTheme: textTheme.apply(
        bodyColor: AppColors.textMainLight,
        displayColor: AppColors.textMainLight,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.textMainLight),
      ),
    );

    final darkTheme = ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.backgroundDark,
      primaryColor: AppColors.primary,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        background: AppColors.backgroundDark,
        surface: AppColors.cardDark,
        onPrimary: Colors.white,
        onSecondary: AppColors.primary,
        onBackground: AppColors.textMainDark,
        onSurface: AppColors.textMainDark,
      ),
      textTheme: textTheme.apply(
        bodyColor: AppColors.textMainDark,
        displayColor: AppColors.textMainDark,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.textMainDark),
      ),
    );

    return MaterialApp(
      title: 'American Football App',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.system, // Or ThemeMode.dark / ThemeMode.light
      debugShowCheckedModeBanner: false,
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
  List<Article> _articles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchArticles();
  }

  Future<void> _fetchArticles() async {
    try {
      final response = await Supabase.instance.client.functions.invoke('get-latest-deepdive');

      final data = response.data as List;
      
      final articles = data.map((item) => Article.fromSupabase(item)).toList();

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
      }
    }
  }

  void _selectArticle(Article article) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ArticleViewerScreen(article: article),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: SizedBox(
                          height: screenHeight * 0.65,
                          child: HeroSection(
                            article: _articles.isNotEmpty ? _articles[0] : null,
                            onReadMore: () => _selectArticle(_articles[0]),
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: Transform.translate(
                          offset: const Offset(0, -20),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(24),
                                topRight: Radius.circular(24),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 40,
                                  spreadRadius: -10,
                                  offset: const Offset(0, -10),
                                ),
                              ],
                              border: Border(
                                top: BorderSide(
                                  color: Theme.of(context).brightness == Brightness.dark
                                      ? Colors.white.withOpacity(0.05)
                                      : Colors.white.withOpacity(0.5),
                                  width: 1,
                                ),
                              ),
                            ),
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                                  child: Container(
                                    width: 48,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.withOpacity(0.5),
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                                  child: Column(
                                    children: [
                                      const SizedBox(height: 24),
                                      const LiveOnAirBanner(),
                                      const SizedBox(height: 40),
                                      const PickedForYouSection(),
                                      const SizedBox(height: 40),
                                      TrendingNowSection(
                                        articles: _articles.length > 1 ? _articles.sublist(1) : [],
                                        onSelectArticle: _selectArticle,
                                      ),
                                      const SizedBox(height: 120),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: CustomHeader(),
          ),
          const Positioned(
            bottom: 24,
            left: 24,
            right: 24,
            child: BottomNavigation(),
          ),
        ],
      ),
    );
  }
}
