import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../../providers/settings_provider.dart';
import '../../l10n/app_strings.dart';
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/auth_service.dart';
import '../../screens/auth/sign_up_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  // Create the object that holds this screen's changing data
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controls password visibility
  bool _obscurePassword = true;
  // Our auth service object, used to call sign in
  final AuthService _authService = AuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  // Error shown under the fields (wrong email or password)
  String? _fieldError;
  // Error shown in the banner (disabled or unregistered account)
  String? _bannerError;
  // Whether sign up is still open (true until settings/setup exists)
  bool _signUpOpen = true;
  @override
  void initState() {
    super.initState();
    _checkSignUp();
    // Showe the message left by the auth gate, if there is one
    _bannerError = context.read<SettingsProvider>().loginNotice;
    // Clears the message after the first so it shows only once
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SettingsProvider>().setLoginNotice(null);
    });
  }

  Future<void> _checkSignUp() async {
    final open = await _authService.isSignUpOpen();
    // Stop if the screen was close during the await
    if (!mounted) return;
    setState(() {
      _signUpOpen = open;
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Handles the login button press
  Future<void> _login() async {
    try {
// Read the email and trim extra spaces
      String email = _emailController.text.trim();
      String password = _passwordController.text.trim();
      // Sign in with Firebase Auth

      await _authService.signIn(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      // Show the wrong credentials error under the fields
      setState(() {
        // Check if the account is disabled
        if (e.code == 'user-disabled') {
          _bannerError = AppStrings.of(context).accountDisabled;
          _fieldError = null;
        } else {
          _bannerError = null;
          _fieldError = AppStrings.of(context).invalidCredentials;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Build the login screen structure

    return Scaffold(
      body: SafeArea(

          // Makes the form scrollable when the keyboard opens
          child: SingleChildScrollView(
              // Side spacing for the form
              child: Center(
                  child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 450),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              SizedBox(
                height: 12,
              ),
              // Put the language button on the right side
              Align(
                // Right edge of the screen
                alignment: Alignment.centerRight,
                child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                    ),
                    onPressed: () {
                      // Get the settings provider without listening to it
                      final settings = context.read<SettingsProvider>();
                      // Switch to the other language
                      settings.setLocale(
                        Locale(
                            settings.locale.languageCode == 'ar' ? 'en' : 'ar'),
                      );
                    },
                    child: Text(AppStrings.of(context).switchLanguage)),
              ),
              const SizedBox(
                height: 10,
              ),
              // App logo
              ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: Image.asset(
                  'assets/images/app_logo.png',
                  width: 100,
                  height: 100,
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              Text(
                AppStrings.of(context).appTitle,
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F766E)),
              ),
              const SizedBox(
                height: 20,
              ),
              // Show the red banner only when there is a banner error
              if (_bannerError != null)
                Container(
                  // Fill the full width of the form
                  width: double.infinity,
                  // Inner spacing around the text
                  padding: const EdgeInsets.all(12),
                  // Light red background with rounded corners
                  decoration: BoxDecoration(
                    color: AppColors.danger.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  // The banner message in the danger color
                  child: Text(
                    _bannerError!,
                    style: TextStyle(color: AppColors.danger),
                  ),
                ),
              // Space under the banner, only when it is visible
              if (_bannerError != null) const SizedBox(height: 12),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surface,
                    labelText: AppStrings.of(context).email,
                    hintText: AppStrings.of(context).emailHint,
                    prefixIcon: Icon(Icons.email_outlined),
                    // Default field style
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20)),
                    // Border on focus
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide:
                            BorderSide(color: AppColors.primary, width: 1.5)),
                    // Unfocused border
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.outlineVariant,
                            width: 1))),
              ),
              const SizedBox(
                height: 16,
              ),
              TextFormField(
                controller: _passwordController,

                decoration: InputDecoration(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface,
                  labelText: AppStrings.of(context).password,
                  prefixIcon: Icon(Icons.lock_outlined),
                  // Eye button to show or hide the password
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined),
                    onPressed: () {
                      // Rebuild the screen with the new value
                      setState(() {
                        // Flip the value: true becomes false, false becomes true
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  // Default field style
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide:
                        BorderSide(color: AppColors.primary, width: 1.5),
                  ),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.outlineVariant,
                          width: 1)),
                ),
                // Use the variable instead of a fixed value
                obscureText: _obscurePassword,
              ),
              const SizedBox(
                height: 24,
              ),
              SizedBox(
                // Full width
                width: double.infinity, height: 48,

                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                  child: Text(AppStrings.of(context).login,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  // Runs the login function when the button is pressed
                  onPressed: _login,
                ),
              ),
              if (_fieldError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    _fieldError!,
                    style: TextStyle(color: AppColors.danger),
                  ),
                ),
              const SizedBox(
                height: 10,
              ),
              if (_signUpOpen)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      AppStrings.of(context).noAccount,
                    ),
                    TextButton(
                      child: Text(AppStrings.of(context).signUP,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary)),
                      // Open the sign up screen on top of the login screen
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const SignUpScreen()));
                      },
                    ),
                  ],
                ),
            ],
          ),
        ),
      )))),
    );
  }
}
