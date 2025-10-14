import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../models/user.dart';
import '../models/message.dart';
import '../models/group.dart';
import '../models/community.dart';
import '../services/search_service.dart';
import '../services/auth_service.dart';

class AdvancedSearchWidget extends StatefulWidget {
  final Function(User)? onUserSelected;
  final Function(Message)? onMessageSelected;
  final Function(Group)? onGroupSelected;
  final Function(Community)? onCommunitySelected;

  const AdvancedSearchWidget({
    Key? key,
    this.onUserSelected,
    this.onMessageSelected,
    this.onGroupSelected,
    this.onCommunitySelected,
  }) : super(key: key);

  @override
  State<AdvancedSearchWidget> createState() => _AdvancedSearchWidgetState();
}

class _AdvancedSearchWidgetState extends State<AdvancedSearchWidget>
    with TickerProviderStateMixin {
  final SearchService _searchService = GetIt.instance<SearchService>();
  final AuthService _authService = GetIt.instance<AuthService>();
  final TextEditingController _searchController = TextEditingController();
  
  late TabController _tabController;
  
  List<User> _users = [];
  List<Message> _messages = [];
  List<Group> _groups = [];
  List<Community> _communities = [];
  
  bool _isLoading = false;
  String _currentQuery = '';
  String? _currentToken;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _getAuthToken();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _getAuthToken() async {
    try {
      _currentToken = await _authService.getToken();
    } catch (e) {
      debugPrint('Erro ao obter token: $e');
    }
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty || _currentToken == null) return;

    setState(() {
      _isLoading = true;
      _currentQuery = query;
    });

    try {
      final results = await _searchService.globalSearch(query, _currentToken!);
      
      setState(() {
        _users = results['users'] as List<User>;
        _messages = results['messages'] as List<Message>;
        _groups = results['groups'] as List<Group>;
        _communities = results['communities'] as List<Community>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro na busca: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _searchUsers(String query) async {
    if (query.isEmpty || _currentToken == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final users = await _searchService.searchUsers(query, _currentToken!);
      setState(() {
        _users = users;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _searchMessages(String query) async {
    if (query.isEmpty || _currentToken == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final messages = await _searchService.searchMessages(query, _currentToken!);
      setState(() {
        _messages = messages;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _searchGroups(String query) async {
    if (query.isEmpty || _currentToken == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final groups = await _searchService.searchGroups(query, _currentToken!);
      setState(() {
        _groups = groups;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _searchCommunities(String query) async {
    if (query.isEmpty || _currentToken == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final communities = await _searchService.searchCommunities(query, _currentToken!);
      setState(() {
        _communities = communities;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Busca Avançada'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Usuários'),
            Tab(text: 'Mensagens'),
            Tab(text: 'Grupos'),
            Tab(text: 'Comunidades'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Barra de busca
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Digite para buscar...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _users.clear();
                            _messages.clear();
                            _groups.clear();
                            _communities.clear();
                            _currentQuery = '';
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                if (value.length >= 2) {
                  _performSearch(value);
                } else if (value.isEmpty) {
                  setState(() {
                    _users.clear();
                    _messages.clear();
                    _groups.clear();
                    _communities.clear();
                    _currentQuery = '';
                  });
                }
              },
            ),
          ),

          // Resultados da busca
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildUsersTab(),
                _buildMessagesTab(),
                _buildGroupsTab(),
                _buildCommunitiesTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsersTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_users.isEmpty && _currentQuery.isNotEmpty) {
      return const Center(
        child: Text('Nenhum usuário encontrado'),
      );
    }

    return ListView.builder(
      itemCount: _users.length,
      itemBuilder: (context, index) {
        final user = _users[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.grey[300],
            child: user.avatar != null
                ? ClipOval(child: Image.network(user.avatar!, fit: BoxFit.cover))
                : const Icon(Icons.person),
          ),
          title: Text(user.displayName),
          subtitle: Text(user.bio ?? ''),
          trailing: user.isOnline
              ? Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                )
              : null,
          onTap: () {
            widget.onUserSelected?.call(user);
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  Widget _buildMessagesTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_messages.isEmpty && _currentQuery.isNotEmpty) {
      return const Center(
        child: Text('Nenhuma mensagem encontrada'),
      );
    }

    return ListView.builder(
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.grey[300],
            child: const Icon(Icons.message),
          ),
          title: Text(message.content),
          subtitle: Text(
            '${message.sender?.name ?? 'Usuário'} • ${_formatDate(message.createdAt)}',
          ),
          trailing: Icon(
            _getMessageTypeIcon(message.type),
            size: 20,
          ),
          onTap: () {
            widget.onMessageSelected?.call(message);
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  Widget _buildGroupsTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_groups.isEmpty && _currentQuery.isNotEmpty) {
      return const Center(
        child: Text('Nenhum grupo encontrado'),
      );
    }

    return ListView.builder(
      itemCount: _groups.length,
      itemBuilder: (context, index) {
        final group = _groups[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.grey[300],
            child: group.avatar != null
                ? ClipOval(child: Image.network(group.avatar!, fit: BoxFit.cover))
                : const Icon(Icons.group),
          ),
          title: Text(group.name),
          subtitle: Text(group.description ?? ''),
          trailing: group.isPrivate
              ? const Icon(Icons.lock, size: 20)
              : const Icon(Icons.public, size: 20),
          onTap: () {
            widget.onGroupSelected?.call(group);
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  Widget _buildCommunitiesTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_communities.isEmpty && _currentQuery.isNotEmpty) {
      return const Center(
        child: Text('Nenhuma comunidade encontrada'),
      );
    }

    return ListView.builder(
      itemCount: _communities.length,
      itemBuilder: (context, index) {
        final community = _communities[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.grey[300],
            child: community.avatar != null
                ? ClipOval(child: Image.network(community.avatar!, fit: BoxFit.cover))
                : const Icon(Icons.people),
          ),
          title: Text(community.name),
          subtitle: Text(community.description ?? ''),
          trailing: community.isPrivate
              ? const Icon(Icons.lock, size: 20)
              : const Icon(Icons.public, size: 20),
          onTap: () {
            widget.onCommunitySelected?.call(community);
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  IconData _getMessageTypeIcon(MessageType type) {
    switch (type) {
      case MessageType.text:
        return Icons.text_fields;
      case MessageType.image:
        return Icons.image;
      case MessageType.video:
        return Icons.videocam;
      case MessageType.audio:
        return Icons.audiotrack;
      case MessageType.voice:
        return Icons.mic;
      case MessageType.file:
        return Icons.attach_file;
      case MessageType.location:
        return Icons.location_on;
      case MessageType.contact:
        return Icons.contact_phone;
      case MessageType.sticker:
        return Icons.emoji_emotions;
      case MessageType.gif:
        return Icons.gif;
      case MessageType.document:
        return Icons.description;
      case MessageType.poll:
        return Icons.poll;
      case MessageType.system:
        return Icons.info;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d atrás';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h atrás';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m atrás';
    } else {
      return 'Agora';
    }
  }
}