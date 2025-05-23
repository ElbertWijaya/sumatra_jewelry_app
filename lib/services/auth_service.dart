import 'package:flutter/foundation.dart';

/// Dummy AuthService for demonstration and future backend integration.
/// In production, replace all dummy logic with real authentication APIs.
class AuthService {
  static final AuthService _instance = AuthService._internal();

  factory AuthService() => _instance;

  AuthService._internal();

  String? _currentUserId;

  /// Simulates user login. Replace with real authentication logic.
  Future<bool> login({
    required String username,
    required String password,
  }) async {
    try {
      // TODO: Integrate with real authentication backend.
      await Future.delayed(const Duration(milliseconds: 500));
      if (username.isNotEmpty && password.isNotEmpty) {
        _currentUserId = username;
        return true;
      }
      return false;
    } catch (e, stack) {
      debugPrint('AuthService.login error: $e\n$stack');
      return false;
    }
  }

  /// Simulates user logout.
  Future<void> logout() async {
    _currentUserId = null;
    // TODO: Add backend logic if needed.
  }

  /// Returns true if a user is currently logged in.
  bool get isLoggedIn => _currentUserId != null;

  /// Returns the current user ID, if logged in.
  String? get currentUserId => _currentUserId;
}
