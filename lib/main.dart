import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_colors.dart';
import 'core/localization/app_localizations.dart';
import 'providers/theme_provider.dart';
import 'providers/language_provider.dart';
import 'routes/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables - MANDATORY step
  try {
    await dotenv.load(fileName: "assets/.env");
  } catch (e) {
    // If .env file is missing, throw a clear error
    throw Exception(
      'CRITICAL: .env file not found!\n'
      'Please create a .env file in the assets/ directory with:\n'
      'CHANNEL_ID=your_channel_id\n'
      'READ_API_KEY=your_read_api_key\n'
      '\nError details: $e'
    );
  }
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ProviderScope(child: AgriNestApp()));
}

class AgriNestApp extends ConsumerWidget {
  const AgriNestApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(languageProvider);

    // Update AppColors static flag whenever theme changes
    AppColors.isDarkMode = themeMode == ThemeMode.dark;

    // Use a key to force complete rebuild when theme changes - this prevents any animation issues
    final appKey = ValueKey('theme_${themeMode.name}');

    return MaterialApp.router(
      key: appKey, // Force complete rebuild when theme changes
      title: 'AgriNest',
      debugShowCheckedModeBanner: false,

      // Use single theme - no theme switching
      theme: themeMode == ThemeMode.dark ? AppTheme.darkTheme : AppTheme.lightTheme,
      
      // Localization
      locale: locale,
      supportedLocales: const [
        Locale('en'),
        Locale('am'),
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      
      // Router
      routerConfig: appRouter,
    );
  }
}
