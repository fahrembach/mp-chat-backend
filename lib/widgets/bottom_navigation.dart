import 'package:flutter/material.dart';

class BottomNavigation extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const BottomNavigation({
    Key? key,
    required this.selectedIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: selectedIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      backgroundColor: const Color(0xFF1F2C34),
      selectedItemColor: const Color(0xFF25D366),
      unselectedItemColor: Colors.white60,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.chat_bubble_outline),
          activeIcon: Icon(Icons.chat_bubble),
          label: 'Conversas',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.circle_outlined),
          activeIcon: Icon(Icons.circle),
          label: 'Status',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.groups_outlined),
          activeIcon: Icon(Icons.groups),
          label: 'Comunidades',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.call_outlined),
          activeIcon: Icon(Icons.call),
          label: 'Chamadas',
        ),
      ],
    );
  }
}
