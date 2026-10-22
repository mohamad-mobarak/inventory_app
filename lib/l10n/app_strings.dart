import 'package:flutter/material.dart';

class AppStrings {
  // The current language (ar or en)
  final Locale locale;
  AppStrings(this.locale);
  // Shortcut to get the texts from any screen
  static AppStrings of(BuildContext context) =>
      Localizations.of<AppStrings>(context, AppStrings)!;
  String get login => locale.languageCode == 'ar' ? 'تسجيل الدخول' : 'Login';
  String get appTitle => locale.languageCode == 'ar'
      ? 'نظام ادارة المخزون'
      : 'Inventory Management';
  String get email => locale.languageCode == 'ar' ? 'بريد الكتروني' : 'Email';
  String get password => locale.languageCode == 'ar' ? 'كلمة السر' : 'Password';
  String get emailHint => 'example@email.com';
  String get noAccount => locale.languageCode == 'ar'
      ? 'ليس لديك حساب ؟'
      : "Don't have an account ?";
  String get signUP => locale.languageCode == 'ar' ? 'سجل الان' : 'Sign Up';
  String get invalidCredentials => locale.languageCode == 'ar'
      ? 'البريد الالكتروني او كلمة السر غير صحيحة'
      : 'Incorrect email or password.';
  String get accountDisabled => locale.languageCode == 'ar'
      ? 'هذا الحساب معطلز يرجى التواصل مع المدير'
      : 'This account is disabled. Plese contact the manager';
  String get accountNotRegistered => locale.languageCode == 'ar'
      ? 'هذا الحساب غير مسجل لدى الحل'
      : 'This account is not registered with this shop';
  // Lable of the button that switches to the other language
  String get switchLanguage => locale.languageCode == 'ar' ? 'English' : 'عربي';
  // Sign up screen texts
  // نصوص شاشة التسجيل
  String get signUpTitle => locale.languageCode == 'ar'
      ? 'إنشاء حساب المدير'
      : 'Create admin account';
  String get adminName =>
      locale.languageCode == 'ar' ? 'اسم المدير' : 'Admin name';
  String get shopName =>
      locale.languageCode == 'ar' ? 'اسم المحل' : 'Shop name';
  String get confirmPassword =>
      locale.languageCode == 'ar' ? 'أعد كتابة كلمة السر' : 'Confirm password';
  String get createAccount =>
      locale.languageCode == 'ar' ? 'إنشاء الحساب' : 'Create account';
  String get haveAccount =>
      locale.languageCode == 'ar' ? 'عندك حساب؟' : 'Already have an account?';
  // Shown when any field is empty
  // تظهر عندما يكون أي حقل فارغاً
  String get fillAllFields => locale.languageCode == 'ar'
      ? 'عبّي كل الحقول'
      : 'Please fill in all fields';
  // Shown when the email has no @
  // تظهر عندما لا يحتوي الإيميل على @
  String get invalidEmail => locale.languageCode == 'ar'
      ? 'الإيميل غير صحيح'
      : 'Invalid email address';
  // Shown when the password is shorter than 6 characters
  // تظهر عندما تكون كلمة السر أقل من 6 أحرف
  String get weakPassword => locale.languageCode == 'ar'
      ? 'كلمة السر لازم تكون 6 أحرف على الأقل'
      : 'Password must be at least 6 characters';
  // Shown when the two passwords are different
  // تظهر عندما تختلف كلمتا السر
  String get passwordsNotMatch => locale.languageCode == 'ar'
      ? 'كلمتا السر غير متطابقتين'
      : 'Passwords do not match';
  String get emailInUse => locale.languageCode == 'ar'
      ? 'هذا البريد الإلكتروني مستخدم من قبل'
      : 'This email is already in use';

  String get weakPasswordFirebase => locale.languageCode == 'ar'
      ? 'كلمة السر ضعيفة، اختر كلمة أقوى'
      : 'The password is too weak, choose a stronger one';

  String get networkError => locale.languageCode == 'ar'
      ? 'مشكلة بالاتصال، تأكد من الإنترنت وجرّب مرة أخرى'
      : 'Connection problem, check your internet and try again';

  String get signUpFailed => locale.languageCode == 'ar'
      ? 'حدث خطأ غير متوقع، جرّب مرة أخرى'
      : 'An unexpected error occurred, try again';
}

// Tells Flutter how to load AppStrings
class AppStringsDelegate extends LocalizationsDelegate<AppStrings> {
  // Empty constructor so we can use const
  const AppStringsDelegate();
  @override
  // Checks if the language is supported (ar or en)
  bool isSupported(Locale locale) => ['ar', 'en'].contains(locale.languageCode);
  // Creates the AppStrings object for the chosen language
  @override
  Future<AppStrings> load(Locale locale) async => AppStrings(locale);
  // No need to reload the delegate itself
  @override
  bool shouldReload(AppStringsDelegate old) => false;
}
