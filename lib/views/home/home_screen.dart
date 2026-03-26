import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../fne_result/fne_web_view_screen.dart';
import '../../controllers/history_controller.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/responsive.dart';
import '../acquisition/acquisition_screen.dart';
import '../history/history_screen.dart';
import '../../models/fne_record.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final historyCtrl = Get.put(HistoryController());
    final isTablet = R.isTablet(context);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── AppBar ──────────────────────────────────────────
            SliverAppBar(
              backgroundColor: AppTheme.primary,
              expandedHeight: isTablet ? 180 : 140,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: EdgeInsetsDirectional.only(
                  start: R.hPad(context),
                  bottom: 16,
                ),
                title: Text(
                  'FNE Express',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: R.fs(context, 20),
                  ),
                ),
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppTheme.primary, AppTheme.primaryLight],
                    ),
                  ),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: EdgeInsets.only(right: R.hPad(context)),
                      child: Icon(
                        Icons.receipt_long,
                        size: R.icon(context, 90),
                        color: Colors.white.withValues(alpha: 0.15),
                      ),
                    ),
                  ),
                ),
              ),
              actions: [
                IconButton(
                  icon: Icon(Icons.history,
                      color: Colors.white, size: R.icon(context, 24)),
                  onPressed: () => Get.to(() => const HistoryScreen()),
                  tooltip: 'Historique',
                ),
                SizedBox(width: R.hPad(context) - 16),
              ],
            ),

            // ── Bouton Nouvelle FNE ─────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: R.hPad(context),
                  vertical: R.vPad(context),
                ),
                child: R.centered(context,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: double.infinity,
                          height: R.btnH(context),
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Get.to(() => const AcquisitionScreen())
                                  ?.then((_) => historyCtrl.loadRecords());
                            },
                            icon: Icon(Icons.add_circle_outline,
                                size: R.icon(context, 26)),
                            label: Text(
                              'Nouvelle FNE',
                              style: TextStyle(fontSize: R.fs(context, 17)),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.accent,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(R.radius(context)),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: R.gap(context) * 1.8),
                        Text(
                          'FNE Récentes',
                          style: TextStyle(
                            fontSize: R.fs(context, 17),
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textDark,
                          ),
                        ),
                        SizedBox(height: R.gap(context) * 0.7),
                      ],
                    )),
              ),
            ),

            // ── Liste / Grille des FNE ──────────────────────────
            Obx(() {
              final records = historyCtrl.records.take(6).toList();
              if (records.isEmpty) {
                return SliverToBoxAdapter(child: _EmptyState(context));
              }

              // Tablette → grille, Mobile → liste
              if (R.isTablet(context)) {
                return SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: R.hPad(context)),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                      (ctx, i) => _FneCard(
                        record: records[i],
                        onTap: () => _openRecord(records[i]),
                      ),
                      childCount: records.length,
                    ),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: R.cols(context),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 2.8,
                    ),
                  ),
                );
              }

              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (ctx, i) => Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: R.hPad(context),
                      vertical: 4,
                    ),
                    child: _FneCard(
                      record: records[i],
                      onTap: () => _openRecord(records[i]),
                    ),
                  ),
                  childCount: records.length,
                ),
              );
            }),

            // ── Lien "Voir tout" ────────────────────────────────
            SliverToBoxAdapter(
              child: Obx(() {
                if (historyCtrl.records.length > 6) {
                  return Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: R.hPad(context),
                      vertical: 8,
                    ),
                    child: TextButton.icon(
                      onPressed: () => Get.to(() => const HistoryScreen()),
                      icon: const Icon(Icons.history),
                      label: Text(
                        'Voir tout (${historyCtrl.records.length} FNE)',
                        style: TextStyle(fontSize: R.fs(context, 14)),
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              }),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
      ),
    );
  }
}

// ── Ouverture de la facture certifiée ────────────────────────────────────────
void _openRecord(FneRecord record) {
  if (record.qrCode != null && record.qrCode!.isNotEmpty) {
    Get.to(() => FneWebViewScreen(url: record.qrCode!));
  } else {
    Get.snackbar('Indisponible', 'Aucun lien de vérification pour cette FNE',
        snackPosition: SnackPosition.BOTTOM);
  }
}

// ── Écran vide ────────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final BuildContext parentCtx;
  const _EmptyState(this.parentCtx);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: R.isTablet(context) ? 80 : 48),
        child: Column(
          children: [
            Icon(
              Icons.receipt_outlined,
              size: R.icon(context, 72),
              color: AppTheme.textGrey.withValues(alpha: 0.35),
            ),
            SizedBox(height: R.gap(context)),
            Text(
              'Aucune FNE générée',
              style: TextStyle(
                color: AppTheme.textGrey.withValues(alpha: 0.7),
                fontSize: R.fs(context, 16),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Appuyez sur "Nouvelle FNE" pour commencer',
              style: TextStyle(
                color: AppTheme.textGrey.withValues(alpha: 0.5),
                fontSize: R.fs(context, 13),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Carte FNE ─────────────────────────────────────────────────────────────────
class _FneCard extends StatelessWidget {
  final FneRecord record;
  final VoidCallback onTap;
  const _FneCard({required this.record, required this.onTap});

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
                      '${AppFormatters.date(record.createdAt)} • ${record.fneNumber ?? 'En attente'}',
                      style: TextStyle(
                        color: AppTheme.textGrey,
                        fontSize: R.fs(context, 11.5),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              SizedBox(width: isTablet ? 16 : 8),
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
                  const SizedBox(height: 4),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: record.fneNumber != null
                          ? Colors.green.shade100
                          : Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      record.fneNumber != null ? 'Validé' : 'Brouillon',
                      style: TextStyle(
                        fontSize: R.fs(context, 10),
                        fontWeight: FontWeight.w600,
                        color: record.fneNumber != null
                            ? Colors.green.shade700
                            : Colors.orange.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
