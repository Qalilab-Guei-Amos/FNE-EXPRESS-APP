import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import '../../controllers/history_controller.dart';
import '../../controllers/settings_controller.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive.dart';
import '../../models/fne_record.dart';
import '../history/history_screen.dart';
import '../fne_result/fne_pdf_view_screen.dart';
import '../fne_result/fne_web_view_screen.dart';
import 'components/dashboard_header.dart';
import 'components/stats_row.dart';
import 'components/fne_card.dart';
import 'components/home_empty_state.dart';

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

            // ── Section Metrics & Activités ──────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: R.hPad(context)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    StatsRow(historyCtrl: historyCtrl),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Dernières Activités',
                          style: TextStyle(
                            fontSize: R.fs(context, 16),
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textDark,
                          ),
                        ),
                        TextButton(
                          onPressed: () => Get.to(() => const HistoryScreen()),
                          child: Text(
                            'TOUT VOIR',
                            style: TextStyle(
                              fontSize: R.fs(context, 11),
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                              color: AppTheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),

            // ── Liste d'Activités ───────────────────────────────
            Obx(() {
              final records = historyCtrl.records.take(6).toList();
              if (records.isEmpty) {
                return const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                    child: HomeEmptyState(),
                  ),
                );
              }

              final isTablet = R.isTablet(context);
              final columns = isTablet ? 3 : 1;

              if (isTablet) {
                return SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: R.hPad(context)),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                      (ctx, i) => FneCard(
                        record: records[i],
                        onTap: () => _openRecord(records[i]),
                      ),
                      childCount: records.length,
                    ),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
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
                      vertical: 6,
                    ),
                    child: FneCard(
                      record: records[i],
                      onTap: () => _openRecord(records[i]),
                    ),
                  ),
                  childCount: records.length,
                ),
              );
            }),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  void _openRecord(FneRecord record) {
    final localPath = record.pdfPath;
    if (localPath != null && localPath.isNotEmpty && File(localPath).existsSync()) {
      Get.to(() => FnePdfViewScreen(path: localPath));
      return;
    }
    if (record.qrCode != null && record.qrCode!.isNotEmpty) {
      Get.to(() => FneWebViewScreen(url: record.qrCode!, recordId: record.id));
    } else {
      Get.snackbar(
        'Indisponible',
        'Aucun lien de vérification pour cette FNE',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
