// sumatra_jewelry_app/lib/screens/auth/login_screen.dart
import 'package:flutter/material.dart';
import 'package:sumatra_jewelry_app/screens/sales/sales_dashboard_screen.dart'; // Import dashboard sales
import 'package:sumatra_jewelry_app/screens/designer/designer_dashboard_screen.dart'; // Import dashboard designer
import 'package:sumatra_jewelry_app/screens/carver/carver_dashboard_screen.dart'; // Import dashboard carver
import 'package:sumatra_jewelry_app/screens/polisher/polisher_dashboard_screen.dart'; // Import dashboard polisher
import 'package:sumatra_jewelry_app/screens/admin/admin_dashboard_screen.dart'; // Import dashboard admin

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      // Simulasi autentikasi
      await Future.delayed(const Duration(seconds: 2));

      final String username = _usernameController.text;
      final String password = _passwordController.text;

      // Logika autentikasi dummy
      if (username == 'sales' && password == 'sales123') {
        _navigateToDashboard('sales');
      } else if (username == 'designer' && password == 'designer123') {
        _navigateToDashboard('designer');
      } else if (username == 'carver' && password == 'carver123') {
        _navigateToDashboard('carver');
      } else if (username == 'polisher' && password == 'polisher123') {
        _navigateToDashboard('polisher');
      } else if (username == 'admin' && password == 'admin123') {
        _navigateToDashboard('admin');
      } else {
        setState(() {
          _errorMessage = 'Invalid username or password.';
        });
      }

      setState(() {
        _isLoading = false;
      });
    }
  }

  void _navigateToDashboard(String role) {
    Widget dashboardScreen;
    switch (role) {
      case 'sales':
        dashboardScreen = const SalesDashboardScreen();
        break;
      case 'designer':
        dashboardScreen = const DesignerDashboardScreen();
        break;
      case 'carver':
        dashboardScreen = const CarverDashboardScreen();
        break;
      case 'polisher':
        dashboardScreen = const PolisherDashboardScreen();
        break;
      case 'admin':
        dashboardScreen = const AdminDashboardScreen();
        break;
      default:
        dashboardScreen = const LoginScreen(); // Fallback
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => dashboardScreen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false, // Penting untuk menjaga background tetap utuh
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/images/toko_sumatra.jpg', // Path gambar background
              fit: BoxFit.cover,
              colorBlendMode: BlendMode.darken, // Memberikan efek gelap
              color: Colors.black.withOpacity(0.4), // Tingkat kegelapan
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Image.asset(
                      'assets/images/logo_sumatra.png', // Ganti dengan logo aplikasi Anda
                      height: 120,
                    ),
                    const SizedBox(height: 32.0),
                    Text(
                      'Sumatra Jewelry App',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 32.0),
                    TextFormField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        labelText: 'Username',
                        prefixIcon: const Icon(Icons.person, color: Colors.white70),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.2),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        labelStyle: const TextStyle(color: Colors.white70),
                        hintStyle: const TextStyle(color: Colors.white54),
                        floatingLabelStyle: const TextStyle(color: Colors.white),
                      ),
                      style: const TextStyle(color: Colors.white),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your username';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock, color: Colors.white70),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.2),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        labelStyle: const TextStyle(color: Colors.white70),
                        hintStyle: const TextStyle(color: Colors.white54),
                        floatingLabelStyle: const TextStyle(color: Colors.white),
                      ),
                      style: const TextStyle(color: Colors.white),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24.0),
                    _isLoading
                        ? const Center(child: CircularProgressIndicator(color: Colors.white))
                        : ElevatedButton(
                            onPressed: _login,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16.0),
                              backgroundColor: Theme.of(context).primaryColor, // Warna primer aplikasi
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Login',
                              style: TextStyle(fontSize: 18.0, color: Colors.white),
                            ),
                          ),
                    if (_errorMessage.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Text(
                          _errorMessage,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.redAccent, fontSize: 14.0),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}