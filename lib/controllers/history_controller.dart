import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toastification/toastification.dart';
import '../models/fne_record.dart';
import '../services/storage_service.dart';
import '../services/supabase_service.dart';
import '../views/acquisition/acquisition_screen.dart';
import '../views/validation/validation_screen.dart';
import 'validation_controller.dart';

class HistoryController extends GetxController {
  final RxList<FneRecord> records = <FneRecord>[].obs;

  // ── Filtres ──────────────────────────────────────────────────────────────────
  // Période : 'all' | 'today' | 'week' | 'month' | 'custom'
  final RxString filterPeriod = 'all'.obs;
  final RxString searchQuery = ''.obs;
  final Rx<DateTime?> customStart = Rx<DateTime?>(null);
  final Rx<DateTime?> customEnd = Rx<DateTime?>(null);

  late TextEditingController searchCtrl;

  @override
  void onInit() {
    super.onInit();
    searchCtrl = TextEditingController();
    searchCtrl.addListener(() => searchQuery.value = searchCtrl.text);
    loadRecords();
  }

  @override
  void onClose() {
    searchCtrl.dispose();
    super.onClose();
  }

  void loadRecords() {
    final allRecords = Get.find<StorageService>().getAllFne();
    final currentUserId = Get.isRegistered<SupabaseService>() 
        ? Get.find<SupabaseService>().currentUser?.id 
        : null;

    records.value = allRecords.where((r) {
      if (currentUserId == null) {
        // Mode hors ligne : voir uniquement les factures sans propriétaire (locales non connectées)
        return r.userId == null;
      } else {
        // Connecté : voir les siennes + s'approprier visuellement les sans propriétaires
        return r.userId == null || r.userId == currentUserId;
      }
    }).toList();
  }

  void scanNewInvoice() {
    Get.to(() => const AcquisitionScreen());
  }

  Future<void> deleteRecord(String id) async {
    final record = records.firstWhereOrNull((r) => r.id == id);
    if (record == null) return;

    if (record.status == FneStatus.certifiee) {
      toastification.show(
        type: ToastificationType.warning,
        title: const Text('Action impossible'),
        description:
            const Text('Les FNE certifiées ne peuvent pas être supprimées.'),
        autoCloseDuration: const Duration(seconds: 3),
      );
      return;
    }

    await Get.find<StorageService>().deleteFne(id);
    records.removeWhere((r) => r.id == id);
  }

  void updateRecord(FneRecord record) {
    Get.find<StorageService>().saveFne(record);
    
    // On rafraîchit toute la liste pour être sûr que l'isolation et les nouveaux éléments sont OK
    loadRecords();
  }

  void retryRecord(FneRecord record) {
    Get.delete<ValidationController>(force: true);
    final valCtrl = Get.put(ValidationController());
    valCtrl.loadRecordForRetry(record);
    Get.to(() => const ValidationScreen());
  }

  void resetFilters() {
    filterPeriod.value = 'all';
    searchCtrl.clear();
    customStart.value = null;
    customEnd.value = null;
  }

  // ── Liste filtrée par statut (réactive — à appeler dans Obx) ─────────────
  List<FneRecord> filteredRecordsByStatus(FneStatus status) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return records.where((r) {
      if (r.status != status) return false;

      // Filtre période
      switch (filterPeriod.value) {
        case 'today':
          if (!_sameDay(r.createdAt, now)) return false;
          break;
        case 'week':
          final weekStart = today.subtract(Duration(days: today.weekday - 1));
          if (r.createdAt.isBefore(weekStart)) return false;
          break;
        case 'month':
          if (r.createdAt.month != now.month ||
              r.createdAt.year != now.year) return false;
          break;
        case 'custom':
          if (customStart.value != null) {
            final start = DateTime(customStart.value!.year,
                customStart.value!.month, customStart.value!.day);
            final endRaw = customEnd.value ?? now;
            final end = DateTime(
                endRaw.year, endRaw.month, endRaw.day, 23, 59, 59);
            if (r.createdAt.isBefore(start) || r.createdAt.isAfter(end)) {
              return false;
            }
          }
          break;
      }

      // Recherche
      final q = searchQuery.value.toLowerCase().trim();
      if (q.isNotEmpty) {
        final matchName = r.clientName.toLowerCase().contains(q);
        final matchAmount = r.totalTTC.toStringAsFixed(0).contains(q);
        if (!matchName && !matchAmount) return false;
      }

      return true;
    }).toList();
  }

  /// CA certifié des enregistrements filtrés (période + recherche).
  double get filteredCertifiedCa =>
      filteredRecordsByStatus(FneStatus.certifiee)
          .fold(0.0, (s, r) => s + r.totalTTC);

  // ── Stats (réactives — à appeler dans Obx) ────────────────────────────────
  double get caToday {
    final now = DateTime.now();
    return records
        .where((r) =>
            r.status == FneStatus.certifiee && _sameDay(r.createdAt, now))
        .fold(0.0, (s, r) => s + r.totalTTC);
  }

  double get caThisMonth {
    final now = DateTime.now();
    return records
        .where((r) =>
            r.status == FneStatus.certifiee &&
            r.createdAt.month == now.month &&
            r.createdAt.year == now.year)
        .fold(0.0, (s, r) => s + r.totalTTC);
  }

  double get caThisWeek {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekStart = today.subtract(Duration(days: today.weekday - 1));
    return records
        .where((r) =>
            r.status == FneStatus.certifiee &&
            !r.createdAt.isBefore(weekStart))
        .fold(0.0, (s, r) => s + r.totalTTC);
  }

  int get countCertifiee =>
      records.where((r) => r.status == FneStatus.certifiee).length;

  int get countEchec =>
      records.where((r) => r.status == FneStatus.echec).length;

  int get countBrouillon =>
      records.where((r) => r.status == FneStatus.brouillon).length;

  /// CA certifié par jour sur les 7 derniers jours (index 0 = il y a 6 jours).
  List<double> get activityLast7Days {
    final now = DateTime.now();
    return List.generate(7, (i) {
      final day = now.subtract(Duration(days: 6 - i));
      return records
          .where((r) =>
              r.status == FneStatus.certifiee && _sameDay(r.createdAt, day))
          .fold(0.0, (s, r) => s + r.totalTTC);
    });
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
