import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';
import 'package:get/get.dart';
import '../../controllers/acquisition_controller.dart';
import '../../controllers/validation_controller.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive.dart';
import '../validation/validation_screen.dart';

class AcquisitionScreen extends StatelessWidget {
  const AcquisitionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(AcquisitionController());

    return Scaffold(
      appBar: AppBar(
        title: Text('Importer une Facture',
            style: TextStyle(fontSize: R.fs(context, 18))),
      ),
      body: Obx(() {
        if (ctrl.isLoading.value) {
          return const Center(
              child: CircularProgressIndicator(color: AppTheme.primary));
        }
        if (ctrl.hasFile) return _PreviewView(ctrl: ctrl);
        return _ImportView(ctrl: ctrl);
      }),
    );
  }
}

// ── Vue import ────────────────────────────────────────────────────────────────
class _ImportView extends StatelessWidget {
  final AcquisitionController ctrl;
  const _ImportView({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final isTablet = R.isTablet(context);

    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(
          horizontal: R.hPad(context),
          vertical: R.vPad(context),
        ),
        child: R.centered(context,
            child: Column(
              children: [
                SizedBox(height: isTablet ? 40 : 24),

                // Icône hero
                Container(
                  width: R.icon(context, 110),
                  height: R.icon(context, 110),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.upload_file,
                      size: R.icon(context, 54), color: AppTheme.primary),
                ),
                SizedBox(height: isTablet ? 28 : 20),

                Text(
                  'Importer votre facture',
                  style: TextStyle(
                    fontSize: R.fs(context, 22),
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: isTablet ? 12 : 8),
                Text(
                  'Choisissez une méthode pour importer\nvotre document de vente',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: R.fs(context, 15),
                    color: AppTheme.textGrey.withValues(alpha: 0.8),
                    height: 1.5,
                  ),
                ),
                SizedBox(height: isTablet ? 48 : 40),

                // Sur tablette : 2 colonnes
                if (isTablet) ...[
                  Row(
                    children: [
                      Expanded(
                        child: _OptionButton(
                          icon: Icons.camera_alt,
                          label: 'Prendre une photo',
                          subtitle: 'Photographier la facture papier',
                          color: AppTheme.primary,
                          onTap: ctrl.pickFromCamera,
                        ),
                      ),
                      SizedBox(width: R.gap(context)),
                      Expanded(
                        child: _OptionButton(
                          icon: Icons.photo_library,
                          label: 'Depuis la galerie',
                          subtitle: 'Sélectionner une image existante',
                          color: const Color(0xFF2E7D9E),
                          onTap: ctrl.pickFromGallery,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: R.gap(context)),
                  _OptionButton(
                    icon: Icons.picture_as_pdf,
                    label: 'Importer un PDF',
                    subtitle: 'Fichier PDF ou image depuis l\'appareil',
                    color: const Color(0xFFB23535),
                    onTap: ctrl.pickDocument,
                  ),
                ] else ...[
                  _OptionButton(
                    icon: Icons.camera_alt,
                    label: 'Prendre une photo',
                    subtitle: 'Photographier la facture papier',
                    color: AppTheme.primary,
                    onTap: ctrl.pickFromCamera,
                  ),
                  SizedBox(height: R.gap(context)),
                  _OptionButton(
                    icon: Icons.photo_library,
                    label: 'Depuis la galerie',
                    subtitle: 'Sélectionner une image existante',
                    color: const Color(0xFF2E7D9E),
                    onTap: ctrl.pickFromGallery,
                  ),
                  SizedBox(height: R.gap(context)),
                  _OptionButton(
                    icon: Icons.picture_as_pdf,
                    label: 'Importer un PDF',
                    subtitle: 'Fichier PDF ou image depuis l\'appareil',
                    color: const Color(0xFFB23535),
                    onTap: ctrl.pickDocument,
                  ),
                ],
                SizedBox(height: isTablet ? 48 : 32),
              ],
            )),
      ),
    );
  }
}

// ── Bouton d'option ───────────────────────────────────────────────────────────
class _OptionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _OptionButton({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isTablet = R.isTablet(context);
    final iconBoxSize = R.icon(context, 52);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(R.radius(context)),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: isTablet ? 24 : 18,
          vertical: isTablet ? 20 : 16,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(R.radius(context)),
          border: Border.all(color: color.withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              width: iconBoxSize,
              height: iconBoxSize,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(isTablet ? 14 : 12),
              ),
              child: Icon(icon, color: color, size: R.icon(context, 26)),
            ),
            SizedBox(width: isTablet ? 20 : 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: R.fs(context, 15.5),
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: R.fs(context, 12.5),
                      color: AppTheme.textGrey,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right,
                color: color.withValues(alpha: 0.5),
                size: R.icon(context, 22)),
          ],
        ),
      ),
    );
  }
}

// ── Prévisualisation PDF ──────────────────────────────────────────────────────
class _PdfPreview extends StatefulWidget {
  final String path;
  const _PdfPreview({required this.path});

  @override
  State<_PdfPreview> createState() => _PdfPreviewState();
}

class _PdfPreviewState extends State<_PdfPreview> {
  late final PdfControllerPinch _controller;

  @override
  void initState() {
    super.initState();
    _controller = PdfControllerPinch(
      document: PdfDocument.openFile(widget.path),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PdfViewPinch(
      controller: _controller,
      builders: PdfViewPinchBuilders<DefaultBuilderOptions>(
        options: const DefaultBuilderOptions(),
        documentLoaderBuilder: (_) =>
            const Center(child: CircularProgressIndicator(color: AppTheme.primary)),
        pageLoaderBuilder: (_) =>
            const Center(child: CircularProgressIndicator(color: AppTheme.primary)),
      ),
    );
  }
}

// ── Vue prévisualisation ──────────────────────────────────────────────────────
class _PreviewView extends StatelessWidget {
  final AcquisitionController ctrl;
  const _PreviewView({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final file = ctrl.selectedFile.value!;
    final isPdf = ctrl.selectedMimeType.value == 'application/pdf';
    final isTablet = R.isTablet(context);

    return Column(
      children: [
        Expanded(
          child: isPdf
              ? _PdfPreview(path: file.path)
              : InteractiveViewer(
                  child: Image.file(file, fit: BoxFit.contain)),
        ),

        // Barre d'actions
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: R.hPad(context),
            vertical: isTablet ? 20 : 16,
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
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: ctrl.clearFile,
                        icon: Icon(Icons.refresh, size: R.icon(context, 20)),
                        label: Text('Changer',
                            style: TextStyle(fontSize: R.fs(context, 15))),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.primary,
                          side: const BorderSide(color: AppTheme.primary),
                          padding: EdgeInsets.symmetric(
                              vertical: isTablet ? 16 : 14),
                        ),
                      ),
                    ),
                    SizedBox(width: R.gap(context)),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          final validCtrl = Get.put(ValidationController());
                          Get.to(() => const ValidationScreen());
                          Future.microtask(() => validCtrl.extractFromFile(
                                ctrl.selectedFile.value!,
                                ctrl.selectedMimeType.value,
                              ));
                        },
                        icon: Icon(Icons.auto_awesome,
                            size: R.icon(context, 20)),
                        label: Text('Extraire les données',
                            style: TextStyle(fontSize: R.fs(context, 15))),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.accent,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                              vertical: isTablet ? 16 : 14),
                        ),
                      ),
                    ),
                  ],
                )),
          ),
        ),
      ],
    );
  }
}
