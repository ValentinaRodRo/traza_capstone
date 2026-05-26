import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/report_sheet.dart';
import '../../../../core/widgets/shared_widgets.dart';
import '../../domain/entities/zone.dart';
import '../bloc/map_bloc.dart';

const _chiCenter = LatLng(4.8653, -74.0366);

// ✅ Dos estilos de mapa — dark y light
const _mapStyleDark = '''
[
  {"elementType":"geometry","stylers":[{"color":"#0E1117"}]},
  {"elementType":"labels.text.fill","stylers":[{"color":"#4B5263"}]},
  {"elementType":"labels.text.stroke","stylers":[{"color":"#0E1117"}]},
  {"featureType":"administrative","elementType":"geometry","stylers":[{"visibility":"off"}]},
  {"featureType":"poi","stylers":[{"visibility":"off"}]},
  {"featureType":"road","elementType":"geometry","stylers":[{"color":"#1E2538"}]},
  {"featureType":"road","elementType":"geometry.stroke","stylers":[{"color":"#161923"}]},
  {"featureType":"road","elementType":"labels","stylers":[{"visibility":"off"}]},
  {"featureType":"road.highway","elementType":"geometry","stylers":[{"color":"#252B3A"}]},
  {"featureType":"transit","stylers":[{"visibility":"off"}]},
  {"featureType":"water","elementType":"geometry","stylers":[{"color":"#141824"}]},
  {"featureType":"water","elementType":"labels.text","stylers":[{"visibility":"off"}]}
]
''';

const _mapStyleLight = '''
[
  {"elementType":"geometry","stylers":[{"color":"#F5F7FC"}]},
  {"elementType":"labels.text.fill","stylers":[{"color":"#9CA3AF"}]},
  {"elementType":"labels.text.stroke","stylers":[{"color":"#F5F7FC"}]},
  {"featureType":"administrative","elementType":"geometry","stylers":[{"visibility":"off"}]},
  {"featureType":"poi","stylers":[{"visibility":"off"}]},
  {"featureType":"road","elementType":"geometry","stylers":[{"color":"#E5E7EB"}]},
  {"featureType":"road","elementType":"geometry.stroke","stylers":[{"color":"#F3F4F6"}]},
  {"featureType":"road","elementType":"labels","stylers":[{"visibility":"off"}]},
  {"featureType":"road.highway","elementType":"geometry","stylers":[{"color":"#D1D5DB"}]},
  {"featureType":"transit","stylers":[{"visibility":"off"}]},
  {"featureType":"water","elementType":"geometry","stylers":[{"color":"#BFDBFE"}]},
  {"featureType":"water","elementType":"labels.text","stylers":[{"visibility":"off"}]}
]
''';

// ─────────────────────────────────────────────
//  Helpers
// ─────────────────────────────────────────────

Color _zoneColor(ZoneRiskLevel level) => switch (level) {
      ZoneRiskLevel.low      => const Color(0xFF1D9E75),
      ZoneRiskLevel.medium   => const Color(0xFF378ADD),
      ZoneRiskLevel.high     => const Color(0xFFEF9F27),
      ZoneRiskLevel.critical => const Color(0xFFE8793D),
    };

Color _zoneBg(ZoneRiskLevel level, BuildContext context) => switch (level) {
      ZoneRiskLevel.low      => TrazaThemeTokens.successSub(context),
      ZoneRiskLevel.medium   => TrazaThemeTokens.infoSub(context),
      ZoneRiskLevel.high     => TrazaThemeTokens.warningSub(context),
      ZoneRiskLevel.critical => TrazaThemeTokens.isDark(context)
          ? const Color(0xFF221508)
          : const Color(0xFFFFF3E0),
    };

String _riskLabel(ZoneRiskLevel level) => switch (level) {
      ZoneRiskLevel.low      => 'Tranquilo',
      ZoneRiskLevel.medium   => 'Actividad normal',
      ZoneRiskLevel.high     => 'Actividad elevada',
      ZoneRiskLevel.critical => 'Muy activo',
    };

