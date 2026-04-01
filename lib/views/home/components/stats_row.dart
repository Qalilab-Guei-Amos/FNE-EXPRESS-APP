import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../controllers/history_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/responsive.dart';
// import '../../history/history_screen.dart';
// import '../../main_layout.dart';

class StatsRow extends StatelessWidget {
  final HistoryController historyCtrl;
  const StatsRow({super.key, required this.historyCtrl});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final caToday = historyCtrl.caToday;
      final caWeek = historyCtrl.caThisWeek;
      final caMonth = historyCtrl.caThisMonth;
      final bars = historyCtrl.activityLast7Days;

      return Column(
        children: [
          // ── Carte CA Mensuel (Nouveau Design) ─────────────────────
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primary,
                  AppTheme.primary.withValues(alpha: 0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primary.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Cercles décoratifs (Glassmorphism effect)
                Positioned(
                  right: -30,
                  top: -30,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                ),
                Positioned(
                  right: 40,
                  bottom: -40,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.05),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.account_balance_wallet_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Revenus du jour',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  fontSize: R.fs(context, 14),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              "Aujourd'hui",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: R.fs(context, 10),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        AppFormatters.currency(caToday),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: R.fs(context, 30),
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _InlineStat(
                              title: 'Cette semaine',
                              value: AppFormatters.currency(caWeek),
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 24,
                            color: Colors.white.withValues(alpha: 0.2),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 16),
                              child: _InlineStat(
                                title: 'Ce mois',
                                value: AppFormatters.currency(caMonth),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ── BOUTON ACCÈS HISTORIQUE (Nouveau Emplacement) ─────────
          /*GestureDetector(
            onTap: () {
              if (Get.isRegistered<MainLayoutController>()) {
                Get.find<MainLayoutController>().changeTab(1); // Basculer sur l'onglet Historique
              } else {
                Get.to(() => const HistoryScreen()); // Sécurité si pas de layout
              }
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
                border: Border.all(color: AppTheme.primary.withValues(alpha: 0.1)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.history_edu_rounded,
                      color: AppTheme.primary,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Historique Complet',
                          style: TextStyle(
                            color: AppTheme.textDark,
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          'Gérer & Imprimer vos factures certifiées',
                          style: TextStyle(
                            color: AppTheme.textGrey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: AppTheme.textGrey,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),*/
          const SizedBox(height: 20),

          // ── Histogramme 7 jours ───────────────────────────────────
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
              border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Activité (7 derniers jours)',
                      style: TextStyle(
                        fontSize: R.fs(context, 14),
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textDark,
                      ),
                    ),
                    Icon(
                      Icons.bar_chart_rounded,
                      color: AppTheme.textGrey.withValues(alpha: 0.5),
                      size: 20,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _BarChart(bars: bars),
              ],
            ),
          ),
        ],
      );
    });
  }
}

class _InlineStat extends StatelessWidget {
  final String title;
  final String value;

  const _InlineStat({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: R.fs(context, 11.5),
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: R.fs(context, 15),
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _BarChart extends StatelessWidget {
  final List<double> bars;
  const _BarChart({required this.bars});

  @override
  Widget build(BuildContext context) {
    final maxVal = bars.reduce((a, b) => a > b ? a : b);
    final now = DateTime.now();
    final dayLabels = List.generate(7, (i) {
      final d = now.subtract(Duration(days: 6 - i));
      return DateFormat('E', 'fr_FR').format(d).substring(0, 2);
    });
    final maxBar = R.isTablet(context) ? 80.0 : 55.0;

    return SizedBox(
      height: R.isTablet(context) ? 140 : 110,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(7, (i) {
          final val = bars[i];
          final ratio = maxVal > 0 ? val / maxVal : 0.0;
          final isToday = i == 6;

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (val > 0)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(
                        _shortCurrency(val),
                        style: TextStyle(
                          fontSize: R.fs(context, 9),
                          color: isToday ? AppTheme.primary : AppTheme.textGrey,
                          fontWeight: isToday
                              ? FontWeight.w800
                              : FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.fastLinearToSlowEaseIn,
                    height: val > 0 ? (ratio * maxBar).clamp(8.0, maxBar) : 6,
                    decoration: BoxDecoration(
                      gradient: isToday
                          ? LinearGradient(
                              colors: [
                                AppTheme.primary,
                                AppTheme.primary.withValues(alpha: 0.6),
                              ],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            )
                          : null,
                      color: isToday
                          ? null
                          : val > 0
                          ? AppTheme.primary.withValues(alpha: 0.2)
                          : Colors.grey.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    dayLabels[i].capitalizeFirst ?? dayLabels[i],
                    style: TextStyle(
                      fontSize: R.fs(context, 10),
                      color: isToday ? AppTheme.primary : AppTheme.textGrey,
                      fontWeight: isToday ? FontWeight.w800 : FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  String _shortCurrency(double v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(0)}k';
    return v.toStringAsFixed(0);
  }
}
