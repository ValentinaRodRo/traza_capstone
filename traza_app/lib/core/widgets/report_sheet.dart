import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/report/presentation/bloc/report_bloc.dart';
import '../../features/report/presentation/pages/report_form_page.dart';
import '../theme/app_theme.dart';

class ReportSheet extends StatelessWidget {
  const ReportSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context);
    return DraggableScrollableSheet(
      initialChildSize: 0.93,
      minChildSize: 0.5,
      maxChildSize: 0.97,
      snap: true,
      snapSizes: const [0.93, 0.97],
      builder: (_, scrollController) => Container(
        decoration: BoxDecoration(
          // ✅ bgOverlay adaptativo via bottomSheetTheme
          color: tt.bottomSheetTheme.backgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 4),
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  // ✅ border adaptativo
                  color: tt.dividerTheme.color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const Expanded(child: ReportFormPage()),
          ],
        ),
      ),
    );
  }
}

void showReportSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => BlocProvider.value(
      value: context.read<ReportBloc>(),
      child: const ReportSheet(),
    ),
  );
}