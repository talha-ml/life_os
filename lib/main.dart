// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // 🚀 NEW: For Premium System UI configurations
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/app_theme.dart';
import 'views/auth/auth_screen.dart';
import 'core/utils/notification_helper.dart';

// 🌟 PREMIUM TOUCH: App automatically detects native Light/Dark mode!
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);

void main() async {
  // Ensures all native bridges are initialized before running the app
  WidgetsFlutterBinding.ensureInitialized();

  // 🚀 EDGE-TO-EDGE UI: Transparent status bar for modern, immersive look
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // Makes the top bar blend with the app
    ),
  );

  // 🚀 LOCK ORIENTATION: Prevents UI breakage by keeping it in Portrait mode
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize Notifications Engine BEFORE app runs
  await NotificationHelper.init();

  // ProviderScope is mandatory to enable Riverpod across the entire app
  runApp(const ProviderScope(child: LifeOSApp()));
}

class LifeOSApp extends ConsumerWidget {
  const LifeOSApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the current theme state (System, Light, or Dark)
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'LifeOS',
      debugShowCheckedModeBanner: false, // Clean, production-ready look
      theme: AppTheme.lightTheme, // Linked to our premium AppTheme
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,

      // 🚀 THE MASTER STROKE: App starts securely locked!
      home: const AuthScreen(),
    );
  }
}