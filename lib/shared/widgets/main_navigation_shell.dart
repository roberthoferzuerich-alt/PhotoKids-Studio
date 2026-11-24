import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:photokids_studio/core/theme/app_colors.dart';

class MainNavigationShell extends StatelessWidget {
  final Widget child;

  const MainNavigationShell({super.key, required this.child});

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/albums')) {
      return 1;
    }
    if (location.startsWith('/slideshow')) {
      return 2;
    }
    if (location.startsWith('/settings') || location.startsWith('/cloud')) {
      return 3;
    }
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/albums');
        break;
      case 2:
        context.go('/slideshow');
        break;
      case 3:
        context.go('/settings');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _calculateSelectedIndex(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final navBgColor = isDark ? const Color(0xFF201A2C) : Colors.white;

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        color: navBgColor,
        child: SafeArea(
          top: false,
          child: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              child: NavigationBar(
                selectedIndex: selectedIndex,
                onDestinationSelected: (idx) => _onItemTapped(idx, context),
                height: 68,
                backgroundColor: navBgColor,
                destinations: const [
                  NavigationDestination(
                    icon: Icon(Icons.photo_library_outlined),
                    selectedIcon: Icon(Icons.photo_library_rounded, color: AppColors.pinkPrimary),
                    label: 'Galerie 🖼️',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.folder_open_rounded),
                    selectedIcon: Icon(Icons.folder_rounded, color: AppColors.turquoiseSecondary),
                    label: 'Alben 📚',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.slideshow_outlined),
                    selectedIcon: Icon(Icons.slideshow_rounded, color: AppColors.purpleAccent),
                    label: 'Diashow 🎬',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.family_restroom_outlined),
                    selectedIcon: Icon(Icons.family_restroom_rounded, color: AppColors.yellowDark),
                    label: 'Eltern ⚙️',
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
