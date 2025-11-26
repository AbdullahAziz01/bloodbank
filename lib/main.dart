/// BloodBank - Flutter Frontend App
/// 
/// Run: flutter pub get → flutter run
/// (Frontend only, no backend yet)
/// 
/// TODO: Add Firebase integration for backend
/// TODO: Add AI features for donor prediction
/// TODO: Add hospital analytics
/// TODO: Add push notifications
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme.dart';
import 'routes.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
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
    return MaterialApp(
      title: 'BloodBank',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRoutes.generateRoute,
      // TODO: Add dark theme support
      // TODO: Add localization delegates for proper i18n
    );
  }
}
