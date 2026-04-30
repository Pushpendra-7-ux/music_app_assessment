import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Simple auth state — just tracks whether user is logged in.
/// Uses SharedPreferences to persist login status across app restarts.
class AuthViewmodel extends StateNotifier<AsyncValue<bool>> {
  AuthViewmodel() : super(const AsyncValue.loading());

  static const _loginKey = 'is_logged_in';
  static const _emailKey = 'user_email';

  /// Check if user was previously logged in
  Future<void> checkLoginStatus() async {
    state = const AsyncValue.loading();
    try {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool(_loginKey) ?? false;
      state = AsyncValue.data(isLoggedIn);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Mock login — just validates email format and password length
  Future<String?> login({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();

    // simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    // basic validation
    if (email.isEmpty || !email.contains('@')) {
      state = const AsyncValue.data(false);
      return 'Please enter a valid email address';
    }
    if (password.length < 4) {
      state = const AsyncValue.data(false);
      return 'Password must be at least 4 characters';
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_loginKey, true);
      await prefs.setString(_emailKey, email);
      state = const AsyncValue.data(true);
      return null; // null means success
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return 'Something went wrong. Please try again.';
    }
  }

  /// Logout and clear stored data
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_loginKey);
    await prefs.remove(_emailKey);
    state = const AsyncValue.data(false);
  }

  /// Get the stored email
  Future<String> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_emailKey) ?? 'User';
  }
}

final authViewmodelProvider =
    StateNotifierProvider<AuthViewmodel, AsyncValue<bool>>((ref) {
  return AuthViewmodel();
});
