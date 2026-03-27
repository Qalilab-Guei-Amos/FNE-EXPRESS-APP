import 'package:get/get.dart';
import '../models/fne_record.dart';
import '../services/storage_service.dart';
import '../views/acquisition/acquisition_screen.dart';

class HistoryController extends GetxController {
  final RxList<FneRecord> records = <FneRecord>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadRecords();
  }

  void loadRecords() {
    records.value = Get.find<StorageService>().getAllFne();
  }

  void scanNewInvoice() {
    Get.to(() => const AcquisitionScreen());
  }

  Future<void> deleteRecord(String id) async {
    await Get.find<StorageService>().deleteFne(id);
    records.removeWhere((r) => r.id == id);
  }
}
