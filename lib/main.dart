import 'package:flutter/material.dart';
import 'screens/auth/login_screen.dart';
import 'screens/sales/sales_dashboard_screen.dart';
import 'screens/sales/sales_create_screen.dart';
// Import dashboard lain bila ada

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sumatra Jewelry App',
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/sales/dashboard': (context) => const SalesDashboardScreen(),
        '/sales/create': (context) => const SalesCreateScreen(),
        // Tambahkan dashboard lain di sini
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
