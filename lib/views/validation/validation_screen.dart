import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../fne_result/fne_web_view_screen.dart';
import '../../controllers/acquisition_controller.dart';
import '../../controllers/validation_controller.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/responsive.dart';
import '../../models/extracted_invoice.dart';
import '../../models/invoice_item.dart';

// Libellés pour les dropdowns
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

class ValidationScreen extends StatelessWidget {
  const ValidationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<ValidationController>();
    AcquisitionController? acqCtrl;
    try {
      acqCtrl = Get.find<AcquisitionController>();
    } catch (_) {}

    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(
              _appBarTitle(ctrl.state.value),
              style: TextStyle(fontSize: R.fs(context, 18)),
            )),
        actions: [
          Obx(() {
            if (ctrl.state.value == ValidationState.reviewing) {
              return TextButton.icon(
                onPressed: ctrl.addItem,
                icon: Icon(Icons.add,
                    color: Colors.white, size: R.icon(context, 20)),
                label: Text('Ajouter',
                    style: TextStyle(
                        color: Colors.white, fontSize: R.fs(context, 14))),
              );
            }
            return const SizedBox.shrink();
          }),
          if (R.isTablet(context)) SizedBox(width: R.hPad(context) - 16),
        ],
      ),
      body: Obx(() {
        switch (ctrl.state.value) {
          case ValidationState.extracting:
            return _ExtractionLoader();
          case ValidationState.reviewing:
          case ValidationState.submitting:
            if (R.isTablet(context)) {
              return _TabletLayout(ctrl: ctrl, acqCtrl: acqCtrl);
            }
            return _ReviewForm(ctrl: ctrl);
          case ValidationState.success:
            WidgetsBinding.instance.addPostFrameCallback((_) {
              final record = ctrl.generatedFne.value;
              Get.back();
              if (record != null && record.qrCode != null) {
                Get.to(() => FneWebViewScreen(url: record.qrCode!));
              }
            });
            return const Center(
                child: CircularProgressIndicator(color: AppTheme.primary));
          case ValidationState.error:
            return _ErrorView(ctrl: ctrl);
          default:
            return const SizedBox.shrink();
        }
      }),
    );
  }

  String _appBarTitle(ValidationState state) {
    switch (state) {
      case ValidationState.extracting:
        return 'Analyse en cours...';
      case ValidationState.submitting:
        return 'Certification en cours...';
      default:
        return 'Vérification des données';
    }
  }
}

