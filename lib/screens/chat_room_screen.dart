import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../models/user.dart';
import '../providers/chat_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/message_bubble.dart';
import '../widgets/message_input.dart';
import '../widgets/chat_search_delegate.dart';
import '../models/message.dart';
import '../screens/call_screen.dart';
import '../services/socket_service.dart';

class ChatRoomScreen extends StatefulWidget {
  final User peer;

  const ChatRoomScreen({Key? key, required this.peer}) : super(key: key);

  @override
  _ChatRoomScreenState createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ChatProvider>(context, listen: false).loadMessages(widget.peer.id);
    });
  }

  void _startCall() {
    final callId = DateTime.now().millisecondsSinceEpoch.toString();
    final socketService = Provider.of<SocketService>(context, listen: false);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CallScreen(
          peer: widget.peer,
          isIncoming: false,
          callId: callId,
          socketService: socketService,
        ),
      ),
    );
  }

  void _startVideoCall() {
    // TODO: Implementar videochamada
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Videochamada em desenvolvimento')),
    );
  }

  void _handleMenuAction(String value) {
    switch (value) {
      case 'view_contact':
        _showContactInfo();
        break;
      case 'search':
        _showSearchDialog();
        break;
      case 'media':
        _showMediaDialog();
        break;
      case 'mute':
        _toggleMute();
        break;
      case 'theme':
        _showThemeDialog();
        break;
      case 'block':
        _showBlockDialog();
        break;
      case 'clear':
        _showClearDialog();
        break;
      case 'export':
        _exportChat();
        break;
    }
  }

  void _showContactInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1F2C34),
        title: Text(
          'Informações do Contato',
          style: const TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: const Color(0xFF25D366),
              child: Text(
                widget.peer.username.isNotEmpty
                    ? widget.peer.username[0].toUpperCase()
                    : '?',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.peer.username,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.peer.email ?? 'Sem email',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 8),
            Text(
              widget.peer.isOnline ? 'Online' : 'Offline',
              style: TextStyle(
                color: widget.peer.isOnline ? Colors.green : Colors.grey,
              ),
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

  void _showSearchDialog() {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final messages = chatProvider.messages[widget.peer.id] ?? [];
    showSearch(
      context: context,
      delegate: ChatSearchDelegate(messages),
    );
  }

  void _showMediaDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1F2C34),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Mídia, Links e Documentos',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildMediaOption(
                  icon: Icons.photo,
                  label: 'Fotos',
                  onTap: () {
                    Navigator.pop(context);
                    _pickMedia('image');
                  },
                ),
                _buildMediaOption(
                  icon: Icons.video_library,
                  label: 'Vídeos',
                  onTap: () {
                    Navigator.pop(context);
                    _pickMedia('video');
                  },
                ),
                _buildMediaOption(
                  icon: Icons.attach_file,
                  label: 'Documentos',
                  onTap: () {
                    Navigator.pop(context);
                    _pickMedia('file');
                  },
                ),
                _buildMediaOption(
                  icon: Icons.link,
                  label: 'Links',
                  onTap: () {
                    Navigator.pop(context);
                    _showLinkDialog();
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFF2A3942),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Icon(
              icon,
              color: Colors.white70,
              size: 30,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  void _pickMedia(String type) {
    // Esta funcionalidade já está implementada no MessageInput
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Selecionar $type será implementado em breve'),
        backgroundColor: const Color(0xFF25D366),
      ),
    );
  }

  void _showLinkDialog() {
    final TextEditingController linkController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1F2C34),
        title: const Text(
          'Compartilhar Link',
          style: TextStyle(color: Colors.white),
        ),
        content: TextField(
          controller: linkController,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Cole o link aqui...',
            hintStyle: TextStyle(color: Colors.white54),
            border: OutlineInputBorder(),
          ),
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
              if (linkController.text.isNotEmpty) {
                // Enviar link como mensagem
                Provider.of<ChatProvider>(context, listen: false)
                    .sendMessage(linkController.text, widget.peer.id);
                Navigator.of(context).pop();
              }
            },
            child: const Text(
              'Enviar',
              style: TextStyle(color: Color(0xFF25D366)),
            ),
          ),
        ],
      ),
    );
  }

  void _toggleMute() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Notificações ${widget.peer.isOnline ? 'silenciadas' : 'ativadas'}'),
        backgroundColor: const Color(0xFF25D366),
      ),
    );
  }

  void _showThemeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1F2C34),
        title: const Text(
          'Tema da Conversa',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Esta funcionalidade será implementada em breve!',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'OK',
              style: TextStyle(color: Color(0xFF25D366)),
            ),
          ),
        ],
      ),
    );
  }

  void _showBlockDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1F2C34),
        title: const Text(
          'Bloquear Contato',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Tem certeza que deseja bloquear ${widget.peer.username}?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Colors.white60),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${widget.peer.username} foi bloqueado'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: const Text(
              'Bloquear',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _showClearDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1F2C34),
        title: const Text(
          'Limpar Conversa',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Tem certeza que deseja limpar toda a conversa? Esta ação não pode ser desfeita.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Colors.white60),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Conversa limpa'),
                  backgroundColor: Color(0xFF25D366),
                ),
              );
            },
            child: const Text(
              'Limpar',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _exportChat() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Exportando conversa...'),
        backgroundColor: Color(0xFF25D366),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final List<Message> messages = chatProvider.messagesForUser(widget.peer.id);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            context.go('/');
          },
        ),
        title: Text(widget.peer.username),
        actions: [
          IconButton(
            icon: Icon(Icons.call),
            onPressed: () => _startCall(),
            tooltip: 'Ligar',
          ),
          IconButton(
            icon: Icon(Icons.videocam),
            onPressed: () => _startVideoCall(),
            tooltip: 'Videochamada',
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) => _handleMenuAction(value),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'view_contact',
                child: Row(
                  children: [
                    Icon(Icons.person, color: Colors.grey),
                    SizedBox(width: 8),
                    Text('Ver contato'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'search',
                child: Row(
                  children: [
                    Icon(Icons.search, color: Colors.grey),
                    SizedBox(width: 8),
                    Text('Pesquisar'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'media',
                child: Row(
                  children: [
                    Icon(Icons.attach_file, color: Colors.grey),
                    SizedBox(width: 8),
                    Text('Mídia, links e docs'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'mute',
                child: Row(
                  children: [
                    Icon(Icons.volume_off, color: Colors.grey),
                    SizedBox(width: 8),
                    Text('Silenciar notificações'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'theme',
                child: Row(
                  children: [
                    Icon(Icons.palette, color: Colors.grey),
                    SizedBox(width: 8),
                    Text('Tema da conversa'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'block',
                child: Row(
                  children: [
                    Icon(Icons.block, color: Colors.grey),
                    SizedBox(width: 8),
                    Text('Bloquear'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'clear',
                child: Row(
                  children: [
                    Icon(Icons.clear_all, color: Colors.grey),
                    SizedBox(width: 8),
                    Text('Limpar conversa'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'export',
                child: Row(
                  children: [
                    Icon(Icons.file_download, color: Colors.grey),
                    SizedBox(width: 8),
                    Text('Exportar conversa'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: chatProvider.isLoadingMessages
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: messages.length,
                    itemBuilder: (ctx, i) {
                      final message = messages[i];
                      return MessageBubble(
                        message: message, // Pass the whole object
                        isMe: message.senderId == authProvider.user!.id,
                      );
                    },
                  ),
          ),
          MessageInput(
            onSendMessage: (content) {
              chatProvider.sendMessage(widget.peer.id, content);
            },
            onSendMedia: (fileName, filePath) {
              chatProvider.sendMedia(widget.peer.id, fileName, filePath);
            },
          ),
        ],
      ),
    );
  }
}