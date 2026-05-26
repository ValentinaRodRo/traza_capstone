import '../../domain/entities/zone.dart';

class ZoneModel extends Zone {
  const ZoneModel({
    required super.zoneId,
    required super.name,
    required super.latitude,
    required super.longitude,
    required super.radius,
    required super.riskScore,
    required super.reportCount,
    required super.lastUpdated,
  });

  factory ZoneModel.fromJson(Map<String, dynamic> json) {
    return ZoneModel(
      zoneId: json['zone_id'] as String,
      name: json['name'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      radius: (json['radius'] as num).toDouble(),
      riskScore: (json['risk_score'] as num).toDouble(),
      reportCount: json['report_count'] as int,
      lastUpdated: DateTime.parse(json['last_updated'] as String),
    );
  }

  /// Parsea el payload completo del broadcast: { zones: [...], computed_at: ... }
  static List<ZoneModel> listFromBroadcast(Map<String, dynamic> json) {
    final list = json['zones'] as List<dynamic>;
    return list
        .map((z) => ZoneModel.fromJson(z as Map<String, dynamic>))
        .toList();
  }
}