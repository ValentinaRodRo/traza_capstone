import '../../domain/entities/report.dart';

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

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
      id: json['id'] as String,
      type: ReportType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ReportType.other,
      ),
      location: json['location'] as String,
      latitude: json['latitude'] as double?,
      longitude: json['longitude'] as double?,
      description: json['description'] as String,
      isAnonymous: json['isAnonymous'] as bool? ?? true,
      status: ReportStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ReportStatus.pending,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      officerNote: json['officerNote'] as String?,
      trustLevel: json['trustLevel'] != null
          ? CitizenTrust.values.firstWhere(
              (e) => e.name == json['trustLevel'],
              orElse: () => CitizenTrust.noRecord,
            )
          : null,
      coincidentReports: json['coincidentReports'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
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
  }

  factory ReportModel.fromEntity(Report report) {
    return ReportModel(
      id: report.id,
      type: report.type,
      location: report.location,
      latitude: report.latitude,
      longitude: report.longitude,
      description: report.description,
      isAnonymous: report.isAnonymous,
      status: report.status,
      createdAt: report.createdAt,
      officerNote: report.officerNote,
      trustLevel: report.trustLevel,
      coincidentReports: report.coincidentReports,
    );
  }
}