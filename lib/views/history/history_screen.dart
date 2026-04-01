import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/history_controller.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive.dart';
import '../../models/fne_record.dart';
import '../../services/export_service.dart';
import 'components/mobile_list.dart';
import 'components/tablet_grid.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(HistoryController(), tag: 'history_screen');

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Historique FNE',
              style: TextStyle(fontSize: R.fs(context, 18))),
          actions: [
            Obx(() {
              final hasFilters = ctrl.filterPeriod.value != 'all' ||
                  ctrl.searchQuery.value.isNotEmpty;
              if (!hasFilters) return const SizedBox.shrink();
              return TextButton.icon(
                onPressed: ctrl.resetFilters,
                icon: const Icon(Icons.filter_alt_off,
                    size: 16, color: Colors.white),
                label: const Text('Réinitialiser',
                    style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w600)),
              );
            }),
            PopupMenuButton<String>(
              icon: const Icon(Icons.download_outlined, color: Colors.white),
              tooltip: 'Exporter',
              onSelected: (value) {
                final allFiltered =
                    ctrl.filteredRecordsByStatus(FneStatus.certifiee);
                final export = Get.find<ExportService>();
                if (value == 'pdf') {
                  export.exportReportPdf(allFiltered, title: 'Rapport FNE');
                } else if (value == 'csv') {
                  export.exportCsv(allFiltered);
                }
              },
              itemBuilder: (_) => const [
                PopupMenuItem(
                  value: 'pdf',
                  child: Row(children: [
                    Icon(Icons.picture_as_pdf_outlined,
                        size: 18, color: Colors.black),
                    SizedBox(width: 10),
                    Text('Export PDF'),
                  ]),
                ),
                PopupMenuItem(
                  value: 'csv',
                  child: Row(children: [
                    Icon(Icons.table_chart_outlined,
                        size: 18, color: Colors.black),
                    SizedBox(width: 10),
                    Text('Export CSV'),
                  ]),
                ),
              ],
            ),
            SizedBox(width: R.hPad(context) - 16),
          ],
          bottom: TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white60,
            labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
            unselectedLabelStyle: const TextStyle(fontSize: 13),
            tabs: [
              Obx(() => Tab(text: 'Certifiées (${ctrl.filteredRecordsByStatus(FneStatus.certifiee).length})')),
              Obx(() => Tab(text: 'Brouillons (${ctrl.filteredRecordsByStatus(FneStatus.brouillon).length})')),
              Obx(() => Tab(text: 'Échecs (${ctrl.filteredRecordsByStatus(FneStatus.echec).length})')),
            ],
          ),
        ),
        body: Column(
          children: [
            // ── Recherche + bouton filtre période ──────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(
                  R.hPad(context), 12, R.hPad(context), 0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: ctrl.searchCtrl,
                      decoration: InputDecoration(
                        hintText: 'Rechercher un client, un montant…',
                        hintStyle: TextStyle(
                            fontSize: R.fs(context, 13),
                            color: AppTheme.textGrey),
                        prefixIcon: const Icon(Icons.search,
                            color: AppTheme.textGrey),
                        suffixIcon: Obx(() =>
                            ctrl.searchQuery.value.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.close,
                                        size: 18, color: AppTheme.textGrey),
                                    onPressed: ctrl.searchCtrl.clear,
                                  )
                                : const SizedBox.shrink()),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Obx(() {
                    final active = ctrl.filterPeriod.value != 'all';
                    return GestureDetector(
                      onTap: () => _showPeriodDialog(context, ctrl),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: active ? AppTheme.primary : Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: active
                                ? AppTheme.primary
                                : AppTheme.divider,
                            width: 1.2,
                          ),
                        ),
                        child: Icon(
                          Icons.tune_rounded,
                          size: 20,
                          color: active ? Colors.white : AppTheme.textGrey,
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 6),
            // ── Filtre actif ────────────────────────────────────────
            Obx(() {
              final period = ctrl.filterPeriod.value;
              final customStart = ctrl.customStart.value;
              final customEnd = ctrl.customEnd.value;
              if (period == 'all') return const SizedBox(height: 8);
              final String label;
              switch (period) {
                case 'today':
                  label = "Aujourd'hui";
                  break;
                case 'week':
                  label = 'Cette semaine';
                  break;
                case 'month':
                  label = 'Ce mois';
                  break;
                case 'custom':
                  if (customStart != null) {
                    final s =
                        '${customStart.day.toString().padLeft(2, '0')}/${customStart.month.toString().padLeft(2, '0')}';
                    final e = customEnd ?? DateTime.now();
                    final eStr =
                        '${e.day.toString().padLeft(2, '0')}/${e.month.toString().padLeft(2, '0')}';
                    label = '$s – $eStr';
                  } else {
                    label = 'Plage libre';
                  }
                  break;
                default:
                  label = period;
              }
              return Padding(
                padding: EdgeInsets.fromLTRB(R.hPad(context), 6, R.hPad(context), 2),
                child: Row(
                  children: [
                    Icon(Icons.filter_list_rounded,
                        size: 13, color: AppTheme.primary),
                    const SizedBox(width: 5),
                    Text(
                      'Période : $label',
                      style: TextStyle(
                        fontSize: R.fs(context, 11.5),
                        color: AppTheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            }),
            // ── Onglets ────────────────────────────────────────────
            Expanded(
              child: TabBarView(
                children: [
                  _TabContent(ctrl: ctrl, status: FneStatus.certifiee),
                  _TabContent(ctrl: ctrl, status: FneStatus.brouillon),
                  _TabContent(ctrl: ctrl, status: FneStatus.echec),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPeriodDialog(BuildContext context, HistoryController ctrl) {
    showDialog(
      context: context,
      builder: (_) => _PeriodDialog(ctrl: ctrl),
    );
  }
}

// ── Contenu d'un onglet ────────────────────────────────────────────────────────
class _TabContent extends StatelessWidget {
  final HistoryController ctrl;
  final FneStatus status;
  const _TabContent({required this.ctrl, required this.status});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final records = ctrl.filteredRecordsByStatus(status);
      if (records.isEmpty) {
        return _EmptyTab(
          status: status,
          hasFilters: ctrl.filterPeriod.value != 'all' ||
              ctrl.searchQuery.value.isNotEmpty,
        );
      }
      if (R.isTablet(context)) {
        return HistoryTabletGrid(ctrl: ctrl, records: records);
      }
      return HistoryMobileList(ctrl: ctrl, records: records);
    });
  }
}

// ── État vide par onglet ───────────────────────────────────────────────────────
class _EmptyTab extends StatelessWidget {
  final FneStatus status;
  final bool hasFilters;
  const _EmptyTab({required this.status, required this.hasFilters});

  @override
  Widget build(BuildContext context) {
    final IconData icon;
    final String message;
    if (hasFilters) {
      icon = Icons.search_off;
      message = 'Aucune FNE ne correspond\nà vos critères';
    } else {
      switch (status) {
        case FneStatus.certifiee:
          icon = Icons.verified_outlined;
          message = 'Aucune FNE certifiée';
          break;
        case FneStatus.brouillon:
          icon = Icons.edit_note_outlined;
          message = 'Aucun brouillon';
          break;
        case FneStatus.echec:
          icon = Icons.error_outline;
          message = 'Aucun échec enregistré';
          break;
      }
    }
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon,
              size: R.icon(context, 72),
              color: Colors.grey.withValues(alpha: 0.3)),
          SizedBox(height: R.gap(context)),
          Text(
            message,
            textAlign: TextAlign.center,
            style:
                TextStyle(color: Colors.grey, fontSize: R.fs(context, 15)),
          ),
        ],
      ),
    );
  }
}

// ── Dialog filtre période ──────────────────────────────────────────────────────
class _PeriodDialog extends StatelessWidget {
  final HistoryController ctrl;
  const _PeriodDialog({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filtrer par période',
              style: TextStyle(
                fontSize: R.fs(context, 16),
                fontWeight: FontWeight.w800,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 16),
            Obx(() => Column(
                  children: [
                    _PeriodOption(
                      label: 'Tout',
                      icon: Icons.list_alt_outlined,
                      selected: ctrl.filterPeriod.value == 'all',
                      onTap: () {
                        ctrl.filterPeriod.value = 'all';
                        Get.back();
                      },
                    ),
                    _PeriodOption(
                      label: "Aujourd'hui",
                      icon: Icons.today_outlined,
                      selected: ctrl.filterPeriod.value == 'today',
                      onTap: () {
                        ctrl.filterPeriod.value = 'today';
                        Get.back();
                      },
                    ),
                    _PeriodOption(
                      label: 'Cette semaine',
                      icon: Icons.calendar_view_week_outlined,
                      selected: ctrl.filterPeriod.value == 'week',
                      onTap: () {
                        ctrl.filterPeriod.value = 'week';
                        Get.back();
                      },
                    ),
                    _PeriodOption(
                      label: 'Ce mois',
                      icon: Icons.calendar_month_outlined,
                      selected: ctrl.filterPeriod.value == 'month',
                      onTap: () {
                        ctrl.filterPeriod.value = 'month';
                        Get.back();
                      },
                    ),
                    _PeriodOption(
                      label: 'Plage libre',
                      icon: Icons.date_range_outlined,
                      selected: ctrl.filterPeriod.value == 'custom',
                      subtitle: ctrl.filterPeriod.value == 'custom' &&
                              ctrl.customStart.value != null
                          ? '${_fmt(ctrl.customStart.value!)} – ${_fmt(ctrl.customEnd.value ?? DateTime.now())}'
                          : null,
                      onTap: () async {
                        Get.back();
                        final range = await showDateRangePicker(
                          context: context,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                          locale: const Locale('fr', 'FR'),
                          initialDateRange: ctrl.customStart.value != null
                              ? DateTimeRange(
                                  start: ctrl.customStart.value!,
                                  end: ctrl.customEnd.value ?? DateTime.now())
                              : null,
                          builder: (context, child) => Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: const ColorScheme.light(
                                  primary: AppTheme.primary),
                            ),
                            child: child!,
                          ),
                        );
                        if (range != null) {
                          ctrl.customStart.value = range.start;
                          ctrl.customEnd.value = range.end;
                          ctrl.filterPeriod.value = 'custom';
                        }
                      },
                    ),
                  ],
                )),
          ],
        ),
      ),
    );
  }

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}';
}

// ── Option période ─────────────────────────────────────────────────────────────
class _PeriodOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final String? subtitle;
  final VoidCallback onTap;

  const _PeriodOption({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    const color = AppTheme.primary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: selected
              ? color.withValues(alpha: 0.08)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected
                ? color.withValues(alpha: 0.4)
                : AppTheme.divider,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon,
                size: 20,
                color: selected ? color : AppTheme.textGrey),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: R.fs(context, 14),
                      fontWeight:
                          selected ? FontWeight.w700 : FontWeight.normal,
                      color: selected ? color : AppTheme.textDark,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: TextStyle(
                          fontSize: R.fs(context, 11),
                          color: AppTheme.textGrey),
                    ),
                ],
              ),
            ),
            if (selected)
              const Icon(Icons.check_circle, size: 18, color: color),
          ],
        ),
      ),
    );
  }
}