String _contextDescription(ZoneRiskLevel level) => switch (level) {
      ZoneRiskLevel.low      => 'Zona tranquila en este momento. Presencia normal.',
      ZoneRiskLevel.medium   => 'Actividad habitual para esta hora del día.',
      ZoneRiskLevel.high     => 'Zona concurrida. Más movimiento de lo normal.',
      ZoneRiskLevel.critical => 'Zona muy activa ahora. Presencia policial informada.',
    };

String _peakHourHint(ZoneRiskLevel level) => switch (level) {
      ZoneRiskLevel.low      => 'Históricamente tranquilo a esta hora.',
      ZoneRiskLevel.medium   => 'Pico histórico: 6pm – 9pm.',
      ZoneRiskLevel.high     => 'Pico histórico: 6pm – 9pm. Hora actual coincide.',
      ZoneRiskLevel.critical => 'Actividad superior al promedio histórico.',
    };

Circle _zoneToCircle(Zone zone) {
  final color = _zoneColor(zone.riskLevel);
  return Circle(
    circleId: CircleId(zone.zoneId),
    center: LatLng(zone.latitude, zone.longitude),
    radius: zone.radius,
    fillColor: color.withOpacity(0.15),
    strokeColor: color.withOpacity(0.6),
    strokeWidth: 1,
  );
}

Future<Marker> _zoneToMarker(Zone zone, BitmapDescriptor icon) async {
  return Marker(
    markerId: MarkerId(zone.zoneId),
    position: LatLng(zone.latitude, zone.longitude),
    icon: icon,
    infoWindow: InfoWindow(
      title: zone.name,
      snippet: '${zone.reportCount} reportes · ${_riskLabel(zone.riskLevel)}',
    ),
  );
}

Future<BitmapDescriptor> _buildPin(Color color) async {
  const size = 28.0;
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  canvas.drawCircle(
    const Offset(size / 2, size / 2 + 1),
    size / 2 - 2,
    Paint()..color = Colors.black.withOpacity(0.25),
  );
  canvas.drawCircle(
    const Offset(size / 2, size / 2),
    size / 2 - 2,
    Paint()..color = color,
  );
  canvas.drawCircle(
    const Offset(size / 2, size / 2),
    size / 6,
    Paint()..color = Colors.white,
  );
  final picture = recorder.endRecording();
  final image = await picture.toImage(size.toInt(), size.toInt());
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  return BitmapDescriptor.fromBytes(bytes!.buffer.asUint8List());
}

// ═══════════════════════════════════════════════════════════════════════════════
//  PAGE
// ═══════════════════════════════════════════════════════════════════════════════

class CitizenMapPage extends StatelessWidget {
  const CitizenMapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<MapBloc>()..add(MapStarted()),
      child: const _CitizenMapView(),
    );
  }
}

class _CitizenMapView extends StatefulWidget {
  const _CitizenMapView();

  @override
  State<_CitizenMapView> createState() => _CitizenMapViewState();
}

class _CitizenMapViewState extends State<_CitizenMapView> {
  final Completer<GoogleMapController> _mapController = Completer();

  Set<Circle> _circles = {};
  Set<Marker> _markers = {};

  final Map<ZoneRiskLevel, BitmapDescriptor> _pinCache = {};

  Future<BitmapDescriptor> _getPin(ZoneRiskLevel level) async {
    if (_pinCache.containsKey(level)) return _pinCache[level]!;
    final pin = await _buildPin(_zoneColor(level));
    _pinCache[level] = pin;
    return pin;
  }

  Future<void> _updateMapOverlays(List<Zone> zones) async {
    final circles = <Circle>{};
    final markers = <Marker>{};
    for (final zone in zones) {
      circles.add(_zoneToCircle(zone));
      final pin = await _getPin(zone.riskLevel);
      markers.add(await _zoneToMarker(zone, pin));
    }
    if (mounted) {
      setState(() {
        _circles = circles;
        _markers = markers;
      });
    }
  }

  // ✅ Actualiza el estilo del mapa cuando cambia el tema
  Future<void> _applyMapStyle(bool isDark) async {
    if (_mapController.isCompleted) {
      final controller = await _mapController.future;
      controller.setMapStyle(isDark ? _mapStyleDark : _mapStyleLight);
    }
  }

