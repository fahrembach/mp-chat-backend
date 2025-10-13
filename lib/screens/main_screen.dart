import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../providers/chat_provider.dart';
import '../models/chat.dart';
import '../models/user.dart';
import '../widgets/conversation_tile.dart';
import '../widgets/search_bar.dart' as custom;
import '../widgets/whatsapp_app_bar.dart';
import '../widgets/bottom_navigation.dart';
import '../widgets/settings_drawer.dart';
import 'status_screen.dart';
import 'communities_screen.dart';
import 'calls_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: WhatsAppAppBar(
        onSearchTap: () => setState(() => _isSearching = !_isSearching),
        onMenuTap: () => _scaffoldKey.currentState?.openDrawer(),
        searchController: _searchController,
        isSearching: _isSearching,
      ),
      drawer: const SettingsDrawer(),
      body: Column(
        children: [
          if (_isSearching) custom.SearchBar(controller: _searchController),
          Expanded(
            child: _buildBody(),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigation(
        selectedIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return const ConversationsTab();
      case 1:
        return const StatusScreen();
      case 2:
        return const CommunitiesScreen();
      case 3:
        return const CallsScreen();
      default:
        return const ConversationsTab();
    }
  }

  Widget _buildFloatingActionButton() {
    switch (_selectedIndex) {
      case 0:
        return FloatingActionButton(
          onPressed: () => context.go('/users'),
          backgroundColor: const Color(0xFF25D366),
          child: const Icon(Icons.chat, color: Colors.white),
        );
      case 1:
        return FloatingActionButton(
          onPressed: () {
            // TODO: Implementar criação de status
          },
          backgroundColor: const Color(0xFF25D366),
          child: const Icon(Icons.camera_alt, color: Colors.white),
        );
      case 2:
        return FloatingActionButton(
          onPressed: () {
            // TODO: Implementar criação de comunidade
          },
          backgroundColor: const Color(0xFF25D366),
          child: const Icon(Icons.add, color: Colors.white),
        );
      case 3:
        return FloatingActionButton(
          onPressed: () {
            // TODO: Implementar nova chamada
          },
          backgroundColor: const Color(0xFF25D366),
          child: const Icon(Icons.add_call, color: Colors.white),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

class ConversationsTab extends StatelessWidget {
  const ConversationsTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, child) {
        if (chatProvider.chats.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.chat_bubble_outline,
                  size: 80,
                  color: Colors.white38,
                ),
                SizedBox(height: 16),
                Text(
                  'Nenhuma conversa ainda',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white70,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Toque no botão + para iniciar uma conversa',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white54,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: chatProvider.chats.length,
          itemBuilder: (context, index) {
            final chat = chatProvider.chats[index];
            return ConversationTile(
              chat: chat,
              onTap: () => context.go('/chat/${chat.peer.id}', extra: chat.peer),
            );
          },
        );
      },
    );
  }
}

class StatusTab extends StatelessWidget {
  const StatusTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.circle_outlined,
            size: 80,
            color: Colors.white38,
          ),
          SizedBox(height: 16),
          Text(
            'Status em breve',
            style: TextStyle(
              fontSize: 18,
              color: Colors.white70,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Esta funcionalidade será implementada',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white54,
            ),
          ),
        ],
      ),
    );
  }
}

class CommunitiesTab extends StatelessWidget {
  const CommunitiesTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.groups,
            size: 80,
            color: Colors.white38,
          ),
          SizedBox(height: 16),
          Text(
            'Comunidades em breve',
            style: TextStyle(
              fontSize: 18,
              color: Colors.white70,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Esta funcionalidade será implementada',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white54,
            ),
          ),
        ],
      ),
    );
  }
}

class CallsTab extends StatelessWidget {
  const CallsTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.call,
            size: 80,
            color: Colors.white38,
          ),
          SizedBox(height: 16),
          Text(
            'Chamadas em breve',
            style: TextStyle(
              fontSize: 18,
              color: Colors.white70,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Esta funcionalidade será implementada',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white54,
            ),
          ),
        ],
      ),
    );
  }
}
