import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/target_data.dart';
import '../models/realisasi_data.dart';

const String apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://localhost/evaluasi_ws/api_php/index.php',
);
const String apiKey = 'TPK-NILAM-2026';

class ApiService {
  Uri _buildUri(String request, {int? id}) {
    final base = Uri.parse(apiBaseUrl);
    final queryParams = Map<String, String>.from(base.queryParameters);
    queryParams['request'] = request;
    if (id != null) {
      queryParams['id'] = id.toString();
    }
    return base.replace(queryParameters: queryParams);
  }

  Map<String, String> _headers() {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey',
    };
  }

  void _ensureSuccess(http.Response response, String action) {
    if (response.statusCode != 200) {
      throw Exception(
          '$action failed: ${response.statusCode} ${response.body}');
    }
  }

  Future<List<TargetData>> fetchTargetData() async {
    final response = await http.get(
      _buildUri('target_data'),
      headers: _headers(),
    );
    _ensureSuccess(response, 'Fetch target data');

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final data = body['data'] as List<dynamic>? ?? [];
    return data
        .map((item) => _targetFromApi(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<RealisasiData>> fetchRealisasiData() async {
    final response = await http.get(
      _buildUri('realisasi_data'),
      headers: _headers(),
    );
    _ensureSuccess(response, 'Fetch realisasi data');

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final data = body['data'] as List<dynamic>? ?? [];
    return data
        .map((item) => _realisasiFromApi(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> createTargetData(TargetData target) async {
    final response = await http.post(
      _buildUri('target_data'),
      headers: _headers(),
      body: jsonEncode(_targetToApi(target)),
    );

    _ensureSuccess(response, 'Create target data');
  }

  Future<void> createRealisasiData(RealisasiData realisasi) async {
    final response = await http.post(
      _buildUri('realisasi_data'),
      headers: _headers(),
      body: jsonEncode(_realisasiToApi(realisasi)),
    );

    _ensureSuccess(response, 'Create realisasi data');
  }

  Future<void> deleteTargetData(int id) async {
    final response = await http.delete(
      _buildUri('target_data', id: id),
      headers: _headers(),
    );
    _ensureSuccess(response, 'Delete target data');
  }

  Future<void> deleteRealisasiData(int id) async {
    final response = await http.delete(
      _buildUri('realisasi_data', id: id),
      headers: _headers(),
    );
    _ensureSuccess(response, 'Delete realisasi data');
  }

  // Generic delete method
  Future<Map<String, dynamic>> deleteData(
      {required String endpoint, required int id}) async {
    try {
      final response = await http.delete(
        _buildUri(endpoint, id: id),
        headers: _headers(),
      );

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Data deleted successfully'};
      } else {
        return {
          'success': false,
          'message': 'Delete failed: ${response.statusCode}'
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // Generic update method
  Future<Map<String, dynamic>> updateData(
      String endpoint, int id, Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        _buildUri(endpoint, id: id),
        headers: _headers(),
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Data updated successfully'};
      } else {
        return {
          'success': false,
          'message': 'Update failed: ${response.statusCode}'
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  TargetData _targetFromApi(Map<String, dynamic> map) {
    return TargetData(
      id: _parseInt(map['id']),
      pelayaran: map['pelayaran']?.toString() ?? '',
      kodeWS: map['kodeWS']?.toString() ?? '',
      periode: map['periode']?.toString() ?? '',
      waktuBerthing: map['waktuBerthing']?.toString() ?? '',
      waktuDeparture: map['waktuDeparture']?.toString() ?? '',
      berthingTime: map['berthingTime']?.toString() ?? '',
      targetBongkar: _parseInt(map['targetBongkar']) ?? 0,
      targetMuat: _parseInt(map['targetMuat']) ?? 0,
      createdAt: map['createdAt']?.toString() ?? '',
    );
  }

  RealisasiData _realisasiFromApi(Map<String, dynamic> map) {
    return RealisasiData(
      id: _parseInt(map['id']),
      pelayaran: map['pelayaran']?.toString() ?? '',
      kodeWS: map['kodeWS']?.toString() ?? '',
      namaKapal: map['namaKapal']?.toString() ?? '',
      periode: map['periode']?.toString() ?? '',
      waktuArrival: map['waktuArrival']?.toString() ?? '',
      waktuBerthing: map['waktuBerthing']?.toString() ?? '',
      waktuDeparture: map['waktuDeparture']?.toString() ?? '',
      berthingTime: map['berthingTime']?.toString() ?? '',
      realisasiBongkar: _parseInt(map['realisasiBongkar']) ?? 0,
      realisasiMuat: _parseInt(map['realisasiMuat']) ?? 0,
      createdAt: map['createdAt']?.toString() ?? '',
    );
  }

  Map<String, dynamic> _targetToApi(TargetData target) {
    return {
      'pelayaran': target.pelayaran,
      'kodeWS': target.kodeWS,
      'periode': target.periode,
      'waktuBerthing': target.waktuBerthing,
      'waktuDeparture': target.waktuDeparture,
      'berthingTime': target.berthingTime,
      'targetBongkar': target.targetBongkar,
      'targetMuat': target.targetMuat,
      'createdAt': target.createdAt,
    };
  }

  Map<String, dynamic> _realisasiToApi(RealisasiData realisasi) {
    return {
      'pelayaran': realisasi.pelayaran,
      'kodeWS': realisasi.kodeWS,
      'namaKapal': realisasi.namaKapal,
      'periode': realisasi.periode,
      'waktuArrival': realisasi.waktuArrival,
      'waktuBerthing': realisasi.waktuBerthing,
      'waktuDeparture': realisasi.waktuDeparture,
      'berthingTime': realisasi.berthingTime,
      'realisasiBongkar': realisasi.realisasiBongkar,
      'realisasiMuat': realisasi.realisasiMuat,
      'createdAt': realisasi.createdAt,
    };
  }

  int? _parseInt(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is int) {
      return value;
    }
    return int.tryParse(value.toString());
  }
}
