// Basic Flutter widgets (StatefulWidget, Scaffold, ...)
// ويدجتس فلاتر الأساسية
import 'package:flutter/material.dart';
// Firebase Auth to know if a user is already signed in
// فايربيس أوث لنعرف إذا في مستخدم مسجّل دخول
import 'package:firebase_auth/firebase_auth.dart';
// Our service that talks to Firebase
// السيرفس تبعنا اللي بتحكي مع فايربيس
import '../../services/auth_service.dart';
// Temporary home page for active users
// صفحة رئيسية مؤقتة للحسابات الفعّالة
import '../sellers/sellers_screen.dart';
// Login page
// صفحة تسجيل الدخول
import 'login_screen.dart';

// Decides which screen opens first when the app starts
// بتقرر أي شاشة تنفتح أول لما يشتغل التطبيق
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  // Service object used to call our Firebase functions
  // كائن السيرفس لنستدعي فيه دوالنا
  final AuthService _authService = AuthService();
  // Holds the screen we decided to open (filled in initState)
  // بيحمل الشاشة اللي قررنا نفتحها (بنعطيه قيمة بـ initState)
  late final Future<Widget> _startScreen;

  @override
  void initState() {
    super.initState();
    // Start the check once, when the gate is created
    // منبلّش الفحص مرة وحدة بس، لما تنعمل البوابة
    _startScreen = _decideScreen();
  }

  // Checks the user and returns the screen to open
  // بتفحص المستخدم وبترجع الشاشة اللي لازم تنفتح
  Future<Widget> _decideScreen() async {
    // Wait for Firebase to tell us who is signed in (null = nobody)
    // منستنى فايربيس يقول مين مسجّل دخول (null يعني ما حدا)
    final user = await FirebaseAuth.instance.authStateChanges().first;
    // No signed in user, so show login
    // ما في مستخدم، فنفتح اللوجين
    if (user == null) {
      return LoginScreen();
    }
    // Ask Firestore if this account is active
    // منسأل فايرستور إذا الحساب فعّال
    final isActive = await _authService.isUserActive(user.uid);
    // Disabled account: sign out and go to login
    // حساب معطّل: منطلّعه ومنفتح اللوجين
    if (!isActive) {
      await _authService.signOut();
      return LoginScreen();
    }
    // Active account: open the home page
    // حساب فعّال: منفتح الصفحة الرئيسية
    return SellersScreen();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      // The check we started in initState
      // الفحص اللي بلّشناه بـ initState
      future: _startScreen,
      builder: (context, snapshot) {
        // Still checking: show a loading circle
        // لسا عم نفحص: منعرض دايرة تحميل
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        // Something failed (for example no internet): go to login
        // صار خطأ (مثلاً النت): منفتح اللوجين
        if (snapshot.hasError) {
          return LoginScreen();
        }
        // Check finished: show the chosen screen
        // خلص الفحص: منعرض الشاشة اللي اخترناها
        return snapshot.data!;
      },
    );
  }
}
