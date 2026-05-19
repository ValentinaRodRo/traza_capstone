import 'package:equatable/equatable.dart';

enum ReportType {
  theft('Hurto'),
  suspicious('Comportamiento sospechoso'),
  vandalism('Vandalismo'),
  other('Otro');

  const ReportType(this.label);
  final String label;
}

enum ReportStatus {
  pending('Sin atender'),
  received('Recibido'),
  inProgress('En proceso'),
  resolved('Resuelto');

  const ReportStatus(this.label);
  final String label;
}

enum CitizenTrust {
  reliable('Ciudadano confiable'),
  noRecord('Sin registro'),
  firstTime('Primera vez');

  const CitizenTrust(this.label);
  final String label;
}

class Report extends Equatable {
  final String id;
  final ReportType type;
  final String location;
  final double? latitude;
  final double? longitude;
  final String description;
  final bool isAnonymous;
  final ReportStatus status;
  final DateTime createdAt;
  final String? officerNote;
  final CitizenTrust? trustLevel;
  final int coincidentReports;

  const Report({
    required this.id,
    required this.type,
    required this.location,
    this.latitude,
    this.longitude,
    required this.description,
    required this.isAnonymous,
    required this.status,
    required this.createdAt,
    this.officerNote,
    this.trustLevel,
    this.coincidentReports = 0,
  });

  Report copyWith({
    String? id,
    ReportType? type,
    String? location,
    double? latitude,
    double? longitude,
    String? description,
    bool? isAnonymous,
    ReportStatus? status,
    DateTime? createdAt,
    String? officerNote,
    CitizenTrust? trustLevel,
    int? coincidentReports,
  }) {
    return Report(
      id: id ?? this.id,
      type: type ?? this.type,
      location: location ?? this.location,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      description: description ?? this.description,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      officerNote: officerNote ?? this.officerNote,
      trustLevel: trustLevel ?? this.trustLevel,
      coincidentReports: coincidentReports ?? this.coincidentReports,
    );
  }

  @override
  List<Object?> get props => [
        id, type, location, latitude, longitude, description,
        isAnonymous, status, createdAt, officerNote, trustLevel, coincidentReports,
      ];
}