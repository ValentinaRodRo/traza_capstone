import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
  String? _locationError;
  String? _typeError;

  @override
  void dispose() {
    _locationCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
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
        backgroundColor: TrazaColors.surfaceAlt,
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
                        // ── Tipo de incidente ──────────────────────────────
                        FormSectionCard(
                          label: '¿Qué ocurrió?',
                          child: Column(
                            children: [
                              if (_typeError != null)
                                InlineErrorBanner(_typeError!),
                              ...ReportType.values.map((t) {
                                return SelectableOptionTile(
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

                        // ── Ubicación ──────────────────────────────────────
                        FormSectionCard(
                          label: '¿Dónde ocurrió?',
                          child: Column(
                            children: [
                              if (_locationError != null)
                                InlineErrorBanner(_locationError!),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: _locationCtrl,
                                      onChanged: (_) => setState(
                                          () => _locationError = null),
                                      style: const TextStyle(fontSize: 13),
                                      decoration: InputDecoration(
                                        hintText:
                                            'Parque principal, Calle 11…',
                                        prefixIcon: const Icon(
                                          Icons.place_rounded,
                                          size: 17,
                                          color: TrazaColors.textTertiary,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: TrazaSpacing.sm),
                                  _GpsButton(
                                    onTap: () => setState(() {
                                      _locationCtrl.text =
                                          'Parque principal, Chía (GPS)';
                                      _locationError = null;
                                    }),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: TrazaSpacing.md),

                        // ── Descripción ────────────────────────────────────
                        FormSectionCard(
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

                        // ── Reporte anónimo ────────────────────────────────
                        FormSectionCard(
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: TrazaColors.purpleLight,
                                  borderRadius:
                                      BorderRadius.circular(TrazaRadius.md),
                                ),
                                child: const Icon(
                                  Icons.shield_outlined,
                                  color: TrazaColors.purple,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: TrazaSpacing.md),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Reporte anónimo',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      'Tu identidad no será visible',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: TrazaColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Switch.adaptive(
                                value: _isAnonymous,
                                onChanged: (v) =>
                                    setState(() => _isAnonymous = v),
                                activeColor: TrazaColors.navyMid,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: TrazaSpacing.md),

                        // ── Hint denuncia formal ───────────────────────────
                        InfoHintBanner(
                          child: Text.rich(
                            TextSpan(
                              text: 'Denuncia formal: ',
                              style: const TextStyle(
                                  fontSize: 11,
                                  color: TrazaColors.infoText),
                              children: const [
                                TextSpan(
                                  text: 'fiscalia.gov.co',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600),
                                ),
                                TextSpan(text: '  ·  Línea '),
                                TextSpan(
                                  text: '122',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600),
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

                // ── CTA pegado al fondo ────────────────────────────────────
                Container(
                  color: TrazaColors.surface,
                  padding: EdgeInsets.fromLTRB(
                    TrazaSpacing.lg,
                    TrazaSpacing.md,
                    TrazaSpacing.lg,
                    MediaQuery.of(context).padding.bottom +
                        TrazaSpacing.md,
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

  // Descripción corta por tipo — podría moverse a la entidad ReportType
  String _typeDescription(ReportType t) => switch (t) {
        ReportType.theft => 'Objetos o pertenencias',
        ReportType.suspicious => 'Comportamiento inusual',
        ReportType.vandalism => 'Daño a propiedad',
        ReportType.other => 'Descríbelo tú mismo',
      };
}

// ── GPS Button ────────────────────────────────────────────────────────────────
// Widget privado del formulario, específico de esta pantalla. No necesita ir
// en shared_widgets porque no tiene caso de uso fuera de campos de ubicación.
class _GpsButton extends StatelessWidget {
  final VoidCallback onTap;
  const _GpsButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: TrazaColors.navyMid,
          borderRadius: BorderRadius.circular(TrazaRadius.md),
        ),
        child:
            const Icon(Icons.my_location_rounded, color: Colors.white, size: 20),
      ),
    );
  }
}