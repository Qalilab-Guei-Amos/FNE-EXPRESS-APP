import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/acquisition_controller.dart';
import '../../core/theme/app_theme.dart';
import 'components/import_view.dart';
import 'components/preview_view.dart';

class AcquisitionScreen extends StatelessWidget {
  const AcquisitionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(AcquisitionController());

    return Scaffold(
      appBar: AppBar(
        title: Text('Importer une Facture',
            style: TextStyle(fontSize: 18)),
      ),
      body: Obx(() {
        if (ctrl.isLoading.value) {
          return const Center(
              child: CircularProgressIndicator(color: AppTheme.primary));
        }
        if (ctrl.hasFile) return PreviewView(ctrl: ctrl);
        return ImportView(ctrl: ctrl);
      }),
    );
  }
}
