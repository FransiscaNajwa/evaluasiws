import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/evaluasi_data.dart';
import '../models/target_data.dart';
import '../models/realisasi_data.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static late SharedPreferences _prefs;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await _prefs.setBool('initialized', true);
    print('SharedPreferences initialized successfully');
  }

  // Helper method to ensure initialization
  void _ensureInitialized() {
    if (!(_prefs.getBool('initialized') ?? false)) {
      print(
          'Warning: SharedPreferences not initialized. Call initialize() in main()');
    }
  }

  // ======================== EVALUASI DATA METHODS ========================

  // Insert evaluasi data
  Future<int> insertEvaluasi(EvaluasiData evaluasi) async {
    _ensureInitialized();
    try {
      List<EvaluasiData> all = await getAllEvaluasi();
      int maxId = all.isEmpty
          ? 0
          : all.map((e) => e.id ?? 0).reduce((a, b) => a > b ? a : b);
      int newId = maxId + 1;

      List<String> evaluasiList = _prefs.getStringList('evaluasi_list') ?? [];
      Map<String, dynamic> dataMap = evaluasi.toMap();
      dataMap['id'] = newId;
      evaluasiList.add(jsonEncode(dataMap));
      await _prefs.setStringList('evaluasi_list', evaluasiList);

      return newId;
    } catch (e) {
      print('Error inserting evaluasi: $e');
      return 0;
    }
  }

  // Get all evaluasi data
  Future<List<EvaluasiData>> getAllEvaluasi() async {
    _ensureInitialized();
    try {
      List<String> evaluasiList = _prefs.getStringList('evaluasi_list') ?? [];
      return List.generate(evaluasiList.length, (i) {
        return EvaluasiData.fromMap(jsonDecode(evaluasiList[i]));
      });
    } catch (e) {
      print('Error getting all evaluasi: $e');
      return [];
    }
  }

  // Search evaluasi data
  Future<List<EvaluasiData>> searchEvaluasi(String query) async {
    _ensureInitialized();
    try {
      List<EvaluasiData> all = await getAllEvaluasi();
      return all.where((evaluasi) {
        return evaluasi.kapal.toLowerCase().contains(query.toLowerCase()) ||
            evaluasi.tanggal.toLowerCase().contains(query.toLowerCase());
      }).toList();
    } catch (e) {
      print('Error searching evaluasi: $e');
      return [];
    }
  }

  // Update evaluasi data
  Future<int> updateEvaluasi(EvaluasiData evaluasi) async {
    _ensureInitialized();
    try {
      List<String> evaluasiList = _prefs.getStringList('evaluasi_list') ?? [];
      int index = evaluasiList.indexWhere((item) {
        final data = EvaluasiData.fromMap(jsonDecode(item));
        return data.id == evaluasi.id;
      });

      if (index >= 0) {
        evaluasiList[index] = jsonEncode(evaluasi.toMap());
        await _prefs.setStringList('evaluasi_list', evaluasiList);
        return 1;
      }
      return 0;
    } catch (e) {
      print('Error updating evaluasi: $e');
      return 0;
    }
  }

  // Delete evaluasi data
  Future<int> deleteEvaluasi(int id) async {
    _ensureInitialized();
    try {
      List<String> evaluasiList = _prefs.getStringList('evaluasi_list') ?? [];
      evaluasiList.removeWhere((item) {
        final data = EvaluasiData.fromMap(jsonDecode(item));
        return data.id == id;
      });
      await _prefs.setStringList('evaluasi_list', evaluasiList);
      return 1;
    } catch (e) {
      print('Error deleting evaluasi: $e');
      return 0;
    }
  }

  // Get statistics
  Future<Map<String, dynamic>> getStatistics() async {
    _ensureInitialized();
    try {
      List<EvaluasiData> all = await getAllEvaluasi();

      int totalBongkar = 0,
          totalMuat = 0,
          totalTargetBongkar = 0,
          totalTargetMuat = 0;

      for (var item in all) {
        totalBongkar += item.realisasiBongkar;
        totalMuat += item.realisasiMuat;
        totalTargetBongkar += item.targetBongkar;
        totalTargetMuat += item.targetMuat;
      }

      int avgBongkar = all.isEmpty ? 0 : (totalBongkar ~/ all.length);
      int avgMuat = all.isEmpty ? 0 : (totalMuat ~/ all.length);

      return {
        'totalBongkar': totalBongkar,
        'totalMuat': totalMuat,
        'avgBongkar': avgBongkar,
        'avgMuat': avgMuat,
        'persenBongkar': totalTargetBongkar > 0
            ? (totalBongkar / totalTargetBongkar * 100)
            : 0.0,
        'persenMuat':
            totalTargetMuat > 0 ? (totalMuat / totalTargetMuat * 100) : 0.0,
        'totalRecords': all.length,
      };
    } catch (e) {
      print('Error getting statistics: $e');
      return {
        'totalBongkar': 0,
        'totalMuat': 0,
        'avgBongkar': 0,
        'avgMuat': 0,
        'persenBongkar': 0.0,
        'persenMuat': 0.0,
        'totalRecords': 0,
      };
    }
  }

  // ======================== TARGET DATA METHODS ========================

  // Insert target data
  Future<int> insertTargetData(TargetData target) async {
    _ensureInitialized();
    try {
      List<TargetData> all = await getAllTargetData();
      int maxId = all.isEmpty
          ? 0
          : all.map((e) => e.id ?? 0).reduce((a, b) => a > b ? a : b);
      int newId = maxId + 1;

      List<String> targetList = _prefs.getStringList('target_data_list') ?? [];
      Map<String, dynamic> dataMap = target.toMap();
      dataMap['id'] = newId;
      String jsonData = jsonEncode(dataMap);
      targetList.add(jsonData);
      bool saveSuccess =
          await _prefs.setStringList('target_data_list', targetList);

      print('DEBUG: insertTargetData - ID: $newId');
      print(
          'DEBUG: insertTargetData - Data: ${dataMap['pelayaran']} - ${dataMap['kodeWS']}');
      print('DEBUG: insertTargetData - Save Success: $saveSuccess');
      print(
          'DEBUG: insertTargetData - Total records now: ${targetList.length}');

      return newId;
    } catch (e) {
      print('Error inserting target data: $e');
      return 0;
    }
  }

  // Get all target data
  Future<List<TargetData>> getAllTargetData() async {
    _ensureInitialized();
    try {
      List<String> targetList = _prefs.getStringList('target_data_list') ?? [];
      print(
          'DEBUG: getAllTargetData - Found ${targetList.length} records in SharedPreferences');

      List<TargetData> result = [];
      for (int i = 0; i < targetList.length; i++) {
        try {
          final data = TargetData.fromMap(jsonDecode(targetList[i]));
          result.add(data);
          print(
              'DEBUG: Loaded target data #${i + 1}: ${data.pelayaran} - ${data.kodeWS}');
        } catch (parseError) {
          print('DEBUG: Error parsing target data at index $i: $parseError');
        }
      }
      print(
          'DEBUG: getAllTargetData - Successfully loaded ${result.length} items');
      return result;
    } catch (e) {
      print('Error getting all target data: $e');
      return [];
    }
  }

  // Get target data by periode
  Future<List<TargetData>> getTargetDataByPeriode(String periode) async {
    _ensureInitialized();
    try {
      List<TargetData> all = await getAllTargetData();
      return all.where((target) => target.periode == periode).toList();
    } catch (e) {
      print('Error getting target data by periode: $e');
      return [];
    }
  }

  // Search target data
  Future<List<TargetData>> searchTargetData(String query) async {
    _ensureInitialized();
    try {
      List<TargetData> all = await getAllTargetData();
      return all.where((target) {
        return target.kodeWS.toLowerCase().contains(query.toLowerCase()) ||
            target.pelayaran.toLowerCase().contains(query.toLowerCase());
      }).toList();
    } catch (e) {
      print('Error searching target data: $e');
      return [];
    }
  }

  // Update target data
  Future<int> updateTargetData(TargetData target) async {
    _ensureInitialized();
    try {
      List<String> targetList = _prefs.getStringList('target_data_list') ?? [];
      int index = targetList.indexWhere((item) {
        final data = TargetData.fromMap(jsonDecode(item));
        return data.id == target.id;
      });

      if (index >= 0) {
        targetList[index] = jsonEncode(target.toMap());
        await _prefs.setStringList('target_data_list', targetList);
        return 1;
      }
      return 0;
    } catch (e) {
      print('Error updating target data: $e');
      return 0;
    }
  }

  // Delete target data
  Future<int> deleteTargetData(int id) async {
    _ensureInitialized();
    try {
      List<String> targetList = _prefs.getStringList('target_data_list') ?? [];
      targetList.removeWhere((item) {
        final data = TargetData.fromMap(jsonDecode(item));
        return data.id == id;
      });
      await _prefs.setStringList('target_data_list', targetList);
      return 1;
    } catch (e) {
      print('Error deleting target data: $e');
      return 0;
    }
  }

  // ======================== REALISASI DATA METHODS ========================

  // Insert realisasi data
  Future<int> insertRealisasiData(RealisasiData realisasi) async {
    _ensureInitialized();
    try {
      List<RealisasiData> all = await getAllRealisasiData();
      int maxId = all.isEmpty
          ? 0
          : all.map((e) => e.id ?? 0).reduce((a, b) => a > b ? a : b);
      int newId = maxId + 1;

      List<String> realisasiList =
          _prefs.getStringList('realisasi_data_list') ?? [];
      Map<String, dynamic> dataMap = realisasi.toMap();
      dataMap['id'] = newId;
      String jsonData = jsonEncode(dataMap);
      realisasiList.add(jsonData);
      bool saveSuccess =
          await _prefs.setStringList('realisasi_data_list', realisasiList);

      print('DEBUG: insertRealisasiData - ID: $newId');
      print(
          'DEBUG: insertRealisasiData - Data: ${dataMap['namaKapal']} - ${dataMap['kodeWS']}');
      print('DEBUG: insertRealisasiData - Save Success: $saveSuccess');
      print(
          'DEBUG: insertRealisasiData - Total records now: ${realisasiList.length}');

      return newId;
    } catch (e) {
      print('Error inserting realisasi data: $e');
      return 0;
    }
  }

  // Get all realisasi data
  Future<List<RealisasiData>> getAllRealisasiData() async {
    _ensureInitialized();
    try {
      List<String> realisasiList =
          _prefs.getStringList('realisasi_data_list') ?? [];
      print(
          'DEBUG: getAllRealisasiData - Found ${realisasiList.length} records in SharedPreferences');

      List<RealisasiData> result = [];
      for (int i = 0; i < realisasiList.length; i++) {
        try {
          final data = RealisasiData.fromMap(jsonDecode(realisasiList[i]));
          result.add(data);
          print(
              'DEBUG: Loaded realisasi data #${i + 1}: ${data.namaKapal} - ${data.kodeWS}');
        } catch (parseError) {
          print('DEBUG: Error parsing realisasi data at index $i: $parseError');
        }
      }
      print(
          'DEBUG: getAllRealisasiData - Successfully loaded ${result.length} items');
      return result;
    } catch (e) {
      print('Error getting all realisasi data: $e');
      return [];
    }
  }

  // Get realisasi data by periode
  Future<List<RealisasiData>> getRealisasiDataByPeriode(String periode) async {
    _ensureInitialized();
    try {
      List<RealisasiData> all = await getAllRealisasiData();
      return all.where((realisasi) => realisasi.periode == periode).toList();
    } catch (e) {
      print('Error getting realisasi data by periode: $e');
      return [];
    }
  }

  // Search realisasi data
  Future<List<RealisasiData>> searchRealisasiData(String query) async {
    _ensureInitialized();
    try {
      List<RealisasiData> all = await getAllRealisasiData();
      return all.where((realisasi) {
        return realisasi.namaKapal
                .toLowerCase()
                .contains(query.toLowerCase()) ||
            realisasi.kodeWS.toLowerCase().contains(query.toLowerCase()) ||
            realisasi.pelayaran.toLowerCase().contains(query.toLowerCase());
      }).toList();
    } catch (e) {
      print('Error searching realisasi data: $e');
      return [];
    }
  }

  // Update realisasi data
  Future<int> updateRealisasiData(RealisasiData realisasi) async {
    _ensureInitialized();
    try {
      List<String> realisasiList =
          _prefs.getStringList('realisasi_data_list') ?? [];
      int index = realisasiList.indexWhere((item) {
        final data = RealisasiData.fromMap(jsonDecode(item));
        return data.id == realisasi.id;
      });

      if (index >= 0) {
        realisasiList[index] = jsonEncode(realisasi.toMap());
        await _prefs.setStringList('realisasi_data_list', realisasiList);
        return 1;
      }
      return 0;
    } catch (e) {
      print('Error updating realisasi data: $e');
      return 0;
    }
  }

  // Delete realisasi data
  Future<int> deleteRealisasiData(int id) async {
    _ensureInitialized();
    try {
      List<String> realisasiList =
          _prefs.getStringList('realisasi_data_list') ?? [];
      realisasiList.removeWhere((item) {
        final data = RealisasiData.fromMap(jsonDecode(item));
        return data.id == id;
      });
      await _prefs.setStringList('realisasi_data_list', realisasiList);
      return 1;
    } catch (e) {
      print('Error deleting realisasi data: $e');
      return 0;
    }
  }

  // Get combined statistics (Target vs Realisasi)
  Future<Map<String, dynamic>> getCombinedStatistics() async {
    _ensureInitialized();
    try {
      List<TargetData> allTarget = await getAllTargetData();
      List<RealisasiData> allRealisasi = await getAllRealisasiData();

      int totalTargetBongkar = 0, totalTargetMuat = 0;
      int totalRealisasiBongkar = 0, totalRealisasiMuat = 0;

      for (var target in allTarget) {
        totalTargetBongkar += target.targetBongkar;
        totalTargetMuat += target.targetMuat;
      }

      for (var realisasi in allRealisasi) {
        totalRealisasiBongkar += realisasi.realisasiBongkar;
        totalRealisasiMuat += realisasi.realisasiMuat;
      }

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
        'totalTargetRecords': allTarget.length,
        'totalRealisasiRecords': allRealisasi.length,
      };
    } catch (e) {
      print('Error getting combined statistics: $e');
      return {
        'totalTargetBongkar': 0,
        'totalTargetMuat': 0,
        'totalRealisasiBongkar': 0,
        'totalRealisasiMuat': 0,
        'achievementBongkar': 0.0,
        'achievementMuat': 0.0,
        'totalTargetRecords': 0,
        'totalRealisasiRecords': 0,
      };
    }
  }

  // Clear all data (optional, for testing)
  Future<void> clearAllData() async {
    _ensureInitialized();
    try {
      await _prefs.remove('evaluasi_list');
      await _prefs.remove('target_data_list');
      await _prefs.remove('realisasi_data_list');
    } catch (e) {
      print('Error clearing all data: $e');
    }
  }
}
