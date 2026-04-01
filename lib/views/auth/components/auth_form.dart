import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/auth_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/responsive.dart';
import 'auth_logo.dart';
import 'auth_text_field.dart';

class AuthForm extends StatelessWidget {
  final AuthController ctrl;
  final bool isTablet;

  const AuthForm({
    super.key,
    required this.ctrl,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (!isTablet) ...[
          SizedBox(height: MediaQuery.of(context).padding.top),
          const AuthLogo(size: 100),
          const SizedBox(height: 40),
        ],
        
        Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 32,
                offset: const Offset(0, 10),
              )
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Obx(() => Text(
                ctrl.isLoginMode.value ? 'Bienvenue !' : 'Créer un compte',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: R.fs(context, 26), 
                  fontWeight: FontWeight.w900, 
                  color: AppTheme.textDark, 
                  letterSpacing: -0.5
                ),
              )),
              const SizedBox(height: 8),
              Obx(() => Text(
                ctrl.isLoginMode.value 
                    ? 'Connectez-vous pour synchroniser vos factures.' 
                    : 'Rejoignez-nous pour sauvegarder vos données.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: R.fs(context, 14), 
                  color: AppTheme.textGrey, 
                  height: 1.4
                ),
              )),
              const SizedBox(height: 32),
              
              Obx(() => !ctrl.isLoginMode.value 
                ? Column(
                    children: [
                      AuthTextField(
                        controller: ctrl.displayNameCtrl,
                        label: 'Nom de l\'entreprise',
                        icon: Icons.person_outline_rounded,
                      ),
                      const SizedBox(height: 16),
                    ],
                  )
                : const SizedBox.shrink()),

              AuthTextField(
                controller: ctrl.emailCtrl,
                label: 'Adresse Email',
                icon: Icons.email_outlined,
              ),
              const SizedBox(height: 16),
              AuthTextField(
                controller: ctrl.passwordCtrl,
                label: 'Mot de passe',
                icon: Icons.lock_outline_rounded,
                obscure: true,
              ),
              const SizedBox(height: 32),
              
              Obx(() => SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: ctrl.isLoading.value ? null : ctrl.submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: ctrl.isLoading.value
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                      : Text(
                          ctrl.isLoginMode.value ? 'Se connecter' : 'S\'inscrire', 
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5)
                        ),
                ),
              )),
              
              const SizedBox(height: 24),
              
              Obx(() => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    ctrl.isLoginMode.value ? 'Pas de compte ? ' : 'Déjà un compte ? ', 
                    style: const TextStyle(color: AppTheme.textGrey, fontSize: 14)
                  ),
                  GestureDetector(
                    onTap: ctrl.isLoading.value ? null : ctrl.toggleMode,
                    child: Text(
                      ctrl.isLoginMode.value ? 'Créer ici' : 'Me connecter', 
                      style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold, fontSize: 14)
                    ),
                  ),
                ],
              )),
            ],
          ),
        ),
      ],
    );
  }
}
