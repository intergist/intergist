// Poker Sharp — Bottom Navigation Bar

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../tokens/spacing_tokens.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;

  const BottomNavBar({super.key, required this.currentIndex});

  static const _tabs = [
    (path: '/', icon: Icons.home_outlined, activeIcon: Icons.home, label: 'Home'),
    (path: '/stats', icon: Icons.bar_chart_outlined, activeIcon: Icons.bar_chart, label: 'Stats'),
    (path: '/settings', icon: Icons.settings_outlined, activeIcon: Icons.settings, label: 'Settings'),
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer.withValues(alpha: 0.9),
        border: Border(
          top: BorderSide(
            color: colorScheme.outlineVariant,
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 56,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_tabs.length, (i) {
              final tab = _tabs[i];
              final isActive = i == currentIndex;
              return Expanded(
                child: InkWell(
                  onTap: () {
                    if (!isActive) context.go(tab.path);
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isActive ? tab.activeIcon : tab.icon,
                        size: 22,
                        color: isActive
                            ? colorScheme.primary
                            : colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        tab.label,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: isActive
                              ? colorScheme.primary
                              : colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

/// Shell widget that wraps Home/Stats/Settings with bottom nav.
class ScaffoldWithNav extends StatelessWidget {
  final Widget child;
  final int currentIndex;

  const ScaffoldWithNav({
    super.key,
    required this.child,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavBar(currentIndex: currentIndex),
    );
  }
}
