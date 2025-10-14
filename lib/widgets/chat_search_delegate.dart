import 'package:flutter/material.dart';
import '../models/message.dart';

class ChatSearchDelegate extends SearchDelegate<Message> {
  final List<Message> messages;

  ChatSearchDelegate(this.messages);

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
        close(context, Message(
          id: '',
          content: '',
          type: MessageType.text,
          senderId: '',
          receiverId: '',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isRead: false,
        ));
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
    final filteredMessages = messages.where((message) {
      return message.content.toLowerCase().contains(query.toLowerCase());
    }).toList();

    if (filteredMessages.isEmpty) {
      return const Center(
        child: Text(
          'Nenhuma mensagem encontrada',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    return ListView.builder(
      itemCount: filteredMessages.length,
      itemBuilder: (context, index) {
        final message = filteredMessages[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: const Color(0xFF25D366),
            child: Text(
              message.senderId.isNotEmpty ? message.senderId[0].toUpperCase() : '?',
              style: const TextStyle(color: Colors.white),
            ),
          ),
          title: Text(
            message.content,
            style: const TextStyle(color: Colors.white),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            _formatTime(message.createdAt),
            style: const TextStyle(color: Colors.white70),
          ),
          onTap: () {
            close(context, message);
          },
        );
      },
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } else if (difference.inHours > 0) {
      return '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else {
      return '${dateTime.minute.toString().padLeft(2, '0')} min atrás';
    }
  }
}
