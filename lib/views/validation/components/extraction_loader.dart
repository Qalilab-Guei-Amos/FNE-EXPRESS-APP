import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/responsive.dart';

class ExtractionLoader extends StatelessWidget {
  const ExtractionLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(R.hPad(context)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: R.icon(context, 100),
              height: R.icon(context, 100),
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: CircularProgressIndicator(
                    color: AppTheme.primary,
                    strokeWidth: R.isTablet(context) ? 4 : 3),
              ),
            ),
            SizedBox(height: R.gap(context) * 1.5),
            Text(
              'Analyse en cours',
              style: TextStyle(
                fontSize: R.fs(context, 20),
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: R.gap(context) * 0.6),
            Text(
              'Extraction des données\nde votre facture...',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: R.fs(context, 15),
                color: AppTheme.textGrey.withValues(alpha: 0.8),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
