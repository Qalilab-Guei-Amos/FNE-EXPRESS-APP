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
import 'history_controller.dart';

enum ValidationState { idle, extracting, reviewing, submitting, success, error }

class ValidationController extends GetxController {
  final Rx<ValidationState> state = ValidationState.idle.obs;
  final Rx<ExtractedInvoice?> invoice = Rx<ExtractedInvoice?>(null);
  final RxString errorMessage = ''.obs;
  final Rx<FneRecord?> generatedFne = Rx<FneRecord?>(null);

  // Champs généraux
  late TextEditingController clientNameCtrl;
  late TextEditingController invoiceNumberCtrl;
  late TextEditingController dateCtrl;
  // Champs client requis par l'API FNE
  late TextEditingController clientPhoneCtrl;
  late TextEditingController clientEmailCtrl;
  late TextEditingController clientNccCtrl;
  late TextEditingController rneCtrl;
  // Devise étrangère (B2F)
  late TextEditingController foreignCurrencyRateCtrl;
  final RxString foreignCurrency = ''.obs;
  // Paramètres FNE
  final RxString paymentMethod = 'mobile-money'.obs;
  final RxString template = 'B2B'.obs;
  final RxBool isRne = false.obs;

  // Code TVA global (appliqué à tous les articles par défaut)
  final RxString globalTaxCode = 'TVAD'.obs;

  // Fichier conservé pour relancer l'extraction en cas d'erreur
  File? _lastFile;
  String _lastMimeType = '';
  final RxBool isExtractionError = false.obs;

  // Contrôleurs articles : champs texte
  final itemControllers = <Map<String, TextEditingController>>[].obs;
  final itemTaxCodes = <RxString>[].obs;
  final itemExpanded = <RxBool>[].obs;

  final RxInt currentStep = 0.obs;

  @override
  void onInit() {
    super.onInit();
    clientNameCtrl = TextEditingController();
    invoiceNumberCtrl = TextEditingController();
    dateCtrl = TextEditingController();
    clientPhoneCtrl = TextEditingController();
    clientEmailCtrl = TextEditingController();
    clientNccCtrl = TextEditingController();
    rneCtrl = TextEditingController();
    foreignCurrencyRateCtrl = TextEditingController();
    currentStep.value = 0;
  }

  void nextStep() {
    if (currentStep.value == 0) {
      // Client → Produits : validation des champs client
      if (clientNameCtrl.text.trim().isEmpty) {
        _showError('Veuillez saisir le nom du client.');
        return;
      }
      if (clientPhoneCtrl.text.trim().isEmpty) {
        _showError('Veuillez saisir le numéro de téléphone du client.');
        return;
      }
      if (clientEmailCtrl.text.trim().isEmpty) {
        _showError('Veuillez saisir l\'e-mail du client.');
        return;
      }
      if (template.value == 'B2B' && clientNccCtrl.text.trim().isEmpty) {
        _showError('Le NCC du client est requis pour une facture B2B.');
        return;
      }
      if (isRne.value && rneCtrl.text.trim().isEmpty) {
        _showError('Veuillez saisir le numéro du reçu (RNE).');
        return;
      }
      currentStep.value++;
    }
  }

  void previousStep() {
    if (currentStep.value > 0) {
      currentStep.value--;
    }
  }

  @override
  void onClose() {
    clientNameCtrl.dispose();
    invoiceNumberCtrl.dispose();
    dateCtrl.dispose();
    clientPhoneCtrl.dispose();
    clientEmailCtrl.dispose();
    clientNccCtrl.dispose();
    rneCtrl.dispose();
    foreignCurrencyRateCtrl.dispose();
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
    itemTaxCodes.clear();
    itemExpanded.clear();
  }

  void startManualEntry() {
    _loadInvoice(ExtractedInvoice(items: []));
    state.value = ValidationState.reviewing;
    currentStep.value = 0;
  }

