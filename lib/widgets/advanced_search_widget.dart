// widgets/advanced_search_widget.dart
import 'package:flutter/material.dart';
import '../services/search_service.dart';
import '../models/user.dart';
import '../models/message.dart';
import '../models/group.dart';
import '../models/community.dart';

class AdvancedSearchWidget extends StatefulWidget {
  final String token;
  final Function(Message)? onMessageSelected;
  final Function(User)? onUserSelected;
  final Function(Group)? onGroupSelected;
  final Function(Community)? onCommunitySelected;

  const AdvancedSearchWidget({
    Key? key,
    required this.token,
    this.onMessageSelected,
    this.onUserSelected,
    this.onGroupSelected,
    this.onCommunitySelected,
  }) : super(key: key);

  @override
  State<AdvancedSearchWidget> createState() => _AdvancedSearchWidgetState();
}

class _AdvancedSearchWidgetState extends State<AdvancedSearchWidget>
    with TickerProviderStateMixin {
  final SearchService _searchService = SearchService();
  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;

  String _currentQuery = '';
  List<User> _users = [];
  List<Message> _messages = [];
  List<Group> _groups = [];
  List<Community> _communities = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _users.clear();
        _messages.clear();
        _groups.clear();
        _communities.clear();
        _error = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
      _currentQuery = query;
    });

    try {
      final results = await _searchService.globalSearch(query, widget.token);
      
      setState(() {
        _users = results['users'] as List<User>;
        _messages = results['messages'] as List<Message>;
        _groups = results['groups'] as List<Group>;
        _communities = results['communities'] as List<Community>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Buscar mensagens, usuários, grupos...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _performSearch('');
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Theme.of(context).cardColor,
        ),
        onChanged: (value) {
          if (value.length >= 2) {
            _performSearch(value);
          } else if (value.isEmpty) {
            _performSearch('');
          }
        },
      ),
    );
  }

  Widget _buildTabBar() {
    return TabBar(
      controller: _tabController,
      tabs: [
        Tab(
          text: 'Mensagens',
          icon: Icon(Icons.message, size: 20),
        ),
        Tab(
          text: 'Usuários',
          icon: Icon(Icons.people, size: 20),
        ),
        Tab(
          text: 'Grupos',
          icon: Icon(Icons.group, size: 20),
        ),
        Tab(
          text: 'Comunidades',
          icon: Icon(Icons.public, size: 20),
        ),
      ],
    );
  }

  Widget _buildMessagesTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(_error!, textAlign: TextAlign.center),
          ],
        ),
      );
    }

    if (_messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.message, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              _currentQuery.isEmpty
                  ? 'Digite algo para buscar mensagens'
                  : 'Nenhuma mensagem encontrada',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: message.sender?.avatar != null
                ? NetworkImage(message.sender!.avatar!)
                : null,
            child: message.sender?.avatar == null
                ? Text(message.sender?.displayName.substring(0, 1).toUpperCase() ?? '?')
                : null,
          ),
          title: Text(message.sender?.displayName ?? 'Usuário desconhecido'),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message.content,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                _formatDate(message.createdAt),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          trailing: Icon(
            _getMessageTypeIcon(message.type),
            size: 20,
          ),
          onTap: () => widget.onMessageSelected?.call(message),
        );
      },
    );
  }

  Widget _buildUsersTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(_error!, textAlign: TextAlign.center),
          ],
        ),
      );
    }

    if (_users.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              _currentQuery.isEmpty
                  ? 'Digite algo para buscar usuários'
                  : 'Nenhum usuário encontrado',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _users.length,
      itemBuilder: (context, index) {
        final user = _users[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: user.avatar != null
                ? NetworkImage(user.avatar!)
                : null,
            child: user.avatar == null
                ? Text(user.displayName.substring(0, 1).toUpperCase())
                : null,
          ),
          title: Text(user.displayName),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('@${user.username}'),
              if (user.bio != null) Text(user.bio!),
              Text(
                user.isOnline ? 'Online' : user.lastSeenText,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: user.isOnline ? Colors.green : Colors.grey,
                ),
              ),
            ],
          ),
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
          onTap: () => widget.onUserSelected?.call(user),
        );
      },
    );
  }

  Widget _buildGroupsTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(_error!, textAlign: TextAlign.center),
          ],
        ),
      );
    }

    if (_groups.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.group, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              _currentQuery.isEmpty
                  ? 'Digite algo para buscar grupos'
                  : 'Nenhum grupo encontrado',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _groups.length,
      itemBuilder: (context, index) {
        final group = _groups[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: group.avatar != null
                ? NetworkImage(group.avatar!)
                : null,
            child: group.avatar == null
                ? Text(group.name.substring(0, 1).toUpperCase())
                : null,
          ),
          title: Text(group.name),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (group.description != null) Text(group.description!),
              Text(
                '${group.members.length} membros',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          trailing: group.isPrivate
              ? Icon(Icons.lock, size: 20, color: Colors.grey)
              : Icon(Icons.public, size: 20, color: Colors.green),
          onTap: () => widget.onGroupSelected?.call(group),
        );
      },
    );
  }

  Widget _buildCommunitiesTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(_error!, textAlign: TextAlign.center),
          ],
        ),
      );
    }

    if (_communities.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.public, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              _currentQuery.isEmpty
                  ? 'Digite algo para buscar comunidades'
                  : 'Nenhuma comunidade encontrada',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _communities.length,
      itemBuilder: (context, index) {
        final community = _communities[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: community.avatar != null
                ? NetworkImage(community.avatar!)
                : null,
            child: community.avatar == null
                ? Text(community.name.substring(0, 1).toUpperCase())
                : null,
          ),
          title: Text(community.name),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (community.description != null) Text(community.description!),
              Text(
                '${community.memberCount} membros',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          trailing: community.isPrivate
              ? Icon(Icons.lock, size: 20, color: Colors.grey)
              : Icon(Icons.public, size: 20, color: Colors.green),
          onTap: () => widget.onCommunitySelected?.call(community),
        );
      },
    );
  }

  IconData _getMessageTypeIcon(dynamic type) {
    switch (type.toString()) {
      case 'image':
        return Icons.image;
      case 'video':
        return Icons.videocam;
      case 'audio':
        return Icons.audiotrack;
      case 'file':
        return Icons.attach_file;
      case 'location':
        return Icons.location_on;
      case 'contact':
        return Icons.contact_phone;
      case 'sticker':
        return Icons.emoji_emotions;
      case 'gif':
        return Icons.gif;
      default:
        return Icons.message;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} dias atrás';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} horas atrás';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutos atrás';
    } else {
      return 'Agora mesmo';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildSearchBar(),
        _buildTabBar(),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildMessagesTab(),
              _buildUsersTab(),
              _buildGroupsTab(),
              _buildCommunitiesTab(),
            ],
          ),
        ),
      ],
    );
  }
}
