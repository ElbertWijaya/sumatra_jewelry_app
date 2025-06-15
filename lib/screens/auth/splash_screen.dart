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

    if (!mounted) return;

    if (isLoggedIn) {
      switch (role) {
        case 'sales':
          Navigator.pushReplacementNamed(context, '/sales_dashboard');
          break;
        case 'designer':
          Navigator.pushReplacementNamed(context, '/designer_dashboard');
          break;
        case 'boss':
          Navigator.pushReplacementNamed(context, '/boss/dashboard');
          return;
        case 'finisher':
          Navigator.pushReplacementNamed(context, '/finisher/dashboard');
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
          // Jika role tidak dikenali, logout dan kembali ke login
          await prefs.clear();
          Navigator.pushReplacementNamed(context, '/login');
      }
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
