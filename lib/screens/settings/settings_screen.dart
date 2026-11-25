import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../services/settings_service.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_strings.dart';
import '../../providers/settings_provider.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';

// Shows the app settings for the logged-in user
class SettingsScreen extends StatefulWidget {
  // Tells the screen if the user is the admin
  final bool isAdmin;

  const SettingsScreen({super.key, required this.isAdmin});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Reads the user's name from Firestore
  final _authService = AuthService();

  // Holds the currency text typed by the admin
  final _currencyController = TextEditingController();

  // Stores the user's name after it loads
  String _name = '';

  @override
  void initState() {
    super.initState();
    _loadName();
  }

  @override
  void dispose() {
    _currencyController.dispose();
    super.dispose();
  }

  // Loads the logged-in user's name once when the screen opens
  Future<void> _loadName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final name = await _authService.getUserName(user.uid);
    if (!mounted) return;
    setState(() {
      _name = name ?? '';
    });
  }

  // Saves the currency to Firestore
  Future<void> _saveCurrency() async {
    final currency = _currencyController.text.trim();
    if (currency.isEmpty) return;
    await SettingsService().saveCurrency(currency);
    if (!mounted) return;
    context.read<SettingsProvider>().setCurrency(currency);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(
        children: [
          Icon(
            Icons.check_circle,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
          const SizedBox(
            width: 10,
          ),
          Text(AppStrings.of(context).currencySaved)
        ],
      ),
      backgroundColor: Theme.of(context).colorScheme.primary,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ));
  }

  // Builds one white card with an icon box and a title
  Widget _buildCard({
    required IconData icon,
    required String title,
    required Widget child,
    Color? accent,
    Widget? badge,
  }) {
    final colors = Theme.of(context).colorScheme;
    final iconColor = accent ?? colors.primary;

    return Card(
      elevation: 1,
      margin: EdgeInsets.zero,
      color: colors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Shows the icon inside a soft tinted square
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconColor),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (badge != null) badge,
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }

  // Builds one selectable button for the language and theme choices
  Widget _buildOption({
    required String label,
    required bool selected,
    required VoidCallback onPressed,
    IconData? icon,
  }) {
    final colors = Theme.of(context).colorScheme;

    return Expanded(
      child: SizedBox(
        height: 48,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            elevation: 0,
            padding: EdgeInsets.zero,
            backgroundColor: selected
                ? colors.primary
                : Theme.of(context).scaffoldBackgroundColor,
            foregroundColor: selected ? colors.onPrimary : colors.onSurface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16),
                const SizedBox(width: 4),
              ],
              Text(label),
            ],
          ),
        ),
      ),
    );
  }

  // Builds one label and value line for the account card
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        runSpacing: 4,
        children: [
          Text(
            '$label :',
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(
            width: 20,
          ),
          Text(value),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final colors = Theme.of(context).colorScheme;
    // Rebuilds the screen when the language or theme changes
    final settings = context.watch<SettingsProvider>();
    final email = FirebaseAuth.instance.currentUser?.email ?? '';

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 72,
        leadingWidth: 72,
        // Shows the app logo inside a white rounded box
        leading: Padding(
          padding: const EdgeInsets.all(8),
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Image.asset('assets/images/app_logo.png'),
          ),
        ),
        // Shows the app name above the screen name
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              s.inventorySystem,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(s.settings, style: const TextStyle(fontSize: 14)),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Lets the user choose Arabic or English
          _buildCard(
            icon: Icons.language,
            title: s.language,
            child: Row(
              children: [
                _buildOption(
                  label: s.arabic,
                  selected: settings.locale.languageCode == 'ar',
                  onPressed: () {
                    // Set the app langguage to Arabic
                    context
                        .read<SettingsProvider>()
                        .setLocale(const Locale('ar'));
                  },
                ),
                const SizedBox(width: 8),
                _buildOption(
                  label: s.english,
                  selected: settings.locale.languageCode == 'en',
                  onPressed: () {
                    context
                        .read<SettingsProvider>()
                        .setLocale(const Locale('en'));
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Lets the user choose light, dark or the device theme
          _buildCard(
            icon: Icons.palette,
            title: s.appearance,
            child: Row(
              children: [
                _buildOption(
                  label: s.lightMode,
                  icon: Icons.light_mode,
                  selected: settings.themeMode == ThemeMode.light,
                  onPressed: () {
                    context
                        .read<SettingsProvider>()
                        .setThemeMode(ThemeMode.light);
                  },
                ),
                const SizedBox(width: 6),
                _buildOption(
                  label: s.darkMode,
                  icon: Icons.dark_mode,
                  selected: settings.themeMode == ThemeMode.dark,
                  onPressed: () {
                    context
                        .read<SettingsProvider>()
                        .setThemeMode(ThemeMode.dark);
                  },
                ),
                const SizedBox(width: 6),
                _buildOption(
                  label: s.systemMode,
                  icon: Icons.phone_android,
                  selected: settings.themeMode == ThemeMode.system,
                  onPressed: () {
                    context
                        .read<SettingsProvider>()
                        .setThemeMode(ThemeMode.system);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Shows the account details as read-only text
          _buildCard(
            icon: Icons.person,
            title: s.accountInfo,
            child: Column(
              children: [
                _buildInfoRow(s.name, _name),
                const Divider(height: 1),
                _buildInfoRow(s.email, email),
                const Divider(height: 1),
                _buildInfoRow(s.role, widget.isAdmin ? s.admin : s.seller),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Shows the currency card to the admin only
          if (widget.isAdmin) ...[
            _buildCard(
              icon: Icons.payments,
              title: s.currency,
              accent: AppColors.warning,
              badge: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  s.adminOnly,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.warning,
                  ),
                ),
              ),
              child: settings.currency == null
                  ? Row(
                      children: [
                        // Takes the currency symbol typed by the admin
                        Expanded(
                          child: TextField(
                            controller: _currencyController,
                            decoration: InputDecoration(
                              hintText: s.currencyHint,
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Saves the typed currency
                        SizedBox(
                          height: 48,
                          child: ElevatedButton(
                            onPressed: () {
                              _saveCurrency();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colors.primary,
                              foregroundColor: colors.onPrimary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: Text(s.save),
                          ),
                        ),
                      ],
                    )
                  : Text('${s.currency}: ${settings.currency!}'),
            ),
            const SizedBox(height: 12),
          ],

          // Shows the app version as plain text
          _buildCard(
            icon: Icons.info,
            title: s.aboutApp,
            child: _buildInfoRow(s.versionNumber, '1.0.0'),
          ),
          const SizedBox(height: 12),

          // Logs the user out of the app
          SizedBox(
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () {
                _authService.signOut();
              },
              icon: const Icon(Icons.logout),
              label: Text(s.logout),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.danger,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
