import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/candle_model.dart';

class CandleDatabase {
  CandleDatabase._privateConstructor();
  static final CandleDatabase instance = CandleDatabase._privateConstructor();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB('candle_cache.db');
    return _db!;
  }

  Future<Database> _initDB(String fileName) async {
    final path = join(await getDatabasesPath(), fileName);
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, _) async {
        await db.execute('''
          CREATE TABLE candles(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            symbol TEXT,
            timeframe TEXT,
            time INTEGER,
            open REAL,
            high REAL,
            low REAL,
            close REAL,
            digits INTEGER,
            tickVolume INTEGER
          )
        ''');
      },
    );
  }

  /// Insert 1 candle baru
  Future<void> insertCandle(
      String symbol, String timeframe, CandleModel c) async {
    final db = await database;
    await db.insert(
      'candles',
      {
        'symbol': symbol,
        'timeframe': timeframe,
        ...c.toDbMap(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Update candle terakhir untuk symbol + timeframe
  Future<void> updateLastCandle(
      String symbol, String timeframe, CandleModel c) async {
    final db = await database;

    // Ambil id terakhir dulu
    final result = await db.rawQuery(
      '''
      SELECT id FROM candles 
      WHERE symbol = ? AND timeframe = ?
      ORDER BY time DESC
      LIMIT 1
      ''',
      [symbol, timeframe],
    );

    if (result.isEmpty) return;

    final int lastId = result.first['id'] as int;

    await db.update(
      'candles',
      c.toDbMap(),
      where: 'id = ?',
      whereArgs: [lastId],
    );
  }

  /// Hapus semua candle sesuai symbol + timeframe
  Future<void> deleteCandlesFor(String symbol, String timeframe) async {
    final db = await database;
    await db.delete(
      'candles',
      where: 'symbol = ? AND timeframe = ?',
      whereArgs: [symbol, timeframe],
    );
  }

  /// Load semua candle dari DB untuk symbol/timeframe
  Future<List<CandleModel>> loadCandles(
      String symbol, String timeframe) async {
    final db = await database;

    final data = await db.query(
      'candles',
      where: 'symbol = ? AND timeframe = ?',
      whereArgs: [symbol, timeframe],
      orderBy: 'time ASC',
    );

    return data.map((e) => CandleModel.fromDbMap(e)).toList();
  }
}
