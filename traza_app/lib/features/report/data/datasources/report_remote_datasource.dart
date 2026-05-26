import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/error/failures.dart';
import '../models/report_model.dart';

abstract class ReportRemoteDataSource {
  Future<ReportModel> submitReport({
    required String incidentType,
    required String description,
    required double latitude,
    required double longitude,
    required bool anonymous,
  });

  Future<List<ReportModel>> getUserReports();
}

class ReportRemoteDataSourceImpl implements ReportRemoteDataSource {
  final http.Client httpClient;
  final SharedPreferences prefs;
  final String baseUrl;

  static const _cachedUserKey = 'CACHED_USER';

  ReportRemoteDataSourceImpl({
    required this.httpClient,
    required this.prefs,
    required this.baseUrl,
  });

  String _getToken() {
    final jsonStr = prefs.getString(_cachedUserKey);
    if (jsonStr == null) throw const ServerFailure('No hay sesión activa');
    final user = jsonDecode(jsonStr) as Map<String, dynamic>;
    final token = user['token'] as String?;
    if (token == null || token.isEmpty) {
      throw const ServerFailure('Token no encontrado');
    }
    return token;
  }

  Map<String, String> _authHeaders() => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${_getToken()}',
      };

  @override
  Future<ReportModel> submitReport({
    required String incidentType,
    required String description,
    required double latitude,
    required double longitude,
    required bool anonymous,
  }) async {
    final response = await httpClient.post(
      Uri.parse('$baseUrl/reports/'),
      headers: _authHeaders(),
      body: jsonEncode({
        'incident_type': incidentType,
        'description': description,
        'latitude': latitude,
        'longitude': longitude,
        'anonymous': anonymous,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return ReportModel.fromBackendJson(json);
    }

    throw ServerFailure(
      'Error al crear reporte (${response.statusCode}): ${response.body}',
    );
  }

  @override
  Future<List<ReportModel>> getUserReports() async {
    final response = await httpClient.get(
      Uri.parse('$baseUrl/reports/my-reports'),
      headers: _authHeaders(),
    );

    if (response.statusCode == 200) {
      final list = jsonDecode(response.body) as List;
      return list
          .map((j) => ReportModel.fromBackendJson(j as Map<String, dynamic>))
          .toList();
    }

    throw ServerFailure(
      'Error al cargar reportes (${response.statusCode}): ${response.body}',
    );
  }
}