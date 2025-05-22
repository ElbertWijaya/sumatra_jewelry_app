import 'package:flutter/material.dart';

// Import semua dashboard
import 'package:sumatra_jewelry_app/screens/boss/boss_dashboard_screen.dart';
import 'package:sumatra_jewelry_app/screens/sales/sales_dashboard_screen.dart';
import 'package:sumatra_jewelry_app/screens/designer/designer_dashboard_screen.dart';
import 'package:sumatra_jewelry_app/screens/cor/cor_dashboard_screen.dart'; // Pastikan ini terimport
import 'package:sumatra_jewelry_app/screens/carver/carver_dashboard_screen.dart';
import 'package:sumatra_jewelry_app/screens/repairer/repairer_dashboard_screen.dart';
import 'package:sumatra_jewelry_app/screens/diamond_setter/diamond_setter_dashboard_screen.dart';
import 'package:sumatra_jewelry_app/screens/finisher/finisher_dashboard_screen.dart';
import 'package:sumatra_jewelry_app/screens/inventory/inventory_dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final Map<String, String> _dummyAccounts = {
    'boss': 'password', // Username: boss, Password: password
    'sales': 'password',
    'designer': 'password',
    'cor': 'password', // Menambahkan 'cor' ke dummy accounts
    'carver': 'password',
    'repairer': 'password',
    'diamondsetter': 'password',
    'finisher': 'password',
    'inventory': 'password',
  };

  void _login() {
    String username = _usernameController.text;
    String password = _passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Username dan Password tidak boleh kosong!'),
        ),
      );
      return;
    }

    // Periksa otentikasi dummy
    if (_dummyAccounts.containsKey(username) &&
        _dummyAccounts[username] == password) {
      Widget?
      nextScreen; // Menggunakan Widget? karena bisa jadi null jika tidak cocok

      // Gunakan 'username' yang berhasil login sebagai 'userRole'
      // Untuk dashboard yang sudah kita modifikasi, wajib kirim userRole.
      // Untuk dashboard yang belum dimodifikasi (Boss, Sales, Repairer, Inventory), biarkan seperti sebelumnya.
      if (username == 'boss') {
        nextScreen = const BossDashboardScreen();
      } else if (username == 'sales') {
        nextScreen = const SalesDashboardScreen();
      } else if (username == 'designer') {
        nextScreen = DesignerDashboardScreen();
      } else if (username == 'cor') {
        nextScreen = CorDashboardScreen();
      } else if (username == 'carver') {
        nextScreen = CarverDashboardScreen(
          userRole: username,
        ); // Diperbaiki di sini
      } else if (username == 'repairer') {
        nextScreen =
            const RepairerDashboardScreen(); // Repairer belum dimodifikasi, biarkan const
      } else if (username == 'diamondsetter') {
        // Perhatikan: username di dummy 'diamondsetter' tanpa underscore
        nextScreen = DiamondSetterDashboardScreen(
          userRole: username,
        ); // Diperbaiki di sini
      } else if (username == 'finisher') {
        nextScreen = FinisherDashboardScreen();
      } else if (username == 'inventory') {
        nextScreen =
            const InventoryDashboardScreen(); // Inventory belum dimodifikasi, biarkan const
      } else {
        // Ini seharusnya tidak tercapai jika username ada di _dummyAccounts
        // dan password benar, tapi sebagai fallback.
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Peran tidak dikenal atau terjadi kesalahan.'),
          ),
        );
        return;
      }

      // Pastikan nextScreen tidak null sebelum navigasi
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => nextScreen!),
      );
    } else {
      // Jika username tidak ditemukan atau password salah
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Username atau Password salah!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sumatra Jewelry'), centerTitle: true),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Pastikan path logo benar
              Image.asset('assets/logo_sumatra_jewelry.png', height: 150),
              const SizedBox(height: 48.0),
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 24.0),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
              ),
              const SizedBox(height: 36.0),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: const Text('Login', style: TextStyle(fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
