// sumatra_jewelry_app/main.dart
import 'package:flutter/material.dart';
import 'package:sumatra_jewelry_app/screens/auth/login_screen.dart';
// Tambahkan import ini

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sumatra Jewelry App',
      theme: ThemeData(
        primarySwatch: Colors.brown, // Warna utama yang cocok untuk perhiasan
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      // Untuk tujuan pengujian Designer Dashboard, ubah baris di bawah ini.
      // Setelah selesai menguji, kembalikan ke 'LoginScreen()' atau logika autentikasi Anda.
      home:
          const LoginScreen(), // <<-- DIUBAH DI SINI UNTUK PENGUJIAN DESIGNER DASHBOARD
      // home: const LoginScreen(), // Ini adalah baris asli jika ingin kembali ke Login Screen
      debugShowCheckedModeBanner: false,
    );
  }
}
