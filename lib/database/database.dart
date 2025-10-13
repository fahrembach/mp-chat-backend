import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';

part 'database.g.dart';

// This enum should be used across the app
enum MessageType { text, image, file, audio }

class Messages extends Table {
  TextColumn get id => text()();
  TextColumn get content => text()();
  IntColumn get type => intEnum<MessageType>()();
  TextColumn get senderId => text()();
  TextColumn get receiverId => text()();
  DateTimeColumn get createdAt => dateTime()();
  BoolColumn get isRead => boolean().withDefault(const Constant(false))();
  TextColumn get mediaUrl => text().nullable()();
  TextColumn get fileName => text().nullable()();
  IntColumn get fileSize => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [Messages])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  Future<void> onCreate(Database db, int version) async {
    db.execute('''
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
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase(file);
  });
}