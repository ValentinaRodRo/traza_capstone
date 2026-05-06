import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/shared_widgets.dart';
import '../../../report/domain/entities/report.dart';
import '../bloc/authority_bloc.dart';

class AuthorityDetailPage extends StatefulWidget {
  final Report report;
  const AuthorityDetailPage({super.key, required this.report});

  @override
  State<AuthorityDetailPage> createState() => _AuthorityDetailPageState();
}

class _AuthorityDetailPageState extends State<AuthorityDetailPage> {
  late Report _report;
  final _noteCtrl = TextEditingController();
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    _report = widget.report;
    _noteCtrl.text = _report.officerNote ?? '';
  }

  void _updateStatus(ReportStatus status) {
    context.read<AuthorityBloc>().add(UpdateStatus(
      reportId: _report.id,
      status: status,
      note: _noteCtrl.text.trim().isNotEmpty ? _noteCtrl.text.trim() : null,
    ));
    setState(() => _report = _report.copyWith(status: status));
  }

  void _save() {
    context.read<AuthorityBloc>().add(UpdateStatus(
      reportId: _report.id,
      status: _report.status,
      note: _noteCtrl.text.trim(),
    ));
    setState(() => _saved = true);
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _saved = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TrazaColors.surfaceAlt,
      appBar: AppBar(
        backgroundColor: TrazaColors.authorityBlue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Reporte ${_report.id}',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              StatusBadge(_report.status),
              const SizedBox(width: 8),
              TrustBadge(_report.trustLevel),
            ]),
            const SizedBox(height: 14),

            _InfoCard(report: _report),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: TrazaColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: TrazaColors.borderLight),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Descripción', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: TrazaColors.textSecondary)),
                const SizedBox(height: 8),
                Text(_report.description, style: const TextStyle(fontSize: 13, color: TrazaColors.textPrimary, height: 1.5)),
              ]),
            ),
            const SizedBox(height: 12),

            if (_saved)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: TrazaColors.successLight, borderRadius: BorderRadius.circular(12)),
                child: const Row(children: [
                  Icon(Icons.check_circle_rounded, size: 16, color: TrazaColors.successText),
                  SizedBox(width: 8),
                  Text('Estado actualizado. Ciudadano notificado.', style: TextStyle(fontSize: 12, color: TrazaColors.successText)),
                ]),
              ),

            const Text('Actualizar estado', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: TrazaColors.textSecondary)),
            const SizedBox(height: 8),
            Wrap(spacing: 8, children: [
              _StatusButton('En proceso', ReportStatus.inProgress, TrazaColors.warning, TrazaColors.warningLight, _updateStatus),
              _StatusButton('Resuelto', ReportStatus.resolved, TrazaColors.success, TrazaColors.successLight, _updateStatus),
              _StatusButton('Sin atender', ReportStatus.pending, TrazaColors.danger, TrazaColors.dangerLight, _updateStatus),
            ]),
            const SizedBox(height: 14),

            TextField(
              controller: _noteCtrl,
              maxLines: 3,
              style: const TextStyle(fontSize: 13),
              decoration: InputDecoration(
                labelText: 'Mensaje al ciudadano',
                hintText: 'Ej: Patrulla asignada al sector...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 14),

            TrazaPrimaryButton(label: 'Guardar y notificar', icon: Icons.save_rounded,
                color: TrazaColors.authorityBlue, onPressed: _save),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: TrazaColors.authorityBlue),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  foregroundColor: TrazaColors.authorityBlue,
                ),
                icon: const Icon(Icons.description_outlined, size: 18),
                label: const Text('Crear reporte policial', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                onPressed: () {},
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final Report report;
  const _InfoCard({required this.report});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: TrazaColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: TrazaColors.borderLight)),
      child: Column(children: [
        _Row('Tipo', report.type.label),
        _Row('Ubicación', report.location),
        _Row('Hora', '${report.createdAt.hour}:${report.createdAt.minute.toString().padLeft(2,'0')} AM'),
        _Row('Reportes coincidentes', '${report.coincidentReports}'),
        _Row('Ciudadano', 'Sin registro de identidad'),
      ]),
    );
  }
}

class _Row extends StatelessWidget {
  final String label, value;
  const _Row(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(children: [
        SizedBox(width: 120, child: Text(label, style: const TextStyle(fontSize: 11, color: TrazaColors.textSecondary))),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: TrazaColors.textPrimary))),
      ]),
    );
  }
}

class _StatusButton extends StatelessWidget {
  final String label;
  final ReportStatus status;
  final Color fg, bg;
  final Function(ReportStatus) onTap;

  const _StatusButton(this.label, this.status, this.fg, this.bg, this.onTap);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(status),
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(100), border: Border.all(color: fg.withOpacity(0.4))),
        child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: fg)),
      ),
    );
  }
}