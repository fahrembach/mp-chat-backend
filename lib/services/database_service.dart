import '../database/database.dart' as db;
import '../models/message.dart' as model;
import 'package:drift/drift.dart';

class DatabaseService {
  final db.AppDatabase _db;

  DatabaseService(this._db);

  Future<void> initializeDatabase() async {
    try {
      // Tentar executar uma query simples para verificar se a tabela existe
      await _db.into(_db.messages).insert(db.MessagesCompanion(
        id: const Value('test'),
        content: const Value('test'),
        type: const Value(db.MessageType.text),
        senderId: const Value('test'),
        receiverId: const Value('test'),
        createdAt: Value(DateTime.now()),
      ), mode: InsertMode.replace);
      
      // Se chegou aqui, a tabela existe, então remove o registro de teste
      await (_db.delete(_db.messages)..where((tbl) => tbl.id.equals('test'))).go();
    } catch (e) {
      print('[DATABASE] Creating messages table...');
      // Se falhou, criar a tabela manualmente usando SQL direto
      await _db.customStatement('''
        CREATE TABLE IF NOT EXISTS messages (
          id TEXT PRIMARY KEY,
          content TEXT NOT NULL,
          type INTEGER NOT NULL,
          sender_id TEXT NOT NULL,
          receiver_id TEXT NOT NULL,
          created_at INTEGER NOT NULL,
          is_read INTEGER NOT NULL DEFAULT 0,
          media_url TEXT,
          file_name TEXT,
          file_size INTEGER
        )
      ''');
      print('[DATABASE] Messages table created successfully');
    }
  }

  Future<void> clearMessages(String peerId) async {
    try {
      await (_db.delete(_db.messages)
            ..where((m) => m.senderId.equals(peerId) | m.receiverId.equals(peerId)))
          .go();
      print('[DATABASE] Cleared messages for peer: $peerId');
    } catch (e) {
      print('[DATABASE] Error clearing messages: $e');
    }
  }

  model.Message _fromDriftMessage(db.Message driftMsg) {
    print('[DATABASE] Converting message: ${driftMsg.id}, type: ${driftMsg.type}, fileName: ${driftMsg.fileName}');
    print('[DATABASE] mediaUrl: ${driftMsg.mediaUrl}');
    return model.Message(
      id: driftMsg.id,
      content: driftMsg.content,
      type: model.MessageType.values[driftMsg.type.index],
      senderId: driftMsg.senderId,
      receiverId: driftMsg.receiverId,
      createdAt: driftMsg.createdAt,
      isRead: driftMsg.isRead,
      mediaUrl: driftMsg.mediaUrl,
      fileName: driftMsg.fileName,
      fileSize: driftMsg.fileSize,
    );
  }

  Future<void> insertMessage(model.Message message) async {
    try {
      print('[DATABASE] Inserting message: ${message.id}, type: ${message.type}, fileName: ${message.fileName}');
      final companion = db.MessagesCompanion(
        id: Value(message.id),
        content: Value(message.content),
        type: Value(db.MessageType.values[message.type.index]),
        senderId: Value(message.senderId),
        receiverId: Value(message.receiverId),
        createdAt: Value(message.createdAt),
        isRead: Value(message.isRead),
        mediaUrl: Value(message.mediaUrl),
        fileName: Value(message.fileName),
        fileSize: Value(message.fileSize),
      );
      await _db.into(_db.messages).insert(companion, mode: InsertMode.replace);
      print('[DATABASE] Message inserted successfully');
    } catch (e) {
      print('[DATABASE] Error inserting message, initializing database...');
      await initializeDatabase();
      // Tentar novamente após inicializar
      final companion = db.MessagesCompanion(
        id: Value(message.id),
        content: Value(message.content),
        type: Value(db.MessageType.values[message.type.index]),
        senderId: Value(message.senderId),
        receiverId: Value(message.receiverId),
        createdAt: Value(message.createdAt),
        isRead: Value(message.isRead),
        mediaUrl: Value(message.mediaUrl),
        fileName: Value(message.fileName),
        fileSize: Value(message.fileSize),
      );
      await _db.into(_db.messages).insert(companion, mode: InsertMode.replace);
      print('[DATABASE] Message inserted successfully after initialization');
    }
  }

  Future<List<model.Message>> getMessages(String currentUserId, String peerId) async {
    final query = _db.select(_db.messages)
      ..where((tbl) =>
          (tbl.senderId.equals(currentUserId) & tbl.receiverId.equals(peerId)) |
          (tbl.senderId.equals(peerId) & tbl.receiverId.equals(currentUserId)))
      ..orderBy([(t) => OrderingTerm(expression: t.createdAt)]);
      
    final driftMessages = await query.get();
    return driftMessages.map<model.Message>(_fromDriftMessage).toList();
  }
}