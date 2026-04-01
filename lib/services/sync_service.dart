import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toastification/toastification.dart';
import '../models/fne_record.dart';
import '../controllers/history_controller.dart';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

class SyncService extends GetxService {
  final SupabaseService _supabase = Get.find<SupabaseService>();
  final RxBool isSyncing = false.obs;

  Future<void> syncAll({bool silent = false}) async {
    if (!_supabase.isAuthenticated) {
      if (!silent) _showToast('Non connecté', 'Veuillez vous connecter pour synchroniser.', ToastificationType.warning);
      return;
    }
    if (isSyncing.value) return;
    
    isSyncing.value = true;
    try {
      int uploaded = await _internalSyncUp();
      int downloaded = await _internalSyncDown();
      
      if (!silent) {
        if (uploaded > 0 || downloaded > 0) {
          _showToast('Synchronisation réussie', 'Envoi: $uploaded, Réception: $downloaded factures.', ToastificationType.success);
        } else {
          _showToast('À jour', 'Vos données locales et Cloud sont parfaitement synchronisées.', ToastificationType.info);
        }
      }
    } catch (e) {
      if (!silent) _showToast('Erreur', 'La synchronisation a échoué.', ToastificationType.error);
    } finally {
      isSyncing.value = false;
    }
  }

  Future<int> _internalSyncUp() async {
    final historyCtrl = Get.find<HistoryController>();
    final recordsToSync = historyCtrl.records.where((r) => r.status == FneStatus.certifiee && !r.isSynced).toList();
    int count = 0;
    if (recordsToSync.isNotEmpty) {
      final userId = _supabase.currentUser!.id;
      for (var record in recordsToSync) {
        try {
          await _uploadRecord(record);
          historyCtrl.updateRecord(record.copyWith(isSynced: true, userId: userId));
          count++;
        } catch (e) {
          debugPrint('Erreur upload ${record.id}: $e');
        }
      }
    }
    return count;
  }

  Future<int> _internalSyncDown() async {
    final historyCtrl = Get.find<HistoryController>();
    final userId = _supabase.currentUser!.id;
    final List<dynamic> response = await _supabase.client
        .from('fne_records')
        .select()
        .eq('user_id', userId);

    int count = 0;
    for (var row in response) {
      final String id = row['id'];
      final existingIndex = historyCtrl.records.indexWhere((r) => r.id == id);

      if (existingIndex == -1) {
        FneRecord record = FneRecord.fromJson(row).copyWith(isSynced: true);

        // 1. Récupérer le PDF manquant si présent sur le cloud
        if (row['pdf_path'] != null && row['pdf_path'].toString().isNotEmpty) {
           final localPdfPath = await _downloadFileFromCloud(row['pdf_path'], '${id}_pdf.pdf');
           if (localPdfPath != null) record = record.copyWith(pdfPath: localPdfPath);
        }
        // 2. Récupérer le fichier source si présent
        if (row['source_path'] != null && row['source_path'].toString().isNotEmpty) {
           final ext = row['source_path'].toString().split('.').last;
           final localSrcPath = await _downloadFileFromCloud(row['source_path'], '${id}_source.$ext');
           if (localSrcPath != null) record = record.copyWith(sourcePath: localSrcPath);
        }

        historyCtrl.updateRecord(record);
        count++;
      } else {
        final localRecord = historyCtrl.records[existingIndex];
        bool needsLocalUpdate = false;
        FneRecord updatedLocal = localRecord.copyWith();

        // 1. Check PDF : Le cloud a le PDF, le local l'a perdu ? (On télécharge)
        if (row['pdf_path'] != null && row['pdf_path'].toString().isNotEmpty) {
           if (localRecord.pdfPath == null || !(File(localRecord.pdfPath!).existsSync())) {
              final localPdfPath = await _downloadFileFromCloud(row['pdf_path'], '${id}_pdf.pdf');
              if (localPdfPath != null) {
                 updatedLocal = updatedLocal.copyWith(pdfPath: localPdfPath);
                 needsLocalUpdate = true;
              }
           }
        } // Le local l'a, mais le Cloud ne l'a pas ? (On uploade au Storage et complétons le row)
        else if (localRecord.pdfPath != null && File(localRecord.pdfPath!).existsSync()) {
            await _uploadFileAndFixCloudRecord(localRecord, 'pdf_path', localRecord.pdfPath!);
        }

        // 2. Check Fichier source (PJ) pareillement
        if (row['source_path'] != null && row['source_path'].toString().isNotEmpty) {
           if (localRecord.sourcePath == null || !(File(localRecord.sourcePath!).existsSync())) {
              final ext = row['source_path'].toString().split('.').last;
              final localSrcPath = await _downloadFileFromCloud(row['source_path'], '${id}_source.$ext');
              if (localSrcPath != null) {
                 updatedLocal = updatedLocal.copyWith(sourcePath: localSrcPath);
                 needsLocalUpdate = true;
              }
           }
        } else if (localRecord.sourcePath != null && File(localRecord.sourcePath!).existsSync()) {
            await _uploadFileAndFixCloudRecord(localRecord, 'source_path', localRecord.sourcePath!);
        }

        if (needsLocalUpdate) {
          historyCtrl.updateRecord(updatedLocal);
        }
      }
    }
    return count;
  }

