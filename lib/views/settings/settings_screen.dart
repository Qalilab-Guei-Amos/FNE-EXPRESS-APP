import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/settings_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive.dart';
import '../auth/components/auth_text_field.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsCtrl = Get.find<SettingsController>();
    final authCtrl = Get.find<AuthController>();
    final isTablet = R.isTablet(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9), // Un gris plus moderne et doux
      appBar: isTablet ? null : AppBar(
        title: const Text('Mon Profil & Paramètres', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: -0.5)),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(
          horizontal: R.hPad(context), 
          vertical: 24
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Section Profil (Si connecté) ───────────────────
            Obx(() {
              if (!authCtrl.isAuthenticated) return const SizedBox.shrink();
              return Container(
                margin: const EdgeInsets.only(bottom: 32),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.primary, Color(0xFF1E3A2E)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(color: AppTheme.primary.withValues(alpha: 0.2), blurRadius: 20, offset: const Offset(0, 10))
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.business_center_rounded, color: Colors.white, size: 40),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            authCtrl.displayName,
                            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900),
                          ),
                          Text(
                            authCtrl.currentUser.value?.email ?? 'Connecté au cloud',
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),

            // ── Bouton d'activation de l'édition (Autonome) ─────
            Obx(() => Container(
              margin: const EdgeInsets.only(bottom: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => settingsCtrl.toggleEditing(),
                    icon: Icon(
                      settingsCtrl.isEditing.value ? Icons.close : Icons.edit_note_rounded, 
                      size: 20
                    ),
                    label: Text(
                      settingsCtrl.isEditing.value ? 'ANNULER L\'ÉDITION' : 'MODIFIER MES INFOS',
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: settingsCtrl.isEditing.value ? Colors.orange.shade700 : AppTheme.primary,
                      side: BorderSide(color: (settingsCtrl.isEditing.value ? Colors.orange.shade700 : AppTheme.primary).withValues(alpha: 0.3)),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ],
              ),
            )),

            // ── Grille/Liste des paramètres ─────────────────────
            Obx(() => isTablet
                ? _buildTabletGrid(settingsCtrl, context)
                : _buildMobileSettings(settingsCtrl, context)),

            const SizedBox(height: 32),

            // ── Bouton de Sauvegarde (Seulement si édition) ─────
            Obx(() {
              if (!settingsCtrl.isEditing.value) return const SizedBox.shrink();
              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        settingsCtrl.save();
                        settingsCtrl.isEditing.value = false;
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                        elevation: 8,
                        shadowColor: AppTheme.primary.withValues(alpha: 0.4),
                      ),
                      icon: const Icon(Icons.check_circle_outline, size: 24),
                      label: const Text('ENREGISTRER LES MODIFICATIONS', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
                    ),
                  ),
                ),
              );
            }),

            const SizedBox(height: 24),

            // ── Section Sécurité & Déconnexion ───────────────────
            _buildSectionCard(
              context, 
              'Sécurité du Compte', 
              Icons.shield_outlined, 
              [
                const Text(
                  'Gérez votre session et la sécurité de vos données cloud.',
                  style: TextStyle(color: AppTheme.textGrey, fontSize: 13),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: OutlinedButton.icon(
                    onPressed: () => authCtrl.signOut(),
                    icon: const Icon(Icons.logout_rounded, size: 20),
                    label: const Text('SE DÉCONNECTER DE LA SESSION', style: TextStyle(fontWeight: FontWeight.bold)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.redAccent.shade400,
                      side: BorderSide(color: Colors.redAccent.shade400.withValues(alpha: 0.3), width: 1.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
              ]
            ),
            
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  Widget _buildTabletGrid(SettingsController ctrl, BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _buildSectionCard(
            context,
            'Identité de l’Établissement',
            Icons.business_rounded,
            [
              _buildModernField(label: 'Nom de l’établissement', controller: ctrl.establishmentCtrl, icon: Icons.storefront_rounded, enabled: ctrl.isEditing.value),
              const SizedBox(height: 16),
              _buildModernField(label: 'Code Point de Vente', controller: ctrl.pointOfSaleCtrl, icon: Icons.vpn_key_outlined, enabled: ctrl.isEditing.value),
              const SizedBox(height: 16),
              _buildModernField(label: 'Nom du vendeur', controller: ctrl.sellerNameCtrl, icon: Icons.person_outline, enabled: ctrl.isEditing.value),
            ],
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: _buildSectionCard(
            context,
            'Personnalisation Facture',
            Icons.receipt_long_rounded,
            [
              _buildModernField(label: 'Message Commercial', controller: ctrl.commercialMessageCtrl, icon: Icons.chat_bubble_outline_rounded, enabled: ctrl.isEditing.value),
              const SizedBox(height: 16),
              _buildModernField(label: 'Mentions Bas de Page', controller: ctrl.footerCtrl, icon: Icons.article_outlined, enabled: ctrl.isEditing.value),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileSettings(SettingsController ctrl, BuildContext context) {
    return Column(
      children: [
        _buildSectionCard(
          context,
          'Identité de l’Établissement',
          Icons.business_rounded,
          [
            _buildModernField(label: 'Nom de l’établissement', controller: ctrl.establishmentCtrl, icon: Icons.storefront_rounded, enabled: ctrl.isEditing.value),
            const SizedBox(height: 16),
            _buildModernField(label: 'Point de Vente', controller: ctrl.pointOfSaleCtrl, icon: Icons.location_on_outlined, enabled: ctrl.isEditing.value),
          ],
        ),
        const SizedBox(height: 32),
        _buildSectionCard(
          context,
          'Personnalisation Facture',
          Icons.receipt_long_rounded,
          [
            _buildModernField(label: 'Message Commercial', controller: ctrl.commercialMessageCtrl, icon: Icons.message_outlined, enabled: ctrl.isEditing.value),
            const SizedBox(height: 16),
            _buildModernField(label: 'Mentions Légales', controller: ctrl.footerCtrl, icon: Icons.info_outline, enabled: ctrl.isEditing.value),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionCard(BuildContext context, String title, IconData groupIcon, List<Widget> fields) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 20, offset: const Offset(0, 10))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(groupIcon, color: AppTheme.primary, size: 22),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w900, color: AppTheme.textDark, fontSize: 16, letterSpacing: -0.5),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ...fields,
        ],
      ),
    );
  }

  Widget _buildModernField({
    required String label, 
    required TextEditingController controller, 
    required IconData icon,
    bool enabled = true,
  }) {
    return AuthTextField(
      controller: controller, 
      label: label, 
      icon: icon,
      enabled: enabled,
    );
  }
}
