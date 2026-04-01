import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
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
  final RxString defaultPaymentMethod = 'espèces'.obs;
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
    final saved = Get.find<StorageService>().getSettings();
    
    establishmentCtrl.text = saved?.establishment ?? dotenv.env['FNE_ESTABLISHMENT'] ?? 'AMANI DIGITAL SERVICES';
    pointOfSaleCtrl.text = saved?.pointOfSale ?? dotenv.env['FNE_POINT_OF_SALE'] ?? 'PDV-001';
    sellerNameCtrl.text = saved?.sellerName ?? 'Vendeur';
    commercialMessageCtrl.text = saved?.commercialMessage ?? 'Merci de votre confiance. Généré par FNE Express.';
    footerCtrl.text = saved?.footer ?? 'FNE Express System';
    
    defaultPaymentMethod.value = saved?.defaultPaymentMethod ?? 'espèces';
    defaultTemplate.value = saved?.defaultTemplate ?? 'B2B';
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
  }

  bool get isConfigured {
    final saved = Get.find<StorageService>().getSettings();
    final establishment = saved?.establishment ?? dotenv.env['FNE_ESTABLISHMENT'] ?? '';
    final pointOfSale = saved?.pointOfSale ?? dotenv.env['FNE_POINT_OF_SALE'] ?? '';
    return establishment.isNotEmpty && pointOfSale.isNotEmpty;
  }
}
