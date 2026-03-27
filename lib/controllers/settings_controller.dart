import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:toastification/toastification.dart';
import 'package:flutter/material.dart';
import '../models/app_settings.dart';
import '../services/storage_service.dart';

class SettingsController extends GetxController {
  // Identité du vendeur
  late TextEditingController establishmentCtrl;
  late TextEditingController pointOfSaleCtrl;
  late TextEditingController sellerNameCtrl;
  // Personnalisation facture
  late TextEditingController commercialMessageCtrl;
  late TextEditingController footerCtrl;
  // Préférences par défaut
  final RxString defaultPaymentMethod = 'mobile-money'.obs;
  final RxString defaultTemplate = 'B2B'.obs;

  @override
  void onInit() {
    super.onInit();
    establishmentCtrl = TextEditingController();
    pointOfSaleCtrl = TextEditingController();
    sellerNameCtrl = TextEditingController();
    commercialMessageCtrl = TextEditingController();
    footerCtrl = TextEditingController();
    _loadSettings();
  }

  @override
  void onClose() {
    establishmentCtrl.dispose();
    pointOfSaleCtrl.dispose();
    sellerNameCtrl.dispose();
    commercialMessageCtrl.dispose();
    footerCtrl.dispose();
    super.onClose();
  }

  void _loadSettings() {
    establishmentCtrl.text = 'AMANI DIGITAL SERVICES';
    pointOfSaleCtrl.text = 'ABIDJAN_PLATEAU_01';
    sellerNameCtrl.text = 'AMANI';
    commercialMessageCtrl.text = 'Merci de votre confiance. Appli Générée par FNE Express.';
    footerCtrl.text = 'SOCIÉTÉ ANONYME AU CAPITAL DE 10.000.000 FCFA';
    defaultPaymentMethod.value = 'espèces';
    defaultTemplate.value = 'B2B';
  }

  Future<void> save() async {
    final settings = AppSettings(
      establishment: establishmentCtrl.text.trim(),
      pointOfSale: pointOfSaleCtrl.text.trim(),
      sellerName: sellerNameCtrl.text.trim(),
      commercialMessage: commercialMessageCtrl.text.trim(),
      footer: footerCtrl.text.trim(),
      defaultPaymentMethod: defaultPaymentMethod.value,
      defaultTemplate: defaultTemplate.value,
    );
    await Get.find<StorageService>().saveSettings(settings);
    toastification.show(
      type: ToastificationType.success,
      title: const Text('Paramètres sauvegardés'),
      autoCloseDuration: const Duration(seconds: 3),
    );
  }

  bool get isConfigured {
    final saved = Get.find<StorageService>().getSettings();
    final establishment = saved?.establishment.isNotEmpty == true
        ? saved!.establishment
        : dotenv.env['FNE_ESTABLISHMENT'] ?? '';
    final pointOfSale = saved?.pointOfSale.isNotEmpty == true
        ? saved!.pointOfSale
        : dotenv.env['FNE_POINT_OF_SALE'] ?? '';
    return establishment.isNotEmpty &&
        pointOfSale.isNotEmpty &&
        !pointOfSale.contains('YOUR_');
  }
}
