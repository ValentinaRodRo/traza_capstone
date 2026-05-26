import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/zone.dart';

abstract class ZoneRepository {
  /// Fetch inicial por REST — llama GET /zones/active
  Future<Either<Failure, List<Zone>>> getActiveZones();

  /// Stream de actualizaciones por WebSocket — emite cada broadcast del backend
  Stream<Either<Failure, List<Zone>>> watchZones();

  /// Cierra la conexión WebSocket limpiamente
  void dispose();
}