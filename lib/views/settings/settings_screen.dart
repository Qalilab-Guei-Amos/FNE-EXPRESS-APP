import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/settings_controller.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsCtrl = Get.find<SettingsController>();

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: R.isTablet(context) ? null : AppBar(
        title: const Text('Paramètres du profil', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildSection(
              'Identité de l\'Entreprise',
              [
                _buildField(
                  label: 'Nom de l\'établissement',
                  controller: settingsCtrl.establishmentCtrl,
                  icon: Icons.business_rounded,
                ),
                _buildField(
                  label: 'Point de Vente',
                  controller: settingsCtrl.pointOfSaleCtrl,
                  icon: Icons.location_on_rounded,
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSection(
              'Facturation & Mentions',
              [
                _buildField(
                  label: 'Message Commercial',
                  controller: settingsCtrl.commercialMessageCtrl,
                  icon: Icons.message_rounded,
                  maxLines: 2,
                ),
                _buildField(
                  label: 'Pied de page (RC, Capital, etc.)',
                  controller: settingsCtrl.footerCtrl,
                  icon: Icons.info_rounded,
                  maxLines: 3,
                ),
              ],
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () => settingsCtrl.save(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 4,
                ),
                icon: const Icon(Icons.save_rounded),
                label: const Text('SAUVEGARDER LES MODIFICATIONS', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w800, color: AppTheme.textDark, fontSize: 13),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildField({required String label, required TextEditingController controller, required IconData icon, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: AppTheme.textGrey, fontSize: 13),
          prefixIcon: Icon(icon, color: AppTheme.primary.withValues(alpha: 0.7), size: 20),
          border: InputBorder.none,
          focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppTheme.primary, width: 1.5)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
        ),
      ),
    );
  }
}