  Future<void> extractFromFile(File file, String mimeType) async {
    _lastFile = file;
    _lastMimeType = mimeType;
    isExtractionError.value = false;
    state.value = ValidationState.extracting;
    errorMessage.value = '';
    currentStep.value = 0;
    try {
      final bytes = await file.readAsBytes();
      final extracted = await Get.find<GeminiService>().extractFromBytes(
        bytes,
        mimeType,
      );
      _loadInvoice(extracted);
      state.value = ValidationState.reviewing;
    } catch (e) {
      isExtractionError.value = true;
      print(e);
      errorMessage.value = 'Erreur d\'extraction';
      state.value = ValidationState.error;
    }
  }

  Future<void> retryExtraction() async {
    if (_lastFile != null) {
      await extractFromFile(_lastFile!, _lastMimeType);
    }
  }

  void _loadInvoice(ExtractedInvoice extracted) {
    invoice.value = extracted;
    clientNameCtrl.text = extracted.clientName ?? '';
    invoiceNumberCtrl.text = extracted.invoiceNumber ?? '';
    clientPhoneCtrl.text = extracted.clientPhone ?? '';
    clientEmailCtrl.text = extracted.clientEmail ?? '';
    clientNccCtrl.text = extracted.clientNcc ?? '';
    rneCtrl.text = extracted.rne ?? '';
    foreignCurrency.value = extracted.foreignCurrency;
    foreignCurrencyRateCtrl.text = extracted.foreignCurrencyRate > 0
        ? extracted.foreignCurrencyRate.toStringAsFixed(0)
        : '';
    paymentMethod.value = extracted.paymentMethod;
    template.value = extracted.template;
    isRne.value = extracted.isRne;
    if (extracted.date != null) {
      final d = extracted.date!;
      dateCtrl.text =
          '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
    } else {
      dateCtrl.text = '';
    }
    _disposeItemControllers();
    // Charger les articles dans l'ordre original
    for (final item in extracted.items) {
      _addItemControllers(item, atTop: false);
    }
  }

  final scrollController = ScrollController();

  void _addItemControllers(InvoiceItem item,
      {bool atTop = true, bool expanded = false}) {
    final controllers = {
      'designation': TextEditingController(text: item.designation),
      'quantity': TextEditingController(
          text: item.quantity % 1 == 0
              ? item.quantity.toInt().toString()
              : item.quantity.toString()),
      'unitPrice':
          TextEditingController(text: item.unitPrice.toStringAsFixed(0)),
      'discount': TextEditingController(text: item.discount.toStringAsFixed(0)),
    };

    if (atTop) {
      itemControllers.insert(0, controllers);
      itemTaxCodes.insert(0, (item.taxCode.isNotEmpty ? item.taxCode : globalTaxCode.value).obs);
      itemExpanded.insert(0, expanded.obs);
    } else {
      itemControllers.add(controllers);
      itemTaxCodes.add((item.taxCode.isNotEmpty ? item.taxCode : globalTaxCode.value).obs);
      itemExpanded.add(expanded.obs);
    }
  }

  /// Applique le code TVA global à tous les articles existants.
  void applyGlobalTaxCode(String code) {
    globalTaxCode.value = code;
    for (final rx in itemTaxCodes) {
      rx.value = code;
    }
    _refreshTotals();
  }

  void addItem() {
    final newItem = InvoiceItem(
      designation: '',
      quantity: 1,
      unitPrice: 0,
      discount: 0,
      taxCode: globalTaxCode.value,
    );
    final currentInv = invoice.value;
    if (currentInv == null) {
      invoice.value = ExtractedInvoice(items: [newItem]);
    } else {
      currentInv.items.add(newItem);
      invoice.value = _copyInvoice(
        currentInv,
        items: List.from(currentInv.items),
      );
    }
    _addItemControllers(newItem, atTop: false, expanded: true);

    // Scroll vers le bas pour voir le nouvel article
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void removeItem(int index) {
    final currentInv = invoice.value;
    if (currentInv == null || index >= currentInv.items.length) return;
    currentInv.items.removeAt(index);
    final ctrlMap = itemControllers.removeAt(index);
    for (final c in ctrlMap.values) {
      c.dispose();
    }
    itemTaxCodes.removeAt(index);
    if (index < itemExpanded.length) itemExpanded.removeAt(index);
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
      discount: double.tryParse(ctrls['discount']!.text) ?? 0,
      taxCode: index < itemTaxCodes.length ? itemTaxCodes[index].value : 'TVA',
    );
    _refreshTotals();
  }

