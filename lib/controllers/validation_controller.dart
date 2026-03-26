import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toastification/toastification.dart';
import '../models/extracted_invoice.dart';
import '../models/invoice_item.dart';
import '../models/fne_record.dart';
import '../services/gemini_service.dart';
import '../services/fne_api_service.dart';
import '../services/storage_service.dart';

enum ValidationState {
  idle,
  extracting,
  reviewing,
  submittingStep1,
  confirming,
  submittingStep2,
  success,
  error
}

class ValidationController extends GetxController {
  final Rx<ValidationState> state = ValidationState.idle.obs;
  final Rx<ExtractedInvoice?> invoice = Rx<ExtractedInvoice?>(null);
  final RxString errorMessage = ''.obs;
  final RxString draftId = ''.obs;
  final Rx<FneRecord?> generatedFne = Rx<FneRecord?>(null);

  // Form controllers
  late TextEditingController clientNameCtrl;
  late TextEditingController invoiceNumberCtrl;
  late TextEditingController dateCtrl;
  final RxList<Map<String, TextEditingController>> itemControllers =
      <Map<String, TextEditingController>>[].obs;

  @override
  void onInit() {
    super.onInit();
    clientNameCtrl = TextEditingController();
    invoiceNumberCtrl = TextEditingController();
    dateCtrl = TextEditingController();
  }

  @override
  void onClose() {
    clientNameCtrl.dispose();
    invoiceNumberCtrl.dispose();
    dateCtrl.dispose();
    _disposeItemControllers();
    super.onClose();
  }

  void _disposeItemControllers() {
    for (final map in itemControllers) {
      for (final c in map.values) {
        c.dispose();
      }
    }
    itemControllers.clear();
  }

  Future<void> extractFromFile(File file, String mimeType) async {
    state.value = ValidationState.extracting;
    errorMessage.value = '';
    try {
      final bytes = await file.readAsBytes();
      final extracted = await Get.find<GeminiService>().extractFromBytes(bytes, mimeType);
      _loadInvoice(extracted);
      state.value = ValidationState.reviewing;
    } catch (e) {
      errorMessage.value = 'Erreur d\'extraction IA: $e';
      state.value = ValidationState.error;
    }
  }

  void _loadInvoice(ExtractedInvoice extracted) {
    invoice.value = extracted;
    clientNameCtrl.text = extracted.clientName ?? '';
    invoiceNumberCtrl.text = extracted.invoiceNumber ?? '';
    if (extracted.date != null) {
      final d = extracted.date!;
      dateCtrl.text =
          '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
    } else {
      dateCtrl.text = '';
    }
    _disposeItemControllers();
    for (final item in extracted.items) {
      itemControllers.add(_createItemControllers(item));
    }
  }

  Map<String, TextEditingController> _createItemControllers(
      InvoiceItem item) {
    return {
      'designation': TextEditingController(text: item.designation),
      'quantity':
          TextEditingController(text: item.quantity.toString()),
      'unitPrice': TextEditingController(
          text: item.unitPrice.toStringAsFixed(0)),
      'tvaRate': TextEditingController(
          text: (item.tvaRate * 100).toStringAsFixed(0)),
      'discount': TextEditingController(
          text: (item.discount * 100).toStringAsFixed(0)),
    };
  }

  void addItem() {
    final newItem =
        InvoiceItem(designation: '', quantity: 1, unitPrice: 0);
    final currentInv = invoice.value;
    if (currentInv == null) {
      // Create a new invoice if none exists
      invoice.value = ExtractedInvoice(items: [newItem]);
    } else {
      currentInv.items.add(newItem);
      // Trigger refresh
      invoice.value = ExtractedInvoice(
        clientName: currentInv.clientName,
        date: currentInv.date,
        invoiceNumber: currentInv.invoiceNumber,
        items: List.from(currentInv.items),
        tvaRate: currentInv.tvaRate,
      );
    }
    itemControllers.add(_createItemControllers(newItem));
  }

