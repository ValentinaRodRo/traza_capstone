import 'package:equatable/equatable.dart';

class Zone extends Equatable {
  final String zoneId;
  final String name;
  final double latitude;
  final double longitude;
  final double radius;
  final double riskScore;   // 0.0 – 1.0
  final int reportCount;
  final DateTime lastUpdated;

  const Zone({
    required this.zoneId,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.radius,
    required this.riskScore,
    required this.reportCount,
    required this.lastUpdated,
  });

  /// Nivel de riesgo derivado del risk_score para UI
  ZoneRiskLevel get riskLevel {
    if (riskScore >= 0.75) return ZoneRiskLevel.critical;
    if (riskScore >= 0.50) return ZoneRiskLevel.high;
    if (riskScore >= 0.25) return ZoneRiskLevel.medium;
    return ZoneRiskLevel.low;
  }

  @override
  List<Object?> get props => [zoneId, riskScore, reportCount, lastUpdated];
}

enum ZoneRiskLevel { low, medium, high, critical }