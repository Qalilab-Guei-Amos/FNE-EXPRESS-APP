import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pdfx/pdfx.dart';
import '../fne_result/fne_web_view_screen.dart';
import '../../controllers/acquisition_controller.dart';
import '../../controllers/validation_controller.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive.dart';
import 'components/extraction_loader.dart';
import 'components/validation_tablet_layout.dart';
import 'components/review_form.dart';
import 'components/error_view.dart';

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
          if (!R.isTablet(context))
            Obx(() {
              final state = ctrl.state.value;
              final canShow = state == ValidationState.reviewing ||
                  state == ValidationState.submitting;
              if (!canShow) return const SizedBox.shrink();

              // Cas 1 : scan frais — fichier en mémoire via AcquisitionController
              final aq = acqCtrl;
              if (aq != null && aq.selectedFile.value != null) {
                return IconButton(
                  icon: Icon(Icons.visibility_outlined,
                      size: R.icon(context, 22)),
                  tooltip: 'Voir la facture',
                  onPressed: () => Get.to(() => _InvoicePreviewScreen(
                        file: aq.selectedFile.value!,
                        mimeType: aq.selectedMimeType.value,
                      )),
                );
              }

              // Cas 2 : retry brouillon/échec — fichier sur disque via sourcePath
              final path = ctrl.sourceFilePath.value;
              if (path.isNotEmpty && File(path).existsSync()) {
                final mimeType = path.toLowerCase().endsWith('.pdf')
                    ? 'application/pdf'
                    : 'image/jpeg';
                return IconButton(
                  icon: Icon(Icons.visibility_outlined,
                      size: R.icon(context, 22)),
                  tooltip: 'Voir la facture importée',
                  onPressed: () => Get.to(() => _InvoicePreviewScreen(
                        file: File(path),
                        mimeType: mimeType,
                      )),
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
            return const ExtractionLoader();
          case ValidationState.reviewing:
          case ValidationState.submitting:
            if (R.isTablet(context)) {
              return ValidationTabletLayout(ctrl: ctrl, acqCtrl: acqCtrl);
            }
            return ReviewForm(ctrl: ctrl);
          case ValidationState.success:
            WidgetsBinding.instance.addPostFrameCallback((_) {
              final record = ctrl.generatedFne.value;
              // Vider la pile jusqu'à la HomeScreen (supprime AcquisitionScreen + ValidationScreen)
              Get.until((route) => route.isFirst);
              if (record != null && record.qrCode != null) {
                Get.to(() => FneWebViewScreen(
                      url: record.qrCode!,
                      recordId: record.id,
                    ));
              }
            });
            return const Center(
                child: CircularProgressIndicator(color: AppTheme.primary));
          case ValidationState.error:
            return ErrorView(ctrl: ctrl);
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

// ── Écran de prévisualisation de la facture importée ─────────────────────────

class _InvoicePreviewScreen extends StatefulWidget {
  final File file;
  final String mimeType;
  const _InvoicePreviewScreen({required this.file, required this.mimeType});

  @override
  State<_InvoicePreviewScreen> createState() => _InvoicePreviewScreenState();
}

class _InvoicePreviewScreenState extends State<_InvoicePreviewScreen> {
  PdfControllerPinch? _pdfCtrl;
  bool _pdfError = false;

  @override
  void initState() {
    super.initState();
    if (widget.mimeType == 'application/pdf') {
      try {
        _pdfCtrl = PdfControllerPinch(
          document: PdfDocument.openFile(widget.file.path),
        );
      } catch (_) {
        _pdfError = true;
      }
    }
  }

  @override
  void dispose() {
    _pdfCtrl?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2A2A2A),
      appBar: AppBar(
        title: const Text('Aperçu de la facture'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (widget.mimeType == 'application/pdf') {
      if (_pdfError || _pdfCtrl == null) {
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.picture_as_pdf, size: 72, color: Color(0xFFB23535)),
              SizedBox(height: 16),
              Text('Aperçu non disponible',
                  style: TextStyle(color: Colors.white54, fontSize: 15)),
            ],
          ),
        );
      }
      return PdfViewPinch(
        controller: _pdfCtrl!,
        builders: PdfViewPinchBuilders<DefaultBuilderOptions>(
          options: const DefaultBuilderOptions(),
          documentLoaderBuilder: (_) => const Center(
            child: CircularProgressIndicator(color: AppTheme.primary),
          ),
          pageLoaderBuilder: (_) => const Center(
            child: CircularProgressIndicator(color: AppTheme.primary),
          ),
          errorBuilder: (_, _) => const Center(
            child: Icon(Icons.picture_as_pdf,
                size: 72, color: Color(0xFFB23535)),
          ),
        ),
      );
    }
    // Image (JPEG / PNG)
    return InteractiveViewer(
      minScale: 0.5,
      maxScale: 4.0,
      child: Center(
        child: Image.file(widget.file, fit: BoxFit.contain),
      ),
    );
  }
}
