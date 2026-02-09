import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/evaluasi_data.dart';
import '../models/target_data.dart';
import '../models/realisasi_data.dart';

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
      version: 2, // Increment version for schema changes
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Original evaluasi table (for backward compatibility)
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

    // New target_data table
    await db.execute('''
      CREATE TABLE target_data(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        pelayaran TEXT NOT NULL,
        kodeWS TEXT NOT NULL,
        periode TEXT NOT NULL,
        waktuBerthing TEXT NOT NULL,
        waktuDeparture TEXT NOT NULL,
        berthingTime TEXT NOT NULL,
        targetBongkar INTEGER NOT NULL,
        targetMuat INTEGER NOT NULL,
        createdAt TEXT NOT NULL
      )
    ''');

    // New realisasi_data table
    await db.execute('''
      CREATE TABLE realisasi_data(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        pelayaran TEXT NOT NULL,
        kodeWS TEXT NOT NULL,
        namaKapal TEXT NOT NULL,
        periode TEXT NOT NULL,
        waktuArrival TEXT NOT NULL,
        waktuBerthing TEXT NOT NULL,
        waktuDeparture TEXT NOT NULL,
        berthingTime TEXT NOT NULL,
        realisasiBongkar INTEGER NOT NULL,
        realisasiMuat INTEGER NOT NULL,
        createdAt TEXT NOT NULL
      )
    ''');

    // Insert sample data for old table (backward compatibility)
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

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Create new tables if upgrading from version 1
      await db.execute('''
        CREATE TABLE IF NOT EXISTS target_data(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          pelayaran TEXT NOT NULL,
          kodeWS TEXT NOT NULL,
          periode TEXT NOT NULL,
          waktuBerthing TEXT NOT NULL,
          waktuDeparture TEXT NOT NULL,
          berthingTime TEXT NOT NULL,
          targetBongkar INTEGER NOT NULL,
          targetMuat INTEGER NOT NULL,
          createdAt TEXT NOT NULL
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS realisasi_data(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          pelayaran TEXT NOT NULL,
          kodeWS TEXT NOT NULL,
          namaKapal TEXT NOT NULL,
          periode TEXT NOT NULL,
          waktuArrival TEXT NOT NULL,
          waktuBerthing TEXT NOT NULL,
          waktuDeparture TEXT NOT NULL,
          berthingTime TEXT NOT NULL,
          realisasiBongkar INTEGER NOT NULL,
          realisasiMuat INTEGER NOT NULL,
          createdAt TEXT NOT NULL
        )
      ''');
    }
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

  // ======================== TARGET DATA METHODS ========================

  // Insert target data
  Future<int> insertTargetData(TargetData target) async {
    Database db = await database;
    return await db.insert('target_data', target.toMap());
  }

  // Get all target data
  Future<List<TargetData>> getAllTargetData() async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'target_data',
      orderBy: 'id DESC',
    );
    return List.generate(maps.length, (i) {
      return TargetData.fromMap(maps[i]);
    });
  }

  // Get target data by periode
  Future<List<TargetData>> getTargetDataByPeriode(String periode) async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'target_data',
      where: 'periode = ?',
      whereArgs: [periode],
      orderBy: 'id DESC',
    );
    return List.generate(maps.length, (i) {
      return TargetData.fromMap(maps[i]);
    });
  }

  // Search target data
  Future<List<TargetData>> searchTargetData(String query) async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'target_data',
      where: 'kodeWS LIKE ? OR pelayaran LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'id DESC',
    );
    return List.generate(maps.length, (i) {
      return TargetData.fromMap(maps[i]);
    });
  }

  // Update target data
  Future<int> updateTargetData(TargetData target) async {
    Database db = await database;
    return await db.update(
      'target_data',
      target.toMap(),
      where: 'id = ?',
      whereArgs: [target.id],
    );
  }

  // Delete target data
  Future<int> deleteTargetData(int id) async {
    Database db = await database;
    return await db.delete(
      'target_data',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ======================== REALISASI DATA METHODS ========================

  // Insert realisasi data
  Future<int> insertRealisasiData(RealisasiData realisasi) async {
    Database db = await database;
    return await db.insert('realisasi_data', realisasi.toMap());
  }

  // Get all realisasi data
  Future<List<RealisasiData>> getAllRealisasiData() async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'realisasi_data',
      orderBy: 'id DESC',
    );
    return List.generate(maps.length, (i) {
      return RealisasiData.fromMap(maps[i]);
    });
  }

  // Get realisasi data by periode
  Future<List<RealisasiData>> getRealisasiDataByPeriode(String periode) async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'realisasi_data',
      where: 'periode = ?',
      whereArgs: [periode],
      orderBy: 'id DESC',
    );
    return List.generate(maps.length, (i) {
      return RealisasiData.fromMap(maps[i]);
    });
  }

  // Search realisasi data
  Future<List<RealisasiData>> searchRealisasiData(String query) async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'realisasi_data',
      where: 'namaKapal LIKE ? OR kodeWS LIKE ? OR pelayaran LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%'],
      orderBy: 'id DESC',
    );
    return List.generate(maps.length, (i) {
      return RealisasiData.fromMap(maps[i]);
    });
  }

  // Update realisasi data
  Future<int> updateRealisasiData(RealisasiData realisasi) async {
    Database db = await database;
    return await db.update(
      'realisasi_data',
      realisasi.toMap(),
      where: 'id = ?',
      whereArgs: [realisasi.id],
    );
  }

  // Delete realisasi data
  Future<int> deleteRealisasiData(int id) async {
    Database db = await database;
    return await db.delete(
      'realisasi_data',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Get combined statistics (Target vs Realisasi)
  Future<Map<String, dynamic>> getCombinedStatistics() async {
    Database db = await database;

    // Get target totals
    final targetResult = await db.rawQuery('''
      SELECT 
        SUM(targetBongkar) as totalTargetBongkar,
        SUM(targetMuat) as totalTargetMuat,
        COUNT(*) as totalTargetRecords
      FROM target_data
    ''');

    // Get realisasi totals
    final realisasiResult = await db.rawQuery('''
      SELECT 
        SUM(realisasiBongkar) as totalRealisasiBongkar,
        SUM(realisasiMuat) as totalRealisasiMuat,
        COUNT(*) as totalRealisasiRecords
      FROM realisasi_data
    ''');

    final target = targetResult.first;
    final realisasi = realisasiResult.first;

    final totalTargetBongkar =
        (target['totalTargetBongkar'] as num?)?.toInt() ?? 0;
    final totalTargetMuat = (target['totalTargetMuat'] as num?)?.toInt() ?? 0;
    final totalRealisasiBongkar =
        (realisasi['totalRealisasiBongkar'] as num?)?.toInt() ?? 0;
    final totalRealisasiMuat =
        (realisasi['totalRealisasiMuat'] as num?)?.toInt() ?? 0;

    return {
      'totalTargetBongkar': totalTargetBongkar,
      'totalTargetMuat': totalTargetMuat,
      'totalRealisasiBongkar': totalRealisasiBongkar,
      'totalRealisasiMuat': totalRealisasiMuat,
      'achievementBongkar': totalTargetBongkar > 0
          ? (totalRealisasiBongkar / totalTargetBongkar * 100)
          : 0.0,
      'achievementMuat': totalTargetMuat > 0
          ? (totalRealisasiMuat / totalTargetMuat * 100)
          : 0.0,
      'totalTargetRecords': target['totalTargetRecords'] ?? 0,
      'totalRealisasiRecords': realisasi['totalRealisasiRecords'] ?? 0,
    };
  }

  // Clear all data (optional, for testing)
  Future<void> clearAllData() async {
    Database db = await database;
    await db.delete('evaluasi');
    await db.delete('target_data');
    await db.delete('realisasi_data');
  }

  // Close database
  Future<void> close() async {
    Database db = await database;
    await db.close();
  }
}