  void _refreshTotals() {
    final inv = invoice.value;
    if (inv == null) return;
    invoice.value = _copyInvoice(inv, items: List.from(inv.items));
  }

  ExtractedInvoice _copyInvoice(
    ExtractedInvoice inv, {
    List<InvoiceItem>? items,
  }) {
    return ExtractedInvoice(
      clientName: inv.clientName,
      date: inv.date,
      invoiceNumber: inv.invoiceNumber,
      items: items ?? inv.items,
      tvaRate: inv.tvaRate,
      priceType: inv.priceType,
      paymentMethod: inv.paymentMethod,
      template: inv.template,
      clientPhone: inv.clientPhone,
      clientEmail: inv.clientEmail,
      clientNcc: inv.clientNcc,
      isRne: inv.isRne,
      rne: inv.rne,
      foreignCurrency: inv.foreignCurrency,
      foreignCurrencyRate: inv.foreignCurrencyRate,
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

    for (int i = 0; i < itemControllers.length; i++) {
      updateItemFromControllers(i);
    }

    return ExtractedInvoice(
      clientName: clientNameCtrl.text.trim(),
      date: parsedDate,
      invoiceNumber: invoiceNumberCtrl.text.trim(),
      items: List<InvoiceItem>.from(invoice.value?.items ?? []),
      tvaRate: 0.18,
      paymentMethod: paymentMethod.value,
      template: template.value,
      clientPhone: clientPhoneCtrl.text.trim(),
      clientEmail: clientEmailCtrl.text.trim(),
      clientNcc: clientNccCtrl.text.trim(),
      isRne: isRne.value,
      rne: isRne.value ? rneCtrl.text.trim() : null,
      foreignCurrency: foreignCurrency.value,
      foreignCurrencyRate:
          double.tryParse(foreignCurrencyRateCtrl.text.trim()) ?? 0,
    );
  }

  Future<void> submitAndSign() async {
    final inv = _buildInvoiceFromForm();

    if (inv.items.isEmpty) {
      _showError('Veuillez ajouter au moins un article.');
      return;
    }
    if (inv.clientName == null || inv.clientName!.isEmpty) {
      _showError('Veuillez saisir le nom du client.');
      return;
    }
    if (inv.clientPhone == null || inv.clientPhone!.isEmpty) {
      _showError('Veuillez saisir le numéro de téléphone du client.');
      return;
    }
    if (inv.clientEmail == null || inv.clientEmail!.isEmpty) {
      _showError('Veuillez saisir l\'e-mail du client.');
      return;
    }
    if (inv.template == 'B2B' &&
        (inv.clientNcc == null || inv.clientNcc!.isEmpty)) {
      _showError('Le NCC du client est requis pour une facture B2B.');
      return;
    }
    if (inv.isRne && (inv.rne == null || inv.rne!.isEmpty)) {
      _showError('Veuillez saisir le numéro du reçu (RNE).');
      return;
    }
    if (inv.template == 'B2F' &&
        inv.foreignCurrency.isNotEmpty &&
        inv.foreignCurrencyRate <= 0) {
      _showError(
        'Veuillez saisir le taux de change pour la devise ${inv.foreignCurrency}.',
      );
      return;
    }

    state.value = ValidationState.submitting;
    invoice.value = inv;

    final result = await Get.find<FneApiService>().signInvoice(inv);

    if (result.success) {
      final record = FneRecord(
        id: 'FNE_${DateTime.now().millisecondsSinceEpoch}',
        createdAt: DateTime.now(),
        clientName: inv.clientName ?? 'Client inconnu',
        totalTTC: inv.totalTTC,
        fneNumber: result.fneNumber,
        qrCode: result.qrCode,
        invoice: inv,
      );
      await Get.find<StorageService>().saveFne(record);
      if (Get.isRegistered<HistoryController>()) {
        Get.find<HistoryController>().loadRecords();
      }
      generatedFne.value = record;
      state.value = ValidationState.success;
    } else {
      errorMessage.value =
          result.errorMessage ?? 'Erreur lors de la certification';
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
