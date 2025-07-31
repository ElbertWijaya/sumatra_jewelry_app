import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

/// AuthService for handling authentication with the backend.
/// Integrates with the backend API for login and account management.
class AuthService {
  static final AuthService _instance = AuthService._internal();

  factory AuthService() => _instance;

  AuthService._internal();

  Map<String, dynamic>? _currentAccount;

  /// Login ke backend, return true jika sukses dan simpan akun.
  Future<bool> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('http://10.173.96.56/sumatra_api/login.php'),
        body: {
          'username': username,
          'password': password, // Kirim plain, hash di backend
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          _currentAccount = data['account'];
          debugPrint(
            '[AuthService] Login berhasil, accounts_id: [33m${_currentAccount?['accounts_id']}[0m',
          );
          return true;
        }
      }
      return false;
    } catch (e, stack) {
      debugPrint('AuthService.login error: $e\n$stack');
      return false;
    }
  }

  /// Simulates user logout.
  Future<void> logout() async {
    _currentAccount = null;
    // TODO: Add backend logic if needed.
  }

  /// Returns true if a user is currently logged in.
  bool get isLoggedIn => _currentAccount != null;

  /// Returns the current user ID, if logged in.
  String? get currentUserId {
    final id = _currentAccount?['accounts_id']?.toString();
    debugPrint(
      '[AuthService] currentUserId dipanggil, accounts_id: \x1B[36m$id\x1B[0m',
    );
    return id;
  }

  /// Returns the current user role, if logged in.
  String? get currentRole => _currentAccount?['accounts_role'];

  /// Returns the current username, if logged in.
  String? get currentUsername => _currentAccount?['accounts_username'];

  /// Returns the current user name, if logged in.
  String? get currentName => _currentAccount?['accounts_name'];

  /// Returns the current account data, if logged in.
  Map<String, dynamic>? get currentAccount => _currentAccount;
}
