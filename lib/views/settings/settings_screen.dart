import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/settings_controller.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive.dart';

const Map<String, String> kPaymentMethods = {
  'mobile-money': 'Mobile Money',
  'cash': 'Espèces',
  'card': 'Carte bancaire',
  'check': 'Chèque',
  'transfer': 'Virement bancaire',
  'deferred': 'À terme',
};

const Map<String, String> kTemplates = {
  'B2B': 'B2B — Entreprise (NCC)',
  'B2C': 'B2C — Particulier',
  'B2G': 'B2G — Gouvernement',
  'B2F': 'B2F — International',
};

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(SettingsController());

    return Scaffold(
      appBar: AppBar(
        title: Text('Paramètres',
            style: TextStyle(fontSize: R.fs(context, 18))),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(
          horizontal: R.hPad(context),
          vertical: R.vPad(context),
        ),
        child: R.centered(context,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Identité du vendeur ───────────────────────────
                _SectionCard(
                  icon: Icons.storefront,
                  title: 'Identité du vendeur',
                  child: Column(
                    children: [
                      _Field(
                        controller: ctrl.establishmentCtrl,
                        label: 'Nom de l\'établissement *',
                        hint: 'Ex : AMANI DIGITAL SERVICES',
                        icon: Icons.business,
                      ),
                      SizedBox(height: R.gap(context) * 0.8),
                      _Field(
                        controller: ctrl.pointOfSaleCtrl,
                        label: 'ID du point de vente *',
                        hint: 'Numéro fourni par la DGI',
                        icon: Icons.pin,
                        keyboardType: TextInputType.number,
                      ),
                      SizedBox(height: R.gap(context) * 0.8),
                      _Field(
                        controller: ctrl.sellerNameCtrl,
                        label: 'Nom du vendeur',
                        hint: 'Ex : Ali Hassan',
                        icon: Icons.person,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: R.gap(context)),

                // ── Préférences de facturation ────────────────────
                _SectionCard(
                  icon: Icons.tune,
                  title: 'Préférences de facturation',
                  child: Column(
                    children: [
                      Obx(() => DropdownButtonFormField<String>(
                            initialValue: ctrl.defaultPaymentMethod.value,
                            decoration: InputDecoration(
                              labelText: 'Mode de paiement par défaut',
                              labelStyle:
                                  TextStyle(fontSize: R.fs(context, 13.5)),
                              prefixIcon: Icon(Icons.payment,
                                  size: R.icon(context, 20)),
                            ),
                            style: TextStyle(
                                fontSize: R.fs(context, 14),
                                color: AppTheme.textDark),
                            items: kPaymentMethods.entries
                                .map((e) => DropdownMenuItem(
                                    value: e.key, child: Text(e.value)))
                                .toList(),
                            onChanged: (v) {
                              if (v != null) ctrl.defaultPaymentMethod.value = v;
                            },
                          )),
                      SizedBox(height: R.gap(context) * 0.8),
                      Obx(() => DropdownButtonFormField<String>(
                            initialValue: ctrl.defaultTemplate.value,
                            decoration: InputDecoration(
                              labelText: 'Type de facturation par défaut',
                              labelStyle:
                                  TextStyle(fontSize: R.fs(context, 13.5)),
                              prefixIcon: Icon(Icons.account_tree,
                                  size: R.icon(context, 20)),
                            ),
                            style: TextStyle(
                                fontSize: R.fs(context, 14),
                                color: AppTheme.textDark),
                            items: kTemplates.entries
                                .map((e) => DropdownMenuItem(
                                    value: e.key, child: Text(e.value)))
                                .toList(),
                            onChanged: (v) {
                              if (v != null) ctrl.defaultTemplate.value = v;
                            },
                          )),
                    ],
                  ),
                ),
                SizedBox(height: R.gap(context)),

                // ── Personnalisation de la facture ────────────────
                _SectionCard(
                  icon: Icons.edit_note,
                  title: 'Personnalisation de la facture',
                  child: Column(
                    children: [
                      _Field(
                        controller: ctrl.commercialMessageCtrl,
                        label: 'Message commercial',
                        hint: 'Ex : Soyez les bienvenus',
                        icon: Icons.campaign,
                        maxLines: 2,
                      ),
                      SizedBox(height: R.gap(context) * 0.8),
                      _Field(
                        controller: ctrl.footerCtrl,
                        label: 'Pied de page',
                        hint: 'Ex : Toujours là pour votre bonheur',
                        icon: Icons.notes,
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: R.gap(context) * 1.5),

                // Bouton Enregistrer
                SizedBox(
                  width: double.infinity,
                  height: R.btnH(context),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      ctrl.save();
                    },
                    icon: Icon(Icons.save, size: R.icon(context, 20)),
                    label: Text('Enregistrer',
                        style: TextStyle(fontSize: R.fs(context, 15))),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            )),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;
  const _SectionCard(
      {required this.icon, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(R.radius(context))),
      child: Padding(
        padding: EdgeInsets.all(R.isTablet(context) ? 20 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppTheme.primary, size: R.icon(context, 18)),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: R.fs(context, 13.5),
                    color: AppTheme.primary,
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            child,
          ],
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final TextInputType keyboardType;
  final int maxLines;

  const _Field({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: TextStyle(fontSize: R.fs(context, 14)),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: TextStyle(fontSize: R.fs(context, 13.5)),
        prefixIcon: maxLines == 1
            ? Icon(icon, size: R.icon(context, 20))
            : Padding(
                padding: const EdgeInsets.only(bottom: 40),
                child: Icon(icon, size: R.icon(context, 20)),
              ),
      ),
    );
  }
}
