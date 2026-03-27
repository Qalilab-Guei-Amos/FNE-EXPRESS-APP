import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pdfx/pdfx.dart';
import '../../../controllers/acquisition_controller.dart';
import '../../../controllers/validation_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/responsive.dart';
import '../../validation/validation_screen.dart';

class PreviewView extends StatelessWidget {
  final AcquisitionController ctrl;
  const PreviewView({super.key, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final file = ctrl.selectedFile.value!;
    final isPdf = ctrl.selectedMimeType.value == 'application/pdf';
    final isTablet = R.isTablet(context);

    return Column(
      children: [
        Expanded(
          child: isPdf
              ? PdfPreview(path: file.path)
              : InteractiveViewer(
                  child: Image.file(file, fit: BoxFit.contain)),
        ),
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
                          Get.delete<ValidationController>(force: true);
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

class PdfPreview extends StatefulWidget {
  final String path;
  const PdfPreview({super.key, required this.path});

  @override
  State<PdfPreview> createState() => _PdfPreviewState();
}

class _PdfPreviewState extends State<PdfPreview> {
  PdfControllerPinch? _controller;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initController();
  }

  void _initController() {
    try {
      _controller = PdfControllerPinch(
        document: PdfDocument.openFile(widget.path),
      );
    } catch (_) {
      if (mounted) setState(() => _hasError = true);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError || _controller == null) {
      return _PdfFallback(path: widget.path);
    }
    return PdfViewPinch(
      controller: _controller!,
      builders: PdfViewPinchBuilders<DefaultBuilderOptions>(
        options: const DefaultBuilderOptions(),
        documentLoaderBuilder: (_) =>
            const Center(child: CircularProgressIndicator(color: AppTheme.primary)),
        pageLoaderBuilder: (_) =>
            const Center(child: CircularProgressIndicator(color: AppTheme.primary)),
        errorBuilder: (_, _) => _PdfFallback(path: widget.path),
      ),
    );
  }
}

class _PdfFallback extends StatelessWidget {
  final String path;
  const _PdfFallback({required this.path});

  @override
  Widget build(BuildContext context) {
    final filename = path.split('/').last;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.picture_as_pdf, size: 72, color: Color(0xFFB23535)),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              filename,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Color(0xFF64748B)),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Aperçu non disponible',
            style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
          ),
        ],
      ),
    );
  }
}
