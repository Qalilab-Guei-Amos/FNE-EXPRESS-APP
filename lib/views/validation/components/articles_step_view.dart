import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/validation_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/responsive.dart';
import 'item_card.dart';
import 'totals_card.dart';

class ArticlesStepView extends StatelessWidget {
  final ValidationController ctrl;
  const ArticlesStepView({super.key, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final pad = R.isTablet(context) ? 20.0 : 16.0;
    return Column(
      children: [
        const SizedBox(height: 8),
        // ── EN-TETE FIXE ──────────────────────────────────────────
        Padding(
          padding: EdgeInsets.symmetric(horizontal: pad),
          
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Obx(() {
                final count = ctrl.itemControllers.length;
                return Row(
                  children: [
                    Text(
                      'Articles',
                      style: TextStyle(
                        fontSize: R.fs(context, 18),
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textDark,
                      ),
                    ),
                    if (count > 0) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$count',
                          style: TextStyle(
                            fontSize: R.fs(context, 11),
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ],
                );
              }),
              ElevatedButton.icon(
                onPressed: ctrl.addItem,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 0,
                  ),
                  minimumSize: const Size(0, 36),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: const Icon(Icons.add, size: 18),
                label: const Text(
                  'Ajouter',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),

        // ── LISTE SCROLLABLE ──────────────────────────────────────
        Expanded(
          child: Obx(
            () => ListView.builder(
              controller: ctrl.scrollController,
              padding: EdgeInsets.fromLTRB(pad, 12, pad, 100),
              itemCount: ctrl.itemControllers.length + 1,
              itemBuilder: (context, i) {
                if (i < ctrl.itemControllers.length) {
                  return ItemCard(ctrl: ctrl, index: i);
                }
                return TotalsCard(invoice: ctrl.invoice.value);
              },
            ),
          ),
        ),
      ],
    );
  }
}
