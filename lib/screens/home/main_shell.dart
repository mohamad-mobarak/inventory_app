import 'package:flutter/material.dart';
import 'package:inventory_app/l10n/app_strings.dart';
import '../products/products_screen.dart';
import '../sellers/sellers_screen.dart';

class MainShell extends StatefulWidget {
  final bool isAdmin;
  const MainShell({super.key, required this.isAdmin});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    // Screen list depends on the user's role
    final List<Widget> screens = widget.isAdmin
        ? [ProductsScreen(isAdmin: true), const SellersScreen()]
        : [ProductsScreen(isAdmin: false)];
    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: (screens.length > 1)
          ? NavigationBar(
              selectedIndex: _currentIndex,
              onDestinationSelected: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              destinations: widget.isAdmin
                  ? [
                      NavigationDestination(
                        icon: Icon(Icons.inventory_2),
                        label: AppStrings.of(context).products,
                      ),
                      NavigationDestination(
                        icon: Icon(Icons.people),
                        label: AppStrings.of(context).sellers,
                      ),
                    ]
                  : [
                      NavigationDestination(
                        icon: Icon(Icons.inventory_2),
                        label: AppStrings.of(context).products,
                      ),
                    ],
            )
          : null,
    );
  }
}
