import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/history_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/responsive.dart';
import '../../acquisition/acquisition_screen.dart';
import '../../history/history_screen.dart';

class QuickActions extends StatelessWidget {
  final HistoryController historyCtrl;
  const QuickActions({super.key, required this.historyCtrl});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: R.isTablet(context) ? 4.0 : 2.0,
      children: [
        _ActionCard(
          icon: Icons.add_a_photo_rounded,
          label: 'Nouvelle',
          subtitle: 'Certification',
          color: AppTheme.primary,
          onTap: () => Get.to(
            () => const AcquisitionScreen(),
          )?.then((_) => historyCtrl.loadRecords()),
        ),
        _ActionCard(
          icon: Icons.history_rounded,
          label: 'Tout voir',
          subtitle: 'Historique',
          color: AppTheme.accent,
          onTap: () => Get.to(() => const HistoryScreen()),
        ),
      ],
    );
  }
}



class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.divider.withValues(alpha: 0.5)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: R.fs(context, 14),
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: AppTheme.textGrey,
                      fontSize: R.fs(context, 12),
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: AppTheme.textGrey.withValues(alpha: 0.5)),
          ],
        ),
      ),
    );
  }
}
