import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/services/supabase_service.dart';

class AuthProvider extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();
  
  User? _user;
  bool _isLoading = false;
  bool _isRestoringSession = false;

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;
  bool get isRestoringSession => _isRestoringSession;

  Future<void> initialize() async {
    _isRestoringSession = true;
    notifyListeners();

    try {
      // Zero-tap: restore session silently
      final restored = await _supabaseService.restoreSession();
      if (restored) {
        _user = _supabaseService.currentUser;
      }
    } catch (e) {
      debugPrint('Session restore error: $e');
    }

    // Listen to auth changes
    _supabaseService.authStateChanges.listen((state) {
      _user = state.session?.user;
      notifyListeners();
    });

    _isRestoringSession = false;
    notifyListeners();
  }

  Future<void> signInWithGoogle() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _supabaseService.signInWithGoogle();
      // Result handled by authStateChanges listener
    } catch (e) {
      debugPrint('Google sign-in error: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signInWithApple() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _supabaseService.signInWithApple();
    } catch (e) {
      debugPrint('Apple sign-in error: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _supabaseService.signOut();
      _user = null;
    } catch (e) {
      debugPrint('Sign out error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}