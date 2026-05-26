import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/zone.dart';
import '../../domain/repositories/zone_repository.dart';
import '../datasources/zone_datasource.dart';

class ZoneRepositoryImpl implements ZoneRepository {
  final ZoneDataSource dataSource;

  ZoneRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, List<Zone>>> getActiveZones() async {
    try {
      final zones = await dataSource.getActiveZones();
      return Right(zones);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Stream<Either<Failure, List<Zone>>> watchZones() {
    return dataSource.watchZones().map<Either<Failure, List<Zone>>>(
          (zones) => Right(zones),
        ).handleError(
          (error) => Left(ServerFailure(error.toString())),
        );
  }

  @override
  void dispose() => dataSource.dispose();
}