  Future<String?> _downloadFileFromCloud(String cloudPath, String localFilename) async {
    try {
      final storage = _supabase.client.storage.from('fne_documents');
      final Uint8List fileBytes = await storage.download(cloudPath);
      final docDir = await getApplicationDocumentsDirectory();
      final File localFile = File('${docDir.path}/$localFilename');
      await localFile.writeAsBytes(fileBytes);
      return localFile.path;
    } catch(e) {
      debugPrint('Erreur download fichier $cloudPath: $e');
      return null;
    }
  }

  Future<void> _uploadFileAndFixCloudRecord(FneRecord record, String columnToUpdate, String localFilePath) async {
    try {
      final file = File(localFilePath);
      if (!file.existsSync()) return;

      final userId = _supabase.currentUser!.id;
      final ext = localFilePath.split('.').last;
      final suffix = columnToUpdate == 'pdf_path' ? 'pdf' : 'source';
      final remoteName = '$userId/${record.id}_$suffix.$ext';

      final storage = _supabase.client.storage.from('fne_documents');
      await storage.upload(remoteName, file, fileOptions: const FileOptions(upsert: true));
      
      await _supabase.client.from('fne_records').update({
         columnToUpdate: remoteName,
      }).eq('id', record.id);
      
      debugPrint('Correction Cloud appliquée: $columnToUpdate uploadé en retard.');
    } catch(e) {
      debugPrint('Erreur lors de la correction Cloud de $columnToUpdate: $e');
    }
  }

  Future<void> syncCertifiedRecords({bool silent = false}) async {
    if (!_supabase.isAuthenticated) {
      if (!silent) _showToast('Non connecté', 'Veuillez vous connecter pour synchroniser.', ToastificationType.warning);
      return;
    }
    if (isSyncing.value) return;

    final historyCtrl = Get.find<HistoryController>();
    // On ne synchronise que les pièces certifiées (validées par DGI) qui ne l'ont pas encore été
    final recordsToSync = historyCtrl.records.where((r) => 
        r.status == FneStatus.certifiee && !r.isSynced
    ).toList();

    if (recordsToSync.isEmpty) {
      if (!silent) _showToast('À jour', 'Toutes vos factures sont déjà sauvegardées sur le cloud.', ToastificationType.info);
      return;
    }

    isSyncing.value = true;
    int successCount = 0;

    try {
      final userId = _supabase.currentUser!.id;

      for (var record in recordsToSync) {
        try {
          await _uploadRecord(record);
          // Marquer en base locale Hive que c'est bien synchronisé et lui attribuer l'ID utilisateur
          historyCtrl.updateRecord(record.copyWith(isSynced: true, userId: userId));
          successCount++;
        } catch (e) {
          debugPrint('Erreur synchronisation facture ${record.id}: $e');
        }
      }

      if (!silent) {
        _showToast('Succès', '$successCount/${recordsToSync.length} factures et de leurs fichiers sauvegardés.', ToastificationType.success);
      }

    } catch (e) {
      if (!silent) _showToast('Erreur réseau', 'Impossible de joindre le serveur Cloud.', ToastificationType.error);
    } finally {
      isSyncing.value = false;
    }
  }

