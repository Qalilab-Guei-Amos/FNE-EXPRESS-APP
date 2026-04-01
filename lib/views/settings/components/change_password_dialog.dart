import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toastification/toastification.dart';
import '../../../controllers/auth_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/components/auth_text_field.dart';

void showChangePasswordDialog(
  BuildContext context,
  AuthController authCtrl,
) {
  final oldPassCtrl = TextEditingController();
  final newPassCtrl = TextEditingController();
  final confirmCtrl = TextEditingController();

  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      title: const Text(
        'Mise à jour d\'accès',
        style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: -0.5),
      ),
      content: Container(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Veuillez valider votre mot de passe actuel avant d\'en définir un nouveau.',
              style: TextStyle(
                fontSize: 13,
                color: AppTheme.textGrey,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            AuthTextField(
              controller: oldPassCtrl,
              label: 'Mot de passe actuel',
              icon: Icons.shield_outlined,
              obscure: true,
            ),
            const SizedBox(height: 16),
            AuthTextField(
              controller: newPassCtrl,
              label: 'Nouveau mot de passe',
              icon: Icons.lock_outline_rounded,
              obscure: true,
            ),
            const SizedBox(height: 16),
            AuthTextField(
              controller: confirmCtrl,
              label: 'Confirmation',
              icon: Icons.check_circle_outline_rounded,
              obscure: true,
            ),
          ],
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12, bottom: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Get.back(),
                child: const Text(
                  'ANNULER',
                  style: TextStyle(
                    color: AppTheme.textGrey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () {
                  if (oldPassCtrl.text.isEmpty ||
                      newPassCtrl.text != confirmCtrl.text ||
                      newPassCtrl.text.length < 6) {
                    toastification.show(
                      title: const Text('Validation échouée'),
                      description: const Text(
                        'Vérifiez que vos nouveaux mots de passe concordent et font au moins 6 caractères.',
                      ),
                      type: ToastificationType.warning,
                      autoCloseDuration: const Duration(seconds: 3),
                    );
                    return;
                  }
                  authCtrl.verifyAndChangePassword(
                    oldPassCtrl.text,
                    newPassCtrl.text,
                  );
                  Get.back();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'METTRE À JOUR',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
