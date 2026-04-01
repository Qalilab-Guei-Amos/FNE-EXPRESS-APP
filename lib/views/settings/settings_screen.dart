import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/settings_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive.dart';
import 'package:toastification/toastification.dart';
import '../auth/components/auth_text_field.dart';
import '../auth/auth_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsCtrl = Get.find<SettingsController>();
    final authCtrl = Get.find<AuthController>();
    final isTablet = R.isTablet(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: isTablet
          ? null
          : AppBar(
              title: Text(
                'Paramètres',
                style: TextStyle(fontSize: R.fs(context, 18)),
              ),
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              toolbarHeight: 64,
              actions: [
                _buildSyncAction(authCtrl),
                SizedBox(width: R.hPad(context) - 16),
              ],
            ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(
          horizontal: R.hPad(context),
          vertical: 24,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header Profil ───────────────────
            Obx(() {
              if (!authCtrl.isAuthenticated) return const SizedBox.shrink();
              return _buildProfileCard(authCtrl, context);
            }),

            const SizedBox(height: 12),
            _buildSectionHeader(
              'IDENTITÉ DE L\'ÉTABLISSEMENT',
              Icons.business_center_rounded,
            ),
            const SizedBox(height: 12),
            _buildAdaptiveGrid(context, isTablet, [
              _buildModernInput(
                label: 'Nom de l\'établissement',
                controller: settingsCtrl.establishmentCtrl,
                icon: Icons.store_rounded,
                isTablet: isTablet,
              ),
              _buildModernInput(
                label: 'Point de Vente',
                controller: settingsCtrl.pointOfSaleCtrl,
                icon: Icons.qr_code_scanner_rounded,
                isTablet: isTablet,
              ),
              _buildModernInput(
                label: 'Responsable / Vendeur',
                controller: settingsCtrl.sellerNameCtrl,
                icon: Icons.person_pin_rounded,
                isTablet: isTablet,
              ),
            ]),

            const SizedBox(height: 32),
            _buildSectionHeader(
              'PERSONNALISATION FACTURE',
              Icons.description_rounded,
            ),
            const SizedBox(height: 12),
            _buildAdaptiveGrid(context, isTablet, [
              _buildModernInput(
                label: 'Message Commercial',
                controller: settingsCtrl.commercialMessageCtrl,
                icon: Icons.chat_bubble_rounded,
                isTablet: isTablet,
              ),
              _buildModernInput(
                label: 'Pied de page (Mentions)',
                controller: settingsCtrl.footerCtrl,
                icon: Icons.subtitles_rounded,
                isTablet: isTablet,
              ),
            ]),

            const SizedBox(height: 48),

            // Boutons d'Action (Sauvegarde)
            SizedBox(
              width: double.infinity,
              height: 58,
              child: ElevatedButton(
                onPressed: () {
                  settingsCtrl.save();
                  toastification.show(
                    title: const Text('Sauvegarde réussie'),
                    description: const Text(
                      'Configuration mise à jour avec succès ✅',
                    ),
                    type: ToastificationType.success,
                    style: ToastificationStyle.flat,
                    autoCloseDuration: const Duration(seconds: 3),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  elevation: 5,
                  shadowColor: AppTheme.primary.withValues(alpha: 0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'ENREGISTRER LA CONFIGURATION',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),
            Center(
              child: Opacity(
                opacity: 0.4,
                child: Column(
                  children: [
                    Text(
                      'FNE EXPRESS • VERSION 1.0.0',
                      style: TextStyle(
                        color: AppTheme.textGrey,
                        fontSize: 10,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '© 2026 AMANI DIGITAL SERVICES',
                      style: TextStyle(color: AppTheme.textGrey, fontSize: 8),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard(AuthController authCtrl, BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primary,
                  AppTheme.primary.withValues(alpha: 0.85),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.white.withValues(alpha: 0.15),
                  child: const Icon(
                    Icons.shield_outlined,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        authCtrl.displayName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                      Text(
                        authCtrl.currentUser.value?.email ??
                            'Compte Certifié',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.75),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => authCtrl.signOut(),
                  icon: const Icon(
                    Icons.logout_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: _profileAction(
                    icon: Icons.key_rounded,
                    label: 'Mot de passe',
                    onTap: () => _showChangePasswordDialog(context, authCtrl),
                  ),
                ),
                Container(width: 1, height: 24, color: Colors.grey.shade300),
                Expanded(
                  child: _profileAction(
                    icon: Icons.sync_rounded,
                    label: 'Synchronisation',
                    onTap: () => toastification.show(
                      title: const Text('Synchronisation active'),
                      autoCloseDuration: const Duration(seconds: 3),
                      
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _profileAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: AppTheme.primary),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppTheme.textGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.primary.withValues(alpha: 0.6)),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: AppTheme.textGrey,
          ),
        ),
      ],
    );
  }

  Widget _buildAdaptiveGrid(
    BuildContext context,
    bool isTablet,
    List<Widget> children,
  ) {
    if (!isTablet) {
      return Column(
        children: children
            .map(
              (c) =>
                  Padding(padding: const EdgeInsets.only(bottom: 12), child: c),
            )
            .toList(),
      );
    }
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      mainAxisExtent: 135, // Augmenté pour l'alignement vertical
      children: children,
    );
  }

  Widget _buildModernInput({
    required String label,
    required TextEditingController? controller,
    required IconData icon,
    bool isTablet = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: isTablet 
        ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: AppTheme.primary),
              ),
              const SizedBox(height: 10),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textGrey,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              TextField(
                controller: controller,
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                  border: InputBorder.none,
                  filled: false,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                ),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textDark,
                ),
              ),
            ],
          )
        : Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 20, color: AppTheme.primary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppTheme.textGrey,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    TextField(
                      controller: controller,
                      decoration: const InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                        border: InputBorder.none,
                        filled: false,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                      ),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textDark,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
    );
  }

  void _showChangePasswordDialog(
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
          width: 400, // Largeur confortable
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

  Widget _buildSyncAction(AuthController authCtrl) {
    return Obx(() {
      final bool isLoggedIn = authCtrl.currentUser.value != null;
      return GestureDetector(
        onTap: () => Get.to(() => const AuthScreen()),
        child: Container(
          margin: const EdgeInsets.only(right: 16),
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            color: isLoggedIn 
                ? Colors.white.withValues(alpha: 0.25)
                : Colors.white.withValues(alpha: 0.1),
            shape: BoxShape.circle,
            border: Border.all(
                color: isLoggedIn ? Colors.white : Colors.white.withValues(alpha: 0.3),
                width: isLoggedIn ? 1.5 : 1),
          ),
          child: Icon(
            isLoggedIn ? Icons.cloud_done_rounded : Icons.cloud_off_rounded,
            color: isLoggedIn ? Colors.white : Colors.white.withValues(alpha: 0.6), 
            size: 18
          ),
        ),
      );
    });
  }
}
