import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/settings_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive.dart';
import 'package:toastification/toastification.dart';
import 'components/profile_card.dart';
import 'components/modern_input.dart';
import 'components/section_header.dart';
import 'components/adaptive_grid.dart';
import 'components/sync_action_button.dart';

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
                SyncActionButton(authCtrl: authCtrl),
                SizedBox(width: R.hPad(context) - 16),
              ],
            ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(
          horizontal: R.hPad(context),
          vertical: 24,
        ),
        child: Obx(() {
          final editing = settingsCtrl.isEditMode.value;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header Profil ───────────────────
              ProfileCard(authCtrl: authCtrl),

              const SectionHeader(
                title: 'IDENTITÉ DE L\'ÉTABLISSEMENT',
                icon: Icons.business_center_rounded,
              ),
              const SizedBox(height: 12),
              AdaptiveGrid(
                isTablet: isTablet,
                children: [
                  ModernInput(
                    label: 'Nom de l\'établissement',
                    controller: settingsCtrl.establishmentCtrl,
                    icon: Icons.store_rounded,
                    readOnly: !editing,
                  ),
                  ModernInput(
                    label: 'Point de Vente',
                    controller: settingsCtrl.pointOfSaleCtrl,
                    icon: Icons.qr_code_scanner_rounded,
                    readOnly: !editing,
                  ),
                  ModernInput(
                    label: 'Responsable / Vendeur',
                    controller: settingsCtrl.sellerNameCtrl,
                    icon: Icons.person_pin_rounded,
                    readOnly: !editing,
                  ),
                ],
              ),

              const SizedBox(height: 24),
              const SectionHeader(
                title: 'PERSONNALISATION FACTURE',
                icon: Icons.description_rounded,
              ),
              const SizedBox(height: 12),
              AdaptiveGrid(
                isTablet: isTablet,
                children: [
                  ModernInput(
                    label: 'Message Commercial',
                    controller: settingsCtrl.commercialMessageCtrl,
                    icon: Icons.chat_bubble_rounded,
                    readOnly: !editing,
                  ),
                  ModernInput(
                    label: 'Pied de page (Mentions)',
                    controller: settingsCtrl.footerCtrl,
                    icon: Icons.subtitles_rounded,
                    readOnly: !editing,
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // ── Bouton Enregistrer (visible uniquement en mode édition) ──
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: editing
                    ? SizedBox(
                        width: double.infinity,
                        height: 58,
                        child: ElevatedButton(
                          onPressed: () {
                            settingsCtrl.save();
                            settingsCtrl.isEditMode.value = false;
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
                            shadowColor: AppTheme.primary.withValues(
                              alpha: 0.3,
                            ),
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
                      )
                    : const SizedBox.shrink(),
              ),

              const SizedBox(height: 28),
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
                        '© 2026 QALILAB AI',
                        style: TextStyle(color: AppTheme.textGrey, fontSize: 8),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          );
        }),
      ),
    );
  }
}
