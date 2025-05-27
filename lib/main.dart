import 'package:flutter/material.dart';
import 'screens/auth/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/sales/sales_dashboard_screen.dart';
import 'screens/sales/sales_create_screen.dart';
// Import dashboard lain jika ada
import 'screens/boss/boss_dashboard_screen.dart';
import 'screens/finisher/finisher_dashboard_screen.dart';
import 'screens/designer/designer_dashboard_screen.dart';
import 'screens/cor/cor_dashboard_screen.dart';
import 'screens/carver/carver_dashboard_screen.dart';
import 'screens/diamond_setter/diamond_setter_dashboard_screen.dart';
import 'screens/inventory/inventory_dashboard_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sumatra Jewelry App',
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/sales/edit': (context) => const SalesCreateScreen(),
        '/sales/dashboard': (context) => const SalesDashboardScreen(),
        '/sales/create': (context) => const SalesCreateScreen(),
        '/boss/dashboard': (context) => const BossDashboardScreen(),
        '/finisher/dashboard': (context) => const FinisherDashboardScreen(),
        '/designer/dashboard': (context) => const DesignerDashboardScreen(),
        '/cor/dashboard': (context) => const CorDashboardScreen(),
        '/carver/dashboard': (context) => const CarverDashboardScreen(),
        '/diamond_setter/dashboard':
            (context) => const DiamondSetterDashboardScreen(),
        '/inventory/dashboard': (context) => const InventoryDashboardScreen(),
      },
    );
  }
}