// ── Loader extraction ─────────────────────────────────────────────────────────
class _ExtractionLoader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(R.hPad(context)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: R.icon(context, 100),
              height: R.icon(context, 100),
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: CircularProgressIndicator(
                    color: AppTheme.primary,
                    strokeWidth: R.isTablet(context) ? 4 : 3),
              ),
            ),
            SizedBox(height: R.gap(context) * 1.5),
            Text(
              'Analyse en cours',
              style: TextStyle(
                fontSize: R.fs(context, 20),
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: R.gap(context) * 0.6),
            Text(
              'Extraction des données\nde votre facture...',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: R.fs(context, 15),
                color: AppTheme.textGrey.withValues(alpha: 0.8),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Layout tablette (split view) ──────────────────────────────────────────────
class _TabletLayout extends StatelessWidget {
  final ValidationController ctrl;
  final AcquisitionController? acqCtrl;
  const _TabletLayout({required this.ctrl, required this.acqCtrl});

  @override
  Widget build(BuildContext context) {
    final file = acqCtrl?.selectedFile.value;
    final isPdf = acqCtrl?.selectedMimeType.value == 'application/pdf';
    final formWidth = R.isLargeTablet(context) ? 520.0 : 440.0;

    return Row(
      children: [
        Expanded(
          child: Container(
            color: Colors.black87,
            child: file != null && !isPdf
                ? InteractiveViewer(
                    child: Center(
                        child: Image.file(file, fit: BoxFit.contain)))
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.picture_as_pdf,
                            size: R.icon(context, 100),
                            color: Colors.white54),
                        const SizedBox(height: 12),
                        Text(
                          file != null
                              ? file.path.split('/').last
                              : 'Aucun document',
                          style: TextStyle(
                              color: Colors.white54,
                              fontSize: R.fs(context, 13)),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
        SizedBox(
          width: formWidth,
          child: _ReviewForm(ctrl: ctrl),
        ),
      ],
    );
  }
}

// ── Formulaire de validation ──────────────────────────────────────────────────
class _ReviewForm extends StatelessWidget {
  final ValidationController ctrl;
  const _ReviewForm({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final pad = R.isTablet(context) ? 20.0 : 16.0;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.all(pad),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Bannière info si prix TTC détecté
                Obx(() {
                  final inv = ctrl.invoice.value;
                  if (inv == null || inv.priceType != PriceType.ttc) {
                    return const SizedBox.shrink();
                  }
                  return Container(
                    width: double.infinity,
                    margin: EdgeInsets.only(bottom: R.gap(context)),
                    padding: EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: R.isTablet(context) ? 14 : 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(R.radius(context)),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline,
                            color: Colors.blue.shade600,
                            size: R.icon(context, 20)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Prix TTC détectés sur la facture. '
                            'Les prix HT ont été calculés automatiquement (÷ 1.18).',
                            style: TextStyle(
                              color: Colors.blue.shade700,
                              fontSize: R.fs(context, 12.5),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),

                // Section : Informations générales
                _SectionCard(
                  title: 'Informations générales',
                  child: Column(
                    children: [
                      TextFormField(
                        controller: ctrl.clientNameCtrl,
                        style: TextStyle(fontSize: R.fs(context, 14)),
                        decoration: InputDecoration(
                          labelText: 'Nom du client *',
                          labelStyle:
                              TextStyle(fontSize: R.fs(context, 13.5)),
                          prefixIcon: Icon(Icons.store,
                              size: R.icon(context, 20)),
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
                                labelStyle: TextStyle(
                                    fontSize: R.fs(context, 12.5)),
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
                                labelStyle: TextStyle(
                                    fontSize: R.fs(context, 12.5)),
                                prefixIcon: Icon(Icons.tag,
                                    size: R.icon(context, 18)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: R.gap(context)),

                // Section : Informations client (FNE)
                _SectionCard(
                  title: 'Informations client',
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: ctrl.clientPhoneCtrl,
                              style: TextStyle(fontSize: R.fs(context, 14)),
                              keyboardType: TextInputType.phone,
                              decoration: InputDecoration(
                                labelText: 'Téléphone *',
                                labelStyle: TextStyle(
                                    fontSize: R.fs(context, 13.5)),
                                prefixIcon: Icon(Icons.phone,
                                    size: R.icon(context, 20)),
                              ),
                            ),
                          ),
                          SizedBox(width: R.gap(context) * 0.7),
                          Expanded(
                            child: TextFormField(
                              controller: ctrl.clientEmailCtrl,
                              style: TextStyle(fontSize: R.fs(context, 14)),
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                labelText: 'E-mail *',
                                labelStyle: TextStyle(
                                    fontSize: R.fs(context, 13.5)),
                                prefixIcon: Icon(Icons.email,
                                    size: R.icon(context, 20)),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: R.gap(context) * 0.8),
                      // NCC visible seulement si template B2B
                      Obx(() => ctrl.template.value == 'B2B'
                          ? TextFormField(
                              controller: ctrl.clientNccCtrl,
                              style: TextStyle(fontSize: R.fs(context, 14)),
                              decoration: InputDecoration(
                                labelText: 'NCC du client *',
                                labelStyle: TextStyle(
                                    fontSize: R.fs(context, 13.5)),
                                prefixIcon: Icon(Icons.badge,
                                    size: R.icon(context, 20)),
                              ),
                            )
                          : const SizedBox.shrink()),
                    ],
                  ),
                ),
                SizedBox(height: R.gap(context)),

                // Section : Paramètres FNE
                _SectionCard(
                  title: 'Paramètres FNE',
                  child: Column(
                    children: [
                      Obx(() => DropdownButtonFormField<String>(
                            initialValue: ctrl.paymentMethod.value,
                            decoration: InputDecoration(
                              labelText: 'Mode de paiement',
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
                                      value: e.key,
                                      child: Text(e.value),
                                    ))
                                .toList(),
                            onChanged: (v) {
                              if (v != null) ctrl.paymentMethod.value = v;
                            },
                          )),
                      SizedBox(height: R.gap(context) * 0.8),
                      Obx(() => DropdownButtonFormField<String>(
                            initialValue: ctrl.template.value,
                            decoration: InputDecoration(
                              labelText: 'Type de facturation',
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
                                      value: e.key,
                                      child: Text(e.value),
                                    ))
                                .toList(),
                            onChanged: (v) {
                              if (v != null) ctrl.template.value = v;
                            },
                          )),
                      SizedBox(height: R.gap(context) * 0.8),
                      Obx(() => DropdownButtonFormField<String>(
                            initialValue: ctrl.globalTaxCode.value,
                            decoration: InputDecoration(
                              labelText: 'Type de TVA (tous les articles)',
                              labelStyle:
                                  TextStyle(fontSize: R.fs(context, 13.5)),
                              prefixIcon: Icon(Icons.percent,
                                  size: R.icon(context, 20)),
                            ),
                            style: TextStyle(
                                fontSize: R.fs(context, 14),
                                color: AppTheme.textDark),
                            items: kTaxLabels.entries
                                .map((e) => DropdownMenuItem(
                                      value: e.key,
                                      child: Text(e.value),
                                    ))
                                .toList(),
                            onChanged: (v) {
                              if (v != null) ctrl.applyGlobalTaxCode(v);
                            },
                          )),
                      SizedBox(height: R.gap(context) * 0.4),
                      // Lié à un reçu (RNE)
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
                                labelStyle:
                                    TextStyle(fontSize: R.fs(context, 13.5)),
                                prefixIcon: Icon(Icons.receipt,
                                    size: R.icon(context, 20)),
                              ),
                            )
                          : const SizedBox.shrink()),
                      // Devise étrangère — visible uniquement en B2F
                      Obx(() => ctrl.template.value == 'B2F'
                          ? Column(
                              children: [
                                SizedBox(height: R.gap(context) * 0.8),
                                DropdownButtonFormField<String>(
                                  initialValue: ctrl.foreignCurrency.value,
                                  decoration: InputDecoration(
                                    labelText: 'Devise étrangère *',
                                    labelStyle: TextStyle(
                                        fontSize: R.fs(context, 13.5)),
                                    prefixIcon: Icon(Icons.currency_exchange,
                                        size: R.icon(context, 20)),
                                  ),
                                  style: TextStyle(
                                      fontSize: R.fs(context, 14),
                                      color: AppTheme.textDark),
                                  items: kForeignCurrencies.entries
                                      .map((e) => DropdownMenuItem(
                                          value: e.key,
                                          child: Text(e.value,
                                              overflow:
                                                  TextOverflow.ellipsis)))
                                      .toList(),
                                  onChanged: (v) {
                                    if (v != null) {
                                      ctrl.foreignCurrency.value = v;
                                    }
                                  },
                                ),
                                SizedBox(height: R.gap(context) * 0.8),
                                TextFormField(
                                  controller: ctrl.foreignCurrencyRateCtrl,
                                  style:
                                      TextStyle(fontSize: R.fs(context, 14)),
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    labelText: 'Taux de change *',
                                    hintText: 'Ex : 655',
                                    labelStyle: TextStyle(
                                        fontSize: R.fs(context, 13.5)),
                                    prefixIcon: Icon(Icons.swap_horiz,
                                        size: R.icon(context, 20)),
                                  ),
                                ),
                              ],
                            )
                          : const SizedBox.shrink()),
                    ],
                  ),
                ),
                SizedBox(height: R.gap(context)),

                // En-tête articles
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Articles',
                      style: TextStyle(
                        fontSize: R.fs(context, 16),
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: ctrl.addItem,
                      icon: Icon(Icons.add, size: R.icon(context, 18)),
                      label: Text('Ajouter',
                          style: TextStyle(fontSize: R.fs(context, 13))),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Obx(() => Column(
                      children: List.generate(
                        ctrl.itemControllers.length,
                        (i) => _ItemCard(ctrl: ctrl, index: i),
                      ),
                    )),
                SizedBox(height: R.gap(context)),
                Obx(() => _TotalsCard(invoice: ctrl.invoice.value)),
                SizedBox(height: R.btnH(context) + 20),
              ],
            ),
          ),
        ),
        _SubmitBar(ctrl: ctrl),
      ],
    );
  }
}

