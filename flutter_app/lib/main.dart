import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'l10n/app_localizations.dart';
import 'design_tokens.dart'; // Still needed for some constants or legacy usage if any
import 'core/theme/t4l_theme.dart'; // New Theme
import 'core/os_shell/views/os_shell_view.dart';
import 'core/app_registry.dart';
import 'core/services/settings_service.dart';
import 'micro_apps/app_store/app_store_app.dart';
import 'micro_apps/deep_dive/deep_dive_app.dart';
import 'micro_apps/breaking_news/breaking_news_app.dart';
import 'micro_apps/radio/radio_app.dart';
import 'micro_apps/radio/controllers/radio_controller.dart';

import 'core/services/installed_apps_service.dart';
import 'core/services/audio_player_service.dart';


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
  AppRegistry().register(RadioApp());
  
  // 3. Initialize Services
  await InstalledAppsService().init();
  await AudioPlayerService().init(); // Initialize Audio Service
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsService()),
        ChangeNotifierProxyProvider<SettingsService, RadioController>(
          create: (context) => RadioController(
            languageCode: Provider.of<SettingsService>(context, listen: false).locale.languageCode,
          ),
          update: (context, settings, controller) {
            return controller!..loadStations(settings.locale.languageCode);
          },
        ),
      ],
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
          
          // Use our standardized T4LTheme
          themeMode: settings.themeMode,
          theme: T4LTheme.light,
          darkTheme: T4LTheme.dark,
          
          builder: (context, child) {
            return child!; // Application content
          },
          home: const OSShellView(),
        );
      },
    );
  }
}
