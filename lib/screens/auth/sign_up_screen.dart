import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:inventory_app/services/auth_service.dart';
import 'package:provider/provider.dart';
import '../../providers/settings_provider.dart';
import '../../l10n/app_strings.dart';
import '../../theme/app_theme.dart';
import '../../services/auth_service.dart';
import '../../screens/home/main_shell.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  // Create the object that holds this screen's changing data
  // أنشئ الكائن الذي يحمل البيانات المتغيرة لهذه الشاشة
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // Controls password visibility for both password fields
  // يتحكم بإظهار كلمة السر في الحقلين
  bool _obscurePassword = true;
  // Reads the admin name field
  // يقرأ حقل اسم المدير
  final TextEditingController _adminNameController = TextEditingController();
  // Reads the shop name field
  // يقرأ حقل اسم المحل
  final TextEditingController _shopNameController = TextEditingController();
  // Reads the email field
  // يقرأ حقل الإيميل
  final TextEditingController _emailController = TextEditingController();
  // Reads the password field
  // يقرأ حقل كلمة السر
  final TextEditingController _passwordController = TextEditingController();
  // Reads the confirm password field
  // يقرأ حقل تأكيد كلمة السر
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  // Error message shown to the user
  String? _errorMessage;
  // True while the account is being created
  bool _isLoading = false;

  // Builds the same field style for every text field
  // يبني نفس شكل الحقل لكل الحقول
  InputDecoration _decoration(String label, IconData icon,
      {Widget? suffixIcon}) {
    return InputDecoration(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      filled: true,
      fillColor: Colors.white,
      labelText: label,
      prefixIcon: Icon(icon),
      suffixIcon: suffixIcon,
      // Default field style
      // الشكل الافتراضي للحقل
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
      // Border on focus
      // الحدود عند التركيز
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: AppColors.primary, width: 1.5)),
      // Unfocused border
      // الحدود بدون تركيز
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1)),
    );
  }

  @override
  void dispose() {
    _adminNameController.dispose();
    _shopNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Checks the fields and returns an error message, or null if all is fine
  // يفحص الحقول ويرجع رسالة الخطأ، أو null إذا كل شي تمام
  String? _validate() {
    // Read the values and trim extra spaces
    // اقرأ القيم وامسح المسافات الزائدة
    final adminName = _adminNameController.text.trim();
    final shopName = _shopNameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    // Any empty field is an error
    // أي حقل فارغ هو خطأ
    if (adminName.isEmpty ||
        shopName.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      return AppStrings.of(context).fillAllFields;
    }
    // The email must contain @
    // الإيميل لازم يحتوي على @
    if (!email.contains('@')) {
      return AppStrings.of(context).invalidEmail;
    }
    // The password must be at least 6 characters
    // كلمة السر لازم تكون 6 أحرف على الأقل
    if (password.length < 6) {
      return AppStrings.of(context).weakPassword;
    }
    // The confirmation must match the password
    // التأكيد لازم يطابق كلمة السر
    if (password != confirmPassword) {
      return AppStrings.of(context).passwordsNotMatch;
    }
    // No errors found
    // ما في أخطاء
    return null;
  }

  Future<void> _signUp() async {
    final error = _validate();
    if (error != null) {
      setState(() {
        _errorMessage = error;
      });
      return;
    }
    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });
    final auth = AuthService();
    try {
      final credential = await auth.signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text);
      // Save the new admin's profile in Firestore
      await auth.createUserDoc(
          uid: credential.user!.uid,
          name: _adminNameController.text.trim(),
          email: _emailController.text.trim());
      // Save the shop name in the shop settings document
      await auth.createShopDoc(shopName: _shopNameController.text.trim());
      // Create the setup docunent last, because it closes sign up
      await auth.createSetupDoc(adminUid: credential.user!.uid);

      if (!mounted) return;
      // Replace the sign up screen with the home screen
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainShell(isAdmin: true)),
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      // Stop if the screen was closed while we were waiting
      // نوقف إذا انسكرت الشاشة وإحنا نستنى
      if (!mounted) return;

      // Pick the right message based on Firebase's error code
      // نختار الرسالة المناسبة حسب كود الخطأ من Firebase
      final strings = AppStrings.of(context);
      String message;
      switch (e.code) {
        case 'email-already-in-use':
          message = strings.emailInUse;
          break;
        case 'weak-password':
          message = strings.weakPasswordFirebase;
          break;
        case 'network-request-failed':
          message = strings.networkError;
          break;
        default:
          message = strings.signUpFailed;
      }

      // Show the message and stop the loading
      // نعرض الرسالة ونوقف التحميل
      setState(() {
        _errorMessage = message;
        _isLoading = false;
      });
    } catch (e) {
      // Stop if the screen was closed while we were waiting
      // نوقف إذا انسكرت الشاشة وإحنا نستنى
      if (!mounted) return;

      // Any other unexpected error gets the general message
      // أي خطأ غير متوقع ياخد الرسالة العامة
      setState(() {
        _errorMessage = AppStrings.of(context).signUpFailed;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Transparent app bar, only to show the back arrow
      // شريط علوي شفاف فقط لإظهار سهم الرجوع
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: AppColors.primary,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextButton(
              style: TextButton.styleFrom(
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                foregroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
              ),
              onPressed: () {
                // Get the settings provider without listening to it
                // احصل على المزوّد بدون الاستماع له
                final settings = context.read<SettingsProvider>();
                // Switch to the other language
                // بدّل للغة الثانية
                settings.setLocale(
                  Locale(settings.locale.languageCode == 'ar' ? 'en' : 'ar'),
                );
              },
              child: Text(AppStrings.of(context).switchLanguage),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          // Lets the form scroll when the keyboard opens
          // يسمح للفورم بالتمرير عند فتح الكيبورد
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  // App logo
                  // شعار التطبيق
                  Image.asset(
                    'assets/images/app_logo.png',
                    width: 100,
                    height: 100,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppStrings.of(context).signUpTitle,
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _adminNameController,
                    decoration: _decoration(
                        AppStrings.of(context).adminName, Icons.person_outline),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _shopNameController,
                    decoration: _decoration(
                        AppStrings.of(context).shopName, Icons.store_outlined),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    decoration: _decoration(
                        AppStrings.of(context).email, Icons.email_outlined),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: _decoration(
                      AppStrings.of(context).password,
                      Icons.lock_outlined,
                      // Eye button to show or hide the password
                      // زر العين لإظهار أو إخفاء كلمة السر
                      suffixIcon: IconButton(
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
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: _obscurePassword,
                    decoration: _decoration(
                        AppStrings.of(context).confirmPassword,
                        Icons.lock_outlined),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    // Full width
                    // العرض الكامل
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                      ),
                      onPressed: _isLoading ? null : _signUp,
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(AppStrings.of(context).createAccount,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: AppColors.danger),
                      ),
                    ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(AppStrings.of(context).haveAccount),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(AppStrings.of(context).login,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
