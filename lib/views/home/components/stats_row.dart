import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../controllers/history_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/responsive.dart';

class StatsRow extends StatelessWidget {
  final HistoryController historyCtrl;
  const StatsRow({super.key, required this.historyCtrl});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final caMonth = historyCtrl.caThisMonth;
      final caWeek = historyCtrl.caThisWeek;
      final certified = historyCtrl.countCertifiee;
      final failed = historyCtrl.countEchec;
      final bars = historyCtrl.activityLast7Days;

      return Column(
        children: [
          // ── KPI principale ────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.primary, AppTheme.primaryLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primary.withValues(alpha: 0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.trending_up,
                        color: Colors.white70, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      'Chiffre d\'affaire certifié ce mois',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: R.fs(context, 12),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  AppFormatters.currency(caMonth),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: R.fs(context, 26),
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _KpiChip(
                      label: 'Cette semaine',
                      value: AppFormatters.currency(caWeek),
                      icon: Icons.calendar_view_week,
                    ),
                    const SizedBox(width: 12),
                    _KpiChip(
                      label: 'Certifiées',
                      value: '$certified',
                      icon: Icons.verified_outlined,
                      color: Colors.greenAccent,
                    ),
                    const SizedBox(width: 12),
                    _KpiChip(
                      label: 'Échecs',
                      value: '$failed',
                      icon: Icons.error_outline,
                      color: Colors.red.shade100,
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── Histogramme 7 jours ───────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Activité (7 derniers jours)',
                  style: TextStyle(
                    fontSize: R.fs(context, 13),
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 12),
                _BarChart(bars: bars),
              ],
            ),
          ),
        ],
      );
    });
  }
}

class _KpiChip extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _KpiChip({
    required this.label,
    required this.value,
    required this.icon,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.25),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                color: Colors.white,
                fontSize: R.fs(context, 12),
                fontWeight: FontWeight.w800,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: R.fs(context, 9.5),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
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

    return SizedBox(
      height: R.isTablet(context) ? 110 : 80,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(7, (i) {
          final val = bars[i];
          final ratio = maxVal > 0 ? val / maxVal : 0.0;
          final isToday = i == 6;

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Valeur au-dessus si > 0
                  if (val > 0)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 3),
                      child: Text(
                        _shortCurrency(val),
                        style: TextStyle(
                          fontSize: R.fs(context, 8),
                          color: AppTheme.textGrey,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  // Barre
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeOut,
                    height: val > 0
                        ? (ratio * (R.isTablet(context) ? 65.0 : 48.0))
                            .clamp(6.0, R.isTablet(context) ? 65.0 : 48.0)
                        : 4,
                    decoration: BoxDecoration(
                      color: isToday
                          ? AppTheme.primary
                          : val > 0
                              ? AppTheme.primary.withValues(alpha: 0.4)
                              : AppTheme.divider,
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(4)),
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Label jour
                  Text(
                    dayLabels[i],
                    style: TextStyle(
                      fontSize: R.fs(context, 9),
                      color: isToday ? AppTheme.primary : AppTheme.textGrey,
                      fontWeight:
                          isToday ? FontWeight.w700 : FontWeight.normal,
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
