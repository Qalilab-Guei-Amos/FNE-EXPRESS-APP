import 'dart:io';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:toastification/toastification.dart';
import 'package:flutter/material.dart';

class AcquisitionController extends GetxController {
  final Rx<File?> selectedFile = Rx<File?>(null);
  final RxString selectedMimeType = ''.obs;
  final RxBool isLoading = false.obs;

  final ImagePicker _imagePicker = ImagePicker();

  bool get hasFile => selectedFile.value != null;

  Future<void> pickFromCamera() async {
    try {
      isLoading.value = true;
      final XFile? photo = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 90,
        maxWidth: 2048,
        maxHeight: 2048,
      );
      if (photo != null) {
        selectedFile.value = File(photo.path);
        selectedMimeType.value = 'image/jpeg';
      }
    } catch (e) {
      _showError('Impossible d\'accéder à la caméra: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> pickFromGallery() async {
    try {
      isLoading.value = true;
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
      );
      if (image != null) {
        selectedFile.value = File(image.path);
        final path = image.path.toLowerCase();
        selectedMimeType.value =
            path.endsWith('.png') ? 'image/png' : 'image/jpeg';
      }
    } catch (e) {
      _showError('Erreur lors de la sélection: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> pickDocument() async {
    try {
      isLoading.value = true;
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      );
      if (result != null && result.files.single.path != null) {
        selectedFile.value = File(result.files.single.path!);
        final ext = result.files.single.extension?.toLowerCase() ?? '';
        if (ext == 'pdf') {
          selectedMimeType.value = 'application/pdf';
        } else if (ext == 'png') {
          selectedMimeType.value = 'image/png';
        } else {
          selectedMimeType.value = 'image/jpeg';
        }
      }
    } catch (e) {
      _showError('Erreur lors de l\'importation: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void loadSharedFile(String path, String mimeType) {
    isLoading.value = false;
    selectedFile.value = File(path);
    selectedMimeType.value = mimeType;
  }

  void clearFile() {
    selectedFile.value = null;
    selectedMimeType.value = '';
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
