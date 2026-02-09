import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/evaluasi_data.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'evaluasi_ws.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE evaluasi(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tanggal TEXT NOT NULL,
        shift TEXT NOT NULL,
        kapal TEXT NOT NULL,
        pelayaran TEXT NOT NULL,
        targetBongkar INTEGER NOT NULL,
        realisasiBongkar INTEGER NOT NULL,
        targetMuat INTEGER NOT NULL,
        realisasiMuat INTEGER NOT NULL,
        persenBongkar REAL NOT NULL,
        persenMuat REAL NOT NULL,
        keterangan TEXT NOT NULL
      )
    ''');

    // Insert sample data
    await db.insert('evaluasi', {
      'tanggal': '10/02/2026',
      'shift': 'Shift 1',
      'kapal': 'MV Ocean Star',
      'pelayaran': 'Pelayaran 1',
      'targetBongkar': 650,
      'realisasiBongkar': 615,
      'targetMuat': 690,
      'realisasiMuat': 680,
      'persenBongkar': 94.6,
      'persenMuat': 98.6,
      'keterangan': 'Normal',
    });

    await db.insert('evaluasi', {
      'tanggal': '10/02/2026',
      'shift': 'Shift 2',
      'kapal': 'MV Pacific Wave',
      'pelayaran': 'Pelayaran 2',
      'targetBongkar': 650,
      'realisasiBongkar': 580,
      'targetMuat': 690,
      'realisasiMuat': 645,
      'persenBongkar': 89.2,
      'persenMuat': 93.5,
      'keterangan': 'Cuaca buruk',
    });
  }

  // Insert data
  Future<int> insertEvaluasi(EvaluasiData evaluasi) async {
    Database db = await database;
    return await db.insert('evaluasi', evaluasi.toMap());
  }

  // Get all data
  Future<List<EvaluasiData>> getAllEvaluasi() async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'evaluasi',
      orderBy: 'id DESC',
    );
    return List.generate(maps.length, (i) {
      return EvaluasiData.fromMap(maps[i]);
    });
  }

  // Search data
  Future<List<EvaluasiData>> searchEvaluasi(String query) async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'evaluasi',
      where: 'kapal LIKE ? OR tanggal LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'id DESC',
    );
    return List.generate(maps.length, (i) {
      return EvaluasiData.fromMap(maps[i]);
    });
  }

  // Update data
  Future<int> updateEvaluasi(EvaluasiData evaluasi) async {
    Database db = await database;
    return await db.update(
      'evaluasi',
      evaluasi.toMap(),
      where: 'id = ?',
      whereArgs: [evaluasi.id],
    );
  }

  // Delete data
  Future<int> deleteEvaluasi(int id) async {
    Database db = await database;
    return await db.delete(
      'evaluasi',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Get statistics
  Future<Map<String, dynamic>> getStatistics() async {
    Database db = await database;

    // Total bongkar dan muat
    final totalResult = await db.rawQuery('''
      SELECT 
        SUM(realisasiBongkar) as totalBongkar,
        SUM(realisasiMuat) as totalMuat,
        SUM(targetBongkar) as totalTargetBongkar,
        SUM(targetMuat) as totalTargetMuat,
        COUNT(*) as totalRecords
      FROM evaluasi
    ''');

    // Average per day
    final avgResult = await db.rawQuery('''
      SELECT 
        AVG(realisasiBongkar) as avgBongkar,
        AVG(realisasiMuat) as avgMuat
      FROM evaluasi
    ''');

    final total = totalResult.first;
    final avg = avgResult.first;

    final totalBongkar = (total['totalBongkar'] as num?)?.toInt() ?? 0;
    final totalMuat = (total['totalMuat'] as num?)?.toInt() ?? 0;
    final totalTargetBongkar =
        (total['totalTargetBongkar'] as num?)?.toInt() ?? 1;
    final totalTargetMuat = (total['totalTargetMuat'] as num?)?.toInt() ?? 1;
    final avgBongkar = (avg['avgBongkar'] as num?)?.toInt() ?? 0;
    final avgMuat = (avg['avgMuat'] as num?)?.toInt() ?? 0;

    return {
      'totalBongkar': totalBongkar,
      'totalMuat': totalMuat,
      'avgBongkar': avgBongkar,
      'avgMuat': avgMuat,
      'persenBongkar': (totalBongkar / totalTargetBongkar * 100),
      'persenMuat': (totalMuat / totalTargetMuat * 100),
      'totalRecords': total['totalRecords'] ?? 0,
    };
  }

  // Clear all data (optional, for testing)
  Future<void> clearAllData() async {
    Database db = await database;
    await db.delete('evaluasi');
  }

  // Close database
  Future<void> close() async {
    Database db = await database;
    await db.close();
  }
}
