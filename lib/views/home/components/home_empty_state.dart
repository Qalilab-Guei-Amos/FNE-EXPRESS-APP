import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/responsive.dart';

class HomeEmptyState extends StatelessWidget {
  const HomeEmptyState({super.key});

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
