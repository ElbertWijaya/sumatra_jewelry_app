import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sumatra_jewelry_app/screens/boss/boss_dashboard_screen.dart';
import 'package:sumatra_jewelry_app/screens/sales/sales_dashboard_screen.dart';
import 'package:sumatra_jewelry_app/screens/finisher/finisher_dashboard_screen.dart';
import 'package:sumatra_jewelry_app/screens/designer/designer_dashboard_screen.dart';
import 'package:sumatra_jewelry_app/screens/cor/cor_dashboard_screen.dart';
import 'package:sumatra_jewelry_app/screens/carver/carver_dashboard_screen.dart';
import 'package:sumatra_jewelry_app/screens/diamond_setter/diamond_setter_dashboard_screen.dart';
import 'package:sumatra_jewelry_app/screens/inventory/inventory_dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String _errorMessage = '';

  Future<void> _setLoginStatus(bool isLoggedIn, {String? role}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', isLoggedIn);
    if (role != null) {
      await prefs.setString('userRole', role);
    } else {
      await prefs.remove('userRole');
    }
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final username = _usernameController.text.trim();
    // final password = _passwordController.text.trim(); // Hapus jika tidak digunakan

    await Future.delayed(const Duration(seconds: 1));

    Widget? nextScreen;
    String? role;

    switch (username.toLowerCase()) {
      case 'boss':
        nextScreen = const BossDashboardScreen();
        role = 'boss';
        break;
      case 'sales':
        nextScreen = const SalesDashboardScreen();
        role = 'sales';
        break;
      case 'finisher':
        nextScreen = const FinisherDashboardScreen();
        role = 'finisher';
        break;
      case 'designer':
        nextScreen = const DesignerDashboardScreen();
        role = 'designer';
        break;
      case 'caster':
        nextScreen = const CorDashboardScreen();
        role = 'cor';
        break;
      case 'carver':
        nextScreen = const CarverDashboardScreen();
        role = 'carver';
        break;
      case 'diamond setter':
        nextScreen = const DiamondSetterDashboardScreen();
        role = 'diamond_setter';
        break;
      case 'inventory':
        nextScreen = const InventoryDashboardScreen();
        role = 'inventory';
        break;
      default:
        setState(() {
          _errorMessage = 'Username atau password salah.';
          _isLoading = false;
        });
        return;
    }

    await _setLoginStatus(true, role: role);

    if (!mounted) return; // Perbaikan use_build_context_synchronously

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => nextScreen!),
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
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/toko_sumatra.jpg',
              fit: BoxFit.cover,
              colorBlendMode: BlendMode.darken,
              color: Colors.black.withAlpha(
                (255 * 0.4).toInt(),
              ), // Ganti withOpacity
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/logo_sumatra_jewelry.png',
                      height: 150,
                    ),
                    const SizedBox(height: 50),
                    TextFormField(
                      controller: _usernameController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Username',
                        hintText: 'Masukkan username Anda',
                        prefixIcon: const Icon(
                          Icons.person,
                          color: Colors.white70,
                        ),
                        labelStyle: const TextStyle(color: Colors.white70),
                        hintStyle: const TextStyle(color: Colors.white54),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Colors.amber,
                            width: 1.5,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Colors.amberAccent,
                            width: 2.5,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Colors.red,
                            width: 1.5,
                          ),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Colors.redAccent,
                            width: 2.5,
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.white.withAlpha(
                          (255 * 0.1).toInt(),
                        ), // Ganti withOpacity
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 20,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Username tidak boleh kosong';
                        }
                        if (value.length < 4) {
                          return 'Username minimal 4 karakter';
                        }
                        return null;
                      },
                      onChanged: (_) {
                        if (_errorMessage.isNotEmpty) {
                          setState(() => _errorMessage = '');
                        }
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Password',
                        hintText: 'Masukkan password Anda',
                        prefixIcon: const Icon(
                          Icons.lock,
                          color: Colors.white70,
                        ),
                        labelStyle: const TextStyle(color: Colors.white70),
                        hintStyle: const TextStyle(color: Colors.white54),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Colors.amber,
                            width: 1.5,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Colors.amberAccent,
                            width: 2.5,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Colors.red,
                            width: 1.5,
                          ),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Colors.redAccent,
                            width: 2.5,
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.white.withAlpha(
                          (255 * 0.1).toInt(),
                        ), // Ganti withOpacity
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 20,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Password tidak boleh kosong';
                        }
                        if (value.length < 6) {
                          return 'Password minimal 6 karakter';
                        }
                        return null;
                      },
                      onChanged: (_) {
                        if (_errorMessage.isNotEmpty) {
                          setState(() => _errorMessage = '');
                        }
                      },
                    ),
                    const SizedBox(height: 30),
                    if (_errorMessage.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20.0),
                        child: Text(
                          _errorMessage,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _login,
                        child:
                            _isLoading
                                ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                                : const Text('Login'),
                      ),
                    ),
                    const SizedBox(height: 50),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Text(
                        'Made by Elbert Wijaya',
                        style: TextStyle(
                          color: Colors.white.withAlpha(
                            (255 * 0.7).toInt(),
                          ), // Ganti withOpacity
                          fontSize: 14,
                        ),
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
