import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show TextInputFormatter, TextEditingValue, TextSelection;
import 'package:get/get.dart';
import '../../../controllers/validation_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/responsive.dart';
import 'section_card.dart';

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

class InfoStepView extends StatelessWidget {
  final ValidationController ctrl;
  const InfoStepView({super.key, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final pad = R.isTablet(context) ? 20.0 : 16.0;
    return SingleChildScrollView(
      padding: EdgeInsets.all(pad),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Titre ──────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              'Informations client',
              style: TextStyle(
                fontSize: R.fs(context, 18),
                fontWeight: FontWeight.w800,
                color: AppTheme.textDark,
              ),
            ),
          ),

          // ── Identité du client ────────────────────────────────────
          SectionCard(
            title: 'Identité du client',
            child: Column(
              children: [
                TextFormField(
                  controller: ctrl.clientNameCtrl,
                  style: TextStyle(fontSize: R.fs(context, 14)),
                  decoration: InputDecoration(
                    labelText: 'Nom du client *',
                    hintText: 'Nom ou raison sociale',
                    labelStyle: TextStyle(fontSize: R.fs(context, 13.5)),
                    prefixIcon:
                        Icon(Icons.person_outline, size: R.icon(context, 20)),
                  ),
                ),
                SizedBox(height: R.gap(context) * 0.8),
                TextFormField(
                  controller: ctrl.clientPhoneCtrl,
                  style: TextStyle(fontSize: R.fs(context, 14)),
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Téléphone *',
                    hintText: 'Ex: 0709080765',
                    labelStyle: TextStyle(fontSize: R.fs(context, 13.5)),
                    prefixIcon:
                        Icon(Icons.phone_outlined, size: R.icon(context, 20)),
                  ),
                ),
                SizedBox(height: R.gap(context) * 0.8),
                TextFormField(
                  controller: ctrl.clientEmailCtrl,
                  style: TextStyle(fontSize: R.fs(context, 14)),
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email *',
                    hintText: 'email@exemple.ci',
                    labelStyle: TextStyle(fontSize: R.fs(context, 13.5)),
                    prefixIcon:
                        Icon(Icons.email_outlined, size: R.icon(context, 20)),
                  ),
                ),
                SizedBox(height: R.gap(context) * 0.8),
                Obx(() => ctrl.template.value == 'B2B'
                    ? TextFormField(
                        controller: ctrl.clientNccCtrl,
                        style: TextStyle(fontSize: R.fs(context, 14)),
                        decoration: InputDecoration(
                          labelText: 'NCC du client *',
                          labelStyle: TextStyle(fontSize: R.fs(context, 13.5)),
                          prefixIcon: Icon(Icons.badge_outlined,
                              size: R.icon(context, 20)),
                        ),
                      )
                    : const SizedBox.shrink()),
              ],
            ),
          ),
          SizedBox(height: R.gap(context)),

          // ── Paramètres de facturation ─────────────────────────────
          SectionCard(
            title: 'Paramètres de facturation',
            child: Column(
              children: [
                Obx(() => DropdownButtonFormField<String>(
                      initialValue: ctrl.template.value,
                      decoration: InputDecoration(
                        labelText: 'Type de facturation *',
                        labelStyle: TextStyle(fontSize: R.fs(context, 13.5)),
                        prefixIcon: Icon(Icons.account_tree_outlined,
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
                        if (v != null) ctrl.template.value = v;
                      },
                    )),
                SizedBox(height: R.gap(context) * 0.8),
                Obx(() => DropdownButtonFormField<String>(
                      initialValue: ctrl.paymentMethod.value,
                      decoration: InputDecoration(
                        labelText: 'Méthode de paiement *',
                        labelStyle: TextStyle(fontSize: R.fs(context, 13.5)),
                        prefixIcon: Icon(Icons.payment_outlined,
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
                        if (v != null) ctrl.paymentMethod.value = v;
                      },
                    )),
                SizedBox(height: R.gap(context) * 0.8),
                TextFormField(
                  controller: ctrl.dateCtrl,
                  style: TextStyle(fontSize: R.fs(context, 14)),
                  keyboardType: TextInputType.number,
                  inputFormatters: [_DateFormatter()],
                  decoration: InputDecoration(
                    labelText: 'Date de la facture',
                    hintText: 'jj/mm/aaaa',
                    labelStyle: TextStyle(fontSize: R.fs(context, 13.5)),
                    prefixIcon: Icon(Icons.calendar_today_outlined,
                        size: R.icon(context, 18)),
                  ),
                ),
                SizedBox(height: R.gap(context) * 0.4),
                Obx(() => SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        'Lié à un reçu (RNE)',
                        style: TextStyle(fontSize: R.fs(context, 14)),
                      ),
                      value: ctrl.isRne.value,
                      activeThumbColor: AppTheme.primary,
                      onChanged: (v) => ctrl.isRne.value = v,
                    )),
                Obx(() => ctrl.isRne.value
                    ? TextFormField(
                        controller: ctrl.rneCtrl,
                        style: TextStyle(fontSize: R.fs(context, 14)),
                        decoration: InputDecoration(
                          labelText: 'Numéro du reçu (RNE) *',
                          labelStyle: TextStyle(fontSize: R.fs(context, 13.5)),
                          prefixIcon: Icon(Icons.receipt_outlined,
                              size: R.icon(context, 20)),
                        ),
                      )
                    : const SizedBox.shrink()),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _DateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Ne garder que les chiffres
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');

    // Construire dd/mm/yyyy (max 8 chiffres → 10 chars avec les /)
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length && i < 8; i++) {
      if (i == 2 || i == 4) buffer.write('/');
      buffer.write(digits[i]);
    }

    // Ajouter automatiquement '/' dès le 2e et 4e chiffre saisi (pas en suppression)
    final isAdding = newValue.text.length >= oldValue.text.length;
    if (isAdding && (digits.length == 2 || digits.length == 4)) {
      buffer.write('/');
    }

    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
