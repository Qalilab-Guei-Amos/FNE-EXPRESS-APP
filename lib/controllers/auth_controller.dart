import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:toastification/toastification.dart';
import '../services/supabase_service.dart';
import '../services/sync_service.dart';
import 'history_controller.dart';
import 'settings_controller.dart';

class AuthController extends GetxController {
  final SupabaseService _supabase = Get.find<SupabaseService>();

  final RxBool isLoading = false.obs;
  final RxBool isLoginMode = true.obs;
  final Rx<User?> currentUser = Rx<User?>(null);

  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final displayNameCtrl = TextEditingController();

  bool get isAuthenticated => currentUser.value != null;

  String get displayName {
    // On privilégie toujours l'établissement défini dans les paramètres
    if (Get.isRegistered<SettingsController>()) {
      final settings = Get.find<SettingsController>();
      if (settings.establishmentCtrl.text.isNotEmpty) {
        return settings.establishmentCtrl.text;
      }
    }
    
    // Fallback si aucun nom d'établissement n'est configuré
    final metadataName = currentUser.value?.userMetadata?['display_name'];
    if (metadataName != null && metadataName.toString().isNotEmpty) {
      return metadataName.toString();
    }
    
    return currentUser.value?.email ?? 'FNE EXPRESS';
  }

  @override
  void onInit() {
    super.onInit();
    // Initialize current user
    currentUser.value = _supabase.currentUser;
    
    // Listen to Auth State changes for reactivity
    _supabase.auth.onAuthStateChange.listen((data) {
      currentUser.value = data.session?.user;
      
      // Rafraîchir l'historique pour appliquer les filtres d'isolation
      if (Get.isRegistered<HistoryController>()) {
        Get.find<HistoryController>().loadRecords();
      }
    });
  }

  void toggleMode() {
    isLoginMode.value = !isLoginMode.value;
  }

  Future<void> submit() async {
    if (emailCtrl.text.isEmpty || passwordCtrl.text.isEmpty || (!isLoginMode.value && displayNameCtrl.text.isEmpty)) {
      _showError('Veuillez remplir tous les champs');
      return;
    }

    isLoading.value = true;
    try {
      if (isLoginMode.value) {
        await _supabase.auth.signInWithPassword(
          email: emailCtrl.text.trim(),
          password: passwordCtrl.text,
        );
        _showSuccess('Connexion réussie');
        
        // ── Fusion automatique Cloud <-> Local ──────────────
        if (Get.isRegistered<SyncService>()) {
          final sync = Get.find<SyncService>();
          sync.restoreFromCloud(silent: true).then((_) {
            sync.syncCertifiedRecords(silent: true);
          });
        }
        
        Get.back();
      } else {
        await _supabase.auth.signUp(
          email: emailCtrl.text.trim(),
          password: passwordCtrl.text,
          data: {'display_name': displayNameCtrl.text.trim()},
        );
        _showSuccess('Inscription réussie. Vous pouvez maintenant vous connecter.');
        isLoginMode.value = true;
      }
    } on AuthException catch (e) {
      _showError(e.message);
    } catch (e) {
      _showError('Une erreur inattendue est survenue');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signOut() async {
    isLoading.value = true;
    try {
      await _supabase.auth.signOut();
      _showSuccess('Déconnexion réussie');
    } catch (e) {
      _showError('Erreur lors de la déconnexion');
    } finally {
      isLoading.value = false;
    }
  }

  void _showError(String msg) {
    toastification.show(
      title: const Text('Erreur d\'authentification'),
      description: Text(msg),
      type: ToastificationType.error,
      style: ToastificationStyle.flat,
      autoCloseDuration: const Duration(seconds: 4),
    );
  }

  void _showSuccess(String msg) {
    toastification.show(
      title: const Text('Succès'),
      description: Text(msg),
      type: ToastificationType.success,
      style: ToastificationStyle.flat,
      autoCloseDuration: const Duration(seconds: 3),
    );
  }

  @override
  void onClose() {
    emailCtrl.dispose();
    passwordCtrl.dispose();
    displayNameCtrl.dispose();
    super.onClose();
  }
}
