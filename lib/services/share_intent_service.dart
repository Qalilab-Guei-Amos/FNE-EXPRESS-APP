import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_sharing_intent/flutter_sharing_intent.dart';
import 'package:flutter_sharing_intent/model/sharing_file.dart';
import 'package:get/get.dart';
import 'package:toastification/toastification.dart';
import '../controllers/acquisition_controller.dart';
import '../controllers/validation_controller.dart';
import '../views/validation/validation_screen.dart';

class ShareIntentService extends GetxService {
  late StreamSubscription<List<SharedFile>> _sub;

  // Flag statique : survit à la re-création du service mais pas à la mort du process.
  // Empêche de retraiter un intent initial déjà consommé lors de la même session.
  static bool _initialSharingConsumed = false;

  @override
  void onInit() {
    super.onInit();

    // App déjà en cours d'exécution → partage entrant en temps réel
    _sub = FlutterSharingIntent.instance
        .getMediaStream()
        .listen(_handleFiles, onError: (_) {});

    // App fermée (cold start) → intent initial (traité une seule fois par session)
    if (!_initialSharingConsumed) {
      FlutterSharingIntent.instance.getInitialSharing().then((files) {
        if (files.isNotEmpty) {
          _initialSharingConsumed = true;
          _handleFiles(files);
        }
      });
    }
  }

  @override
  void onClose() {
    _sub.cancel();
    super.onClose();
  }

  void _handleFiles(List<SharedFile> files) {
    if (files.isEmpty) return;
    final file = files.first;
    final path = file.value;
    if (path == null || path.isEmpty) return;

    switch (file.type) {
      case SharedMediaType.IMAGE:
        final mime = path.toLowerCase().endsWith('.png')
            ? 'image/png'
            : 'image/jpeg';
        _openForExtraction(path, mime);
        break;

      case SharedMediaType.FILE:
        final ext = path.toLowerCase().split('.').last;
        if (ext == 'pdf') {
          _openForExtraction(path, 'application/pdf');
        } else if (['jpg', 'jpeg'].contains(ext)) {
          _openForExtraction(path, 'image/jpeg');
        } else if (ext == 'png') {
          _openForExtraction(path, 'image/png');
        } else {
          _showWarning(
            'Format non supporté',
            'Seuls les images (JPG, PNG) et PDF sont pris en charge.',
          );
        }
        break;

      case SharedMediaType.TEXT:
      case SharedMediaType.URL:
        _showWarning(
          'Texte reçu',
          'Partagez une image ou un PDF de la facture pour l\'extraction.',
        );
        break;

      default:
        _showWarning(
          'Type non supporté',
          'Seuls les images et PDF sont pris en charge.',
        );
    }
  }

  void _openForExtraction(String path, String mimeType) {
    if (!File(path).existsSync()) {
      _showError('Fichier introuvable', 'Impossible d\'accéder au fichier partagé.');
      return;
    }

    // 1. Réinitialiser les contrôleurs pour partir sur une base saine
    final acqCtrl = Get.put(AcquisitionController());
    acqCtrl.loadSharedFile(path, mimeType);

    Get.delete<ValidationController>(force: true);
    final validCtrl = Get.put(ValidationController());

    // 2. Naviguer vers l'écran de validation
    // On utilise offAll pour éviter d'empiler des extractions si l'utilisateur partage plusieurs fois
    Get.offAll(() => const ValidationScreen());

    // 3. Lancer l'extraction avec un léger délai pour laisser l'UI s'installer (crucial pour le cold start)
    Future.delayed(const Duration(milliseconds: 300), () {
      if (acqCtrl.selectedFile.value != null) {
        validCtrl.extractFromFile(acqCtrl.selectedFile.value!, mimeType);
      }
    });
  }

  void _showWarning(String title, String message) {
    toastification.show(
      context: Get.context,
      type: ToastificationType.warning,
      title: Text(title),
      description: Text(message),
      autoCloseDuration: const Duration(seconds: 4),
    );
  }

  void _showError(String title, String message) {
    toastification.show(
      context: Get.context,
      type: ToastificationType.error,
      title: Text(title),
      description: Text(message),
      autoCloseDuration: const Duration(seconds: 4),
    );
  }
}
