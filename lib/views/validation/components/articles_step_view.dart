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
        // ── EN-TETE FIXE ARTICLES ─────────────────────────────────
        Container(
          padding: EdgeInsets.symmetric(horizontal: pad, vertical: 12),
          decoration: BoxDecoration(
            color: AppTheme.background,
            border: Border(bottom: BorderSide(color: AppTheme.divider, width: 0.5)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Articles',
                style: TextStyle(
                  fontSize: R.fs(context, 16),
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
              ElevatedButton.icon(
                onPressed: ctrl.addItem,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                  minimumSize: const Size(0, 36),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Ajouter', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),

        // ── LISTE SCROLLABLE ──────────────────────────────────────
        Expanded(
          child: Obx(() => ListView.builder(
                controller: ctrl.scrollController,
                padding: EdgeInsets.fromLTRB(pad, 12, pad, 100),
                itemCount: ctrl.itemControllers.length + 1,
                itemBuilder: (context, i) {
                  if (i < ctrl.itemControllers.length) {
                    return ItemCard(ctrl: ctrl, index: i);
                  }
                  return TotalsCard(invoice: ctrl.invoice.value);
                },
              )),
        ),
      ],
    );
  }
}
