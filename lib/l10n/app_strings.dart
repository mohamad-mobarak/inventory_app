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
      ? 'هذا الحساب معطل يرجى التواصل مع المدير'
      : 'This account is disabled. Plese contact the manager';
  String get accountNotRegistered => locale.languageCode == 'ar'
      ? 'هذا الحساب غير مسجل لدى المحل'
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
  String get sellers => locale.languageCode == 'ar' ? 'البائعون' : 'Sellers';
  String get addSeller =>
      locale.languageCode == 'ar' ? 'إضافة بائع' : 'Add seller';
  String get sellerActive => locale.languageCode == 'ar' ? 'فعّال' : 'Active';
  String get sellerDisabled =>
      locale.languageCode == 'ar' ? 'معطّل' : 'Disabled';
  String get sellerName =>
      locale.languageCode == 'ar' ? 'اسم البائع' : 'Seller name';
  String get passwordMinHint => locale.languageCode == 'ar'
      ? '6 أحرف على الأقل'
      : 'At least 6 characters';
  String get createSellerAccount => locale.languageCode == 'ar'
      ? 'إنشاء حساب البائع'
      : 'Create seller account';
  String get sellerDetails =>
      locale.languageCode == 'ar' ? 'تفاصيل البائع' : 'Seller details';
  String get accountActive =>
      locale.languageCode == 'ar' ? 'الحساب فعّال' : 'Account active';
  String get saveChanges =>
      locale.languageCode == 'ar' ? 'حفظ التعديلات' : 'Save changes';
  String get viewSellerSales =>
      locale.languageCode == 'ar' ? 'عرض مبيعات البائع' : 'View seller sales';
  String get nameRequired =>
      locale.languageCode == 'ar' ? 'الاسم مطلوب' : 'Name is required';
  String get loasFailed => locale.languageCode == 'ar'
      ? 'تعذّر تحميل البينات'
      : 'Could not load data';
  String get saveFailed => locale.languageCode == 'ar'
      ? 'تعذّر حفظ التعديلات'
      : 'Could not save change';
  String get products => locale.languageCode == 'ar' ? 'المنتجات' : 'Products';
  String get noProducts =>
      locale.languageCode == 'ar' ? 'لا توجد منتجات' : 'No products yet';
  String get available => locale.languageCode == 'ar' ? 'متوفر' : 'In stock';
  String get lowStock => locale.languageCode == 'ar' ? 'منخفض' : 'Low';
  String get outOfStock =>
      locale.languageCode == 'ar' ? 'نفد المخزون' : 'Out of stock';
  String get quantity => locale.languageCode == 'ar' ? 'الكمية' : 'Quantity';
  String get inventorySystem => locale.languageCode == 'ar'
      ? 'نظام إدارة المخزون'
      : 'Inventory Management';
  String get productName =>
      locale.languageCode == 'ar' ? 'اسم المنتج' : 'Product name';
  String get salePrice =>
      locale.languageCode == 'ar' ? 'سعر البيع' : 'Sale price';
  String get purchasePrice =>
      locale.languageCode == 'ar' ? 'سعر الشراء' : 'Purchase price';
  String get lowStockThreshold =>
      locale.languageCode == 'ar' ? 'حد التنبيه' : 'Low stock alert at';
  String get category => locale.languageCode == 'ar' ? 'الفئة' : 'Category';
  String get newCategoryName =>
      locale.languageCode == 'ar' ? 'اسم الفئة الجديدة' : 'New category name';
  String get addNewProduct =>
      locale.languageCode == 'ar' ? 'إضافة منتج جديد' : 'Add new product';
  String get enterProductName =>
      locale.languageCode == 'ar' ? 'أدخل اسم المنتج' : 'Enter product name';
  String get chooseCategory =>
      locale.languageCode == 'ar' ? 'اختر التصنيف' : 'Choose category';
  String get addNewCategory =>
      locale.languageCode == 'ar' ? 'إضافة تصنيف جديد' : 'Add new category';
  String get adminOnly =>
      locale.languageCode == 'ar' ? '(للمدير فقط)' : '(Admin only)';
  String get saveProduct =>
      locale.languageCode == 'ar' ? 'حفظ المنتج' : 'Save product';
  String get cancel => locale.languageCode == 'ar' ? 'إلغاء' : 'Cancel';
  String get editProduct =>
      locale.languageCode == 'ar' ? 'تعديل المنتج' : 'Edit product';
  String get currentQuantity =>
      locale.languageCode == 'ar' ? 'الكمية الحالية' : 'Current quantity';
  String get addQuantity =>
      locale.languageCode == 'ar' ? 'إضافة كمية' : 'Add quantity';
  String get correctQuantity =>
      locale.languageCode == 'ar' ? 'تصحيح الكمية' : 'Correct quantity';
  String get hideProduct =>
      locale.languageCode == 'ar' ? 'إخفاء المنتج' : 'Hide product';
  String get hideProductHint => locale.languageCode == 'ar'
      ? 'المنتج المخفي ما بيظهر بالقائمة '
      : 'A hidden product no longer appears in the list';
  // Validation messages for the add/edit product screens
  String get invalidSalePrice => locale.languageCode == 'ar'
      ? 'أدخل سعر بيع أكبر من صفر'
      : 'Enter a sale price greater than zero';
  String get invalidPurchasePrice => locale.languageCode == 'ar'
      ? 'أدخل سعر شراء أكبر من صفر'
      : 'Enter a purchase price greater than zero';
  String get invalidQuantity => locale.languageCode == 'ar'
      ? 'أدخل كمية صحيحة (صفر أو أكثر)'
      : 'Enter a valid quantity (0 or more)';
  String get invalidThreshold => locale.languageCode == 'ar'
      ? 'أدخل حد تنبيه صحيح (صفر أو أكثر)'
      : 'Enter a valid alert limit (0 or more)';
  String get enterCategoryName => locale.languageCode == 'ar'
      ? 'أدخل اسم الفئة الجديدة'
      : 'Enter the new category name';
  String get productNameExists => locale.languageCode == 'ar'
      ? 'اسم المنتج موجود مسبقاً'
      : 'A product with this name already exists';
  String get couldNotSaveProduct => locale.languageCode == 'ar'
      ? 'تعذر حفظ المنتج'
      : 'Could not save the product';
  String get editQuantity =>
      locale.languageCode == 'ar' ? 'تعديل الكمية' : 'Edit quantity';
  String get confirm => locale.languageCode == 'ar' ? 'تأكيد' : 'Confirm';
  String get couldNotHide => locale.languageCode == 'ar'
      ? 'تعذر  اخفاء المنتج'
      : 'Could not hide the product';
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
