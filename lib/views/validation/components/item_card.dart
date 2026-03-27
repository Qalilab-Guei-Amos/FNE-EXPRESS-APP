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
    final isTablet = R.isTablet(context);
    final fieldStyle = TextStyle(fontSize: R.fs(context, 13.5));
    final labelStyle = TextStyle(fontSize: R.fs(context, 13));
    final gap = R.gap(context) * 0.7;

    return Obx(() {
      if (index >= ctrl.itemControllers.length ||
          index >= ctrl.itemTaxCodes.length) {
        return const SizedBox.shrink();
      }
      final ctrls = ctrl.itemControllers[index];
      final currentTaxCode = ctrl.itemTaxCodes[index].value;
      final inv = ctrl.invoice.value;

      return Card(
        margin: EdgeInsets.only(bottom: R.gap(context) * 0.8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(R.radius(context)),
        ),
        child: Padding(
          padding: EdgeInsets.all(isTablet ? 18 : 14),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Article ${index + 1}',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primary,
                        fontSize: R.fs(context, 14),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.delete_outline,
                      color: Colors.red,
                      size: R.icon(context, 20),
                    ),
                    onPressed: () => ctrl.removeItem(index),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              SizedBox(height: gap),
              TextFormField(
                controller: ctrls['designation'],
                style: fieldStyle,
                decoration: InputDecoration(
                  labelText: 'Désignation',
                  labelStyle: labelStyle,
                ),
                onChanged: (_) => ctrl.updateItemFromControllers(index),
              ),
              SizedBox(height: gap),
                Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: ctrls['quantity'],
                            style: fieldStyle,
                            decoration: InputDecoration(
                              labelText: 'Quantité',
                              labelStyle: labelStyle,
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (_) =>
                                ctrl.updateItemFromControllers(index),
                          ),
                        ),
                        SizedBox(width: gap),
                        Expanded(
                          flex: 1,
                          child: TextFormField(
                            controller: ctrls['unitPrice'],
                            style: fieldStyle,
                            decoration: InputDecoration(
                              labelText: 'Prix HT (FCFA)',
                              labelStyle: labelStyle,
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (_) =>
                                ctrl.updateItemFromControllers(index),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: gap),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: ctrls['discount'],
                            style: fieldStyle,
                            decoration: InputDecoration(
                              labelText: 'Remise (FCFA)',
                              labelStyle: labelStyle,
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (_) =>
                                ctrl.updateItemFromControllers(index),
                          ),
                        ),
                        SizedBox(width: gap),
                        Expanded(
                          child: _buildTaxDropdown(currentTaxCode, labelStyle, index),
                        ),
                      ],
                    ),
                  ],
                ),
              if (inv != null && index < inv.items.length) ...[
                SizedBox(height: gap),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: isTablet ? 10 : 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(R.radius(context)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total TTC:',
                        style: TextStyle(
                          color: AppTheme.textGrey,
                          fontSize: R.fs(context, 13),
                        ),
                      ),
                      Text(
                        AppFormatters.currency(inv.items[index].amountTTC),
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
            ],
          ),
        ),
      );
    });
  }

  Widget _buildTaxDropdown(
      String currentTaxCode, TextStyle labelStyle, int index) {
    return DropdownButtonFormField<String>(
      initialValue: currentTaxCode,
      decoration: InputDecoration(labelText: 'TVA', labelStyle: labelStyle),
      style: TextStyle(fontSize: R.fs(Get.context!, 13.5), color: AppTheme.textDark),
      isExpanded: true,
      items: kTaxLabels.entries
          .map((e) => DropdownMenuItem(
              value: e.key,
              child: Text(e.value, overflow: TextOverflow.ellipsis)))
          .toList(),
      onChanged: (v) {
        if (v != null) {
          ctrl.itemTaxCodes[index].value = v;
          ctrl.updateItemFromControllers(index);
        }
      },
    );
  }
}
