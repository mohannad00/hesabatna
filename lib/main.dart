import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'services/database_service.dart';
import 'services/preferences_service.dart';
import 'screens/home_screen.dart';
import 'l10n/generated/app_localizations.dart';

// Theme mode provider with persistence
class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(PreferencesService.getThemeMode());

  void setThemeMode(ThemeMode mode) {
    state = mode;
    PreferencesService.setThemeMode(mode);
  }
}

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>(
  (ref) => ThemeModeNotifier(),
);

// Username provider with persistence
class UsernameNotifier extends StateNotifier<String> {
  UsernameNotifier() : super(PreferencesService.getUsername());

  void setUsername(String username) {
    state = username;
    PreferencesService.setUsername(username);
  }
}

final usernameProvider = StateNotifierProvider<UsernameNotifier, String>(
  (ref) => UsernameNotifier(),
);

// Locale provider with persistence
class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier() : super(PreferencesService.getLocale());

  void setLocale(Locale locale) {
    state = locale;
    PreferencesService.setLocale(locale);
  }
}

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>(
  (ref) => LocaleNotifier(),
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PreferencesService.init();
  await DatabaseService.init();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp(
      title: 'Hesabatna',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: _buildLightTheme(),
      darkTheme: _buildDarkTheme(),
      themeAnimationDuration: Duration.zero,
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en', 'US'), Locale('ar', 'EG')],
      home: const HomeScreen(),
    );
  }

  ThemeData _buildLightTheme() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF2196F3),
        primary: const Color(0xFF2196F3),
        secondary: const Color(0xFF03A9F4),
        tertiary: const Color(0xFF00BCD4),
        brightness: Brightness.light,
      ),
      useMaterial3: true,
      brightness: Brightness.light,
      splashFactory: NoSplash.splashFactory, // Remove blue splash effects
      highlightColor: Colors.transparent, // Remove highlight overlay
      scaffoldBackgroundColor: const Color(0xFFF5F9FF),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Color(0xFF2D3142),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF5F6FA),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF2196F3), width: 2),
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Color(0xFF2D3142),
        ),
        headlineMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Color(0xFF2D3142),
        ),
        titleLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: Color(0xFF2D3142),
        ),
        titleMedium: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Color(0xFF2D3142),
        ),
        bodyLarge: TextStyle(fontSize: 16, color: Color(0xFF2D3142)),
        bodyMedium: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF2196F3),
        primary: const Color(0xFF42A5F5),
        secondary: const Color(0xFF03A9F4),
        tertiary: const Color(0xFF00BCD4),
        brightness: Brightness.dark,
        surface: const Color(0xFF0D1B2A),
        background: const Color(0xFF0A1628),
      ),
      useMaterial3: true,
      brightness: Brightness.dark,
      splashFactory: NoSplash.splashFactory, // Remove blue splash effects
      highlightColor: Colors.transparent, // Remove highlight overlay
      scaffoldBackgroundColor: const Color(0xFF0A1628),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: const Color(0xFF0D1B2A),
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Color(0xFFE5E7EB),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1A1B26),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF42A5F5), width: 2),
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Color(0xFFE5E7EB),
        ),
        headlineMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Color(0xFFE5E7EB),
        ),
        titleLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: Color(0xFFE5E7EB),
        ),
        titleMedium: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Color(0xFFE5E7EB),
        ),
        bodyLarge: TextStyle(fontSize: 16, color: Color(0xFFE5E7EB)),
        bodyMedium: TextStyle(fontSize: 14, color: Color(0xFF9CA3AF)),
      ),
    );
  }
}
