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
// repairer_dashboard_screen.dart sudah dihapus importnya (sesuai yang Anda sebutkan)

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController(); // Menggunakan username seperti kode Anda
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>(); // Untuk validasi form
  bool _isLoading = false;
  String _errorMessage = '';

  Future<void> _login() async {
    // Validasi form sebelum melanjutkan
    if (!_formKey.currentState!.validate()) {
      return; // Hentikan jika ada error validasi
    }

    setState(() {
      _isLoading = true;
      _errorMessage = ''; // Reset error message
    });

    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    // Simulasi autentikasi. Ganti dengan panggilan ke AuthService Anda nanti.
    await Future.delayed(const Duration(seconds: 1)); // Delay untuk simulasi loading

    // Logika autentikasi dummy Anda
    // Anda bisa menambahkan kondisi password jika diperlukan (misal: if (password != '123'))
    if (username.isEmpty || password.isEmpty) { // Ini sudah ditangani oleh validator di TextFormField
      setState(() {
        _errorMessage = 'Username dan password tidak boleh kosong.';
        _isLoading = false;
      });
      return;
    }

    Widget? nextScreen;

    // Simulasi login berhasil berdasarkan username sebagai role
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
      case 'diamond setter':
        nextScreen = const DiamondSetterDashboardScreen();
        break;
      case 'inventory':
        nextScreen = const InventoryDashboardScreen();
        break;
      default:
        setState(() {
          _errorMessage = 'Username atau password salah.';
        });
        _isLoading = false; // Pastikan loading dihentikan pada default
        return;
    }

    // Navigasi setelah login berhasil
    // Di sini, nextScreen dijamin tidak null karena default case akan melakukan return
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => nextScreen!),
    );

    // Ini mungkin tidak tercapai jika navigasi pushReplacement sudah dilakukan
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
      resizeToAvoidBottomInset: false, // Agar keyboard tidak mengecilkan background
      // AppBar dihapus untuk kesan fullscreen pada login page
      // Jika Anda ingin AppBar tetap ada, uncomment kode AppBar dan sesuaikan warnanya
      // appBar: AppBar(
      //   title: const Text('Login'),
      //   centerTitle: true,
      //   backgroundColor: Colors.transparent, // Agar transparan di atas background
      //   elevation: 0,
      // ),
      // extendBodyBehindAppBar: true, // Jika AppBar ada dan transparan
      body: Stack(
        children: [
          // Latar Belakang Gambar
          Positioned.fill(
            child: Image.asset(
              'assets/images/toko_sumatra.jpg', // Path gambar background
              fit: BoxFit.cover,
              colorBlendMode: BlendMode.darken,
              color: Colors.black.withOpacity(0.4), // Sedikit lebih gelap agar teks lebih jelas
            ),
          ),
          // Konten Login Form
          Center(
            child: SingleChildScrollView( // Agar form bisa di-scroll saat keyboard muncul
              padding: const EdgeInsets.all(24.0),
              child: Form( // Membungkus input dengan Form untuk validasi
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Logo
                    Image.asset(
                      'assets/images/logo_sumatra_jewelry.png', // Ganti dengan path logo Anda
                      height: 150, // Sesuaikan ukuran logo
                      // color: Colors.white.withOpacity(0.9), // Opsional: Beri warna jika logo monokrom
                    ),
                    const SizedBox(height: 50),

                    // Username Input
                    TextFormField( // Menggunakan TextFormField untuk validasi
                      controller: _usernameController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Username',
                        hintText: 'Masukkan username Anda',
                        prefixIcon: const Icon(Icons.person, color: Colors.white70),
                        labelStyle: const TextStyle(color: Colors.white70),
                        hintStyle: const TextStyle(color: Colors.white54),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.amber, width: 1.5), // Border emas
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.amberAccent, width: 2.5), // Border emas saat fokus
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.red, width: 1.5),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.redAccent, width: 2.5),
                        ),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.1), // Transparan
                        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Username tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Password Input
                    TextFormField( // Menggunakan TextFormField untuk validasi
                      controller: _passwordController,
                      obscureText: true, // Untuk menyembunyikan password
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Password',
                        hintText: 'Masukkan password Anda',
                        prefixIcon: const Icon(Icons.lock, color: Colors.white70),
                        labelStyle: const TextStyle(color: Colors.white70),
                        hintStyle: const TextStyle(color: Colors.white54),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.amber, width: 1.5), // Border emas
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.amberAccent, width: 2.5), // Border emas saat fokus
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.red, width: 1.5),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.redAccent, width: 2.5),
                        ),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.1), // Transparan
                        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Password tidak boleh kosong';
                        }
                        // Anda bisa menambahkan validasi panjang password di sini jika mau
                        // if (value.length < 6) {
                        //   return 'Password minimal 6 karakter';
                        // }
                        return null;
                      },
                    ),
                    const SizedBox(height: 30),

                    // Menampilkan error message (jika ada)
                    if (_errorMessage.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20.0),
                        child: Text(
                          _errorMessage,
                          style: const TextStyle(color: Colors.red, fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                      ),

                    // Login Button
                    SizedBox(
                      width: double.infinity, // Tombol mengisi lebar penuh
                      height: 50,
                      child: _isLoading
                          ? const Center(child: CircularProgressIndicator(color: Colors.amber)) // Indikator loading
                          : ElevatedButton(
                              onPressed: _login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.amber, // Warna emas
                                foregroundColor: Colors.black87, // Warna teks tombol
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: const BorderSide(color: Colors.amberAccent, width: 2), // Border emas pada tombol
                                ),
                                elevation: 8, // Efek bayangan
                              ),
                              child: const Text(
                                'Login',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                    ),
                    const SizedBox(height: 50),

                    // "Made by Elbert Wijaya"
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Text(
                        'Made by Elbert Wijaya', // Ganti dengan nama Anda/creator
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
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