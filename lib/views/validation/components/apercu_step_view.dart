import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/validation_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/responsive.dart';
import '../../../models/extracted_invoice.dart';
import 'info_step_view.dart' show kPaymentMethods, kTemplates;
import 'totals_card.dart';

class ApercuStepView extends StatelessWidget {
  final ValidationController ctrl;
  const ApercuStepView({super.key, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final pad = R.isTablet(context) ? 20.0 : 16.0;
    return Obx(() {
      final inv = ctrl.invoice.value;
      final clientName = ctrl.clientNameCtrl.text;
      final phone = ctrl.clientPhoneCtrl.text;
      final email = ctrl.clientEmailCtrl.text;
      final ncc = ctrl.clientNccCtrl.text;
      final template = ctrl.template.value;
      final paymentMethod = ctrl.paymentMethod.value;
      final date = ctrl.dateCtrl.text;

      return SingleChildScrollView(
        padding: EdgeInsets.all(pad),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                'Aperçu de la facture',
                style: TextStyle(
                  fontSize: R.fs(context, 18),
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textDark,
                ),
              ),
            ),

            // ── Informations générales ───────────────────────────────
            _SummaryCard(
              title: 'INFORMATIONS GÉNÉRALES',
              rows: [
                _SummaryRow(label: 'Type', value: 'Facture de vente'),
                _SummaryRow(
                  label: 'Template',
                  value: kTemplates[template]?.split(' — ').first ?? template,
                ),
                _SummaryRow(
                  label: 'Paiement',
                  value: kPaymentMethods[paymentMethod] ?? paymentMethod,
                ),
                if (date.isNotEmpty)
                  _SummaryRow(label: 'Date', value: date),
              ],
            ),
            SizedBox(height: R.gap(context)),

            // ── Client ───────────────────────────────────────────────
            _SummaryCard(
              title: 'CLIENT',
              rows: [
                _SummaryRow(
                  label: 'Nom',
                  value: clientName.isEmpty ? '—' : clientName,
                  highlight: clientName.isEmpty,
                ),
                _SummaryRow(
                  label: 'Tél.',
                  value: phone.isEmpty ? '—' : phone,
                  highlight: phone.isEmpty,
                ),
                _SummaryRow(
                  label: 'Email',
                  value: email.isEmpty ? '—' : email,
                  highlight: email.isEmpty,
                ),
                if (template == 'B2B')
                  _SummaryRow(
                    label: 'NCC',
                    value: ncc.isEmpty ? '—' : ncc,
                    highlight: ncc.isEmpty,
                  ),
              ],
            ),
            SizedBox(height: R.gap(context)),

            // ── Articles ─────────────────────────────────────────────
            _ArticlesSummaryCard(ctrl: ctrl, inv: inv),
            SizedBox(height: R.gap(context)),

            // ── Totaux ───────────────────────────────────────────────
            TotalsCard(invoice: inv),
            const SizedBox(height: 40),
          ],
        ),
      );
    });
  }
}

// ── Carte récapitulatif générique ──────────────────────────────────────────────
class _SummaryCard extends StatelessWidget {
  final String title;
  final List<Widget> rows;
  const _SummaryCard({required this.title, required this.rows});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(R.radius(context))),
      child: Padding(
        padding: EdgeInsets.all(R.isTablet(context) ? 20 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: R.fs(context, 11.5),
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
                color: AppTheme.primary,
              ),
            ),
            const Divider(height: 16),
            ...rows,
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;
  const _SummaryRow({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: TextStyle(
                fontSize: R.fs(context, 13),
                color: AppTheme.textGrey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: R.fs(context, 13.5),
                fontWeight: FontWeight.w600,
                color: highlight ? Colors.red.shade400 : AppTheme.textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Carte articles ─────────────────────────────────────────────────────────────
class _ArticlesSummaryCard extends StatelessWidget {
  final ValidationController ctrl;
  final ExtractedInvoice? inv;
  const _ArticlesSummaryCard({required this.ctrl, required this.inv});

  @override
  Widget build(BuildContext context) {
    final items = inv?.items ?? [];
    return Card(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(R.radius(context))),
      child: Padding(
        padding: EdgeInsets.all(R.isTablet(context) ? 20 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'ARTICLES',
                  style: TextStyle(
                    fontSize: R.fs(context, 11.5),
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                    color: AppTheme.primary,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${items.length}',
                    style: TextStyle(
                      fontSize: R.fs(context, 11),
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primary,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 16),
            if (items.isEmpty)
              Text(
                'Aucun article',
                style: TextStyle(
                    color: AppTheme.textGrey, fontSize: R.fs(context, 13)),
              )
            else
              ...items.asMap().entries.map((entry) {
                final i = entry.key;
                final item = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${i + 1}. ',
                        style: TextStyle(
                          fontSize: R.fs(context, 13),
                          color: AppTheme.textGrey,
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.designation.isEmpty
                                  ? '(sans désignation)'
                                  : item.designation,
                              style: TextStyle(
                                fontSize: R.fs(context, 13.5),
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textDark,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Qté: ${_qty(item.quantity)} × ${AppFormatters.currency(item.unitPrice).replaceAll('FCFA', 'F').trim()}',
                              style: TextStyle(
                                fontSize: R.fs(context, 12),
                                color: AppTheme.textGrey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        AppFormatters.currency(item.amountTTC)
                            .replaceAll('FCFA', 'F')
                            .trim(),
                        style: TextStyle(
                          fontSize: R.fs(context, 13.5),
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                        ),
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  String _qty(double q) =>
      q % 1 == 0 ? q.toInt().toString() : q.toStringAsFixed(2);
}