  void _openFullMap() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _FullMapPage(circles: _circles, markers: _markers),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Reaplica el estilo del mapa si el tema cambia en caliente
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _applyMapStyle(TrazaThemeTokens.isDark(context));
    });

    return BlocListener<MapBloc, MapState>(
      listener: (context, state) {
        if (state is MapLoaded) _updateMapOverlays(state.zones);
      },
      child: TrazaScaffold(
        appBar: TrazaAppBar(
          title: 'Traza',
          subtitle: 'Chía, Cundinamarca',
          isHome: true,
          actions: [
            _NotificationButton(),
            const SizedBox(width: 16),
          ],
        ),
        fab: _ReportFAB(),
        body: SafeArea(
          top: false,
          child: Column(
            children: [
              _CompactMap(
                circles: _circles,
                markers: _markers,
                mapController: _mapController,
                onExpand: _openFullMap,
              ),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _MapLegend(),
                      const SizedBox(height: 20),
                      BlocBuilder<MapBloc, MapState>(
                        builder: (context, state) {
                          if (state is MapLoaded && state.zones.isNotEmpty) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TrazaSectionHeader(
                                  'Tu zona ahora',
                                  action: null,
                                  onAction: null,
                                ),
                                const SizedBox(height: 10),
                                _ZoneContextCard(zones: state.zones),
                                const SizedBox(height: 20),
                              ],
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                      TrazaSectionHeader(
                        'Zonas cercanas',
                        action: 'Ver mapa',
                        onAction: _openFullMap,
                      ),
                      const SizedBox(height: 10),
                      BlocBuilder<MapBloc, MapState>(
                        builder: (context, state) {
                          if (state is MapLoading) {
                            return const _ZoneListSkeleton();
                          }
                          if (state is MapError) {
                            return TrazaErrorBanner(state.message);
                          }
                          if (state is MapLoaded && state.zones.isEmpty) {
                            return const TrazaEmptyState(
                              icon: Icons.map_outlined,
                              title: 'Sin zonas activas',
                              message: 'No hay actividad reciente en Chía.',
                            );
                          }
                          if (state is MapLoaded) {
                            return _ZoneList(zones: state.zones);
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  ZONE CONTEXT CARD
// ─────────────────────────────────────────────

class _ZoneContextCard extends StatelessWidget {
  final List<Zone> zones;
  const _ZoneContextCard({required this.zones});

  Zone? get _topZone => zones
      .where((z) => z.zoneId != 'desconocida')
      .fold<Zone?>(
        null,
        (prev, z) => prev == null || z.riskScore > prev.riskScore ? z : prev,
      );

  @override
  Widget build(BuildContext context) {
    final top = _topZone;
    if (top == null) return const SizedBox.shrink();

    final tt    = Theme.of(context);
    final color = _zoneColor(top.riskLevel);
    final bg    = _zoneBg(top.riskLevel, context);
    final label = _riskLabel(top.riskLevel);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: TrazaRadius.card,
        border: Border.all(color: color.withOpacity(0.3), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(top.name, style: tt.textTheme.titleSmall),
                    const SizedBox(height: 4),
                    Text(
                      _contextDescription(top.riskLevel),
                      style: tt.textTheme.bodySmall?.copyWith(
                        color: TrazaThemeTokens.textSecondary(context),
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  label,
                  style: TrazaTextStyles.badge.copyWith(color: color),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: top.riskScore.clamp(0.0, 1.0),
              minHeight: 3,
              backgroundColor: TrazaThemeTokens.border(context),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(
                Icons.access_time_rounded,
                size: 11,
                color: TrazaThemeTokens.textTertiary(context),
              ),
              const SizedBox(width: 4),
              Text(_peakHourHint(top.riskLevel), style: tt.textTheme.bodySmall),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  ZONE LIST
// ─────────────────────────────────────────────

class _ZoneList extends StatelessWidget {
  final List<Zone> zones;
  const _ZoneList({required this.zones});

  @override
  Widget build(BuildContext context) {
    final visible = zones
        .where((z) => z.zoneId != 'desconocida')
        .take(5)
        .toList();

    if (visible.isEmpty) {
      return const TrazaEmptyState(
        icon: Icons.map_outlined,
        title: 'Sin zonas activas',
        message: 'No hay actividad reciente en Chía.',
      );
    }

    return Column(
      children: visible
          .map((zone) => TrazaZoneCard(
                name: zone.name,
                riskLevel: _riskLabel(zone.riskLevel),
                reports: zone.reportCount,
                timeAgo: _formatTime(zone.lastUpdated),
                accentColor: _zoneColor(zone.riskLevel),
                bgColor: _zoneBg(zone.riskLevel, context),
              ))
          .toList(),
    );
  }

  String _formatTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return 'hace ${diff.inMinutes}min';
    if (diff.inHours < 24)   return 'hace ${diff.inHours}h';
    return 'hace ${diff.inDays}d';
  }
}

// ─────────────────────────────────────────────
//  SKELETON
// ─────────────────────────────────────────────

class _ZoneListSkeleton extends StatelessWidget {
  const _ZoneListSkeleton();

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context);
    return Column(
      children: List.generate(
        3,
        (_) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: tt.colorScheme.surface,
            borderRadius: TrazaRadius.card,
            border: Border.all(
              color: tt.dividerTheme.color ?? TrazaColors.border,
              width: 0.5,
            ),
          ),
          child: const Row(
            children: [
              TrazaLoadingSkeleton(width: 38, height: 38, borderRadius: 11),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TrazaLoadingSkeleton(height: 13),
                    SizedBox(height: 6),
                    TrazaLoadingSkeleton(height: 10, width: 100),
                  ],
                ),
              ),
              SizedBox(width: 8),
              TrazaLoadingSkeleton(width: 56, height: 22, borderRadius: 100),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  COMPACT MAP
// ─────────────────────────────────────────────

class _CompactMap extends StatelessWidget {
  final Set<Circle> circles;
  final Set<Marker> markers;
  final Completer<GoogleMapController> mapController;
  final VoidCallback onExpand;

  const _CompactMap({
    required this.circles,
    required this.markers,
    required this.mapController,
    required this.onExpand,
  });

  @override
  Widget build(BuildContext context) {
    final tt          = Theme.of(context);
    final isDark      = TrazaThemeTokens.isDark(context);
    final overlayBg   = tt.scaffoldBackgroundColor;
    final mapStyle    = isDark ? _mapStyleDark : _mapStyleLight;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: ClipRRect(
        borderRadius: TrazaRadius.map,
        child: SizedBox(
          height: 210,
          child: Stack(
            fit: StackFit.expand,
            children: [
              GoogleMap(
                initialCameraPosition: const CameraPosition(
                  target: _chiCenter,
                  zoom: 14.5,
                ),
                onMapCreated: (controller) {
                  // ✅ Aplica el estilo correcto al crear
                  controller.setMapStyle(mapStyle);
                  if (!mapController.isCompleted) {
                    mapController.complete(controller);
                  }
                },
                circles: circles,
                markers: markers,
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                compassEnabled: false,
                mapToolbarEnabled: false,
                rotateGesturesEnabled: false,
                scrollGesturesEnabled: false,
                tiltGesturesEnabled: false,
                zoomGesturesEnabled: false,
              ),
              Positioned(
                bottom: 0, left: 0, right: 0,
                child: Container(
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        overlayBg.withOpacity(0.6),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 10, left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                  decoration: BoxDecoration(
                    color: overlayBg.withOpacity(0.82),
                    borderRadius: BorderRadius.circular(TrazaRadius.sm),
                    border: Border.all(
                      color: TrazaThemeTokens.border(context).withOpacity(0.5),
                      width: 0.5,
                    ),
                  ),
                  child: BlocBuilder<MapBloc, MapState>(
                    builder: (context, state) {
                      final label = state is MapLoaded
                          ? 'Actualizado hace ${_minsAgo(state.lastUpdated)}'
                          : 'Predicción en vivo';
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 5,
                            height: 5,
                            decoration: BoxDecoration(
                              color: state is MapLoaded
                                  ? TrazaThemeTokens.success(context)
                                  : TrazaThemeTokens.textTertiary(context),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            label,
                            style: tt.textTheme.labelSmall?.copyWith(
                              color: TrazaThemeTokens.textSecondary(context),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
              Positioned(
                top: 10, right: 10,
                child: GestureDetector(
                  onTap: onExpand,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: overlayBg.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(TrazaRadius.sm),
                      border: Border.all(
                        color: TrazaThemeTokens.border(context).withOpacity(0.5),
                        width: 0.5,
                      ),
                    ),
                    child: Icon(
                      Icons.open_in_full_rounded,
                      size: 15,
                      color: TrazaThemeTokens.textSecondary(context),
                    ),
                  ),
                ),
              ),
              BlocBuilder<MapBloc, MapState>(
                builder: (context, state) {
                  if (state is! MapLoading) return const SizedBox.shrink();
                  return Positioned(
                    top: 10, left: 10,
                    child: Container(
                      width: 28,
                      height: 28,
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: overlayBg.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(TrazaRadius.sm),
                      ),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: TrazaThemeTokens.brand(context),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _minsAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return '${diff.inSeconds}s';
    return '${diff.inMinutes}min';
  }
}

// ─────────────────────────────────────────────
//  FULL MAP PAGE
// ─────────────────────────────────────────────

class _FullMapPage extends StatelessWidget {
  final Set<Circle> circles;
  final Set<Marker> markers;

  const _FullMapPage({required this.circles, required this.markers});

  @override
  Widget build(BuildContext context) {
    final tt        = Theme.of(context);
    final isDark    = TrazaThemeTokens.isDark(context);
    final overlayBg = tt.scaffoldBackgroundColor;
    final mapStyle  = isDark ? _mapStyleDark : _mapStyleLight;

    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: _chiCenter,
              zoom: 14.5,
            ),
            onMapCreated: (controller) => controller.setMapStyle(mapStyle),
            circles: circles,
            markers: markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            compassEnabled: false,
            mapToolbarEnabled: false,
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 16,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: overlayBg.withOpacity(0.88),
                  borderRadius: BorderRadius.circular(TrazaRadius.sm),
                  border: Border.all(
                    color: TrazaThemeTokens.border(context).withOpacity(0.5),
                    width: 0.5,
                  ),
                ),
                child: Icon(
                  Icons.close_fullscreen_rounded,
                  size: 16,
                  color: TrazaThemeTokens.textSecondary(context),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 16,
            left: 16, right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: tt.colorScheme.surface,
                borderRadius: TrazaRadius.card,
                border: Border.all(
                  color: tt.dividerTheme.color ?? TrazaColors.border,
                  width: 0.5,
                ),
              ),
              child: const _MapLegend(),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  MAP LEGEND
// ─────────────────────────────────────────────

class _MapLegend extends StatelessWidget {
  const _MapLegend();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _LegendDot(color: _zoneColor(ZoneRiskLevel.low),    label: 'Bajo'),
        const SizedBox(width: 10),
        _LegendDot(color: _zoneColor(ZoneRiskLevel.medium), label: 'Medio'),
        const SizedBox(width: 10),
        _LegendDot(color: _zoneColor(ZoneRiskLevel.high),   label: 'Alto'),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            height: 3,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              gradient: LinearGradient(
                colors: [
                  _zoneColor(ZoneRiskLevel.low),
                  _zoneColor(ZoneRiskLevel.medium),
                  _zoneColor(ZoneRiskLevel.high),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text('Actividad', style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }
}

// ─────────────────────────────────────────────
//  NOTIFICATION BUTTON
// ─────────────────────────────────────────────

class _NotificationButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
            color: tt.cardTheme.color,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: tt.dividerTheme.color ?? TrazaColors.border,
              width: 0.5,
            ),
          ),
          child: Icon(
            Icons.notifications_outlined,
            color: TrazaThemeTokens.textSecondary(context),
            size: 18,
          ),
        ),
        Positioned(
          top: 8, right: 8,
          child: Container(
            width: 7, height: 7,
            decoration: BoxDecoration(
              color: tt.colorScheme.error,
              shape: BoxShape.circle,
              border: Border.all(
                color: tt.scaffoldBackgroundColor,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
//  REPORT FAB
// ─────────────────────────────────────────────

class _ReportFAB extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showReportSheet(context),
      child: Container(
        width: 54, height: 54,
        decoration: BoxDecoration(
          color: TrazaThemeTokens.brand(context),
          borderRadius: BorderRadius.circular(18),
          boxShadow: TrazaShadows.brand,
        ),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 26),
      ),
    );
  }
}