// ── Carte section ─────────────────────────────────────────────────────────────
class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _SectionCard({required this.title, required this.child});

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
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: R.fs(context, 13.5),
                color: AppTheme.primary,
              ),
            ),
            const Divider(height: 20),
            child,
          ],
        ),
      ),
    );
  }
}

// ── Carte article ─────────────────────────────────────────────────────────────
class _ItemCard extends StatelessWidget {
  final ValidationController ctrl;
  final int index;
  const _ItemCard({required this.ctrl, required this.index});

  @override
  Widget build(BuildContext context) {
    final isTablet = R.isTablet(context);
    final fieldStyle = TextStyle(fontSize: R.fs(context, 13.5));
    final labelStyle = TextStyle(fontSize: R.fs(context, 13));
    final gap = R.gap(context) * 0.7;

    // Tout accès aux RxList doit être à l'intérieur de Obx
    return Obx(() {
      if (index >= ctrl.itemControllers.length ||
          index >= ctrl.itemTaxCodes.length) {
        return const SizedBox.shrink();
      }
      final ctrls = ctrl.itemControllers[index];
      final currentTaxCode = ctrl.itemTaxCodes[index].value;
      final inv = ctrl.invoice.value;

      return Card(
        margin: EdgeInsets.only(bottom: R.gap(context) * 0.8),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(R.radius(context))),
        child: Padding(
          padding: EdgeInsets.all(isTablet ? 18 : 14),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Article ${index + 1}',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primary,
                        fontSize: R.fs(context, 14),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete_outline,
                        color: Colors.red, size: R.icon(context, 20)),
                    onPressed: () => ctrl.removeItem(index),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              SizedBox(height: gap),
              TextFormField(
                controller: ctrls['designation'],
                style: fieldStyle,
                decoration: InputDecoration(
                    labelText: 'Désignation', labelStyle: labelStyle),
                onChanged: (_) => ctrl.updateItemFromControllers(index),
              ),
              SizedBox(height: gap),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: ctrls['quantity'],
                      style: fieldStyle,
                      decoration: InputDecoration(
                          labelText: 'Quantité', labelStyle: labelStyle),
                      keyboardType: TextInputType.number,
                      onChanged: (_) => ctrl.updateItemFromControllers(index),
                    ),
                  ),
                  SizedBox(width: gap),
                  Expanded(
                    flex: isTablet ? 2 : 1,
                    child: TextFormField(
                      controller: ctrls['unitPrice'],
                      style: fieldStyle,
                      decoration: InputDecoration(
                          labelText: 'Prix HT (FCFA)', labelStyle: labelStyle),
                      keyboardType: TextInputType.number,
                      onChanged: (_) => ctrl.updateItemFromControllers(index),
                    ),
                  ),
                  SizedBox(width: gap),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: currentTaxCode,
                      decoration: InputDecoration(
                          labelText: 'TVA', labelStyle: labelStyle),
                      style: TextStyle(
                          fontSize: R.fs(context, 13.5),
                          color: AppTheme.textDark),
                      isExpanded: true,
                      items: kTaxLabels.entries
                          .map((e) => DropdownMenuItem(
                              value: e.key,
                              child: Text(e.value,
                                  overflow: TextOverflow.ellipsis)))
                          .toList(),
                      onChanged: (v) {
                        if (v != null) {
                          ctrl.itemTaxCodes[index].value = v;
                          ctrl.updateItemFromControllers(index);
                        }
                      },
                    ),
                  ),
                ],
              ),
              if (inv != null && index < inv.items.length) ...[
                SizedBox(height: gap),
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: 14, vertical: isTablet ? 10 : 8),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(R.radius(context)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total TTC:',
                          style: TextStyle(
                              color: AppTheme.textGrey,
                              fontSize: R.fs(context, 13))),
                      Text(
                        AppFormatters.currency(inv.items[index].amountTTC),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primary,
                          fontSize: R.fs(context, 14),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    });
  }
}

