import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import '../../controllers/history_controller.dart';
import '../../controllers/settings_controller.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive.dart';
import 'components/dashboard_header.dart';
import 'components/stats_row.dart';
import '../history/components/history_card.dart';
import '../history/components/tablet_grid.dart' show openRecord;
import '../history/components/delete_dialog.dart';
import '../../models/fne_record.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final historyCtrl = Get.put(HistoryController());
    final settingsCtrl = Get.put(SettingsController());

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: AppTheme.background,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppTheme.background,
        floatingActionButton: FloatingActionButton.extended(
          onPressed: historyCtrl.scanNewInvoice,
          backgroundColor: AppTheme.primary,
          foregroundColor: Colors.white,
          elevation: 4,
          icon: const Icon(Icons.add_photo_alternate),
          label: const Text(
            'NOUVELLE FNE',
            style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.8),
          ),
        ),
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── Header Dashboard (Status bar color included) ────
            DashboardHeader(settingsCtrl: settingsCtrl),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // ── Section Metrics ──────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: R.hPad(context)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    StatsRow(historyCtrl: historyCtrl),
                    const SizedBox(height: 24),
                    const Text(
                      'Mes 5 dernières factures',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Obx(() {
                      final latest = historyCtrl.latest5Records;
                      if (latest.isEmpty) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(24.0),
                            child: Text(
                              'Aucune activité récente.',
                              style: TextStyle(color: AppTheme.textGrey),
                            ),
                          ),
                        );
                      }
                      
                      if (R.isTablet(context)) {
                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: EdgeInsets.zero,
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: R.cols(context),
                            crossAxisSpacing: 14,
                            mainAxisSpacing: 14,
                            mainAxisExtent: R.isLargeTablet(context) ? 195 : 175,
                          ),
                          itemCount: latest.length,
                          itemBuilder: (context, index) {
                            final record = latest[index];
                            final canDelete = record.status != FneStatus.certifiee;
                            return HistoryCard(
                              record: record,
                              onTap: () => openRecord(record, historyCtrl),
                              onDelete: canDelete
                                  ? () async {
                                      final confirmed = await showDeleteDialog(
                                          context, historyCtrl, record);
                                      if (confirmed == true) {
                                        historyCtrl.deleteRecord(record.id);
                                      }
                                    }
                                  : null,
                            );
                          },
                        );
                      }
                      
                      return Column(
                        children: latest.map((record) {
                          final canDelete = record.status != FneStatus.certifiee;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: HistoryCard(
                              record: record,
                              onTap: () => openRecord(record, historyCtrl),
                              onDelete: canDelete
                                  ? () async {
                                      final confirmed = await showDeleteDialog(
                                          context, historyCtrl, record);
                                      if (confirmed == true) {
                                        historyCtrl.deleteRecord(record.id);
                                      }
                                    }
                                  : null,
                            ),
                          );
                        }).toList(),
                      );
                    }),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }
}
