import 'package:flutter/material.dart';
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
        children: [
          // ── Informations générales ─────────────────────────
          SectionCard(
            title: 'Informations générales',
            child: Column(
              children: [
                TextFormField(
                  controller: ctrl.clientNameCtrl,
                  style: TextStyle(fontSize: R.fs(context, 14)),
                  decoration: InputDecoration(
                    labelText: 'Nom du client *',
                    labelStyle: TextStyle(fontSize: R.fs(context, 13.5)),
                    prefixIcon: Icon(Icons.person_outline, size: R.icon(context, 20)),
                  ),
                ),
                SizedBox(height: R.gap(context) * 0.8),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: ctrl.dateCtrl,
                        style: TextStyle(fontSize: R.fs(context, 14)),
                        decoration: InputDecoration(
                          labelText: 'Date (jj/mm/aaaa)',
                          labelStyle: TextStyle(fontSize: R.fs(context, 12.5)),
                          prefixIcon: Icon(Icons.calendar_today,
                              size: R.icon(context, 18)),
                        ),
                      ),
                    ),
                    SizedBox(width: R.gap(context) * 0.7),
                    Expanded(
                      child: TextFormField(
                        controller: ctrl.invoiceNumberCtrl,
                        style: TextStyle(fontSize: R.fs(context, 14)),
                        decoration: InputDecoration(
                          labelText: 'N° Facture',
                          labelStyle: TextStyle(fontSize: R.fs(context, 12.5)),
                          prefixIcon:
                              Icon(Icons.tag, size: R.icon(context, 18)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: R.gap(context)),

          // ── Informations client ────────────────────────────
          SectionCard(
            title: 'Contact Client',
            child: Column(
              children: [
                TextFormField(
                  controller: ctrl.clientPhoneCtrl,
                  style: TextStyle(fontSize: R.fs(context, 14)),
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Téléphone *',
                    labelStyle: TextStyle(fontSize: R.fs(context, 13.5)),
                    prefixIcon: Icon(Icons.phone, size: R.icon(context, 20)),
                  ),
                ),
                SizedBox(height: R.gap(context) * 0.8),
                TextFormField(
                  controller: ctrl.clientEmailCtrl,
                  style: TextStyle(fontSize: R.fs(context, 14)),
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'E-mail *',
                    labelStyle: TextStyle(fontSize: R.fs(context, 13.5)),
                    prefixIcon: Icon(Icons.email, size: R.icon(context, 20)),
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
                          prefixIcon:
                              Icon(Icons.badge, size: R.icon(context, 20)),
                        ),
                      )
                    : const SizedBox.shrink()),
              ],
            ),
          ),
          SizedBox(height: R.gap(context)),

          // ── Paramètres FNE ─────────────────────────────────
          SectionCard(
            title: 'Paramètres FNE',
            child: Column(
              children: [
                Obx(() => DropdownButtonFormField<String>(
                      value: ctrl.paymentMethod.value,
                      decoration: InputDecoration(
                        labelText: 'Mode de paiement',
                        labelStyle: TextStyle(fontSize: R.fs(context, 13.5)),
                        prefixIcon:
                            Icon(Icons.payment, size: R.icon(context, 20)),
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
                Obx(() => DropdownButtonFormField<String>(
                      value: ctrl.template.value,
                      decoration: InputDecoration(
                        labelText: 'Type de facturation',
                        labelStyle: TextStyle(fontSize: R.fs(context, 13.5)),
                        prefixIcon:
                            Icon(Icons.account_tree, size: R.icon(context, 20)),
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
                          labelText: 'Numéro du reçu (RNE)',
                          labelStyle: TextStyle(fontSize: R.fs(context, 13.5)),
                          prefixIcon:
                              Icon(Icons.receipt, size: R.icon(context, 20)),
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
