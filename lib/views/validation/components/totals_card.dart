import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/responsive.dart';
import '../../../models/extracted_invoice.dart';

class TotalsCard extends StatelessWidget {
  final ExtractedInvoice? invoice;
  const TotalsCard({super.key, required this.invoice});

  @override
  Widget build(BuildContext context) {
    if (invoice == null) return const SizedBox.shrink();
    return Card(
      color: AppTheme.primary,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(R.radius(context))),
      child: Padding(
        padding: EdgeInsets.all(R.isTablet(context) ? 20 : 16),
        child: Column(
          children: [
            TotalRow(label: 'Total HT', value: invoice!.totalHT),
            const Divider(color: Colors.white24, height: 16),
            TotalRow(label: 'TVA', value: invoice!.totalTVA),
            const Divider(color: Colors.white24, height: 16),
            TotalRow(label: 'Total TTC', value: invoice!.totalTTC, isMain: true),
          ],
        ),
      ),
    );
  }
}

class TotalRow extends StatelessWidget {
  final String label;
  final double value;
  final bool isMain;
  const TotalRow(
      {super.key, required this.label, required this.value, this.isMain = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.85),
            fontSize: R.fs(context, isMain ? 15 : 13.5),
            fontWeight: isMain ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          AppFormatters.currency(value),
          style: TextStyle(
            color: Colors.white,
            fontSize: R.fs(context, isMain ? 17 : 14),
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
