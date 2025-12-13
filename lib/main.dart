/// BloodBank - Flutter Frontend App
/// 
/// Run: flutter pub get → flutter run
/// 
/// Features:
/// - Firebase Authentication
/// - Firestore Database
/// - Dark Mode Support
/// - Real-time Data Streaming
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme.dart';
import 'routes.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'services/theme_service.dart';



Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('✅ Firebase initialized successfully');
  } catch (e) {
    debugPrint('❌ Firebase initialization error: $e');
    debugPrint('Make sure Firebase is properly configured with firebase_options.dart or google-services.json');
    // Continue - errors will be shown in UI when Firebase operations are attempted
  }
  
  // Load theme preference
  final themeService = ThemeService();
  final isDark = await themeService.isDarkMode();
  themeNotifier.value = isDark;
  
  // Set preferred orientations
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  runApp(const BloodBankApp());
}

class BloodBankApp extends StatelessWidget {
  const BloodBankApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: themeNotifier,
      builder: (context, isDarkMode, child) {
        return MaterialApp(
          title: 'BloodBank',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
          initialRoute: AppRoutes.splash,
          onGenerateRoute: AppRoutes.generateRoute,
          // TODO: Add localization delegates for proper i18n
        );
      },
    );
  }
}
