// import 'package:sqflite/sqflite.dart';
// import 'package:path/path.dart';
// import 'package:rrfx/src/helpers/database/regol_models/page_one.dart';

// class DatabaseHelper {
//   static final DatabaseHelper _instance = DatabaseHelper._internal();
//   factory DatabaseHelper() => _instance;
//   DatabaseHelper._internal();

//   static Database? _database;

//   Future<Database> get database async {
//     return _database ??= await _initDatabase();
//   }

//   Future<Database> _initDatabase() async {
//     final dbPath = await getDatabasesPath();
//     final path = join(dbPath, 'my_database.db');

//     return await openDatabase(
//       path,
//       version: 1,
//       onCreate: (db, version) async {
//         await db.execute('''
//           CREATE TABLE users(
//             id INTEGER PRIMARY KEY AUTOINCREMENT,
//             name TEXT,
//             age INTEGER
//           )
//         ''');
//       },
//     );
//   }

//   Future<int> insertUser(PageOneModels user) async {
//     final db = await database;
//     return await db.insert('users', user.toMap());
//   }

//   Future<List<PageOneModels>> getUsers() async {
//     final db = await database;
//     final maps = await db.query('users');
//     return List.generate(maps.length, (i) => PageOneModels.fromMap(maps[i]));
//   }

//   Future<int> updateUser(PageOneModels user) async {
//     final db = await database;
//     return await db.update(
//       'users',
//       user.toMap(),
//       where: 'id = ?',
//       whereArgs: [user.id],
//     );
//   }

//   Future<int> deleteUser(int id) async {
//     final db = await database;
//     return await db.delete(
//       'users',
//       where: 'id = ?',
//       whereArgs: [id],
//     );
//   }
// }
