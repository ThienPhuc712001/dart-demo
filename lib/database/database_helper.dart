
import 'dart:io';
import 'package:path/path.dart';
import 'package:sqlite3/sqlite3.dart';
import 'dart:mirrors';
import '../database_annotations.dart';
import 'user_repository.dart';
import 'product_repository.dart';

Future<void> initializeDatabase() async {
  final String path = join(Directory.current.path, 'my_database.db');
  final db = sqlite3.open(path);

  // Create table User
  db.execute('''
    CREATE TABLE IF NOT EXISTS users (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      age INTEGER
    )
  ''');

  // Create table Product
  db.execute('''
    CREATE TABLE IF NOT EXISTS products (
      product_id INTEGER PRIMARY KEY AUTOINCREMENT,
      product_name TEXT NOT NULL,
      price REAL NOT NULL
    )
  ''');
  print('Database initialized successfully!');
}

Future<String> getDatabasesPath() async {
  return Directory.current.path;
}

