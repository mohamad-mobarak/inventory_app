import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:inventory_app/theme/app_theme.dart';
import '../../l10n/app_strings.dart';
import '../../services/seller_service.dart';

class AddSellerScreen extends StatefulWidget {
  const AddSellerScreen({super.key});

  @override
  State<AddSellerScreen> createState() => _AddSellerScreenState();
}

class _AddSellerScreenState extends State<AddSellerScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  // Our service object, used to create the seller account
  final SellerService _sellerService = SellerService();
  // True while the seller account is being created
  bool _isLoading = false;
  // Error message shown under the button, null when there is no error
  String? _errorMessage;
  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Builds the same field style used in the login screen
  InputDecoration _fieldStyle(String label, IconData icon,
      {Widget? suffix, String? helper}) {
    return InputDecoration(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      filled: true,
      fillColor: Theme.of(context).colorScheme.surface,
      labelText: label,
      helperText: helper,
      prefixIcon: Icon(icon),
      suffixIcon: suffix,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: AppColors.primary, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: AppColors.primary, width: 1),
      ),
    );
  }

  // Runs when the create-seller button is pressed
  Future<void> _addSeller() async {
    if (_nameController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = AppStrings.of(context).nameRequired;
      });
      return;
    }
    if (!_emailController.text.contains('@')) {
      setState(() {
        _errorMessage = AppStrings.of(context).invalidEmail;
      });
      return;
    }
    if (_passwordController.text.length < 6) {
      setState(() {
        _errorMessage = AppStrings.of(context).passwordMinHint;
      });
      return;
    }
    setState(() {
      // Show loading and clear any old error
      _isLoading = true;
      _errorMessage = null;
    });
    // Try to create the seller
    try {
      // Create the account through the service
      await _sellerService.addSeller(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text);
      // Do nothing if the screen was closed while waiting
      if (!mounted) return;
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      // Show a friendly message based on the error code
      setState(() {
        final s = AppStrings.of(context);
        switch (e.code) {
          case 'email-already-in-use':
            _errorMessage = s.emailInUse;
            break;
          case 'weak-password':
            _errorMessage = s.weakPasswordFirebase;
            break;
          case 'invalid-email':
            _errorMessage = s.invalidEmail;
            break;
          default:
            _errorMessage = s.signUpFailed;
        }
      });
    } finally {
      // Stop loading, but only if the screen is still open
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(s.addSeller)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: _fieldStyle(s.sellerName, Icons.person_outline),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: _fieldStyle(s.email, Icons.email_outlined),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: _fieldStyle(
                  s.password,
                  Icons.lock_outlined,
                  helper: s.passwordMinHint,
                  suffix: IconButton(
                    icon: Icon(_obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                  onPressed: _isLoading ? null : _addSeller,
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                          ),
                        )
                      : Text(s.createSellerAccount,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(_errorMessage!,
                      style: const TextStyle(color: AppColors.danger)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
