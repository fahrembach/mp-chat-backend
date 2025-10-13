import 'package:flutter/material.dart';

class WhatsAppAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onSearchTap;
  final VoidCallback onMenuTap;
  final TextEditingController searchController;
  final bool isSearching;

  const WhatsAppAppBar({
    Key? key,
    required this.onSearchTap,
    required this.onMenuTap,
    required this.searchController,
    required this.isSearching,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF1F2C34),
      elevation: 0,
      title: isSearching
          ? TextField(
              controller: searchController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Pesquisar conversas',
                hintStyle: TextStyle(color: Colors.white54),
                border: InputBorder.none,
              ),
            )
          : const Text(
              'WhatsApp',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
      actions: [
        IconButton(
          icon: Icon(isSearching ? Icons.close : Icons.search),
          onPressed: onSearchTap,
          color: Colors.white70,
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.white70),
          onSelected: (value) {
            if (value == 'settings') {
              onMenuTap();
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'settings',
              child: Row(
                children: [
                  Icon(Icons.settings, color: Colors.grey),
                  SizedBox(width: 8),
                  Text('Configurações'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
