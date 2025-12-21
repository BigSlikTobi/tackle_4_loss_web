import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'l10n/app_localizations.dart';
import 'design_tokens.dart';
import 'core/os_shell/views/os_shell_view.dart';
import 'core/app_registry.dart';
import 'core/services/settings_service.dart';
import 'micro_apps/app_store/app_store_app.dart';
import 'micro_apps/deep_dive/deep_dive_app.dart';
import 'micro_apps/breaking_news/breaking_news_app.dart';

import 'core/services/installed_apps_service.dart';
import 'core/services/audio_player_service.dart';
import 'core/adk/widgets/mini_player.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  // 1. Initialize Bindings
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load Env
  await dotenv.load(fileName: ".env");

  // Initialize Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  // 2. Register MicroApps
  // In a real app we might load these dynamically or via reflection, 
  // but for now we register them manually on boot.
  AppRegistry().register(AppStoreApp()); 
  AppRegistry().register(DeepDiveApp()); 
  AppRegistry().register(BreakingNewsApp());
  
  // 3. Initialize Services
  await InstalledAppsService().init();
  await AudioPlayerService().init(); // Initialize Audio Service
  
  runApp(
    ChangeNotifierProvider(
      create: (_) => SettingsService(),
      child: const Tackle4LossApp(),
    ),
  );
}

class Tackle4LossApp extends StatelessWidget {
  const Tackle4LossApp({super.key});

  @override
  Widget build(BuildContext context) {
    // System UI cleanup for full immersion
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.black,
    ));

    return Consumer<SettingsService>(
      builder: (context, settings, _) {
        return MaterialApp(
          title: 'Tackle 4 Loss OS',
          debugShowCheckedModeBanner: false,
          locale: settings.locale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'),
            Locale('de'),
          ],
          theme: ThemeData(
            useMaterial3: true,
            scaffoldBackgroundColor: AppColors.background,
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.primary,
              brightness: Brightness.dark,
              surface: AppColors.surface,
            ),
          ),
          builder: (context, child) {
            return Stack(
              children: [
                child!, // The main app content
                const MiniPlayer(), // Global Audio Player Overlay
              ],
            );
          },
          home: const OSShellView(),
        );
      },
    );
  }
}
