import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_colors.dart';
import 'core/localization/app_localizations.dart';
import 'providers/theme_provider.dart';
import 'providers/language_provider.dart';
import 'routes/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
