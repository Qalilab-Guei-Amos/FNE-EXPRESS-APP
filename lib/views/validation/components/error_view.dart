import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/validation_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/responsive.dart';

class ErrorView extends StatelessWidget {
  final ValidationController ctrl;
  const ErrorView({super.key, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(R.hPad(context)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline,
                size: R.icon(context, 80), color: Colors.red),
            SizedBox(height: R.gap(context)),
            Text(
              'Une erreur est survenue',
              style: TextStyle(
                fontSize: R.fs(context, 20),
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: R.gap(context) * 0.7),
            Obx(() => Text(
                  ctrl.errorMessage.value,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: R.fs(context, 14),
                    color: AppTheme.textGrey,
                  ),
                )),
            SizedBox(height: R.gap(context) * 1.5),
            Obx(() {
              final isExtraction = ctrl.isExtractionError.value;
              return ElevatedButton.icon(
                onPressed: isExtraction
                    ? ctrl.retryExtraction
                    : ctrl.resetToReviewing,
                icon: Icon(Icons.refresh, size: R.icon(context, 20)),
                label: Text(
                  isExtraction ? 'Réessayer l\'extraction' : 'Corriger les données',
                  style: TextStyle(fontSize: R.fs(context, 15)),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
