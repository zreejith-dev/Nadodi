import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../features/auth/auth_provider.dart';
import '../theme/app_theme.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        return Scaffold(
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Spacer(flex: 2),
                  // Logo
                  Center(
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Icon(
                        Icons.landscape_rounded,
                        size: 50,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Title
                  Center(
                    child: Column(
                      children: [
                        Text(
                          'Welcome to Nadodi',
                          style: Theme.of(context).textTheme.displayMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Discover Kerala\'s hidden gems,\nplan trips, and save your favorites',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const Spacer(flex: 2),
                  // Sign in buttons
                  if (auth.isLoading)
                    const Center(child: CircularProgressIndicator())
                  else ...[
                    _AuthButton(
                      icon: Icons.g_mobiledata_rounded,
                      label: 'Continue with Google',
                      onPressed: auth.isLoading ? null : () => _signIn(context, auth, 'google'),
                    ),
                    const SizedBox(height: 12),
                    _AuthButton(
                      icon: Icons.apple_rounded,
                      label: 'Continue with Apple',
                      onPressed: auth.isLoading ? null : () => _signIn(context, auth, 'apple'),
                      isOutline: true,
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: auth.isLoading ? null : () => _continueAsGuest(context),
                      child: Text(
                        'Continue as Guest',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  // Terms
                  Text(
                    'By continuing, you agree to our Terms of Service and Privacy Policy',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _signIn(BuildContext context, AuthProvider auth, String provider) async {
    try {
      if (provider == 'google') {
        await auth.signInWithGoogle();
      } else {
        await auth.signInWithApple();
      }
      if (context.mounted && auth.isAuthenticated) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sign in failed: $e')),
        );
      }
    }
  }

  void _continueAsGuest(BuildContext context) {
    Navigator.pushReplacementNamed(context, '/home');
  }
}

class _AuthButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final bool isOutline;

  const _AuthButton({
    required this.icon,
    required this.label,
    this.onPressed,
    this.isOutline = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (isOutline) {
      return OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 22),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
    
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 22),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}