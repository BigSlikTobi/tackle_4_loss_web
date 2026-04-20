import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'l10n/app_localizations.dart';
import 'core/theme/t4l_theme.dart'; // New Theme
import 'core/os_shell/views/os_shell_view.dart';
import 'core/onboarding/views/first_launch_flow.dart';
import 'core/app_registry.dart';
import 'core/services/settings_service.dart';
import 'micro_apps/breaking_news/breaking_news_app.dart';
import 'micro_apps/standings/standings_app.dart';

import 'core/services/installed_apps_service.dart';
import 'core/services/new_content_service.dart';

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

  // MVP: FlutterGemma is not initialized — Game Reports MicroApp (its only
  // consumer) is flag-off. The flutter_gemma package is removed from pubspec
  // to drop the TensorFlowLiteSelectTfOps iOS dependency from the binary.

  // 2. Register MicroApps
  // MVP scope: only Breaking News (data layer for home feed) and Standings.
  // Other MicroApps remain in repo but are not registered or initialized.
  AppRegistry().register(BreakingNewsApp());
  AppRegistry().register(StandingsApp());

  // 3. Initialize Services
  // MVP: InstalledAppsService is not initialized — no AppStrip consumes it.
  // Will be re-enabled when more MicroApps return to the visible surface.
  // AudioPlayerService is lazily initialized on first playback request
  await NewContentService().init(); // Initialize new content tracking

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsService()),
        ChangeNotifierProvider.value(value: InstalledAppsService()),
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
          theme: T4LTheme.light(team: settings.selectedTeam),
          darkTheme: T4LTheme.dark(team: settings.selectedTeam),

          builder: (context, child) {
            return child!; // Application content
          },
          home: _RootGate(settings: settings),
        );
      },
    );
  }
}

/// Decides whether to show a splash, the forced first-launch flow, or the
/// OS Shell. SettingsService loads its persisted prefs asynchronously; we
/// must not render the home screen before that completes, otherwise the
/// onboarding flag is unknown.
class _RootGate extends StatelessWidget {
  final SettingsService settings;

  const _RootGate({required this.settings});

  @override
  Widget build(BuildContext context) {
    if (!settings.isLoaded) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (!settings.onboardingComplete) {
      return const FirstLaunchFlow();
    }
    return const OSShellView();
  }
}
