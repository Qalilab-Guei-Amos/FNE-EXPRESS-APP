import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../fne_result/fne_web_view_screen.dart';
import '../../controllers/history_controller.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/responsive.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(HistoryController(), tag: 'history_screen');

    return Scaffold(
      appBar: AppBar(
        title: Text('Historique FNE',
            style: TextStyle(fontSize: R.fs(context, 18))),
      ),
      body: Obx(() {
        if (ctrl.records.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history,
                    size: R.icon(context, 80),
                    color: AppTheme.textGrey.withValues(alpha: 0.3)),
                SizedBox(height: R.gap(context)),
                Text(
                  'Aucune FNE dans l\'historique',
                  style: TextStyle(
                      color: AppTheme.textGrey,
                      fontSize: R.fs(context, 16)),
                ),
              ],
            ),
          );
        }

        // Tablette → grille, Mobile → liste
        if (R.isTablet(context)) {
          return _TabletGrid(ctrl: ctrl);
        }
        return _MobileList(ctrl: ctrl);
      }),
    );
  }
}

// ── Grille tablette ───────────────────────────────────────────────────────────
class _TabletGrid extends StatelessWidget {
  final HistoryController ctrl;
  const _TabletGrid({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.all(R.hPad(context)),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: R.cols(context),
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: R.isLargeTablet(context) ? 2.6 : 2.2,
      ),
      itemCount: ctrl.records.length,
      itemBuilder: (context, index) {
        final record = ctrl.records[index];
        return _HistoryCard(
          record: record,
          onTap: () => _openRecord(record),
          onDelete: () => _confirmDelete(context, ctrl, record.id),
        );
      },
    );
  }
}

// ── Liste mobile avec swipe-to-delete ─────────────────────────────────────────
class _MobileList extends StatelessWidget {
  final HistoryController ctrl;
  const _MobileList({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.all(R.hPad(context)),
      itemCount: ctrl.records.length,
      separatorBuilder: (_, __) => SizedBox(height: R.gap(context) * 0.6),
      itemBuilder: (context, index) {
        final record = ctrl.records[index];
        return Dismissible(
          key: Key(record.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            decoration: BoxDecoration(
              color: Colors.red.shade600,
              borderRadius: BorderRadius.circular(R.radius(context)),
            ),
            child: Icon(Icons.delete,
                color: Colors.white, size: R.icon(context, 28)),
          ),
          confirmDismiss: (_) => _confirmDelete(context, ctrl, record.id),
          onDismissed: (_) => ctrl.deleteRecord(record.id),
          child: _HistoryCard(
            record: record,
            onTap: () => _openRecord(record),
            onDelete: null,
          ),
        );
      },
    );
  }
}

// ── Carte historique ──────────────────────────────────────────────────────────
class _HistoryCard extends StatelessWidget {
  final dynamic record;
  final VoidCallback onTap;
  final VoidCallback? onDelete;
  const _HistoryCard({
    required this.record,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isTablet = R.isTablet(context);
    return Card(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(R.radius(context))),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(R.radius(context)),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isTablet ? 20 : 16,
            vertical: isTablet ? 14 : 10,
          ),
          child: Row(
            children: [
              Container(
                width: R.icon(context, 46),
                height: R.icon(context, 46),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.receipt_long,
                    color: AppTheme.primary, size: R.icon(context, 24)),
              ),
              SizedBox(width: isTablet ? 16 : 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      record.clientName,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textDark,
                        fontSize: R.fs(context, 14),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      AppFormatters.date(record.createdAt),
                      style: TextStyle(
                          color: AppTheme.textGrey,
                          fontSize: R.fs(context, 12)),
                    ),
                    if (record.fneNumber != null)
                      Text(
                        record.fneNumber!,
                        style: TextStyle(
                            color: AppTheme.primary,
                            fontSize: R.fs(context, 11)),
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    AppFormatters.currency(record.totalTTC),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primary,
                      fontSize: R.fs(context, 13),
                    ),
                  ),
                  if (onDelete != null) ...[
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: onDelete,
                      child: Icon(Icons.delete_outline,
                          color: Colors.red.shade300,
                          size: R.icon(context, 20)),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Ouverture de la facture certifiée ────────────────────────────────────────
void _openRecord(dynamic record) {
  if (record.qrCode != null && record.qrCode!.isNotEmpty) {
    Get.to(() => FneWebViewScreen(url: record.qrCode!));
  } else {
    Get.snackbar('Indisponible', 'Aucun lien de vérification pour cette FNE',
        snackPosition: SnackPosition.BOTTOM);
  }
}

// ── Dialogue de confirmation de suppression ───────────────────────────────────
Future<bool?> _confirmDelete(
    BuildContext context, HistoryController ctrl, String id) {
  return showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text('Supprimer cette FNE ?',
          style: TextStyle(fontSize: R.fs(context, 17))),
      content: Text('Cette action est irréversible.',
          style: TextStyle(fontSize: R.fs(context, 14))),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text('Annuler',
              style: TextStyle(fontSize: R.fs(context, 14))),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: Text('Supprimer',
              style: TextStyle(
                  color: Colors.red, fontSize: R.fs(context, 14))),
        ),
      ],
    ),
  );
}
