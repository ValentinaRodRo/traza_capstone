import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/zone.dart';
import '../../domain/repositories/zone_repository.dart';

// ── Events ────────────────────────────────────────────────────────────────────

abstract class MapEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Arranca el BLoC: hace el fetch REST inicial y luego se suscribe al WebSocket
class MapStarted extends MapEvent {}

/// El WebSocket recibió una snapshot nueva del backend
class _ZonesUpdated extends MapEvent {
  final List<Zone> zones;
  _ZonesUpdated(this.zones);
  @override
  List<Object?> get props => [zones];
}

/// El WebSocket o el fetch inicial fallaron
class _MapFailed extends MapEvent {
  final String message;
  _MapFailed(this.message);
  @override
  List<Object?> get props => [message];
}

// ── States ────────────────────────────────────────────────────────────────────

abstract class MapState extends Equatable {
  @override
  List<Object?> get props => [];
}

class MapInitial extends MapState {}

class MapLoading extends MapState {}

class MapLoaded extends MapState {
  final List<Zone> zones;
  final DateTime lastUpdated;

  MapLoaded({required this.zones, required this.lastUpdated});

  @override
  List<Object?> get props => [zones, lastUpdated];
}

class MapError extends MapState {
  final String message;
  MapError(this.message);
  @override
  List<Object?> get props => [message];
}

// ── BLoC ──────────────────────────────────────────────────────────────────────

class MapBloc extends Bloc<MapEvent, MapState> {
  final ZoneRepository zoneRepository;
  StreamSubscription<dynamic>? _zoneSubscription;

  MapBloc({required this.zoneRepository}) : super(MapInitial()) {
    on<MapStarted>(_onMapStarted);
    on<_ZonesUpdated>(_onZonesUpdated);
    on<_MapFailed>(_onMapFailed);
  }

  Future<void> _onMapStarted(MapStarted event, Emitter<MapState> emit) async {
    emit(MapLoading());

    // 1. Fetch REST para tener datos inmediatos
    final result = await zoneRepository.getActiveZones();
    result.fold(
      (failure) => emit(MapError('No se pudieron cargar las zonas')),
      (zones) => emit(MapLoaded(zones: zones, lastUpdated: DateTime.now())),
    );

    // 2. Suscripción al WebSocket — actualiza el estado con cada broadcast
    await _zoneSubscription?.cancel();
    _zoneSubscription = zoneRepository.watchZones().listen(
      (either) => either.fold(
        (failure) => add(_MapFailed('Conexión perdida con el servidor')),
        (zones) => add(_ZonesUpdated(zones)),
      ),
    );
  }

  void _onZonesUpdated(_ZonesUpdated event, Emitter<MapState> emit) {
    emit(MapLoaded(zones: event.zones, lastUpdated: DateTime.now()));
  }

  void _onMapFailed(_MapFailed event, Emitter<MapState> emit) {
    // Si ya teníamos datos, los mantenemos y no mostramos error pantalla completa
    if (state is! MapLoaded) {
      emit(MapError(event.message));
    }
  }

  @override
  Future<void> close() {
    _zoneSubscription?.cancel();
    zoneRepository.dispose();
    return super.close();
  }
}