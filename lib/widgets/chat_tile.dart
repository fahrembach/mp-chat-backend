import 'package:flutter/material.dart';
import '../models/chat.dart';

class ChatTile extends StatelessWidget {
  final Chat chat;
  final VoidCallback onTap;

  const ChatTile({
    super.key,
    required this.chat,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: chat.peer.avatar != null
            ? NetworkImage(chat.peer.avatar!)
            : null,
        child: chat.peer.avatar == null
            ? Text(chat.peer.username[0].toUpperCase())
            : null,
      ),
      title: Text(
        chat.peer.username,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: chat.lastMessage != null
          ? Text(
              chat.lastMessage!.content,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )
          : Text(
              chat.peer.isOnline ? 'Online' : 'Offline',
              style: TextStyle(
                color: chat.peer.isOnline ? Colors.green : Colors.grey,
              ),
            ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            _formatTime(chat.updatedAt),
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          if (chat.unreadCount > 0) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(
                minWidth: 20,
                minHeight: 20,
              ),
              child: Text(
                chat.unreadCount > 99 ? '99+' : chat.unreadCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ],
      ),
      onTap: onTap,
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${dateTime.day}/${dateTime.month}';
    } else if (difference.inHours > 0) {
      return '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else {
      return '${dateTime.minute.toString().padLeft(2, '0')} min ago';
    }
  }
}