import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'providers/settings_provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: AppFirebaseOptions.web);
  // Provide one SettingsProvider to the whole app
  runApp(
    ChangeNotifierProvider(
        create: (_) => SettingsProvider(), child: const MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Listen to the settings; rebuild this widget when they change
    final settings = context.watch<SettingsProvider>();
    return MaterialApp(
      theme: AppTheme.light(),
      // Theme used when the device is in dark mode
      darkTheme: AppTheme.dark(),
      // Use the user's theme choice instead of the device setting
      themeMode: settings.themeMode,
      // Current app language, taken from the user's choice
      locale: settings.locale,
      // Languages the app supports: Arabic and English
      supportedLocales: const [Locale('ar'), Locale('en')],
      // Translates built-in widgets (buttons, dates) and flips layout to RTL
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      debugShowCheckedModeBanner: false,
      home: const Scaffold(
        body: Center(child: Text('Inventory App')),
      ),
    );
  }
}
