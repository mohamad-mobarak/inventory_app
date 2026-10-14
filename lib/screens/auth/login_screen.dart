import 'dart:html';

import 'package:flutter/material.dart';
import 'package:inventory_app/theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  // Create the object that holds this screen's changing data
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controls password visibility
  bool _obscurePassword = true;
  @override
  Widget build(BuildContext context) {
    // Build the login screen structure
    return Scaffold(
      body: SafeArea(
          child: Center(
              // Side spacing for the form
              child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(
              height: 10,
            ),
            // App logo
            Image.asset(
              'assets/images/app_logo.png',
              width: 100,
              height: 100,
            ),
            const SizedBox(
              height: 16,
            ),
            const Text(
              'نظام ادارة المخزون',
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F766E)),
            ),
            const SizedBox(
              height: 20,
            ),
            TextFormField(
              decoration: InputDecoration(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  filled: true,
                  fillColor: Colors.white,
                  labelText: 'بريد ألكتروني',
                  hintText: 'example@email.com',
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
                      borderSide:
                          BorderSide(color: Colors.grey.shade300, width: 1))),
            ),
            const SizedBox(
              height: 16,
            ),
            TextFormField(
              decoration: InputDecoration(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                filled: true,
                fillColor: Colors.white,
                labelText: 'كلمة سر',
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
                  borderSide: BorderSide(color: AppColors.primary, width: 1.5),
                ),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide:
                        BorderSide(color: Colors.grey.shade300, width: 1)),
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
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                ),
                child: Text('تسجيل الدخول',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                onPressed: () {},
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'ليس لديك حساب ؟',
                ),
                TextButton(
                  child: Text('سجل الان',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary)),
                  onPressed: () {},
                ),
              ],
            ),
          ],
        ),
      ))),
    );
  }
}
