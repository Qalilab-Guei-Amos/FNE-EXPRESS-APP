import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import '../../controllers/history_controller.dart';
import '../../controllers/settings_controller.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive.dart';
import 'components/dashboard_header.dart';
import 'components/stats_row.dart';

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
                    const SizedBox(height: 16),
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
