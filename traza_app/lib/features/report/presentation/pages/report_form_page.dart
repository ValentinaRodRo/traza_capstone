import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/shared_widgets.dart';
import '../../domain/entities/report.dart';
import '../bloc/report_bloc.dart';
import 'report_success_page.dart';

class ReportFormPage extends StatefulWidget {
  const ReportFormPage({super.key});

  @override
  State<ReportFormPage> createState() => _ReportFormPageState();
}

class _ReportFormPageState extends State<ReportFormPage> {
  ReportType? _selectedType;
  final _locationCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  bool _isAnonymous = true;
  bool _isLocating = false;
  String? _locationError;
  String? _typeError;
  double? _latitude;
  double? _longitude;

  @override
  void dispose() {
    _locationCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchGpsLocation() async {
    setState(() {
      _isLocating = true;
      _locationError = null;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() => _locationError = 'Activa el GPS en tu dispositivo');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() => _locationError = 'Permiso de ubicación denegado');
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        setState(() => _locationError =
            'Permiso denegado permanentemente. Habilítalo en Ajustes.');
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
        _locationCtrl.text =
            '${position.latitude.toStringAsFixed(5)}, ${position.longitude.toStringAsFixed(5)}';
        _locationError = null;
      });
    } catch (e) {
      setState(() => _locationError = 'No se pudo obtener la ubicación');
    } finally {
      setState(() => _isLocating = false);
    }
  }

  void _submit() {
    setState(() {
      _typeError = _selectedType == null ? 'Selecciona el tipo de incidente' : null;
      _locationError =
          _locationCtrl.text.trim().isEmpty ? 'Ingresa la ubicación' : null;
    });
    if (_typeError != null || _locationError != null) return;

    context.read<ReportBloc>().add(SubmitReportEvent(
          type: _selectedType!,
          location: _locationCtrl.text.trim(),
          latitude: _latitude,
          longitude: _longitude,
          description: _descCtrl.text.trim().isNotEmpty
              ? _descCtrl.text.trim()
              : 'Sin descripción adicional.',
          isAnonymous: _isAnonymous,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ReportBloc, ReportState>(
      listener: (context, state) {
        if (state is ReportSubmitSuccess) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: context.read<ReportBloc>(),
                child: ReportSuccessPage(report: state.report),
              ),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: TrazaThemeTokens.bg(context),
        appBar: const TrazaAppBar(
          title: 'Reportar incidente',
          showBack: false,
        ),
        body: BlocBuilder<ReportBloc, ReportState>(
          builder: (context, state) {
            final isLoading = state is ReportSubmitting;
            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: TrazaSpacing.pagePadding,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Tipo de incidente ────────────────────────────
                        TrazaFormSectionCard(
                          label: '¿Qué ocurrió?',
                          child: Column(
                            children: [
                              if (_typeError != null)
                                TrazaErrorBanner(_typeError!),
                              ...ReportType.values.map((t) {
                                return TrazaSelectableTile(
                                  icon: _typeIcon(t),
                                  title: t.label,
                                  subtitle: _typeDescription(t),
                                  isSelected: _selectedType == t,
                                  onTap: () => setState(() {
                                    _selectedType = t;
                                    _typeError = null;
                                  }),
                                );
                              }),
                            ],
                          ),
                        ),

                        const SizedBox(height: TrazaSpacing.md),

                        // ── Ubicación ────────────────────────────────────
                        TrazaFormSectionCard(
                          label: '¿Dónde ocurrió?',
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (_locationError != null)
                                TrazaErrorBanner(_locationError!),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: _locationCtrl,
                                      onChanged: (_) => setState(
                                          () => _locationError = null),
                                      style: const TextStyle(fontSize: 13),
                                      decoration: InputDecoration(
                                        hintText: 'Parque principal, Calle 11…',
                                        prefixIcon: Icon(
                                          Icons.place_rounded,
                                          size: 17,
                                          color: TrazaThemeTokens.textTertiary(context),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: TrazaSpacing.sm),
                                  _GpsButton(
                                    isLoading: _isLocating,
                                    onTap: _fetchGpsLocation,
                                  ),
                                ],
                              ),
                              if (_latitude != null) ...[
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.check_circle_outline,
                                      size: 13,
                                      color: TrazaThemeTokens.success(context),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'GPS obtenido',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: TrazaThemeTokens.success(context),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),

                        const SizedBox(height: TrazaSpacing.md),

                        // ── Descripción ──────────────────────────────────
                        TrazaFormSectionCard(
                          label: 'Descripción (opcional)',
                          child: TextField(
                            controller: _descCtrl,
                            maxLines: 3,
                            style: const TextStyle(fontSize: 13),
                            decoration: const InputDecoration(
                              hintText:
                                  '¿Qué ocurrió? ¿Cuántas personas involucradas?',
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: TrazaSpacing.md),

                        // ── Reporte anónimo ──────────────────────────────
                        TrazaFormSectionCard(
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: TrazaThemeTokens.purpleSub(context),
                                  borderRadius:
                                      BorderRadius.circular(TrazaRadius.md),
                                ),
                                child: Icon(
                                  Icons.shield_outlined,
                                  color: TrazaThemeTokens.purple(context),
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: TrazaSpacing.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Reporte anónimo',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: TrazaThemeTokens.textPrimary(context),
                                      ),
                                    ),
                                    Text(
                                      'Tu identidad no será visible',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: TrazaThemeTokens.textSecondary(context),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Switch.adaptive(
                                value: _isAnonymous,
                                onChanged: (v) =>
                                    setState(() => _isAnonymous = v),
                                activeColor: TrazaThemeTokens.brand(context),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: TrazaSpacing.md),

                        // ── Hint denuncia formal ─────────────────────────
                        TrazaInfoBanner(
                          child: Text.rich(
                            TextSpan(
                              text: 'Denuncia formal: ',
                              style: TextStyle(
                                fontSize: 11,
                                color: TrazaThemeTokens.infoText(context),
                              ),
                              children: const [
                                TextSpan(
                                  text: 'fiscalia.gov.co',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                                TextSpan(text: '  ·  Línea '),
                                TextSpan(
                                  text: '122',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: TrazaSpacing.xxxl),
                      ],
                    ),
                  ),
                ),

                // ── CTA pegado al fondo ──────────────────────────────────
                Container(
                  color: TrazaThemeTokens.bgSurface(context),
                  padding: EdgeInsets.fromLTRB(
                    TrazaSpacing.lg,
                    TrazaSpacing.md,
                    TrazaSpacing.lg,
                    MediaQuery.of(context).padding.bottom + TrazaSpacing.md,
                  ),
                  child: TrazaPrimaryButton(
                    label: 'Enviar reporte',
                    icon: Icons.send_rounded,
                    isLoading: isLoading,
                    onPressed: _submit,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  IconData _typeIcon(ReportType t) => switch (t) {
        ReportType.theft => Icons.no_backpack_outlined,
        ReportType.suspicious => Icons.visibility_outlined,
        ReportType.vandalism => Icons.format_paint_outlined,
        ReportType.other => Icons.chat_bubble_outline_rounded,
      };

  String _typeDescription(ReportType t) => switch (t) {
        ReportType.theft => 'Objetos o pertenencias',
        ReportType.suspicious => 'Comportamiento inusual',
        ReportType.vandalism => 'Daño a propiedad',
        ReportType.other => 'Descríbelo tú mismo',
      };
}

// ── GPS Button ────────────────────────────────────────────────────────────────
class _GpsButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool isLoading;

  const _GpsButton({required this.onTap, this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: TrazaThemeTokens.brand(context),
          borderRadius: BorderRadius.circular(TrazaRadius.md),
        ),
        child: isLoading
            ? const Padding(
                padding: EdgeInsets.all(12),
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Icon(
                Icons.my_location_rounded,
                color: Colors.white,
                size: 20,
              ),
      ),
    );
  }
}