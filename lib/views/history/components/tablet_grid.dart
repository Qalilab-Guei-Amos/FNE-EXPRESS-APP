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
  final List<FneRecord> records;
  const HistoryTabletGrid({super.key, required this.ctrl, required this.records});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.all(R.hPad(context)),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: R.cols(context),
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        mainAxisExtent: R.isLargeTablet(context) ? 195 : 175,
      ),
      itemCount: records.length,
      itemBuilder: (context, index) {
        final record = records[index];
        final canDelete = record.status != FneStatus.certifiee;
        return HistoryCard(
          record: record,
          onTap: () => openRecord(record, ctrl),
          onDelete: canDelete
              ? () async {
                  final confirmed =
                      await showDeleteDialog(context, ctrl, record);
                  if (confirmed == true) ctrl.deleteRecord(record.id);
                }
              : null,
        );
      },
    );
  }
}

void openRecord(FneRecord record, HistoryController ctrl) {
  // Brouillon ou échec → retour au formulaire de validation
  if (record.status == FneStatus.brouillon ||
      record.status == FneStatus.echec) {
    ctrl.retryRecord(record);
    return;
  }

  // PDF local disponible → visionneuse directe
  final localPath = record.pdfPath;
  if (localPath != null &&
      localPath.isNotEmpty &&
      File(localPath).existsSync()) {
    Get.to(() => FnePdfViewScreen(path: localPath, fromHistory: true));
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