// ── Carte totaux ──────────────────────────────────────────────────────────────
class _TotalsCard extends StatelessWidget {
  final ExtractedInvoice? invoice;
  const _TotalsCard({required this.invoice});

  @override
  Widget build(BuildContext context) {
    if (invoice == null) return const SizedBox.shrink();
    return Card(
      color: AppTheme.primary,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(R.radius(context))),
      child: Padding(
        padding: EdgeInsets.all(R.isTablet(context) ? 20 : 16),
        child: Column(
          children: [
            _TotalRow(label: 'Total HT', value: invoice!.totalHT),
            const Divider(color: Colors.white24, height: 16),
            _TotalRow(label: 'TVA', value: invoice!.totalTVA),
            const Divider(color: Colors.white24, height: 16),
            _TotalRow(
                label: 'Total TTC', value: invoice!.totalTTC, isMain: true),
          ],
        ),
      ),
    );
  }
}

class _TotalRow extends StatelessWidget {
  final String label;
  final double value;
  final bool isMain;
  const _TotalRow(
      {required this.label, required this.value, this.isMain = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.85),
            fontSize: R.fs(context, isMain ? 15 : 13.5),
            fontWeight: isMain ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          AppFormatters.currency(value),
          style: TextStyle(
            color: Colors.white,
            fontSize: R.fs(context, isMain ? 17 : 14),
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

// ── Barre de soumission ───────────────────────────────────────────────────────
class _SubmitBar extends StatelessWidget {
  final ValidationController ctrl;
  const _SubmitBar({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final isSubmitting = ctrl.state.value == ValidationState.submitting;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: R.hPad(context),
        vertical: R.isTablet(context) ? 18 : 14,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black12, blurRadius: 8, offset: Offset(0, -2))
        ],
      ),
      child: SafeArea(
        child: R.centered(context,
            child: SizedBox(
              width: double.infinity,
              height: R.btnH(context),
              child: ElevatedButton.icon(
                onPressed: isSubmitting ? null : ctrl.submitAndSign,
                icon: isSubmitting
                    ? SizedBox(
                        width: R.icon(context, 20),
                        height: R.icon(context, 20),
                        child: const CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : Icon(Icons.verified, size: R.icon(context, 20)),
                label: Text(
                  isSubmitting ? 'Certification en cours...' : 'Certifier la FNE',
                  style: TextStyle(fontSize: R.fs(context, 15)),
                ),
              ),
            )),
      ),
    );
  }
}

// ── Vue erreur ────────────────────────────────────────────────────────────────
class _ErrorView extends StatelessWidget {
  final ValidationController ctrl;
  const _ErrorView({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(R.hPad(context)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline,
                size: R.icon(context, 80), color: Colors.red),
            SizedBox(height: R.gap(context)),
            Text(
              'Une erreur est survenue',
              style: TextStyle(
                fontSize: R.fs(context, 20),
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: R.gap(context) * 0.7),
            Obx(() => Text(
                  ctrl.errorMessage.value,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: AppTheme.textGrey, fontSize: R.fs(context, 14)),
                )),
            SizedBox(height: R.gap(context) * 1.8),
            ElevatedButton.icon(
              onPressed: ctrl.resetToReviewing,
              icon: Icon(Icons.refresh, size: R.icon(context, 20)),
              label: Text('Modifier et réessayer',
                  style: TextStyle(fontSize: R.fs(context, 15))),
            ),
          ],
        ),
      ),
    );
  }
}
