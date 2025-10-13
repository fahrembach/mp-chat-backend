import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/chat_provider.dart';
import '../models/user.dart';

class UsersScreen extends StatefulWidget {
  @override
  _UsersScreenState createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    // Use addPostFrameCallback to ensure the provider is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ChatProvider>(context, listen: false).loadUsers();
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
    });
  }

  List<User> _getFilteredUsers(List<User> users) {
    if (_searchQuery.isEmpty) {
      return users;
    }
    return users.where((user) {
      return user.username.toLowerCase().contains(_searchQuery) ||
             (user.email?.toLowerCase().contains(_searchQuery) ?? false);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            context.go('/');
          },
        ),
        title: Text('Usuários'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: UserSearchDelegate(chatProvider.users),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra de busca
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar usuários...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Theme.of(context).cardColor,
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
              ),
            ),
          ),
          // Lista de usuários
          Expanded(
            child: chatProvider.isLoadingUsers
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: _getFilteredUsers(chatProvider.users).length,
                    itemBuilder: (ctx, i) {
                      final user = _getFilteredUsers(chatProvider.users)[i];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: user.isOnline ? Colors.green : Colors.grey,
                          child: Text(
                            user.username.isNotEmpty ? user.username[0].toUpperCase() : '?',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(
                          user.username,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          user.isOnline ? 'Online' : 'Offline',
                          style: TextStyle(
                            color: user.isOnline ? Colors.green : Colors.grey,
                          ),
                        ),
                        trailing: user.isOnline
                            ? const Icon(Icons.circle, color: Colors.green, size: 12)
                            : null,
                        onTap: () {
                          context.go('/chat/${user.id}', extra: user);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class UserSearchDelegate extends SearchDelegate<User> {
  final List<User> users;

  UserSearchDelegate(this.users);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, User(id: '', username: '', email: ''));
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    final filteredUsers = users.where((user) {
      return user.username.toLowerCase().contains(query.toLowerCase()) ||
             (user.email?.toLowerCase().contains(query.toLowerCase()) ?? false);
    }).toList();

    return ListView.builder(
      itemCount: filteredUsers.length,
      itemBuilder: (context, index) {
        final user = filteredUsers[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: user.isOnline ? Colors.green : Colors.grey,
            child: Text(
              user.username.isNotEmpty ? user.username[0].toUpperCase() : '?',
              style: const TextStyle(color: Colors.white),
            ),
          ),
          title: Text(
            user.username,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            user.isOnline ? 'Online' : 'Offline',
            style: TextStyle(
              color: user.isOnline ? Colors.green : Colors.grey,
            ),
          ),
          trailing: user.isOnline
              ? const Icon(Icons.circle, color: Colors.green, size: 12)
              : null,
          onTap: () {
            close(context, user);
            // Navegar para o chat
            Navigator.of(context).pushNamed('/chat/${user.id}', arguments: user);
          },
        );
      },
    );
  }
}