  void removeItem(int index) {
    final currentInv = invoice.value;
    if (currentInv == null || index >= currentInv.items.length) return;
    currentInv.items.removeAt(index);
    final ctrlMap = itemControllers.removeAt(index);
    for (final c in ctrlMap.values) {
      c.dispose();
    }
    _refreshTotals();
  }

  void updateItemFromControllers(int index) {
    final currentInv = invoice.value;
    if (currentInv == null || index >= currentInv.items.length) return;
    final ctrls = itemControllers[index];
    currentInv.items[index] = InvoiceItem(
      designation: ctrls['designation']!.text,
      quantity: double.tryParse(ctrls['quantity']!.text) ?? 0,
      unitPrice: double.tryParse(ctrls['unitPrice']!.text) ?? 0,
      tvaRate: (double.tryParse(ctrls['tvaRate']!.text) ?? 18) / 100,
      discount: (double.tryParse(ctrls['discount']!.text) ?? 0) / 100,
    );
    _refreshTotals();
  }

  void _refreshTotals() {
    final inv = invoice.value;
    if (inv == null) return;
    invoice.value = ExtractedInvoice(
      clientName: inv.clientName,
      date: inv.date,
      invoiceNumber: inv.invoiceNumber,
      items: List.from(inv.items),
      tvaRate: inv.tvaRate,
    );
  }

  ExtractedInvoice _buildInvoiceFromForm() {
    DateTime? parsedDate;
    try {
      final parts = dateCtrl.text.split('/');
      if (parts.length == 3) {
        parsedDate = DateTime(
          int.parse(parts[2]),
          int.parse(parts[1]),
          int.parse(parts[0]),
        );
      }
    } catch (_) {}

    // Sync all controllers to invoice items first
    for (int i = 0; i < itemControllers.length; i++) {
      updateItemFromControllers(i);
    }

    final items = List<InvoiceItem>.from(invoice.value?.items ?? []);

    return ExtractedInvoice(
      clientName: clientNameCtrl.text.trim(),
      date: parsedDate,
      invoiceNumber: invoiceNumberCtrl.text.trim(),
      items: items,
      tvaRate: 0.18,
    );
  }

  Future<void> submitStep1() async {
    final inv = _buildInvoiceFromForm();
    if (inv.items.isEmpty) {
      _showError('Veuillez ajouter au moins un article.');
      return;
    }
    if (inv.clientName == null || inv.clientName!.isEmpty) {
      _showError('Veuillez saisir le nom du client.');
      return;
    }

    state.value = ValidationState.submittingStep1;
    final result = await Get.find<FneApiService>().submitInvoiceStep1(inv);
    if (result.success && result.draftId != null) {
      draftId.value = result.draftId!;
      invoice.value = inv;
      state.value = ValidationState.confirming;
    } else {
      errorMessage.value =
          result.errorMessage ?? 'Erreur lors de la soumission';
      state.value = ValidationState.error;
    }
  }

  Future<void> confirmAndGenerate() async {
    final inv = invoice.value;
    if (inv == null) return;
    state.value = ValidationState.submittingStep2;
    final result =
        await Get.find<FneApiService>().confirmAndGenerateStep2(draftId.value, inv);
    if (result.success) {
      final record = FneRecord(
        id: 'FNE_${DateTime.now().millisecondsSinceEpoch}',
        createdAt: DateTime.now(),
        clientName: inv.clientName ?? 'Client inconnu',
        totalTTC: inv.totalTTC,
        fneNumber: result.fneNumber,
        qrCode: result.qrCode,
        pdfPath: result.pdfUrl,
        invoice: inv,
      );
      await Get.find<StorageService>().saveFne(record);
      generatedFne.value = record;
      state.value = ValidationState.success;
    } else {
      errorMessage.value =
          result.errorMessage ?? 'Erreur lors de la génération';
      state.value = ValidationState.error;
    }
  }

  void resetToReviewing() {
    state.value = ValidationState.reviewing;
    errorMessage.value = '';
  }

  void _showError(String message) {
    toastification.show(
      type: ToastificationType.error,
      title: const Text('Erreur'),
      description: Text(message),
      autoCloseDuration: const Duration(seconds: 4),
    );
  }
}
