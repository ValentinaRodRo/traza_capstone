import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/shared_widgets.dart';

// ═══════════════════════════════════════════════════════════════════════════════
//  CITIZEN MAP PAGE
// ═══════════════════════════════════════════════════════════════════════════════

// Coordenadas centradas en Chía, Cundinamarca
const _chiCenter = LatLng(4.8653, -74.0366);

// Estilo oscuro para Google Maps (JSON minimalista oscuro)
const _mapStyle = '''
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

class CitizenMapPage extends StatefulWidget {
  const CitizenMapPage({super.key});

  @override
  State<CitizenMapPage> createState() => _CitizenMapPageState();
}

class _CitizenMapPageState extends State<CitizenMapPage> {
  final Completer<GoogleMapController> _mapController = Completer();

  // Marcadores de zonas de riesgo
  final Set<Circle> _circles = {
    // Parque Central — crítico
    Circle(
      circleId: const CircleId('parque_central'),
      center: const LatLng(4.8620, -74.0340),
      radius: 280,
      fillColor: Color(TrazaColors.danger.value).withOpacity(0.18),
      strokeColor: TrazaColors.danger,
      strokeWidth: 1,
    ),
    // Zona Comercial — alto
    Circle(
      circleId: const CircleId('zona_comercial'),
      center: const LatLng(4.8670, -74.0390),
      radius: 200,
      fillColor: Color(TrazaColors.warning.value).withOpacity(0.18),
      strokeColor: TrazaColors.warning,
      strokeWidth: 1,
    ),
    // La Capilla — bajo
    Circle(
      circleId: const CircleId('la_capilla'),
      center: const LatLng(4.8700, -74.0310),
      radius: 150,
      fillColor: Color(TrazaColors.success.value).withOpacity(0.18),
      strokeColor: TrazaColors.success,
      strokeWidth: 1,
    ),
  };

  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _buildMarkers();
  }

  Future<void> _buildMarkers() async {
    // Marcadores minimalistas como BitmapDescriptor de color sólido
    final danger  = await _coloredPin(TrazaColors.danger);
    final warning = await _coloredPin(TrazaColors.warning);
    final success = await _coloredPin(TrazaColors.success);

    if (!mounted) return;
    setState(() {
      _markers.addAll([
        Marker(
          markerId: const MarkerId('parque_central'),
          position: const LatLng(4.8620, -74.0340),
          icon: danger,
          infoWindow: const InfoWindow(title: 'Parque Central', snippet: 'Riesgo crítico · 23 reportes'),
        ),
        Marker(
          markerId: const MarkerId('zona_comercial'),
          position: const LatLng(4.8670, -74.0390),
          icon: warning,
          infoWindow: const InfoWindow(title: 'Zona Comercial', snippet: 'Riesgo alto · 11 reportes'),
        ),
        Marker(
          markerId: const MarkerId('la_capilla'),
          position: const LatLng(4.8700, -74.0310),
          icon: success,
          infoWindow: const InfoWindow(title: 'La Capilla', snippet: 'Riesgo bajo · 4 reportes'),
        ),
      ]);
    });
  }

  Future<BitmapDescriptor> _coloredPin(Color color) async {
    // Dibuja un pin circular personalizado con Canvas
    const size = 28.0;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final paint = Paint()..color = color;
    // Sombra sutil
    canvas.drawCircle(
      const Offset(size / 2, size / 2 + 1),
      size / 2 - 2,
      Paint()..color = Colors.black.withOpacity(0.25),
    );
    // Relleno principal
    canvas.drawCircle(const Offset(size / 2, size / 2), size / 2 - 2, paint);
    // Centro blanco
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

  void _openFullMap() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _FullMapPage(
          circles: _circles,
          markers: _markers,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TrazaScaffold(
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
            // ── Mapa compacto ────────────────────────────────────────────
            _CompactMap(
              circles: _circles,
              markers: _markers,
              mapController: _mapController,
              onExpand: _openFullMap,
            ),

            // ── Contenido scrollable ─────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _MapLegend(),
                    const SizedBox(height: 20),
                    TrazaSectionHeader(
                      'Resumen del mes',
                      action: 'Ver todo',
                      onAction: () {},
                    ),
                    const SizedBox(height: 10),
                    const _StatsGrid(),
                    const SizedBox(height: 20),
                    TrazaSectionHeader(
                      'Zonas activas',
                      action: 'Ver todas',
                      onAction: _openFullMap,
                    ),
                    const SizedBox(height: 10),
                    TrazaZoneCard(
                      name: 'Parque Central',
                      riskLevel: 'CRÍTICO',
                      reports: 23,
                      timeAgo: 'hace 2h',
                      accentColor: TrazaColors.danger,
                      bgColor: TrazaColors.dangerSub,
                    ),
                    TrazaZoneCard(
                      name: 'Zona Comercial',
                      riskLevel: 'ALTO',
                      reports: 11,
                      timeAgo: 'hace 5h',
                      accentColor: TrazaColors.warning,
                      bgColor: TrazaColors.warningSub,
                    ),
                    TrazaZoneCard(
                      name: 'La Capilla',
                      riskLevel: 'BAJO',
                      reports: 4,
                      timeAgo: 'hace 1d',
                      accentColor: TrazaColors.success,
                      bgColor: TrazaColors.successSub,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  MAPA COMPACTO
// ─────────────────────────────────────────────

class _CompactMap extends StatefulWidget {
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
  State<_CompactMap> createState() => _CompactMapState();
}

class _CompactMapState extends State<_CompactMap> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: ClipRRect(
        borderRadius: TrazaRadius.map,
        child: SizedBox(
          height: 210,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // ── Google Map ───────────────────────────────────────────────
              GoogleMap(
                initialCameraPosition: const CameraPosition(
                  target: _chiCenter,
                  zoom: 14.5,
                ),
                onMapCreated: (controller) {
                  controller.setMapStyle(_mapStyle);
                  if (!widget.mapController.isCompleted) {
                    widget.mapController.complete(controller);
                  }
                },
                circles: widget.circles,
                markers: widget.markers,
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                compassEnabled: false,
                mapToolbarEnabled: false,
                rotateGesturesEnabled: false,
                scrollGesturesEnabled: false,
                tiltGesturesEnabled: false,
                zoomGesturesEnabled: false,
                liteModeEnabled: false,
              ),

              // ── Scrim inferior ───────────────────────────────────────────
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
                        TrazaColors.bg.withOpacity(0.6),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Label inferior izquierdo ─────────────────────────────────
              Positioned(
                bottom: 10, left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                  decoration: BoxDecoration(
                    color: TrazaColors.bg.withOpacity(0.82),
                    borderRadius: BorderRadius.circular(TrazaRadius.sm),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.07),
                      width: 0.5,
                    ),
                  ),
                  child: Text(
                    'Zonas de riesgo · últimos 30 días',
                    style: TrazaTextStyles.labelSmall.copyWith(
                      color: TrazaColors.textSecondary,
                    ),
                  ),
                ),
              ),

              // ── Botón expandir ───────────────────────────────────────────
              Positioned(
                top: 10, right: 10,
                child: GestureDetector(
                  onTap: widget.onExpand,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: TrazaColors.bg.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(TrazaRadius.sm),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.07),
                        width: 0.5,
                      ),
                    ),
                    child: const Icon(
                      Icons.open_in_full_rounded,
                      size: 15,
                      color: TrazaColors.textSecondary,
                    ),
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
//  MAPA PANTALLA COMPLETA
// ─────────────────────────────────────────────

class _FullMapPage extends StatefulWidget {
  final Set<Circle> circles;
  final Set<Marker> markers;

  const _FullMapPage({
    required this.circles,
    required this.markers,
  });

  @override
  State<_FullMapPage> createState() => _FullMapPageState();
}

class _FullMapPageState extends State<_FullMapPage> {
  GoogleMapController? _controller;

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TrazaColors.bg,
      body: Stack(
        children: [
          // ── Mapa full ────────────────────────────────────────────────────
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: _chiCenter,
              zoom: 14.5,
            ),
            onMapCreated: (controller) {
              controller.setMapStyle(_mapStyle);
              _controller = controller;
            },
            circles: widget.circles,
            markers: widget.markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            compassEnabled: false,
            mapToolbarEnabled: false,
          ),

          // ── Botón cerrar ─────────────────────────────────────────────────
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 16,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: TrazaColors.bg.withOpacity(0.88),
                  borderRadius: BorderRadius.circular(TrazaRadius.sm),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.08),
                    width: 0.5,
                  ),
                ),
                child: const Icon(
                  Icons.close_fullscreen_rounded,
                  size: 16,
                  color: TrazaColors.textSecondary,
                ),
              ),
            ),
          ),

          // ── Leyenda flotante ─────────────────────────────────────────────
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 16,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: TrazaColors.bgSurface,
                borderRadius: TrazaRadius.card,
                border: Border.all(color: TrazaColors.border, width: 0.5),
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
//  NOTIFICATION BUTTON
// ─────────────────────────────────────────────

class _NotificationButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: TrazaColors.bgCard,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: TrazaColors.border, width: 0.5),
          ),
          child: const Icon(
            Icons.notifications_outlined,
            color: TrazaColors.textSecondary,
            size: 18,
          ),
        ),
        Positioned(
          top: 8, right: 8,
          child: Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: TrazaColors.danger,
              shape: BoxShape.circle,
              border: Border.all(color: TrazaColors.bg, width: 1.5),
            ),
          ),
        ),
      ],
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
        _LegendDot(color: TrazaColors.mapLow,  label: 'Bajo'),
        const SizedBox(width: 10),
        _LegendDot(color: TrazaColors.mapMid,  label: 'Medio'),
        const SizedBox(width: 10),
        _LegendDot(color: TrazaColors.mapHigh, label: 'Alto'),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            height: 3,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              gradient: const LinearGradient(
                colors: [
                  TrazaColors.mapLow,
                  TrazaColors.mapMid,
                  TrazaColors.mapHigh,
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text('Riesgo', style: TrazaTextStyles.labelSmall),
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
        Text(label, style: TrazaTextStyles.labelSmall),
      ],
    );
  }
}

// ─────────────────────────────────────────────
//  STATS GRID
// ─────────────────────────────────────────────

class _StatsGrid extends StatelessWidget {
  const _StatsGrid();

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      childAspectRatio: 1.55,
      children: const [
        TrazaStatCard(
          value: '47',
          label: 'Reportes este mes',
          icon: Icons.bar_chart_rounded,
          iconColor: TrazaColors.brand,
          iconBg: TrazaColors.brandSub,
        ),
        TrazaStatCard(
          value: '3',
          label: 'Zonas críticas',
          icon: Icons.warning_amber_rounded,
          iconColor: TrazaColors.danger,
          iconBg: TrazaColors.dangerSub,
          valueColor: TrazaColors.danger,
        ),
        TrazaStatCard(
          value: '68%',
          label: 'Tasa de respuesta',
          icon: Icons.check_circle_outline_rounded,
          iconColor: TrazaColors.success,
          iconBg: TrazaColors.successSub,
          valueColor: TrazaColors.success,
        ),
        TrazaStatCard(
          value: '12 min',
          label: 'Tiempo resp. prom.',
          icon: Icons.timer_outlined,
          iconColor: TrazaColors.textSecondary,
          iconBg: TrazaColors.bgCard,
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
      onTap: () {
        HapticFeedback.mediumImpact();
        // Navigator.pushNamed(context, '/report-form');
      },
      child: Container(
        width: 54,
        height: 54,
        decoration: BoxDecoration(
          color: TrazaColors.brand,
          borderRadius: BorderRadius.circular(18),
          boxShadow: TrazaShadows.brand,
        ),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 26),
      ),
    );
  }
}