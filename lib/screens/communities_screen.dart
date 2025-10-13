import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class CommunitiesScreen extends StatefulWidget {
  const CommunitiesScreen({super.key});

  @override
  State<CommunitiesScreen> createState() => _CommunitiesScreenState();
}

class _CommunitiesScreenState extends State<CommunitiesScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Comunidades'),
        backgroundColor: const Color(0xFF1F2C34),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearchDialog(),
          ),
        ],
      ),
      backgroundColor: const Color(0xFF121B22),
      body: Column(
        children: [
          // Barra de busca
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar comunidades...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Theme.of(context).cardColor,
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
              ),
              style: const TextStyle(color: Colors.white),
            ),
          ),
          
          // Lista de comunidades
          Expanded(
            child: ListView(
              children: [
                // Minhas comunidades
                _buildSectionHeader('Minhas Comunidades'),
                _buildCommunityItem(
                  'Família Silva',
                  'Grupo da família',
                  '12 membros',
                  Icons.family_restroom,
                  true,
                ),
                _buildCommunityItem(
                  'Trabalho',
                  'Equipe de desenvolvimento',
                  '8 membros',
                  Icons.work,
                  true,
                ),
                
                const SizedBox(height: 20),
                
                // Comunidades sugeridas
                _buildSectionHeader('Comunidades Sugeridas'),
                _buildCommunityItem(
                  'Flutter Brasil',
                  'Comunidade de desenvolvedores Flutter',
                  '1.2k membros',
                  Icons.code,
                  false,
                ),
                _buildCommunityItem(
                  'Música Local',
                  'Grupo de músicos da região',
                  '45 membros',
                  Icons.music_note,
                  false,
                ),
                _buildCommunityItem(
                  'Esportes',
                  'Grupo de atividades físicas',
                  '89 membros',
                  Icons.sports,
                  false,
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateCommunityDialog(),
        backgroundColor: const Color(0xFF25D366),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF25D366),
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildCommunityItem(
    String name,
    String description,
    String members,
    IconData icon,
    bool isJoined,
  ) {
    return ListTile(
      leading: CircleAvatar(
        radius: 25,
        backgroundColor: const Color(0xFF25D366),
        child: Icon(icon, color: Colors.white),
      ),
      title: Text(
        name,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            description,
            style: const TextStyle(color: Colors.white70),
          ),
          Text(
            members,
            style: const TextStyle(color: Colors.white60),
          ),
        ],
      ),
      trailing: isJoined
          ? const Icon(Icons.check_circle, color: Color(0xFF25D366))
          : ElevatedButton(
              onPressed: () => _joinCommunity(name),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF25D366),
                foregroundColor: Colors.white,
              ),
              child: const Text('Entrar'),
            ),
      onTap: () => _showCommunityDetails(name, description, members),
    );
  }

  void _showSearchDialog() {
    showSearch(
      context: context,
      delegate: CommunitySearchDelegate(),
    );
  }

  void _showCreateCommunityDialog() {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1F2C34),
        title: const Text(
          'Criar Comunidade',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Nome da comunidade',
                hintStyle: TextStyle(color: Colors.white54),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Descrição',
                hintStyle: TextStyle(color: Colors.white54),
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Comunidade criada com sucesso!'),
                  backgroundColor: Color(0xFF25D366),
                ),
              );
            },
            child: const Text(
              'Criar',
              style: TextStyle(color: Color(0xFF25D366)),
            ),
          ),
        ],
      ),
    );
  }

  void _joinCommunity(String name) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Você entrou na comunidade $name'),
        backgroundColor: const Color(0xFF25D366),
      ),
    );
  }

  void _showCommunityDetails(String name, String description, String members) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1F2C34),
        title: Text(
          name,
          style: const TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              description,
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 8),
            Text(
              members,
              style: const TextStyle(color: Colors.white60),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Fechar',
              style: TextStyle(color: Color(0xFF25D366)),
            ),
          ),
        ],
      ),
    );
  }
}

class CommunitySearchDelegate extends SearchDelegate<String> {
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
        close(context, '');
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
    final communities = [
      'Flutter Brasil',
      'Música Local',
      'Esportes',
      'Trabalho',
      'Família Silva',
    ];

    final filteredCommunities = communities.where((community) {
      return community.toLowerCase().contains(query.toLowerCase());
    }).toList();

    return ListView.builder(
      itemCount: filteredCommunities.length,
      itemBuilder: (context, index) {
        final community = filteredCommunities[index];
        return ListTile(
          leading: const CircleAvatar(
            backgroundColor: Color(0xFF25D366),
            child: Icon(Icons.group, color: Colors.white),
          ),
          title: Text(
            community,
            style: const TextStyle(color: Colors.white),
          ),
          onTap: () {
            close(context, community);
          },
        );
      },
    );
  }
}
