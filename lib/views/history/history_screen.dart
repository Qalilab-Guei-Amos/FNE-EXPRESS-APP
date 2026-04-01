import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/history_controller.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/responsive.dart';
import '../../models/fne_record.dart';
import '../../services/export_service.dart';
import 'components/mobile_list.dart';
import 'components/tablet_grid.dart';
import '../../controllers/auth_controller.dart';
import '../auth/auth_screen.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.isRegistered<HistoryController>()
        ? Get.find<HistoryController>()
        : Get.put(HistoryController());
    final bool isTablet = R.isTablet(context);

    // Sur tablette, on utilise le DefaultTabController du MainLayout.
    // Sur mobile, on en crée un local pour l'AppBar.
    final Widget content = Scaffold(
      backgroundColor: AppTheme.background,
      appBar: isTablet
          ? null
          : AppBar(
              automaticallyImplyLeading: false,
              elevation: 0,
              backgroundColor: AppTheme.primary,
              title: Text(
                'Historique des factures',
                style: TextStyle(fontSize: R.fs(context, 18)),
              ),
              toolbarHeight: 64,
              actions: [
                _buildHeaderActions(ctrl, context),
                SizedBox(width: R.hPad(context) - 16),
              ],
              bottom: _buildTabBar(ctrl),
            ),
      body: Column(
        children: [
          // ── Recherche + bouton filtre période ──────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(
              R.hPad(context),
              16,
              R.hPad(context),
              0,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: ctrl.searchCtrl,
                      decoration: InputDecoration(
                        hintText: 'Rechercher un client, un montant…',
                        hintStyle: TextStyle(
                          fontSize: R.fs(context, 13),
                          color: AppTheme.textGrey,
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: AppTheme.textGrey,
                        ),
                        suffixIcon: Obx(
                          () => ctrl.searchQuery.value.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(
                                    Icons.close,
                                    size: 18,
                                    color: AppTheme.textGrey,
                                  ),
                                  onPressed: ctrl.searchCtrl.clear,
                                )
                              : const SizedBox.shrink(),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                      ),
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
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: active ? AppTheme.primary : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                          ),
                        ],
                        border: Border.all(
                          color: active ? AppTheme.primary : AppTheme.divider,
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
                const SizedBox(width: 8),
                PopupMenuButton<String>(
                  tooltip: 'Exporter',
                  offset: const Offset(0, 50),
                  onSelected: (value) {
                    final allFiltered = ctrl.filteredRecordsByStatus(
                      FneStatus.certifiee,
                    );
                    final export = Get.find<ExportService>();
                    if (value == 'pdf') {
                      export.exportReportPdf(
                        allFiltered, 
                        title: 'RAPPORT FINANCIER', 
                        period: ctrl.currentPeriodLabel,
                        landscape: true,
                      );
                    } else if (value == 'csv') {
                      export.exportCsv(allFiltered, period: ctrl.currentPeriodLabel);
                    }
                  },
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      value: 'pdf', 
                      child: Row(
                        children: [
                          const Icon(Icons.picture_as_pdf_outlined, color: AppTheme.primary, size: 20),
                          const SizedBox(width: 12),
                          const Text('Exporter en PDF'),
                        ],
                      )
                    ),
                    PopupMenuItem(
                      value: 'csv', 
                      child: Row(
                        children: [
                           Icon(Icons.table_chart_outlined, color: Colors.blue[700], size: 20),
                           const SizedBox(width: 12),
                           const Text('Exporter en Excel'),
                        ],
                      )
                    ),
                  ],
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                        ),
                      ],
                      border: Border.all(
                        color: AppTheme.divider,
                        width: 1.2,
                      ),
                    ),
                    child: const Icon(
                      Icons.download_rounded,
                      size: 20,
                      color: AppTheme.textGrey,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Filtre actif (Label) ───────────────────────────
          Obx(() {
            final period = ctrl.filterPeriod.value;
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
                if (ctrl.customStart.value != null) {
                  final s =
                      '${ctrl.customStart.value!.day.toString().padLeft(2, '0')}/${ctrl.customStart.value!.month.toString().padLeft(2, '0')}';
                  final e = ctrl.customEnd.value ?? DateTime.now();
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
              padding: EdgeInsets.fromLTRB(
                R.hPad(context),
                6,
                R.hPad(context),
                2,
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.filter_list_rounded,
                    size: 13,
                    color: AppTheme.primary,
                  ),
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

          // ── Chiffre d'affaires certifié ─────────────────────
          Obx(() {
            final ca = ctrl.filteredCertifiedCa;
            return Container(
              margin: EdgeInsets.fromLTRB(
                R.hPad(context),
                4,
                R.hPad(context),
                2,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppTheme.primary.withValues(alpha: 0.15),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.payments_outlined,
                    size: 15,
                    color: AppTheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'CA certifié filtré',
                    style: TextStyle(
                      fontSize: R.fs(context, 12),
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    AppFormatters.currency(ca),
                    style: TextStyle(
                      fontSize: R.fs(context, 13.5),
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            );
          }),

          // ── Listes par onglets ────────────────────────────
          Expanded(
            child: TabBarView(
              children: [
                _TabContent(
                  ctrl: ctrl,
                  status: FneStatus.certifiee,
                  isTablet: isTablet,
                ),
                _TabContent(
                  ctrl: ctrl,
                  status: FneStatus.brouillon,
                  isTablet: isTablet,
                ),
                _TabContent(
                  ctrl: ctrl,
                  status: FneStatus.echec,
                  isTablet: isTablet,
                ),
              ],
            ),
          ),
        ],
      ),
    );

    if (isTablet) return content;

    return DefaultTabController(length: 3, child: content);
  }

  PreferredSizeWidget _buildTabBar(HistoryController ctrl) {
    return TabBar(
      indicatorColor: Colors.white,
      indicatorWeight: 3,
      labelColor: Colors.white,
      unselectedLabelColor: Colors.white60,
      labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
      tabs: [
        Obx(
          () => Tab(
            text:
                'Certifiées (${ctrl.filteredRecordsByStatus(FneStatus.certifiee).length})',
          ),
        ),
        Obx(
          () => Tab(
            text:
                'Brouillons (${ctrl.filteredRecordsByStatus(FneStatus.brouillon).length})',
          ),
        ),
        Obx(
          () => Tab(
            text:
                'Échecs (${ctrl.filteredRecordsByStatus(FneStatus.echec).length})',
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderActions(HistoryController ctrl, BuildContext context) {
    final authCtrl = Get.isRegistered<AuthController>() ? Get.find<AuthController>() : Get.put(AuthController());
    
    return Row(
      children: [
        Obx(() {
          final bool isLoggedIn = authCtrl.currentUser.value != null;
          return GestureDetector(
            onTap: () => Get.to(() => const AuthScreen()),
            child: Container(
              margin: const EdgeInsets.only(right: 16),
          padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: isLoggedIn 
                    ? Colors.white.withValues(alpha: 0.25)
                    : Colors.white.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(
                    color: isLoggedIn ? Colors.white : Colors.white.withValues(alpha: 0.3),
                    width: isLoggedIn ? 1.5 : 1),
              ),
              child: Icon(
                isLoggedIn ? Icons.cloud_done_rounded : Icons.cloud_off_rounded,
                color: isLoggedIn ? Colors.white : Colors.white.withValues(alpha: 0.6), 
                size: 18
              ),
            ),
          );
        }),
      ],
    );
  }

  void _showPeriodDialog(BuildContext context, HistoryController ctrl) {
    showDialog(
      context: context,
      builder: (_) => _PeriodDialog(ctrl: ctrl),
    );
  }
}

class _TabContent extends StatelessWidget {
  final HistoryController ctrl;
  final FneStatus status;
  final bool isTablet;
  const _TabContent({
    required this.ctrl,
    required this.status,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final records = ctrl.filteredRecordsByStatus(status);
      if (records.isEmpty) {
        return _EmptyTab(
          status: status,
          hasFilters:
              ctrl.filterPeriod.value != 'all' ||
              ctrl.searchQuery.value.isNotEmpty,
        );
      }
      if (isTablet) return HistoryTabletGrid(ctrl: ctrl, records: records);
      return HistoryMobileList(ctrl: ctrl, records: records);
    });
  }
}

class _EmptyTab extends StatelessWidget {
  final FneStatus status;
  final bool hasFilters;
  const _EmptyTab({required this.status, required this.hasFilters});

  @override
  Widget build(BuildContext context) {
    IconData icon = Icons.inventory_2_outlined;
    String msg = 'Aucune facture trouvée';
    if (hasFilters) {
      icon = Icons.search_off_rounded;
      msg = 'Aucun résultat pour ces filtres';
    }
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          Text(msg, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}

class _PeriodDialog extends StatelessWidget {
  final HistoryController ctrl;
  const _PeriodDialog({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filtrer par période',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 20),
            _PeriodOption(
              label: 'Tout',
              icon: Icons.list_alt,
              selected: ctrl.filterPeriod.value == 'all',
              onTap: () {
                ctrl.filterPeriod.value = 'all';
                Get.back();
              },
            ),
            _PeriodOption(
              label: "Aujourd'hui",
              icon: Icons.today,
              selected: ctrl.filterPeriod.value == 'today',
              onTap: () {
                ctrl.filterPeriod.value = 'today';
                Get.back();
              },
            ),
            _PeriodOption(
              label: 'Cette semaine',
              icon: Icons.calendar_view_week,
              selected: ctrl.filterPeriod.value == 'week',
              onTap: () {
                ctrl.filterPeriod.value = 'week';
                Get.back();
              },
            ),
            _PeriodOption(
              label: 'Ce mois',
              icon: Icons.calendar_month,
              selected: ctrl.filterPeriod.value == 'month',
              onTap: () {
                ctrl.filterPeriod.value = 'month';
                Get.back();
              },
            ),
            _PeriodOption(
              label: 'Plage libre',
              icon: Icons.date_range,
              selected: ctrl.filterPeriod.value == 'custom',
              onTap: () {
                Get.back(); // Ferme le dialogue de période
                showDialog(
                  context: context,
                  builder: (_) => _CustomDateRangeDialog(ctrl: ctrl),
                );
              },
            ),
          ],
        ),
      ),
      ),
    );
  }
}

class _CustomDateRangeDialog extends StatefulWidget {
  final HistoryController ctrl;
  const _CustomDateRangeDialog({required this.ctrl});

  @override
  State<_CustomDateRangeDialog> createState() => _CustomDateRangeDialogState();
}

class _CustomDateRangeDialogState extends State<_CustomDateRangeDialog> {
  DateTime? _start;
  DateTime? _end;

  @override
  void initState() {
    super.initState();
    _start = widget.ctrl.customStart.value;
    _end = widget.ctrl.customEnd.value;
  }

  Future<void> _pickDate(bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: (isStart ? _start : _end) ?? DateTime.now(),
      firstDate: DateTime(2026),
      lastDate: DateTime.now(),
      locale: const Locale('fr', 'FR'),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: AppTheme.primary),
        ),
        child: child!,
      ),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _start = picked;
          // Si la fin était avant le nouveau début, on la réinitialise
          if (_end != null && _end!.isBefore(_start!)) _end = null;
        } else {
          _end = picked;
          if (_start != null && _start!.isAfter(_end!)) _start = null;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFFE9EEE8), // Fond vert très clair comme l'image
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Plage de dates',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF1A1C19)),
            ),
            const SizedBox(height: 24),
            
            _DateRow(
              label: 'Date début', 
              date: _start, 
              onTap: () => _pickDate(true)
            ),
            const SizedBox(height: 12),
            _DateRow(
              label: 'Date fin', 
              date: _end, 
              onTap: () => _pickDate(false)
            ),
            
            const SizedBox(height: 32),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Get.back(),
                  child: const Text('Annuler', style: TextStyle(color: Color(0xFF424940), fontWeight: FontWeight.bold, fontSize: 16)),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: (_start != null && _end != null) ? () {
                    widget.ctrl.customStart.value = _start;
                    widget.ctrl.customEnd.value = _end;
                    widget.ctrl.filterPeriod.value = 'custom';
                    Get.back();
                  } : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: AppTheme.primary.withValues(alpha: 0.3),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Appliquer', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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

