// sumatra_jewelry_app/lib/screens/auth/login_screen.dart
import 'package:flutter/material.dart';
import 'package:sumatra_jewelry_app/screens/boss/boss_dashboard_screen.dart';
import 'package:sumatra_jewelry_app/screens/sales/sales_dashboard_screen.dart';
import 'package:sumatra_jewelry_app/screens/finisher/finisher_dashboard_screen.dart';
import 'package:sumatra_jewelry_app/screens/designer/designer_dashboard_screen.dart';
import 'package:sumatra_jewelry_app/screens/cor/cor_dashboard_screen.dart';
import 'package:sumatra_jewelry_app/screens/carver/carver_dashboard_screen.dart';
import 'package:sumatra_jewelry_app/screens/diamond_setter/diamond_setter_dashboard_screen.dart';
import 'package:sumatra_jewelry_app/screens/inventory/inventory_dashboard_screen.dart';
// repairer_dashboard_screen.dart sudah dihapus importnya

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String _errorMessage = '';

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    // Simulasi autentikasi. Ganti dengan panggilan ke AuthService Anda nanti.
    await Future.delayed(const Duration(seconds: 1));

    if (username.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'Username dan password tidak boleh kosong.';
      });
      _isLoading = false;
      return; // Langsung keluar jika validasi gagal
    }

    // Simulasi login berhasil berdasarkan username sebagai role
    // Di aplikasi nyata, ini akan divalidasi oleh backend
    Widget? nextScreen;

    switch (username.toLowerCase()) {
      case 'boss':
        nextScreen = const BossDashboardScreen();
        break;
      case 'sales':
        nextScreen = const SalesDashboardScreen();
        break;
      case 'finisher':
        nextScreen = const FinisherDashboardScreen();
        break;
      case 'designer':
        nextScreen = const DesignerDashboardScreen();
        break;
      case 'cor':
        nextScreen = const CorDashboardScreen();
        break;
      case 'carver':
        nextScreen = const CarverDashboardScreen();
        break;
      case 'diamond_setter':
        nextScreen = const DiamondSetterDashboardScreen();
        break;
      case 'inventory':
        nextScreen = const InventoryDashboardScreen();
        break;
      default:
        setState(() {
          _errorMessage = 'Username atau password salah.';
        });
        _isLoading = false;
        return; // Langsung keluar jika tidak ada case yang cocok
    }

    // Di sini, nextScreen dijamin tidak null karena default case akan melakukan return
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => nextScreen!), // nextScreen! aman di sini
    );

    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/sumatra_jewelry_logo.png', // Pastikan path ini benar
                height: 150,
              ),
              const SizedBox(height: 30),
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
              ),
              const SizedBox(height: 20),
              if (_errorMessage.isNotEmpty)
                Text(
                  _errorMessage,
                  style: const TextStyle(color: Colors.red, fontSize: 14),
                ),
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _login,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Login',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}