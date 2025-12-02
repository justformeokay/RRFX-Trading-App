// import 'package:path/path.dart';
// import 'package:sqflite/sqflite.dart';

// class DatabaseService {
//   static final DatabaseService instance = DatabaseService._internal();
//   static Database? _database;

//   DatabaseService._internal();

//   Future<Database> get database async {
//     _database ??= await _initDatabase();
//     return _database!;
//   }
  
//   Future<Database> _initDatabase() async {
//     String path = await getDatabasesPath();
//     return openDatabase(
//       join(path, 'tridentpro.db'),
//       version: 1,
//       singleInstance: true,
//       onCreate: (Database db, int version) async {
//         await createTableAccount(db, version);
//       }
//     );
//   }

//   Future<void> createTableAccount(Database db, int version) async {
//     await db.execute('''
//       CREATE TABLE IF NOT EXISTS account (
//         id INTEGER PRIMARY KEY,
//         type TEXT DEFAULT NULL,
//         typeAcc TEXT DEFAULT NULL,
//         country TEXT DEFAULT NULL,
//         idType TEXT DEFAULT NULL,
//         idNumber TEXT DEFAULT NULL,
//         appFotoIdentitas TEXT DEFAULT NULL,
//         appFotoTerbaru TEXT DEFAULT NULL,
//         npwp TEXT DEFAULT NULL,
//         dateOfBirth TEXT DEFAULT NULL,
//         placeOfBirth TEXT DEFAULT NULL,
//         gender TEXT DEFAULT NULL,
//         province TEXT DEFAULT NULL,
//         city TEXT DEFAULT NULL,
//         district TEXT DEFAULT NULL,
//         village TEXT DEFAULT NULL,
//         address TEXT DEFAULT NULL,
//         postalCode TEXT DEFAULT NULL,
//         motherName TEXT DEFAULT NULL,
//         phoneHome TEXT DEFAULT NULL,
//         faxHome TEXT DEFAULT NULL,
//         phoneNumber TEXT DEFAULT NULL,
//         drrtName TEXT DEFAULT NULL,
//         drrtStatus TEXT DEFAULT NULL,
//         drrtPhone TEXT DEFAULT NULL,
//         drrtAddress TEXT DEFAULT NULL,
//         drrtPostalCode TEXT DEFAULT NULL
//       )
//     ''');
//   }      


//   Future<Map<String, dynamic>> getAccount() async {
//     try {
//       final db = await database;
//       final result = await db.rawQuery('SELECT * FROM account');

//       return result.first;
      
//     } catch (e) {
//       throw Exception("getAccount error: $e");
//     }
//   }

//   Future<void> insertAccount(Map<String, dynamic> account) async {
//     try {
//       final db = await database;
//       await db.insert('account', account, conflictAlgorithm: ConflictAlgorithm.replace);
      
//     } catch (e) {
//       throw Exception("insertAccount error: $e");
//     }
//   }
// }