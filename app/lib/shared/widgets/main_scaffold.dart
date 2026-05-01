import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainScaffold extends StatelessWidget {
  const MainScaffold({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) {
          navigationShell.goBranch(index,
              initialLocation: index == navigationShell.currentIndex);
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.auto_awesome_outlined), label: 'My Core'),
          NavigationDestination(icon: Icon(Icons.chat_bubble_outline), label: 'AI Chat'),
          NavigationDestination(icon: Icon(Icons.checklist_outlined), label: 'Log'),
          NavigationDestination(icon: Icon(Icons.science_outlined), label: 'Lab'),
        ],
      ),
    );
  }
}
