// Basic Flutter widgets (StatefulWidget, Scaffold, ...)
import 'package:flutter/material.dart';
// Firebase Auth to know who is signed in
import 'package:firebase_auth/firebase_auth.dart';
import '../../l10n/app_strings.dart';
import '../../providers/settings_provider.dart';
import '../home/main_shell.dart';
// Our service that talks to Firebase
import '../../services/auth_service.dart';
// Login page
import 'login_screen.dart';
import '../../services/settings_service.dart';
import 'package:provider/provider.dart';

// Decides which screen opens, and reacts every time the user signs in or out
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  // Emits a new value every time a user signs in or out (null = nobody)
  late final Stream<User?> _authStream;

  @override
  void initState() {
    super.initState();
    // Create the stream once, when the gate is created
    _authStream = FirebaseAuth.instance.authStateChanges();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      // The stream we created in initState
      stream: _authStream,
      builder: (context, snapshot) {
        // Waiting for Firebase's first answer: show a loading circle
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        // Something failed: go to login
        if (snapshot.hasError) {
          return LoginScreen();
        }
        final user = snapshot.data;
        // No signed in user, so show login
        if (user == null) {
          return LoginScreen();
        }
        // Signed in user: check the account (the key restarts the check for a new user)
        return _UserCheck(key: ValueKey(user.uid), user: user);
      },
    );
  }
}

// Checks that the signed in account is active and opens the right home page
class _UserCheck extends StatefulWidget {
  // The signed in Firebase user
  final User user;

  const _UserCheck({super.key, required this.user});

  @override
  State<_UserCheck> createState() => _UserCheckState();
}

class _UserCheckState extends State<_UserCheck> {
  // Service object used to call our Firebase functions
  final AuthService _authService = AuthService();
  // Holds the screen we decided to open (filled in initState)
  late final Future<Widget> _screen;

  @override
  void initState() {
    super.initState();
    // Start the check once, when this widget is created
    _screen = _decideScreen();
  }

  // Checks the account and returns the screen to open
  Future<Widget> _decideScreen() async {
    // Get the user's role
    final role = await _authService.getUserRole(widget.user.uid);
    // Unregistered account: sign out and go to login
    if (role == null) {
      if (!mounted) return const SizedBox();

      // Save the unregistered account message before signing out
      context
          .read<SettingsProvider>()
          .setLoginNotice(AppStrings.of(context).accountNotRegistered);
      await _authService.signOut();
      return LoginScreen();
    }
    // Ask Firestore if this account is active
    final isActive = await _authService.isUserActive(widget.user.uid);
    // Disabled account: sign out and go to login
    if (!isActive) {
      if (!mounted) return const SizedBox();

      // Saves the disabled account message before signing out
      context
          .read<SettingsProvider>()
          .setLoginNotice(AppStrings.of(context).accountDisabled);
      await _authService.signOut();
      return LoginScreen();
    }

    String? currency;
    try {
      currency = await SettingsService().getCurrency();
    } catch (e) {
      // Ignores the error, the currency stays null
    }
    if (!mounted) return const SizedBox();
    context.read<SettingsProvider>().setCurrency(currency);
    // Active account: open the home page
    return MainShell(isAdmin: role == 'admin');
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      // The check we started in initState
      future: _screen,
      builder: (context, snapshot) {
        // Still checking: show a loading circle
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        // Something failed (for example no internet): go to login
        if (snapshot.hasError) {
          return LoginScreen();
        }
        // Check finished: show the chosen screen
        return snapshot.data!;
      },
    );
  }
}
