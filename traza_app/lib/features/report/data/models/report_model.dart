import '../../domain/entities/report.dart';

// Mapeo entre los valores del backend y el enum local
extension ReportTypeX on ReportType {
  static ReportType fromBackend(String value) => switch (value) {
        'theft' => ReportType.theft,
        'suspicious' => ReportType.suspicious,
        'vandalism' => ReportType.vandalism,
        _ => ReportType.other,
      };

  String toBackend() => switch (this) {
        ReportType.theft => 'theft',
        ReportType.suspicious => 'suspicious',
        ReportType.vandalism => 'vandalism',
        ReportType.other => 'other',
      };
}

extension ReportStatusX on ReportStatus {
  static ReportStatus fromBackend(String value) => switch (value) {
      'RECIBIDO'    => ReportStatus.received,
      'EN_REVISION' => ReportStatus.inProgress,
      'ATENDIDO'    => ReportStatus.inProgress,
      'CERRADO'     => ReportStatus.resolved,
      _             => ReportStatus.pending,
    };
}

class ReportModel extends Report {
  const ReportModel({
    required super.id,
    required super.type,
    required super.location,
    super.latitude,
    super.longitude,
    required super.description,
    required super.isAnonymous,
    required super.status,
    required super.createdAt,
    super.officerNote,
    super.trustLevel,
    super.coincidentReports,
  });

  // ── desde SharedPreferences (formato local) ───────────────────────────────
  factory ReportModel.fromJson(Map<String, dynamic> j) => ReportModel(
        id: j['id'] as String,
        type: ReportType.values.byName(j['type'] as String),
        location: j['location'] as String? ?? '',
        latitude: (j['latitude'] as num?)?.toDouble(),
        longitude: (j['longitude'] as num?)?.toDouble(),
        description: j['description'] as String,
        isAnonymous: j['isAnonymous'] as bool? ?? true,
        status: ReportStatus.values.byName(j['status'] as String),
        createdAt: DateTime.parse(j['createdAt'] as String),
        officerNote: j['officerNote'] as String?,
        trustLevel: j['trustLevel'] != null
            ? CitizenTrust.values.byName(j['trustLevel'] as String)
            : null,
        coincidentReports: j['coincidentReports'] as int? ?? 0,
      );

  // ── desde la API del backend (tracking_code, incident_type, etc.) ─────────
  factory ReportModel.fromBackendJson(
    Map<String, dynamic> j, {
    String? locationOverride,
  }) =>
      ReportModel(
        id: j['tracking_code'] as String,
        type: ReportTypeX.fromBackend(j['incident_type'] as String),
        location: locationOverride ??
            _locationLabel(
              (j['latitude'] as num?)?.toDouble(),
              (j['longitude'] as num?)?.toDouble(),
            ),
        latitude: (j['latitude'] as num?)?.toDouble(),
        longitude: (j['longitude'] as num?)?.toDouble(),
        description: j['description'] as String,
        isAnonymous: j['anonymous'] as bool? ?? true,
        status: ReportStatusX.fromBackend(j['status'] as String? ?? ''),
        createdAt: j['created_at'] != null
            ? DateTime.parse(j['created_at'] as String).toLocal()
            : DateTime.now(),
        officerNote: j['officer_note'] as String?,  // ← antes era null hardcoded
        trustLevel: null,
        coincidentReports: 0,
      );

  // ── hacia SharedPreferences ───────────────────────────────────────────────
  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'location': location,
        'latitude': latitude,
        'longitude': longitude,
        'description': description,
        'isAnonymous': isAnonymous,
        'status': status.name,
        'createdAt': createdAt.toIso8601String(),
        'officerNote': officerNote,
        'trustLevel': trustLevel?.name,
        'coincidentReports': coincidentReports,
      };

  static ReportModel fromEntity(Report r) => ReportModel(
        id: r.id,
        type: r.type,
        location: r.location,
        latitude: r.latitude,
        longitude: r.longitude,
        description: r.description,
        isAnonymous: r.isAnonymous,
        status: r.status,
        createdAt: r.createdAt,
        officerNote: r.officerNote,
        trustLevel: r.trustLevel,
        coincidentReports: r.coincidentReports,
      );

  static String _locationLabel(double? lat, double? lng) {
    if (lat == null || lng == null) return 'Ubicación desconocida';
    return '${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}';
  }
}