class _DateRow extends StatelessWidget {
  final String label;
  final DateTime? date;
  final VoidCallback onTap;

  const _DateRow({required this.label, required this.date, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final hasDate = date != null;
    final String dateStr = hasDate 
        ? '${date!.day.toString().padLeft(2, '0')}/${date!.month.toString().padLeft(2, '0')}/${date!.year}'
        : 'Sélectionner';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: hasDate ? AppTheme.primary.withValues(alpha: 0.08) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: hasDate ? AppTheme.primary.withValues(alpha: 0.3) : const Color(0xFFC2C8BC)),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today_outlined, size: 20, color: hasDate ? AppTheme.primary : const Color(0xFF424940)),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF424940))),
                Text(
                  dateStr, 
                  style: TextStyle(
                    fontSize: 16, 
                    fontWeight: FontWeight.w600, 
                    color: hasDate ? AppTheme.primary : const Color(0xFF72796F)
                  )
                ),
              ],
            ),
            const Spacer(),
            Icon(Icons.chevron_right, size: 20, color: hasDate ? AppTheme.primary : const Color(0xFF72796F)),
          ],
        ),
      ),
    );
  }
}

class _PeriodOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  const _PeriodOption({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.primary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: selected ? color : AppTheme.divider),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: selected ? color : AppTheme.textGrey),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                color: selected ? color : AppTheme.textDark,
              ),
            ),
            const Spacer(),
            if (selected) Icon(Icons.check_circle, size: 18, color: color),
          ],
        ),
      ),
    );
  }
}
