import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/acquisition_controller.dart';
import '../../controllers/validation_controller.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/responsive.dart';
import '../../models/extracted_invoice.dart';
import '../fne_result/fne_result_screen.dart';

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
          case ValidationState.submittingStep1:
            if (R.isTablet(context)) {
              return _TabletLayout(ctrl: ctrl, acqCtrl: acqCtrl);
            }
            return _ReviewForm(ctrl: ctrl);
          case ValidationState.confirming:
          case ValidationState.submittingStep2:
            return _ConfirmationView(ctrl: ctrl);
          case ValidationState.success:
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (ctrl.generatedFne.value != null) {
                Get.off(() =>
                    FneResultScreen(record: ctrl.generatedFne.value!));
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
      case ValidationState.reviewing:
      case ValidationState.submittingStep1:
        return 'Vérification des données';
      case ValidationState.confirming:
      case ValidationState.submittingStep2:
        return 'Confirmation FNE';
      default:
        return 'Traitement';
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
              'Analyse intelligente en cours',
              style: TextStyle(
                fontSize: R.fs(context, 20),
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: R.gap(context) * 0.6),
            Text(
              'Gemini AI extrait les données\nde votre facture...',
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
    // Sur grande tablette : panneau formulaire plus large
    final formWidth = R.isLargeTablet(context) ? 520.0 : 440.0;

    return Row(
      children: [
        // Gauche : prévisualisation de la facture originale
        Expanded(
          child: Container(
            color: Colors.black87,
            child: file != null && !isPdf
                ? InteractiveViewer(
                    child:
                        Center(child: Image.file(file, fit: BoxFit.contain)))
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
        // Droite : formulaire de validation
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
            padding: EdgeInsets.all(pad),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Infos générales
                _SectionCard(
                  title: 'Informations générales',
                  child: Column(
                    children: [
                      TextFormField(
                        controller: ctrl.clientNameCtrl,
                        style: TextStyle(fontSize: R.fs(context, 14)),
                        decoration: InputDecoration(
                          labelText: 'Nom du client',
                          labelStyle:
                              TextStyle(fontSize: R.fs(context, 13.5)),
                          prefixIcon:
                              Icon(Icons.store, size: R.icon(context, 20)),
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
        Obx(() => _SubmitBar(ctrl: ctrl)),
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
    if (index >= ctrl.itemControllers.length) return const SizedBox.shrink();
    final ctrls = ctrl.itemControllers[index];
    final isTablet = R.isTablet(context);
    final fieldStyle = TextStyle(fontSize: R.fs(context, 13.5));
    final labelStyle = TextStyle(fontSize: R.fs(context, 13));
    final gap = R.gap(context) * 0.7;

    return Card(
      margin: EdgeInsets.only(bottom: R.gap(context) * 0.8),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(R.radius(context))),
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 18 : 14),
        child: Column(
          children: [
            // En-tête article
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
                  labelText: 'Désignation',
                  labelStyle: labelStyle),
              onChanged: (_) => ctrl.updateItemFromControllers(index),
            ),
            SizedBox(height: gap),
            // Sur tablette : 4 champs en 2 colonnes
            if (isTablet) ...[
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: ctrls['quantity'],
                      style: fieldStyle,
                      decoration: InputDecoration(
                          labelText: 'Quantité', labelStyle: labelStyle),
                      keyboardType: TextInputType.number,
                      onChanged: (_) =>
                          ctrl.updateItemFromControllers(index),
                    ),
                  ),
                  SizedBox(width: gap),
                  Expanded(
                    child: TextFormField(
                      controller: ctrls['unitPrice'],
                      style: fieldStyle,
                      decoration: InputDecoration(
                          labelText: 'Prix HT (FCFA)',
                          labelStyle: labelStyle),
                      keyboardType: TextInputType.number,
                      onChanged: (_) =>
                          ctrl.updateItemFromControllers(index),
                    ),
                  ),
                  SizedBox(width: gap),
                  Expanded(
                    child: TextFormField(
                      controller: ctrls['tvaRate'],
                      style: fieldStyle,
                      decoration: InputDecoration(
                          labelText: 'TVA (%)', labelStyle: labelStyle),
                      keyboardType: TextInputType.number,
                      onChanged: (_) =>
                          ctrl.updateItemFromControllers(index),
                    ),
                  ),
                  SizedBox(width: gap),
                  Expanded(
                    child: TextFormField(
                      controller: ctrls['discount'],
                      style: fieldStyle,
                      decoration: InputDecoration(
                          labelText: 'Remise (%)', labelStyle: labelStyle),
                      keyboardType: TextInputType.number,
                      onChanged: (_) =>
                          ctrl.updateItemFromControllers(index),
                    ),
                  ),
                ],
              ),
            ] else ...[
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: ctrls['quantity'],
                      style: fieldStyle,
                      decoration: InputDecoration(
                          labelText: 'Quantité', labelStyle: labelStyle),
                      keyboardType: TextInputType.number,
                      onChanged: (_) =>
                          ctrl.updateItemFromControllers(index),
                    ),
                  ),
                  SizedBox(width: gap),
                  Expanded(
                    child: TextFormField(
                      controller: ctrls['unitPrice'],
                      style: fieldStyle,
                      decoration: InputDecoration(
                          labelText: 'Prix HT (FCFA)',
                          labelStyle: labelStyle),
                      keyboardType: TextInputType.number,
                      onChanged: (_) =>
                          ctrl.updateItemFromControllers(index),
                    ),
                  ),
                ],
              ),
              SizedBox(height: gap),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: ctrls['tvaRate'],
                      style: fieldStyle,
                      decoration: InputDecoration(
                          labelText: 'TVA (%)', labelStyle: labelStyle),
                      keyboardType: TextInputType.number,
                      onChanged: (_) =>
                          ctrl.updateItemFromControllers(index),
                    ),
                  ),
                  SizedBox(width: gap),
                  Expanded(
                    child: TextFormField(
                      controller: ctrls['discount'],
                      style: fieldStyle,
                      decoration: InputDecoration(
                          labelText: 'Remise (%)', labelStyle: labelStyle),
                      keyboardType: TextInputType.number,
                      onChanged: (_) =>
                          ctrl.updateItemFromControllers(index),
                    ),
                  ),
                ],
              ),
            ],
            SizedBox(height: gap),
            // Total TTC calculé
            Obx(() {
              final inv = ctrl.invoice.value;
              if (inv != null && index < inv.items.length) {
                return Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: 14, vertical: isTablet ? 10 : 8),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.05),
                    borderRadius:
                        BorderRadius.circular(R.radius(context)),
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
                );
              }
              return const SizedBox.shrink();
            }),
          ],
        ),
      ),
    );
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
            _TotalRow(label: 'Total TTC', value: invoice!.totalTTC, isMain: true),
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
    final isSubmitting = ctrl.state.value == ValidationState.submittingStep1;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: R.hPad(context),
        vertical: R.isTablet(context) ? 18 : 14,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, -2))
        ],
      ),
      child: SafeArea(
        child: R.centered(context,
            child: SizedBox(
              width: double.infinity,
              height: R.btnH(context),
              child: ElevatedButton.icon(
                onPressed: isSubmitting ? null : ctrl.submitStep1,
                icon: isSubmitting
                    ? SizedBox(
                        width: R.icon(context, 20),
                        height: R.icon(context, 20),
                        child: const CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : Icon(Icons.send, size: R.icon(context, 20)),
                label: Text(
                  isSubmitting ? 'Envoi en cours...' : 'Soumettre à l\'API FNE',
                  style: TextStyle(fontSize: R.fs(context, 15)),
                ),
              ),
            )),
      ),
    );
  }
}

