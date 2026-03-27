import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/validation_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/responsive.dart';
import '../../../models/invoice_item.dart';

class ItemCard extends StatelessWidget {
  final ValidationController ctrl;
  final int index;
  const ItemCard({super.key, required this.ctrl, required this.index});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (index >= ctrl.itemControllers.length ||
          index >= ctrl.itemTaxCodes.length ||
          index >= ctrl.itemExpanded.length) {
        return const SizedBox.shrink();
      }

      final isExpanded = ctrl.itemExpanded[index].value;
      final inv = ctrl.invoice.value;
      final item =
          (inv != null && index < inv.items.length) ? inv.items[index] : null;
      final ctrls = ctrl.itemControllers[index];
      final currentTaxCode = ctrl.itemTaxCodes[index].value;

      if (isExpanded) {
        return _buildEditCard(context, ctrls, currentTaxCode, item);
      } else {
        return _buildSummaryCard(context, ctrls, item, currentTaxCode);
      }
    });
  }

  // ── Mode résumé (compacte) ──────────────────────────────────────────────────
  Widget _buildSummaryCard(
    BuildContext context,
    Map<String, TextEditingController> ctrls,
    InvoiceItem? item,
    String currentTaxCode,
  ) {
    final designation = ctrls['designation']?.text ?? '';
    final qty = ctrls['quantity']?.text ?? '1';
    final price = ctrls['unitPrice']?.text ?? '0';
    final taxLabel = kTaxLabels[currentTaxCode] ?? currentTaxCode;

    return Card(
      margin: EdgeInsets.only(bottom: R.gap(context) * 0.8),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(R.radius(context))),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: R.isTablet(context) ? 18 : 14,
          vertical: 12,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Numéro article
            Container(
              width: 28,
              height: 28,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Text(
                '${index + 1}',
                style: TextStyle(
                  fontSize: R.fs(context, 12),
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primary,
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Désignation + qty × prix
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    designation.isEmpty ? '(sans désignation)' : designation,
                    style: TextStyle(
                      fontSize: R.fs(context, 13.5),
                      fontWeight: FontWeight.w600,
                      color: designation.isEmpty
                          ? AppTheme.textGrey
                          : AppTheme.textDark,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Qté $qty × $price F',
                    style: TextStyle(
                      fontSize: R.fs(context, 12),
                      color: AppTheme.textGrey,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    taxLabel,
                    style: TextStyle(
                      fontSize: R.fs(context, 11),
                      color: AppTheme.textGrey,
                    ),
                  ),
                ],
              ),
            ),

            // Montant TTC
            if (item != null) ...[
              const SizedBox(width: 8),
              Text(
                AppFormatters.currency(item.amountTTC)
                    .replaceAll('FCFA', 'F')
                    .trim(),
                style: TextStyle(
                  fontSize: R.fs(context, 13.5),
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primary,
                ),
              ),
            ],

            // Boutons
            const SizedBox(width: 4),
            IconButton(
              icon: Icon(Icons.edit_outlined,
                  size: R.icon(context, 18), color: AppTheme.textGrey),
              onPressed: () => ctrl.itemExpanded[index].value = true,
              padding: const EdgeInsets.all(6),
              constraints: const BoxConstraints(),
            ),
            IconButton(
              icon: Icon(Icons.delete_outline,
                  size: R.icon(context, 18), color: Colors.red.shade300),
              onPressed: () => ctrl.removeItem(index),
              padding: const EdgeInsets.all(6),
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      ),
    );
  }

  // ── Mode édition (champs inline) ────────────────────────────────────────────
  Widget _buildEditCard(
    BuildContext context,
    Map<String, TextEditingController> ctrls,
    String currentTaxCode,
    InvoiceItem? item,
  ) {
    final isTablet = R.isTablet(context);
    final fieldStyle = TextStyle(fontSize: R.fs(context, 13.5));
    final labelStyle = TextStyle(fontSize: R.fs(context, 13));
    final gap = R.gap(context) * 0.7;

    return Card(
      margin: EdgeInsets.only(bottom: R.gap(context) * 0.8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(R.radius(context)),
        side: BorderSide(
            color: AppTheme.primary.withValues(alpha: 0.4), width: 1.5),
      ),
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 18 : 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête
            Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: AppTheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      fontSize: R.fs(context, 12),
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'Article ${index + 1}',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primary,
                    fontSize: R.fs(context, 14),
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(Icons.delete_outline,
                      color: Colors.red.shade300, size: R.icon(context, 20)),
                  onPressed: () => ctrl.removeItem(index),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            SizedBox(height: gap),

            // Désignation
            TextFormField(
              controller: ctrls['designation'],
              style: fieldStyle,
              decoration: InputDecoration(
                  labelText: 'Désignation', labelStyle: labelStyle),
              onChanged: (_) => ctrl.updateItemFromControllers(index),
            ),
            SizedBox(height: gap),

            // Quantité + Prix
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: ctrls['quantity'],
                    style: fieldStyle,
                    decoration: InputDecoration(
                        labelText: 'Quantité', labelStyle: labelStyle),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (_) => ctrl.updateItemFromControllers(index),
                  ),
                ),
                SizedBox(width: gap),
                Expanded(
                  child: TextFormField(
                    controller: ctrls['unitPrice'],
                    style: fieldStyle,
                    decoration: InputDecoration(
                        labelText: 'Prix HT (FCFA)', labelStyle: labelStyle),
                    keyboardType: TextInputType.number,
                    onChanged: (_) => ctrl.updateItemFromControllers(index),
                  ),
                ),
              ],
            ),
            SizedBox(height: gap),

            // Remise + TVA
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: ctrls['discount'],
                    style: fieldStyle,
                    decoration: InputDecoration(
                        labelText: 'Remise (FCFA)', labelStyle: labelStyle),
                    keyboardType: TextInputType.number,
                    onChanged: (_) => ctrl.updateItemFromControllers(index),
                  ),
                ),
                SizedBox(width: gap),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: currentTaxCode,
                    decoration: InputDecoration(
                        labelText: 'TVA', labelStyle: labelStyle),
                    style: TextStyle(
                        fontSize: R.fs(Get.context!, 13.5),
                        color: AppTheme.textDark),
                    isExpanded: true,
                    items: kTaxLabels.entries
                        .map((e) => DropdownMenuItem(
                            value: e.key,
                            child: Text(e.value,
                                overflow: TextOverflow.ellipsis)))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) {
                        ctrl.itemTaxCodes[index].value = v;
                        ctrl.updateItemFromControllers(index);
                      }
                    },
                  ),
                ),
              ],
            ),

            // TTC en temps réel
            if (item != null) ...[
              SizedBox(height: gap),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(R.radius(context)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total TTC:',
                        style: TextStyle(
                            color: AppTheme.textGrey,
                            fontSize: R.fs(context, 13))),
                    Text(
                      AppFormatters.currency(item.amountTTC),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primary,
                        fontSize: R.fs(context, 14),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            SizedBox(height: gap + 4),

            // Bouton Valider
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  ctrl.updateItemFromControllers(index);
                  ctrl.itemExpanded[index].value = false;
                },
                icon: const Icon(Icons.check, size: 18),
                label: const Text('Valider',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(0, 44),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
