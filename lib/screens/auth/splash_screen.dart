import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  Future<void> _checkLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    final role = prefs.getString('userRole');

    // Delay sejenak biar effect splash kelihatan
    await Future.delayed(const Duration(milliseconds: 800));

    if (isLoggedIn && role != null) {
      switch (role) {
        case 'boss':
          Navigator.pushReplacementNamed(context, '/boss/dashboard');
          return;
        case 'sales':
          Navigator.pushReplacementNamed(context, '/sales/dashboard');
          return;
        case 'finisher':
          Navigator.pushReplacementNamed(context, '/finisher/dashboard');
          return;
        case 'designer':
          Navigator.pushReplacementNamed(context, '/designer/dashboard');
          return;
        case 'cor':
          Navigator.pushReplacementNamed(context, '/cor/dashboard');
          return;
        case 'carver':
          Navigator.pushReplacementNamed(context, '/carver/dashboard');
          return;
        case 'diamond_setter':
          Navigator.pushReplacementNamed(context, '/diamond_setter/dashboard');
          return;
        case 'inventory':
          Navigator.pushReplacementNamed(context, '/inventory/dashboard');
          return;
        default:
          // Fallback ke login
          Navigator.pushReplacementNamed(context, '/login');
          return;
      }
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}