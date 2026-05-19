import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/report.dart';
import '../models/report_model.dart';

abstract class ReportLocalDataSource {
  Future<List<ReportModel>> getUserReports();
  Future<ReportModel> saveReport(ReportModel report);
  Future<ReportModel> updateReport(ReportModel report);
  Future<List<ReportModel>> getAllReports();
}

class ReportLocalDataSourceImpl implements ReportLocalDataSource {
  final SharedPreferences prefs;
  static const _key = 'traza_user_reports';
  static const _allKey = 'traza_all_reports';
  final _uuid = const Uuid();

  ReportLocalDataSourceImpl(this.prefs) {
    _seedMockData();
  }

  void _seedMockData() {
    final existing = prefs.getString(_allKey);
    if (existing != null) return;

    final mockReports = [
      ReportModel(
        id: '#CHI-2026-0821',
        type: ReportType.vandalism,
        location: 'La Capilla',
        latitude: 4.8616,
        longitude: -74.0388,
        description: 'Grafitis en la pared del parque. Sin registro de identidad.',
        isAnonymous: true,
        status: ReportStatus.resolved,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        officerNote: 'Policía atendió el sector. Patrullaje reforzado.',
        trustLevel: CitizenTrust.firstTime,
        coincidentReports: 1,
      ),
      ReportModel(
        id: '#CHI-2026-0838',
        type: ReportType.suspicious,
        location: 'Calle 11 con Cra 8',
        latitude: 4.8637,
        longitude: -74.0352,
        description: 'Grupo de personas rondando vehículos estacionados.',
        isAnonymous: true,
        status: ReportStatus.inProgress,
        createdAt: DateTime.now().subtract(const Duration(minutes: 45)),
        officerNote: 'En revisión por estación de Policía de Chía.',
        trustLevel: CitizenTrust.noRecord,
        coincidentReports: 0,
      ),
      ReportModel(
        id: '#CHI-2026-0847',
        type: ReportType.theft,
        location: 'Parque central',
        latitude: 4.8653,
        longitude: -74.0371,
        description: 'Persona con capucha arrebató celular cerca a la fuente. Huyó hacia la Carrera 8.',
        isAnonymous: true,
        status: ReportStatus.received,
        createdAt: DateTime.now().subtract(const Duration(minutes: 12)),
        trustLevel: CitizenTrust.reliable,
        coincidentReports: 2,
      ),
    ];

    final jsonList = mockReports.map((r) => r.toJson()).toList();
    prefs.setString(_allKey, jsonEncode(jsonList));
  }

  @override
  Future<List<ReportModel>> getUserReports() async {
    final jsonStr = prefs.getString(_key);
    if (jsonStr == null) return [];
    final list = jsonDecode(jsonStr) as List;
    return list.map((j) => ReportModel.fromJson(j as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<ReportModel>> getAllReports() async {
    final jsonStr = prefs.getString(_allKey);
    if (jsonStr == null) return [];
    final list = jsonDecode(jsonStr) as List;
    final reports = list.map((j) => ReportModel.fromJson(j as Map<String, dynamic>)).toList();
    reports.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return reports;
  }

  @override
  Future<ReportModel> saveReport(ReportModel report) async {
    // Save to user reports
    final userReports = await getUserReports();
    userReports.insert(0, report);
    await prefs.setString(_key, jsonEncode(userReports.map((r) => r.toJson()).toList()));

    // Save to all reports
    final allReports = await getAllReports();
    allReports.insert(0, report);
    await prefs.setString(_allKey, jsonEncode(allReports.map((r) => r.toJson()).toList()));

    return report;
  }

  @override
  Future<ReportModel> updateReport(ReportModel updated) async {
    // Update in all reports
    final allReports = await getAllReports();
    final idx = allReports.indexWhere((r) => r.id == updated.id);
    if (idx == -1) throw const CacheFailure('Reporte no encontrado');
    allReports[idx] = updated;
    await prefs.setString(_allKey, jsonEncode(allReports.map((r) => r.toJson()).toList()));

    // Update in user reports if present
    final userReports = await getUserReports();
    final uIdx = userReports.indexWhere((r) => r.id == updated.id);
    if (uIdx != -1) {
      userReports[uIdx] = updated;
      await prefs.setString(_key, jsonEncode(userReports.map((r) => r.toJson()).toList()));
    }

    return updated;
  }

  String generateId() {
    final num = (800 + (DateTime.now().millisecondsSinceEpoch % 200)).toString();
    return '#CHI-2026-0$num';
  }
}