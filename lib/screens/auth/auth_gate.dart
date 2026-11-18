// Basic Flutter widgets (StatefulWidget, Scaffold, ...)
import 'package:flutter/material.dart';
// Firebase Auth to know if a user is already signed in
import 'package:firebase_auth/firebase_auth.dart';
import 'package:inventory_app/screens/home/main_shell.dart';
import 'package:inventory_app/screens/products/products_screen.dart';
// Our service that talks to Firebase
import '../../services/auth_service.dart';
// Temporary home page for active users
import '../sellers/sellers_screen.dart';
// Login page
import 'login_screen.dart';

// Decides which screen opens first when the app starts
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  // Service object used to call our Firebase functions
  final AuthService _authService = AuthService();
  // Holds the screen we decided to open (filled in initState)
  late final Future<Widget> _startScreen;

  @override
  void initState() {
    super.initState();
    // Start the check once, when the gate is created
    _startScreen = _decideScreen();
  }

  // Checks the user and returns the screen to open
  Future<Widget> _decideScreen() async {
    // Wait for Firebase to tell us who is signed in (null = nobody)
    final user = await FirebaseAuth.instance.authStateChanges().first;
    // No signed in user, so show login
    if (user == null) {
      return LoginScreen();
    }
    // Ask Firestore if this account is active
    final isActive = await _authService.isUserActive(user.uid);
    // Disabled account: sign out and go to login
    if (!isActive) {
      await _authService.signOut();
      return LoginScreen();
    }
    // Get the user's role
    final role = await _authService.getUserRole(user.uid);
    // Active account: open the home page
    return MainShell(isAdmin: role == 'admin');
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      // The check we started in initState
      future: _startScreen,
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
