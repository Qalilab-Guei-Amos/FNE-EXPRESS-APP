import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/history_controller.dart';
import '../../../core/utils/responsive.dart';
import '../../../models/fne_record.dart';
import '../../fne_result/fne_pdf_view_screen.dart';
import '../../fne_result/fne_web_view_screen.dart';
import 'history_card.dart';
import 'delete_dialog.dart';

class HistoryTabletGrid extends StatelessWidget {
  final HistoryController ctrl;
  const HistoryTabletGrid({super.key, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.all(R.hPad(context)),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: R.cols(context),
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: R.isLargeTablet(context) ? 2.6 : 2.2,
      ),
      itemCount: ctrl.records.length,
      itemBuilder: (context, index) {
        final record = ctrl.records[index];
        return HistoryCard(
          record: record,
          onTap: () => openRecord(record),
          onDelete: () => showDeleteDialog(context, ctrl, record.id),
        );
      },
    );
  }
}

void openRecord(FneRecord record) {
  // PDF local disponible → visionneuse directe
  final localPath = record.pdfPath;
  if (localPath != null && localPath.isNotEmpty && File(localPath).existsSync()) {
    Get.to(() => FnePdfViewScreen(path: localPath));
    return;
  }
  // Fallback : WebView pour télécharger le PDF
  if (record.qrCode != null && record.qrCode!.isNotEmpty) {
    Get.to(() => FneWebViewScreen(url: record.qrCode!, recordId: record.id));
  } else {
    Get.snackbar('Indisponible', 'Aucun lien de vérification pour cette FNE',
        snackPosition: SnackPosition.BOTTOM);
  }
}
