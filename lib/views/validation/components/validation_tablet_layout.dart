import 'dart:io' show File;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pdfx/pdfx.dart';
import '../../../controllers/acquisition_controller.dart';
import '../../../controllers/validation_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/responsive.dart';
import 'review_form.dart';

class ValidationTabletLayout extends StatelessWidget {
  final ValidationController ctrl;
  final AcquisitionController? acqCtrl;
  const ValidationTabletLayout(
      {super.key, required this.ctrl, required this.acqCtrl});

  @override
  Widget build(BuildContext context) {
    final formWidth = R.isLargeTablet(context) ? 600.0 : 500.0;

    return Row(
      children: [
        // ── Panneau prévisualisation (réactif) ──────────────────
        Expanded(
          child: Obx(() {
            final file = acqCtrl?.selectedFile.value;
            final isPdf =
                acqCtrl?.selectedMimeType.value == 'application/pdf';

            if (file == null) {
              return _NoDocumentPlaceholder();
            }

            if (isPdf) {
              return _PdfPanel(path: file.path);
            }

            return _ImagePanel(path: file.path);
          }),
        ),

        // ── Formulaire ──────────────────────────────────────────
        SizedBox(
          width: formWidth,
          child: ReviewForm(ctrl: ctrl),
        ),
      ],
    );
  }
}

// ── Aucun document ─────────────────────────────────────────────────────────────
class _NoDocumentPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF1A1A1A),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.insert_drive_file_outlined,
                size: R.icon(context, 72), color: Colors.white24),
            const SizedBox(height: 14),
            Text(
              'Aucun document',
              style: TextStyle(
                  color: Colors.white38, fontSize: R.fs(context, 14)),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Prévisualisation image ─────────────────────────────────────────────────────
class _ImagePanel extends StatelessWidget {
  final String path;
  const _ImagePanel({required this.path});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: InteractiveViewer(
        minScale: 0.5,
        maxScale: 4.0,
        child: Center(
          child: Image.file(File(path), fit: BoxFit.contain),
        ),
      ),
    );
  }
}

// ── Prévisualisation PDF ───────────────────────────────────────────────────────
class _PdfPanel extends StatefulWidget {
  final String path;
  const _PdfPanel({required this.path});

  @override
  State<_PdfPanel> createState() => _PdfPanelState();
}

class _PdfPanelState extends State<_PdfPanel> {
  late final PdfControllerPinch _pdfCtrl;

  @override
  void initState() {
    super.initState();
    _pdfCtrl = PdfControllerPinch(
      document: PdfDocument.openFile(widget.path),
    );
  }

  @override
  void dispose() {
    _pdfCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF2A2A2A),
      child: PdfViewPinch(
        controller: _pdfCtrl,
        builders: PdfViewPinchBuilders<DefaultBuilderOptions>(
          options: const DefaultBuilderOptions(),
          documentLoaderBuilder: (_) => const Center(
            child: CircularProgressIndicator(color: AppTheme.primary),
          ),
          pageLoaderBuilder: (_) => const Center(
            child: CircularProgressIndicator(color: AppTheme.primary),
          ),
        ),
      ),
    );
  }
}
