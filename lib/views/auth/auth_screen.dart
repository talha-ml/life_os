// lib/views/auth/auth_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import '../dashboard/dashboard_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with SingleTickerProviderStateMixin {
  final LocalAuthentication _auth = LocalAuthentication();
  bool _isAuthenticating = false;

  // 🚀 PREMIUM: Animation Controller for the glowing heartbeat effect
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Setting up the breathing/pulsing animation
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true); // Loops back and forth infinitely

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Auto-trigger authentication with a slight delay for smooth UI transition
    Future.delayed(const Duration(milliseconds: 500), () {
      _authenticate();
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _authenticate() async {
    bool authenticated = false;
    try {
      setState(() {
        _isAuthenticating = true;
      });

      // 🛠️ UNIVERSAL FIX maintained for maximum compatibility
      authenticated = await _auth.authenticate(
        localizedReason: 'Scan your fingerprint to unlock LifeOS',
      );

      setState(() {
        _isAuthenticating = false;
      });

      if (authenticated) {
        HapticFeedback.heavyImpact();
        if (mounted) {
          Navigator.pushReplacement(
            context,
            // 🚀 PREMIUM: Custom Fade Transition to Dashboard
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => const DashboardScreen(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
              transitionDuration: const Duration(milliseconds: 800),
            ),
          );
        }
      }
    } on PlatformException catch (e) {
      debugPrint("Biometric Error: $e");
      setState(() {
        _isAuthenticating = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline_rounded, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text(e.code == 'NotAvailable' ? 'Biometrics not available on this device.' : 'Authentication failed. Please try again.')),
              ],
            ),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 1000),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, 50 * (1 - value)),
                child: Opacity(
                  opacity: value,
                  child: child,
                ),
              );
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),

                // 🚀 ANIMATED FINGERPRINT VAULT
                ScaleTransition(
                  scale: _pulseAnimation,
                  child: Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: theme.primaryColor.withOpacity(0.1),
                      boxShadow: [
                        BoxShadow(
                          color: theme.primaryColor.withOpacity(0.2),
                          blurRadius: 40,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.fingerprint_rounded,
                      size: 100,
                      color: theme.primaryColor,
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                Text(
                  'LifeOS Secured',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 12),

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    'Authentication required to access your executive missions and dashboard.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 14, height: 1.5),
                  ),
                ),
                const Spacer(),

                // 🚀 ACTION BUTTON
                Padding(
                  padding: const EdgeInsets.only(bottom: 40),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _isAuthenticating
                        ? Column(
                      key: const ValueKey('loading'),
                      children: [
                        CircularProgressIndicator(color: theme.primaryColor),
                        const SizedBox(height: 16),
                        const Text("Verifying Identity...", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                      ],
                    )
                        : ElevatedButton.icon(
                      key: const ValueKey('button'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.primaryColor,
                        foregroundColor: Colors.white,
                        elevation: 8,
                        shadowColor: theme.primaryColor.withOpacity(0.5),
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: _authenticate,
                      icon: const Icon(Icons.lock_open_rounded),
                      label: const Text('Tap to Unlock', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}