// ── Vue confirmation (étape 2) ────────────────────────────────────────────────
class _ConfirmationView extends StatelessWidget {
  final ValidationController ctrl;
  const _ConfirmationView({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final inv = ctrl.invoice.value;
    if (inv == null) return const SizedBox.shrink();
    final isGenerating = ctrl.state.value == ValidationState.submittingStep2;
    final isTablet = R.isTablet(context);

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: R.hPad(context),
        vertical: R.vPad(context),
      ),
      child: R.centered(context,
          child: Column(
            children: [
              // Bannière succès étape 1
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(isTablet ? 24 : 18),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(R.radius(context)),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle,
                        color: Colors.green.shade600,
                        size: R.icon(context, 32)),
                    SizedBox(width: isTablet ? 16 : 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Données validées',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade700,
                              fontSize: R.fs(context, 16),
                            ),
                          ),
                          Text(
                            'Pré-enregistrement FNE réussi.\nConfirmez pour générer la FNE officielle.',
                            style: TextStyle(
                                color: Colors.green.shade600,
                                fontSize: R.fs(context, 13)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: R.gap(context) * 1.5),

              // Récapitulatif
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(R.radius(context))),
                child: Padding(
                  padding: EdgeInsets.all(isTablet ? 24 : 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Récapitulatif',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: R.fs(context, 16),
                          color: AppTheme.textDark,
                        ),
                      ),
                      SizedBox(height: R.gap(context)),
                      // Sur tablette : 2 colonnes
                      if (isTablet) ...[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                children: [
                                  _InfoRow('Client', inv.clientName ?? '-'),
                                  _InfoRow('Date', AppFormatters.date(inv.date)),
                                  _InfoRow('N° Facture',
                                      inv.invoiceNumber ?? '-'),
                                  _InfoRow('Nb. articles',
                                      '${inv.items.length} article(s)'),
                                ],
                              ),
                            ),
                            const SizedBox(width: 24),
                            Expanded(
                              child: Column(
                                children: [
                                  _InfoRow('Total HT',
                                      AppFormatters.currency(inv.totalHT)),
                                  _InfoRow('TVA',
                                      AppFormatters.currency(inv.totalTVA)),
                                  _InfoRow(
                                      'Total TTC',
                                      AppFormatters.currency(inv.totalTTC),
                                      bold: true),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ] else ...[
                        _InfoRow('Client', inv.clientName ?? '-'),
                        _InfoRow('Date', AppFormatters.date(inv.date)),
                        _InfoRow('N° Facture', inv.invoiceNumber ?? '-'),
                        _InfoRow('Nb. articles',
                            '${inv.items.length} article(s)'),
                        const Divider(),
                        _InfoRow('Total HT',
                            AppFormatters.currency(inv.totalHT)),
                        _InfoRow(
                            'TVA', AppFormatters.currency(inv.totalTVA)),
                        _InfoRow('Total TTC',
                            AppFormatters.currency(inv.totalTTC),
                            bold: true),
                      ],
                    ],
                  ),
                ),
              ),
              SizedBox(height: R.gap(context) * 1.5),

              // Boutons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed:
                          isGenerating ? null : ctrl.resetToReviewing,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.primary,
                        side: const BorderSide(color: AppTheme.primary),
                        padding: EdgeInsets.symmetric(
                            vertical: isTablet ? 16 : 14),
                      ),
                      child: Text('Modifier',
                          style: TextStyle(fontSize: R.fs(context, 14))),
                    ),
                  ),
                  SizedBox(width: R.gap(context)),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed:
                          isGenerating ? null : ctrl.confirmAndGenerate,
                      icon: isGenerating
                          ? SizedBox(
                              width: R.icon(context, 20),
                              height: R.icon(context, 20),
                              child: const CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2))
                          : Icon(Icons.verified,
                              size: R.icon(context, 20)),
                      label: Text(
                        isGenerating ? 'Génération...' : 'Générer la FNE',
                        style: TextStyle(fontSize: R.fs(context, 14)),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade600,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                            vertical: isTablet ? 16 : 14),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          )),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;
  const _InfoRow(this.label, this.value, {this.bold = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  color: AppTheme.textGrey, fontSize: R.fs(context, 13.5))),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                color: AppTheme.textDark,
                fontSize: R.fs(context, 13.5),
                fontWeight: bold ? FontWeight.bold : FontWeight.w500,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
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
              label: Text('Réessayer',
                  style: TextStyle(fontSize: R.fs(context, 15))),
            ),
          ],
        ),
      ),
    );
  }
}
