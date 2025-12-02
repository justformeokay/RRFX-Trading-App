import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:deriv_chart/deriv_chart.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB('candles.db');
    return _db!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
        CREATE TABLE candles (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          symbol TEXT NOT NULL,
          timeframe TEXT NOT NULL,
          account TEXT NOT NULL,
          epoch INTEGER,
          open REAL,
          high REAL,
          low REAL,
          close REAL,
          UNIQUE(symbol, timeframe, account, epoch)
        )
        ''');
      },
    );
  }

  Future<void> insertOrReplaceCandles(
    List<Candle> candles, {
    required String symbol,
    required String timeframe,
    required String account,
  }) async {
    final db = await database;
    final batch = db.batch();
    for (var c in candles) {
      batch.insert(
        'candles',
        {
          'symbol': symbol,
          'timeframe': timeframe,
          'account': account,
          'epoch': c.epoch,
          'open': c.open,
          'high': c.high,
          'low': c.low,
          'close': c.close,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<List<Candle>> getCandles({
    required String symbol,
    required String timeframe,
    required String account,
  }) async {
    final db = await database;
    final maps = await db.query(
      'candles',
      where: 'symbol = ? AND timeframe = ? AND account = ?',
      whereArgs: [symbol, timeframe, account],
      orderBy: 'epoch ASC',
    );

    return List.generate(maps.length, (i) {
      return Candle(
        epoch: maps[i]['epoch'] as int,
        open: maps[i]['open'] as double,
        high: maps[i]['high'] as double,
        low: maps[i]['low'] as double,
        close: maps[i]['close'] as double,
      );
    });
  }

  Future<void> deleteOldCandles({
    required String symbol,
    required String timeframe,
    required String account,
    int keepLast = 500,
  }) async {
    final db = await database;
    await db.execute('''
      DELETE FROM candles 
      WHERE id NOT IN (
        SELECT id FROM candles
        WHERE symbol = ? AND timeframe = ? AND account = ?
        ORDER BY epoch DESC
        LIMIT ?
      ) AND symbol = ? AND timeframe = ? AND account = ?
    ''', [symbol, timeframe, account, keepLast, symbol, timeframe, account]);
  }

  Future<void> debugPrintCandles(String symbol) async {
    final db = await database;
    final result = await db.query(
      'candles',
      where: 'symbol = ?',
      whereArgs: [symbol],
      orderBy: 'epoch ASC',
    );

    print('📊 Total candle di $symbol: ${result.length}');
    if (result.isNotEmpty) {
      final last = result.last;
      // print('🕓 Candle pertama: ${DateTime.fromMillisecondsSinceEpoch(first['epoch'] * 1000)}');
      // print('🕓 Candle terakhir: ${DateTime.fromMillisecondsSinceEpoch(last['epoch'] * 1000)}');
      print('🔹 Contoh data terakhir: $last');
    }
  }

}
