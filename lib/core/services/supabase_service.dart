import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_config.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  SupabaseClient get client => Supabase.instance.client;

  Future<void> initialize() async {
    await Supabase.initialize(
      url: SupabaseConfig.url,
      anonKey: SupabaseConfig.anonKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
    );
  }

  // Auth helpers
  User? get currentUser => client.auth.currentUser;
  Stream<AuthState> get authStateChanges => client.auth.onAuthStateChange;

  Future<AuthResponse> signInWithGoogle() async {
    return await client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: 'io.supabase.nadodi://login-callback',
    );
  }

  Future<AuthResponse> signInWithApple() async {
    return await client.auth.signInWithOAuth(
      OAuthProvider.apple,
      redirectTo: 'io.supabase.nadodi://login-callback',
    );
  }

  Future<void> signOut() async {
    await client.auth.signOut();
  }

  // Zero-tap: restore session silently
  Future<bool> restoreSession() async {
    final session = client.auth.currentSession;
    if (session != null) {
      try {
        await client.auth.refreshSession();
        return true;
      } catch (_) {
        return false;
      }
    }
    return false;
  }
}