  /// Synchronise silencieusement UNE facture juste après sa certification.
  Future<void> syncSingleRecord(FneRecord record) async {
    if (!_supabase.isAuthenticated) return;

    try {
      final historyCtrl = Get.isRegistered<HistoryController>() ? Get.find<HistoryController>() : null;
      await _uploadRecord(record);
      // Marquer comme synchronisé en local avec le proprio
      historyCtrl?.updateRecord(record.copyWith(isSynced: true, userId: _supabase.currentUser?.id));
      debugPrint('[SyncService] ✅ Facture ${record.id} synchronisée automatiquement.');
    } catch (e) {
      debugPrint('[SyncService] ⚠️ Synchro auto échouée pour ${record.id}: $e');
    }
  }

  /// Logique commune d'envoi d'un enregistrement + ses fichiers vers Supabase.
  Future<void> _uploadRecord(FneRecord record) async {
    final userId = _supabase.currentUser!.id;
    final db = _supabase.client.rest;
    final storage = _supabase.client.storage.from('fne_documents');

    String? cloudPdfPath;
    String? cloudSourcePath;

    if (record.pdfPath != null && record.pdfPath!.isNotEmpty) {
      final file = File(record.pdfPath!);
      if (await file.exists()) {
        final ext = record.pdfPath!.split('.').last;
        final remoteName = '$userId/${record.id}_pdf.$ext';
        await storage.upload(remoteName, file, fileOptions: const FileOptions(upsert: true));
        cloudPdfPath = remoteName;
      }
    }

    if (record.sourcePath != null && record.sourcePath!.isNotEmpty) {
      final file = File(record.sourcePath!);
      if (await file.exists()) {
        final ext = record.sourcePath!.split('.').last;
        final remoteName = '$userId/${record.id}_source.$ext';
        await storage.upload(remoteName, file, fileOptions: const FileOptions(upsert: true));
        cloudSourcePath = remoteName;
      }
    }

    await db.from('fne_records').upsert({
      'id': record.id,
      'user_id': userId,
      'created_at': record.createdAt.toIso8601String(),
      'client_name': record.clientName,
      'total_ttc': record.totalTTC,
      'fne_number': record.fneNumber,
      'qr_code': record.qrCode,
      'pdf_path': cloudPdfPath,
      'source_path': cloudSourcePath,
      'invoice': record.invoice.toJson(),
      'status': record.status.name,
    });
  }

  /// Récupère toutes les factures du Cloud
  Future<void> restoreFromCloud({bool silent = false}) async {
    if (!_supabase.isAuthenticated) return;
    if (isSyncing.value) return;

    isSyncing.value = true;
    try {
      final userId = _supabase.currentUser!.id;
      final historyCtrl = Get.find<HistoryController>();
      
      final List<dynamic> response = await _supabase.client
          .from('fne_records')
          .select()
          .eq('user_id', userId);

      int restoredCount = 0;

      for (var row in response) {
        final String id = row['id'];
        if (historyCtrl.records.every((r) => r.id != id)) {
          final record = FneRecord.fromJson(row).copyWith(isSynced: true);
          historyCtrl.updateRecord(record);
          restoredCount++;
        }
      }

      if (!silent) {
        if (restoredCount > 0) {
          _showToast('Restauration', '$restoredCount factures récupérées du Cloud.', ToastificationType.success);
        } else {
          _showToast('Info', 'Votre appareil est déjà à jour avec le Cloud.', ToastificationType.info);
        }
      }
    } catch (e) {
      debugPrint('[SyncService] Erreur restauration: $e');
      if (!silent) _showToast('Erreur', 'Impossible de restaurer les données.', ToastificationType.error);
    } finally {
      isSyncing.value = false;
    }
  }

  void _showToast(String title, String desc, ToastificationType type) {
    toastification.show(
      title: Text(title),
      description: Text(desc),
      type: type,
      style: ToastificationStyle.flat,
      autoCloseDuration: const Duration(seconds: 4),
    );
  }
}
