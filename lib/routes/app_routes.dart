import 'package:flutter/material.dart';
import '../presentation/dashboard_screen/dashboard_screen.dart';
import '../presentation/splash_screen/splash_screen.dart';
import '../presentation/settings_screen/settings_screen.dart';
import '../presentation/alerts_screen/alerts_screen.dart';
import '../presentation/analytics_screen/analytics_screen.dart';
import '../presentation/home_screen/home_screen.dart';

class AppRoutes {
  // TODO: Add your routes here
  static const String initial = '/';
  static const String dashboard = '/dashboard-screen';
  static const String splash = '/splash-screen';
  static const String settings = '/settings-screen';
  static const String alerts = '/alerts-screen';
  static const String analytics = '/analytics-screen';
  static const String home = '/home-screen';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const SplashScreen(),
    dashboard: (context) => const DashboardScreen(),
    splash: (context) => const SplashScreen(),
    settings: (context) => const SettingsScreen(),
    alerts: (context) => const AlertsScreen(),
    analytics: (context) => const AnalyticsScreen(),
    home: (context) => const HomeScreen(),
    // TODO: Add your other routes here
  };
}
